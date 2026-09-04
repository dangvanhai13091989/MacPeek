import Cocoa
import SwiftUI

/// Controls the floating NSPanel that displays the preview popup.
/// The panel is borderless, transparent, and floats above the Dock.
/// Supports both single-window and multi-window preview modes.
/// Clicking on a specific window preview activates that particular window.
final class PopupWindowController {

    private var popupPanel: NSPanel?
    private var hostingView: NSHostingView<PreviewPopupView>?
    private var localClickMonitor: Any?
    private var currentDockItem: DockItemInfo?
    private var currentThumbnails: [WindowThumbnail] = []

    /// Callback when user clicks on a preview thumbnail
    var onPreviewClicked: ((DockItemInfo) -> Void)?

    /// Callback when user requests closing a specific window
    var onWindowCloseRequested: ((WindowThumbnail, DockItemInfo) -> Void)?

    /// Whether the popup panel is currently visible
    var isPopupVisible: Bool {
        popupPanel?.isVisible ?? false
    }

    // MARK: - Panel Configuration

    /// Base popup size (will be adjusted based on number of windows)
    private let singlePopupWidth: CGFloat = 380
    private let singlePopupHeight: CGFloat = 280
    private let multiThumbWidth: CGFloat = 188 // 180 + 8 spacing
    private let multiPopupMaxWidth: CGFloat = 600

    init() {
        setupPanel()
    }

    deinit {
        if let monitor = localClickMonitor {
            NSEvent.removeMonitor(monitor)
        }
    }

    // MARK: - Public Methods

    /// Show the popup with thumbnails at the calculated position near the Dock icon.
    func showPopup(thumbnails: [WindowThumbnail], dockItem: DockItemInfo) {
        guard let panel = popupPanel, !thumbnails.isEmpty else { return }

        currentDockItem = dockItem
        currentThumbnails = thumbnails

        // Create or update the SwiftUI content
        let popupView = PreviewPopupView(
            thumbnails: thumbnails,
            onTapWindow: { [weak self] thumbnail in
                self?.handlePreviewClick(thumbnail: thumbnail)
            },
            onCloseWindow: { [weak self] thumbnail in
                guard let self = self, let dockItem = self.currentDockItem else { return }
                self.onWindowCloseRequested?(thumbnail, dockItem)
            }
        )
        let hostingView = NSHostingView(rootView: popupView)
        hostingView.frame = panel.contentView?.bounds ?? .zero
        hostingView.autoresizingMask = [.width, .height]

        // Remove old content and add new
        panel.contentView?.subviews.forEach { $0.removeFromSuperview() }
        panel.contentView?.addSubview(hostingView)
        self.hostingView = hostingView

        // Calculate popup size based on number of windows
        let popupSize = calculatePopupSize(windowCount: thumbnails.count)

        // Calculate popup position relative to the Dock icon
        let position = DockPositionHelper.calculatePopupPosition(
            iconFrame: dockItem.iconFrame,
            popupSize: popupSize
        )

        // Position and show the panel
        panel.setFrame(
            NSRect(origin: position, size: popupSize),
            display: true
        )

        if !panel.isVisible {
            panel.alphaValue = 0
            panel.orderFrontRegardless()
            NSAnimationContext.runAnimationGroup { context in
                context.duration = 0.2
                context.timingFunction = CAMediaTimingFunction(name: .easeOut)
                panel.animator().alphaValue = 1.0
            }
        }
    }

    /// Hide the popup with a fade-out animation.
    func hidePopup() {
        guard let panel = popupPanel, panel.isVisible else { return }

        NSAnimationContext.runAnimationGroup({ context in
            context.duration = 0.15
            context.timingFunction = CAMediaTimingFunction(name: .easeIn)
            panel.animator().alphaValue = 0.0
        }, completionHandler: { [weak self] in
            self?.popupPanel?.orderOut(nil)
            self?.currentDockItem = nil
            self?.currentThumbnails = []
        })
    }

    /// Check if a screen point is inside the popup panel
    func isPointInsidePopup(_ point: CGPoint) -> Bool {
        guard let panel = popupPanel, panel.isVisible else { return false }
        return panel.frame.contains(point)
    }

    // MARK: - Private Setup

    private func setupPanel() {
        let panel = NSPanel(
            contentRect: NSRect(x: 0, y: 0, width: singlePopupWidth, height: singlePopupHeight),
            styleMask: [.borderless, .nonactivatingPanel],
            backing: .buffered,
            defer: true
        )

        // Configure panel to float above everything without stealing focus
        panel.level = .floating
        panel.isOpaque = false
        panel.backgroundColor = .clear
        panel.hasShadow = false // We use SwiftUI shadows instead
        panel.isMovableByWindowBackground = false
        panel.hidesOnDeactivate = false
        panel.collectionBehavior = [.canJoinAllSpaces, .stationary, .fullScreenAuxiliary]
        // Allow mouse events so user can click on the preview
        panel.ignoresMouseEvents = false
        panel.isReleasedWhenClosed = false
        panel.animationBehavior = .none
        // Accept mouse events but don't become key window
        panel.becomesKeyOnlyIfNeeded = true

        // Create the content view
        let contentView = NSView(frame: panel.contentRect(forFrameRect: panel.frame))
        contentView.wantsLayer = true
        contentView.layer?.backgroundColor = .clear
        panel.contentView = contentView

        self.popupPanel = panel
    }

    /// Calculate dynamic popup size based on number of windows.
    /// Uses grid layout: up to 3 columns, 2 rows per page.
    private func calculatePopupSize(windowCount: Int) -> CGSize {
        if windowCount <= 1 {
            return CGSize(width: singlePopupWidth, height: singlePopupHeight)
        }

        let headerHeight: CGFloat = 36
        let thumbWidth: CGFloat = 180
        let thumbHeight: CGFloat = 145 // card height including title bar (reduced from 155)
        let spacing: CGFloat = 8
        let padding: CGFloat = 24
        let paginationHeight: CGFloat = windowCount > 6 ? 40 : 0 // dot indicators + overflow badge

        // Determine grid dimensions (max 6 per page: 3 cols x 2 rows)
        let visibleCount = min(windowCount, 6)
        let cols = visibleCount <= 2 ? visibleCount : min(3, visibleCount)
        let rows = visibleCount <= 3 ? 1 : 2

        let contentWidth = CGFloat(cols) * thumbWidth + CGFloat(cols - 1) * spacing + padding
        let contentHeight = headerHeight + CGFloat(rows) * thumbHeight + CGFloat(max(0, rows - 1)) * spacing + padding + paginationHeight

        return CGSize(width: contentWidth, height: contentHeight)
    }

    private func handlePreviewClick(thumbnail: WindowThumbnail) {
        guard let dockItem = currentDockItem else { return }

        NSLog("[MacPeek] Preview clicked for window: \(thumbnail.windowTitle) (ID: \(thumbnail.windowID))")

        // Activate the specific window by its windowID
        activateSpecificWindow(windowID: thumbnail.windowID, dockItem: dockItem)

        // Hide the popup
        hidePopup()

        // Notify delegate
        onPreviewClicked?(dockItem)
    }

    /// Activate a specific window by its CGWindowID.
    /// First brings the owning app to front, then uses Accessibility API to raise the specific window.
    private func activateSpecificWindow(windowID: CGWindowID, dockItem: DockItemInfo) {
        let runningApps = NSWorkspace.shared.runningApplications

        // Find the app
        var targetApp: NSRunningApplication?

        if dockItem.pid > 0 {
            targetApp = runningApps.first(where: { $0.processIdentifier == dockItem.pid })
        }
        if targetApp == nil, let bundleID = dockItem.bundleIdentifier {
            targetApp = runningApps.first(where: { $0.bundleIdentifier == bundleID })
        }
        if targetApp == nil {
            targetApp = runningApps.first(where: { $0.localizedName == dockItem.appName })
        }

        guard let app = targetApp else {
            NSLog("[MacPeek] Could not find running app: \(dockItem.appName)")
            return
        }

        // Use Accessibility API to raise the specific window
        let appElement = AXUIElementCreateApplication(app.processIdentifier)
        var windowsRef: CFTypeRef?
        let err = AXUIElementCopyAttributeValue(appElement, kAXWindowsAttribute as CFString, &windowsRef)

        if err == .success, let axWindows = windowsRef as? [AXUIElement] {
            // Find the AXWindow that matches our CGWindowID
            // We match by comparing window position/size since AX doesn't expose CGWindowID directly
            if let windowInfo = getWindowBounds(windowID: windowID) {
                for axWindow in axWindows {
                    if let axFrame = getAXWindowFrame(axWindow),
                       abs(axFrame.origin.x - windowInfo.origin.x) < 2,
                       abs(axFrame.origin.y - windowInfo.origin.y) < 2 {
                        // Found the matching window — raise it
                        AXUIElementPerformAction(axWindow, kAXRaiseAction as CFString)
                        NSLog("[MacPeek] Raised specific window: \(dockItem.appName) (ID: \(windowID))")
                        break
                    }
                }
            }
        }

        // Activate the app (bring to front)
        app.activate(options: [.activateIgnoringOtherApps])
        NSLog("[MacPeek] Activated app: \(dockItem.appName)")
    }

    /// Get window bounds from CGWindowList for a specific windowID
    private func getWindowBounds(windowID: CGWindowID) -> CGRect? {
        guard let windowList = CGWindowListCopyWindowInfo(
            [.optionIncludingWindow],
            windowID
        ) as? [[String: Any]],
              let window = windowList.first,
              let bounds = window[kCGWindowBounds as String] as? [String: CGFloat] else {
            return nil
        }

        return CGRect(
            x: bounds["X"] ?? 0,
            y: bounds["Y"] ?? 0,
            width: bounds["Width"] ?? 0,
            height: bounds["Height"] ?? 0
        )
    }

    /// Get the frame of an AXWindow element
    private func getAXWindowFrame(_ element: AXUIElement) -> CGRect? {
        var position = CGPoint.zero
        var size = CGSize.zero

        if let posValue = getAXValue(element, attribute: kAXPositionAttribute) {
            var point = CGPoint.zero
            if AXValueGetValue(posValue, .cgPoint, &point) {
                position = point
            }
        }

        if let sizeValue = getAXValue(element, attribute: kAXSizeAttribute) {
            var s = CGSize.zero
            if AXValueGetValue(sizeValue, .cgSize, &s) {
                size = s
            }
        }

        guard size.width > 0, size.height > 0 else { return nil }
        return CGRect(origin: position, size: size)
    }

    private func getAXValue(_ element: AXUIElement, attribute: String) -> AXValue? {
        var value: CFTypeRef?
        let err = AXUIElementCopyAttributeValue(element, attribute as CFString, &value)
        guard err == .success else { return nil }
        return value as! AXValue?
    }
}
