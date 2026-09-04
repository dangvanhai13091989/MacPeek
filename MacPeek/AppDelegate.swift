import Cocoa
import SwiftUI
import Combine

/// Main application delegate that orchestrates all MacPeek services.
/// Initializes hover monitoring, permission checks, and manages the preview popup lifecycle.
class AppDelegate: NSObject, NSApplicationDelegate {

    private var dockHoverMonitor: DockHoverMonitor?
    private var popupController: PopupWindowController?
    private var onboardingWindow: NSWindow?
    private var cancellables = Set<AnyCancellable>()
    /// Tracks mouse leaving the popup area (movement + clicks)
    private var popupMouseMoveTracker: Any?
    private var popupClickTracker: Any?
    /// Delay timer for hiding popup — gives user time to move mouse to popup
    private var hideDelayTimer: Timer?

    func applicationDidFinishLaunching(_ notification: Notification) {
        UserDefaults.standard.register(defaults: [AppPreferences.enabledKey: true])
        UpdateManager.shared.start()

        // Initialize the popup controller
        popupController = PopupWindowController()

        // Initialize the dock hover monitor
        dockHoverMonitor = DockHoverMonitor()

        // Setup callbacks and observers
        setupPermissionObserver()
        setupEnabledObserver()

        // Setup global click-to-dismiss — always active while popup is visible
        setupGlobalClickDismiss()

        // Show onboarding if permissions are not granted
        if !PermissionManager.shared.allPermissionsGranted {
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                self.showOnboarding()
            }
        } else {
            startMonitoring()
        }
    }

    func applicationWillTerminate(_ notification: Notification) {
        stopMonitoring()
    }

    // MARK: - Private Methods

    private func setupPermissionObserver() {
        PermissionManager.shared.$allPermissionsGranted
            .removeDuplicates()
            .receive(on: DispatchQueue.main)
            .sink { [weak self] granted in
                if granted && AppPreferences.isEnabled {
                    self?.startMonitoring()
                } else {
                    self?.stopMonitoring()
                }
            }
            .store(in: &cancellables)

        // Observe hover events from DockHoverMonitor
        dockHoverMonitor?.onDockItemHovered = { [weak self] dockItem in
            self?.handleDockItemHovered(dockItem)
        }

        dockHoverMonitor?.onDockItemUnhovered = { [weak self] in
            self?.handleDockItemUnhovered()
        }

        // Observe click on preview — the popup controller handles activation internally,
        // but we also dismiss the hover monitor state here
        popupController?.onPreviewClicked = { [weak self] dockItem in
            NSLog("[MacPeek] Preview clicked callback for: \(dockItem.appName)")
            self?.dismissPopupCompletely()
            self?.dockHoverMonitor?.stopMonitoring()
            // Restart monitoring after a short delay to avoid immediate re-trigger
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                if PermissionManager.shared.allPermissionsGranted && AppPreferences.isEnabled {
                    self?.dockHoverMonitor?.startMonitoring()
                }
            }
        }

        // Observe window close request from preview
        popupController?.onWindowCloseRequested = { [weak self] thumbnail, dockItem in
            self?.handleWindowCloseRequest(thumbnail: thumbnail, dockItem: dockItem)
        }
    }

    private func setupEnabledObserver() {
        NotificationCenter.default.publisher(for: .macPeekEnabledChanged)
            .receive(on: DispatchQueue.main)
            .sink { [weak self] notification in
                let enabled = notification.object as? Bool ?? AppPreferences.isEnabled
                if enabled && PermissionManager.shared.allPermissionsGranted {
                    self?.startMonitoring()
                } else {
                    self?.stopMonitoring()
                }
            }
            .store(in: &cancellables)
    }

    /// Setup a persistent global click monitor that dismisses the popup when user clicks outside.
    /// This catches the case where user hovers dock → popup shows → user clicks on another app.
    private func setupGlobalClickDismiss() {
        // This monitors ALL clicks globally. We only act if popup is visible.
        popupClickTracker = NSEvent.addGlobalMonitorForEvents(
            matching: [.leftMouseDown, .rightMouseDown]
        ) { [weak self] event in
            guard let self = self,
                  let popup = self.popupController,
                  popup.isPopupVisible else { return }

            let mouseLocation = NSEvent.mouseLocation

            // If click is inside popup, ignore (popup handles its own clicks)
            if popup.isPointInsidePopup(mouseLocation) {
                return
            }

            // Click is OUTSIDE popup → dismiss it
            NSLog("[MacPeek] Click outside popup — dismissing")
            self.dismissPopupCompletely()
        }
    }

    private func startMonitoring() {
        guard PermissionManager.shared.allPermissionsGranted, AppPreferences.isEnabled else { return }
        dockHoverMonitor?.startMonitoring()
        NSLog("[MacPeek] Dock hover monitoring started")
    }

    private func stopMonitoring() {
        dockHoverMonitor?.stopMonitoring()
        dismissPopupCompletely()
        NSLog("[MacPeek] Dock hover monitoring stopped")
    }

    /// Fully dismiss the popup and clean up all tracking state
    private func dismissPopupCompletely() {
        hideDelayTimer?.invalidate()
        hideDelayTimer = nil
        popupController?.hidePopup()
        removePopupMouseTracker()
    }

    private func handleDockItemHovered(_ item: DockItemInfo) {
        guard AppPreferences.isEnabled else { return }

        // Cancel any pending hide — user moved back to dock
        hideDelayTimer?.invalidate()
        hideDelayTimer = nil
        removePopupMouseTracker()

        NSLog("[MacPeek] Hovered over: \(item.appName)")

        // Capture ALL window thumbnails for the hovered app
        Task { @MainActor in
            let thumbnails = await WindowCaptureService.shared.captureAllWindows(for: item)

            guard !thumbnails.isEmpty else {
                NSLog("[MacPeek] No windows found for \(item.appName)")
                return
            }

            NSLog("[MacPeek] Found \(thumbnails.count) window(s) for \(item.appName)")

            popupController?.showPopup(
                thumbnails: thumbnails,
                dockItem: item
            )
        }
    }

    /// Called when mouse leaves the dock area.
    /// Instead of immediately hiding, we give the user 400ms to reach the popup.
    private func handleDockItemUnhovered() {
        hideDelayTimer?.invalidate()
        hideDelayTimer = Timer.scheduledTimer(withTimeInterval: 0.4, repeats: false) { [weak self] _ in
            guard let self = self else { return }

            let mouseLocation = NSEvent.mouseLocation

            // Check if mouse moved into the popup
            if let popup = self.popupController, popup.isPointInsidePopup(mouseLocation) {
                // Mouse is inside popup — keep it visible and track when it leaves
                self.startPopupMouseTracking()
                return
            }

            // Mouse is not in popup — hide it
            self.popupController?.hidePopup()
        }
    }

    // MARK: - Popup Mouse Tracking

    /// Track mouse movement after it enters the popup, hide when it leaves
    private func startPopupMouseTracking() {
        removePopupMouseTracker()

        popupMouseMoveTracker = NSEvent.addGlobalMonitorForEvents(matching: [.mouseMoved]) { [weak self] event in
            guard let self = self else { return }

            let mouseLocation = NSEvent.mouseLocation

            // Check if mouse is still inside popup OR back on dock icon area
            if let popup = self.popupController, popup.isPointInsidePopup(mouseLocation) {
                // Still in popup — keep showing
                return
            }

            // Mouse left popup area — hide it
            self.popupController?.hidePopup()
            self.removePopupMouseTracker()
        }
    }

    private func removePopupMouseTracker() {
        if let tracker = popupMouseMoveTracker {
            NSEvent.removeMonitor(tracker)
            popupMouseMoveTracker = nil
        }
    }

    // MARK: - Window Close Request

    /// Handle request to close a specific window from the preview popup
    private func handleWindowCloseRequest(thumbnail: WindowThumbnail, dockItem: DockItemInfo) {
        NSLog("[MacPeek] Close window requested: \(thumbnail.windowTitle) (ID: \(thumbnail.windowID))")

        // Use Accessibility API to close the specific window
        closeSpecificWindow(windowID: thumbnail.windowID, dockItem: dockItem)

        // After closing, refresh the popup with remaining windows
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) { [weak self] in
            Task { @MainActor in
                let updatedThumbnails = await WindowCaptureService.shared.captureAllWindows(for: dockItem)

                if updatedThumbnails.isEmpty {
                    // No more windows — dismiss popup
                    self?.dismissPopupCompletely()
                } else {
                    // Refresh popup with updated windows
                    self?.popupController?.showPopup(
                        thumbnails: updatedThumbnails,
                        dockItem: dockItem
                    )
                }
            }
        }
    }

    /// Close a specific window using Accessibility API
    private func closeSpecificWindow(windowID: CGWindowID, dockItem: DockItemInfo) {
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
            NSLog("[MacPeek] Could not find app: \(dockItem.appName)")
            return
        }

        // Get window bounds from CGWindowList for matching
        guard let windowBounds = getWindowBounds(windowID: windowID) else {
            NSLog("[MacPeek] Could not get bounds for window \(windowID)")
            return
        }

        // Use Accessibility API to find and close the window
        let appElement = AXUIElementCreateApplication(app.processIdentifier)
        var windowsRef: CFTypeRef?
        let err = AXUIElementCopyAttributeValue(appElement, kAXWindowsAttribute as CFString, &windowsRef)

        guard err == .success, let axWindows = windowsRef as? [AXUIElement] else {
            NSLog("[MacPeek] Could not get AX windows for \(dockItem.appName)")
            return
        }

        for axWindow in axWindows {
            if let axFrame = getAXWindowFrame(axWindow),
               abs(axFrame.origin.x - windowBounds.origin.x) < 2,
               abs(axFrame.origin.y - windowBounds.origin.y) < 2 {
                // Found the matching window — close it via AX
                var closeButton: CFTypeRef?
                let closeErr = AXUIElementCopyAttributeValue(
                    axWindow,
                    kAXCloseButtonAttribute as CFString,
                    &closeButton
                )

                if closeErr == .success, let button = closeButton {
                    AXUIElementPerformAction(button as! AXUIElement, kAXPressAction as CFString)
                    NSLog("[MacPeek] ✅ Closed window: \(dockItem.appName) (ID: \(windowID))")
                } else {
                    NSLog("[MacPeek] ⚠️ Could not find close button for window \(windowID)")
                }
                break
            }
        }
    }

    /// Get window bounds from CGWindowList
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
            if AXValueGetValue(posValue, .cgPoint, &point) { position = point }
        }
        if let sizeValue = getAXValue(element, attribute: kAXSizeAttribute) {
            var s = CGSize.zero
            if AXValueGetValue(sizeValue, .cgSize, &s) { size = s }
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

    // MARK: - Onboarding

    private func showOnboarding() {
        // If onboarding window already exists, just show it
        if let existing = onboardingWindow, existing.isVisible {
            existing.makeKeyAndOrderFront(nil)
            NSApp.activate(ignoringOtherApps: true)
            return
        }

        // Create onboarding window programmatically
        let onboardingView = OnboardingView()
            .environmentObject(PermissionManager.shared)
            .frame(width: 520, height: 480)

        let hostingView = NSHostingView(rootView: onboardingView)
        hostingView.frame = NSRect(x: 0, y: 0, width: 520, height: 480)

        let window = NSWindow(
            contentRect: NSRect(x: 0, y: 0, width: 520, height: 480),
            styleMask: [.titled, .closable, .fullSizeContentView],
            backing: .buffered,
            defer: false
        )
        window.title = "MacPeek Setup"
        window.titlebarAppearsTransparent = true
        window.titleVisibility = .hidden
        window.contentView = hostingView
        window.center()
        window.isReleasedWhenClosed = false
        window.makeKeyAndOrderFront(nil)

        NSApp.activate(ignoringOtherApps: true)
        self.onboardingWindow = window
    }
}
