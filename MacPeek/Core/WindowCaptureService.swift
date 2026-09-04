import Foundation
import Cocoa
import ScreenCaptureKit

/// Service responsible for capturing window thumbnails.
/// Uses ScreenCaptureKit (preferred on macOS 14+) with CGWindowList fallback.
final class WindowCaptureService {

    static let shared = WindowCaptureService()

    // MARK: - Configuration

    /// Maximum thumbnail width in pixels (single window mode)
    private let thumbnailMaxWidth: CGFloat = 360
    /// Maximum thumbnail height in pixels (single window mode)
    private let thumbnailMaxHeight: CGFloat = 240

    /// Maximum thumbnail width in pixels (multi-window mode)
    private let multiThumbMaxWidth: CGFloat = 180
    /// Maximum thumbnail height in pixels (multi-window mode)
    private let multiThumbMaxHeight: CGFloat = 120

    /// Minimum interval between captures for the same window (seconds)
    private let captureThrottleInterval: TimeInterval = 0.8

    /// Maximum number of windows to capture (performance guard)
    private let maxWindowCaptures: Int = 12

    /// Cache expiry time (seconds) — prevents memory leak from stale entries
    private let cacheExpiryInterval: TimeInterval = 20.0

    // MARK: - Cache

    private var lastCaptureTime: [CGWindowID: Date] = [:]
    private var cachedThumbnails: [CGWindowID: WindowThumbnail] = [:]
    private var lastCacheCleanup: Date = Date()

    /// Cached window list to avoid querying CGWindowList multiple times per hover
    private var cachedWindowList: [[String: Any]]?
    private var windowListCacheTime: Date = .distantPast

    private init() {}

    // MARK: - Public Methods

    /// Capture a single (largest) window thumbnail for the given dock item.
    /// Returns nil if no matching window is found.
    func captureWindow(for dockItem: DockItemInfo) async -> WindowThumbnail? {
        // Find windows belonging to the target app
        guard let windowInfo = findBestWindow(for: dockItem) else {
            return nil
        }

        return await captureSingleWindow(
            windowID: windowInfo.windowID,
            title: windowInfo.title,
            appName: dockItem.appName,
            maxWidth: thumbnailMaxWidth,
            maxHeight: thumbnailMaxHeight
        )
    }

    /// Capture ALL window thumbnails for a dock item.
    /// Returns an array of thumbnails, one per visible window.
    /// If only one window exists, returns a single-element array with larger thumbnail.
    func captureAllWindows(for dockItem: DockItemInfo) async -> [WindowThumbnail] {
        // Clean stale cache entries periodically
        cleanStaleCacheIfNeeded()

        let allWindows = findAllWindows(for: dockItem)

        guard !allWindows.isEmpty else { return [] }

        // Limit windows to capture (performance guard)
        let windowsToCapture = Array(allWindows.prefix(maxWindowCaptures))

        // If only 1 window, use larger thumbnail size
        let isMulti = windowsToCapture.count > 1
        let maxW = isMulti ? multiThumbMaxWidth : thumbnailMaxWidth
        let maxH = isMulti ? multiThumbMaxHeight : thumbnailMaxHeight

        // Capture in parallel using TaskGroup for performance
        return await withTaskGroup(of: (Int, WindowThumbnail?).self) { group in
            for (index, window) in windowsToCapture.enumerated() {
                group.addTask { [self] in
                    let thumb = await self.captureSingleWindow(
                        windowID: window.windowID,
                        title: window.title,
                        appName: dockItem.appName,
                        maxWidth: maxW,
                        maxHeight: maxH
                    )
                    return (index, thumb)
                }
            }

            // Collect results maintaining order
            var results: [(Int, WindowThumbnail)] = []
            results.reserveCapacity(windowsToCapture.count)

            for await (index, thumb) in group {
                if let t = thumb {
                    results.append((index, t))
                }
            }

            // Sort by original order
            results.sort { $0.0 < $1.0 }
            return results.map { $0.1 }
        }
    }

    /// Clear all cached thumbnails.
    func clearCache() {
        cachedThumbnails.removeAll()
        lastCaptureTime.removeAll()
        cachedWindowList = nil
    }

    /// Remove stale cache entries to prevent memory growth
    private func cleanStaleCacheIfNeeded() {
        let now = Date()
        guard now.timeIntervalSince(lastCacheCleanup) > cacheExpiryInterval else { return }

        let expiredIDs = lastCaptureTime.filter {
            now.timeIntervalSince($0.value) > cacheExpiryInterval
        }.map { $0.key }

        for id in expiredIDs {
            cachedThumbnails.removeValue(forKey: id)
            lastCaptureTime.removeValue(forKey: id)
        }
        lastCacheCleanup = now

        if !expiredIDs.isEmpty {
            NSLog("[MacPeek] Cleaned \(expiredIDs.count) stale cache entries")
        }
    }

    // MARK: - Single Window Capture

    private func captureSingleWindow(
        windowID: CGWindowID,
        title: String,
        appName: String,
        maxWidth: CGFloat,
        maxHeight: CGFloat
    ) async -> WindowThumbnail? {
        // Check cache / throttle
        if let cached = cachedThumbnails[windowID],
           let lastCapture = lastCaptureTime[windowID],
           Date().timeIntervalSince(lastCapture) < captureThrottleInterval {
            return cached
        }

        // Try ScreenCaptureKit first, then fall back to CGWindowList
        let image: NSImage?
        if #available(macOS 14.0, *) {
            image = await captureWithScreenCaptureKit(
                windowID: windowID,
                maxWidth: maxWidth,
                maxHeight: maxHeight
            )
        } else {
            image = captureWithCGWindowList(
                windowID: windowID,
                maxWidth: maxWidth,
                maxHeight: maxHeight
            )
        }

        guard let capturedImage = image else { return nil }

        // Create thumbnail
        let thumbnail = WindowThumbnail(
            image: capturedImage,
            windowTitle: title,
            appName: appName,
            windowID: windowID,
            capturedAt: Date()
        )

        // Update cache
        cachedThumbnails[windowID] = thumbnail
        lastCaptureTime[windowID] = Date()

        return thumbnail
    }

    // MARK: - Window Finding

    /// Find the best (largest) window to capture for a given dock item.
    private func findBestWindow(for dockItem: DockItemInfo) -> (windowID: CGWindowID, title: String)? {
        let all = findAllWindows(for: dockItem)
        return all.first
    }

    /// Get the current window list, using cache if fresh enough (within 0.5s)
    private func getWindowList() -> [[String: Any]] {
        let now = Date()
        if let cached = cachedWindowList,
           now.timeIntervalSince(windowListCacheTime) < 0.5 {
            return cached
        }

        let list = CGWindowListCopyWindowInfo(
            [.optionOnScreenOnly, .excludeDesktopElements],
            kCGNullWindowID
        ) as? [[String: Any]] ?? []

        cachedWindowList = list
        windowListCacheTime = now
        return list
    }

    /// Find ALL windows belonging to a given dock item, sorted by area (largest first).
    func findAllWindows(for dockItem: DockItemInfo) -> [(windowID: CGWindowID, title: String)] {
        let windowList = getWindowList()

        // Filter windows belonging to the target app
        var matchingWindows: [(windowID: CGWindowID, title: String, layer: Int, area: CGFloat)] = []

        for window in windowList {
            guard let ownerPID = window[kCGWindowOwnerPID as String] as? pid_t,
                  let windowID = window[kCGWindowNumber as String] as? CGWindowID,
                  let layer = window[kCGWindowLayer as String] as? Int,
                  let bounds = window[kCGWindowBounds as String] as? [String: CGFloat] else {
                continue
            }

            // Match by PID
            let ownerName = window[kCGWindowOwnerName as String] as? String ?? ""
            let windowName = window[kCGWindowName as String] as? String ?? ""

            let isMatch: Bool
            if dockItem.pid > 0 {
                isMatch = ownerPID == dockItem.pid
            } else {
                isMatch = ownerName.lowercased() == dockItem.appName.lowercased()
            }

            guard isMatch else { continue }

            // Skip very small windows (tooltips, status items, etc.)
            let width = bounds["Width"] ?? 0
            let height = bounds["Height"] ?? 0
            let area = width * height
            guard area > 10000 else { continue } // At least ~100x100

            // Only include normal layer windows (layer 0 = standard windows)
            guard layer == 0 else { continue }

            matchingWindows.append((
                windowID: windowID,
                title: windowName.isEmpty ? ownerName : windowName,
                layer: layer,
                area: area
            ))
        }

        // Sort by area (largest first) to get the main window first
        matchingWindows.sort { $0.area > $1.area }

        return matchingWindows.map { ($0.windowID, $0.title) }
    }

    // MARK: - ScreenCaptureKit Capture

    @available(macOS 14.0, *)
    private func captureWithScreenCaptureKit(
        windowID: CGWindowID,
        maxWidth: CGFloat,
        maxHeight: CGFloat
    ) async -> NSImage? {
        do {
            let content = try await SCShareableContent.excludingDesktopWindows(
                false,
                onScreenWindowsOnly: true
            )

            // Find the SCWindow matching our windowID
            guard let scWindow = content.windows.first(where: {
                $0.windowID == windowID
            }) else {
                NSLog("[MacPeek] SCWindow not found for windowID \(windowID)")
                return captureWithCGWindowList(windowID: windowID, maxWidth: maxWidth, maxHeight: maxHeight)
            }

            // Create content filter for this specific window
            let filter = SCContentFilter(desktopIndependentWindow: scWindow)

            // Configure for thumbnail size
            let config = SCStreamConfiguration()

            // Calculate thumbnail dimensions maintaining aspect ratio
            let windowWidth = CGFloat(scWindow.frame.width)
            let windowHeight = CGFloat(scWindow.frame.height)
            let (thumbW, thumbH) = calculateThumbnailSize(
                sourceWidth: windowWidth,
                sourceHeight: windowHeight,
                maxWidth: maxWidth,
                maxHeight: maxHeight
            )

            config.width = Int(thumbW)
            config.height = Int(thumbH)
            config.showsCursor = false
            config.captureResolution = .nominal // Lower res for performance
            config.scalesToFit = true

            // Capture a single screenshot
            let cgImage = try await SCScreenshotManager.captureImage(
                contentFilter: filter,
                configuration: config
            )

            return NSImage(
                cgImage: cgImage,
                size: NSSize(width: thumbW, height: thumbH)
            )
        } catch {
            NSLog("[MacPeek] ScreenCaptureKit error: \(error.localizedDescription)")
            // Fallback to CGWindowList
            return captureWithCGWindowList(windowID: windowID, maxWidth: maxWidth, maxHeight: maxHeight)
        }
    }

    // MARK: - CGWindowList Capture (Fallback)

    private func captureWithCGWindowList(
        windowID: CGWindowID,
        maxWidth: CGFloat,
        maxHeight: CGFloat
    ) -> NSImage? {
        // Use autorelease pool to prevent memory buildup during rapid hover
        return autoreleasepool {
            guard let cgImage = CGWindowListCreateImage(
                .null,
                .optionIncludingWindow,
                windowID,
                [.boundsIgnoreFraming, .nominalResolution]
            ) else {
                NSLog("[MacPeek] CGWindowListCreateImage failed for windowID \(windowID)")
                return nil
            }

            let sourceWidth = CGFloat(cgImage.width)
            let sourceHeight = CGFloat(cgImage.height)
            let (thumbW, thumbH) = calculateThumbnailSize(
                sourceWidth: sourceWidth,
                sourceHeight: sourceHeight,
                maxWidth: maxWidth,
                maxHeight: maxHeight
            )

            let resizedImage = NSImage(size: NSSize(width: thumbW, height: thumbH))
            resizedImage.lockFocus()
            let context = NSGraphicsContext.current!
            context.imageInterpolation = .high
            NSImage(cgImage: cgImage, size: NSSize(width: sourceWidth, height: sourceHeight))
                .draw(
                    in: NSRect(x: 0, y: 0, width: thumbW, height: thumbH),
                    from: .zero,
                    operation: .copy,
                    fraction: 1.0
                )
            resizedImage.unlockFocus()

            return resizedImage
        }
    }

    // MARK: - Utilities

    /// Calculate thumbnail dimensions maintaining aspect ratio.
    private func calculateThumbnailSize(
        sourceWidth: CGFloat,
        sourceHeight: CGFloat,
        maxWidth: CGFloat,
        maxHeight: CGFloat
    ) -> (width: CGFloat, height: CGFloat) {
        guard sourceWidth > 0, sourceHeight > 0 else {
            return (maxWidth, maxHeight)
        }

        let aspectRatio = sourceWidth / sourceHeight
        var width = maxWidth
        var height = width / aspectRatio

        if height > maxHeight {
            height = maxHeight
            width = height * aspectRatio
        }

        return (width: max(width, 80), height: max(height, 50))
    }
}
