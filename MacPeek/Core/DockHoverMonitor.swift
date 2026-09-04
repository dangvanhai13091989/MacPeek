import Foundation
import Cocoa
import ApplicationServices

/// Monitors mouse movement and detects when the cursor hovers over a Dock icon.
/// Uses global mouse event monitoring + AXUIElement Accessibility API to identify Dock items.
final class DockHoverMonitor {

    // MARK: - Callbacks

    /// Called when the mouse hovers over a Dock item for the debounce duration.
    var onDockItemHovered: ((DockItemInfo) -> Void)?

    /// Called when the mouse leaves the Dock item area.
    var onDockItemUnhovered: (() -> Void)?

    /// Called when user clicks while preview is showing — provides the current dock item info.
    var onDockItemClicked: ((DockItemInfo) -> Void)?

    // MARK: - Private Properties

    private var globalMoveMonitor: Any?
    private var globalClickMonitor: Any?
    private let debouncer = Debouncer(delay: 0.3) // 300ms debounce
    private var lastHoveredAppName: String?
    private var isShowingPreview = false
    private var dockPID: pid_t = 0
    private var currentDockItem: DockItemInfo?

    /// Cached AXUIElement for the system-wide element (avoid repeated allocation)
    private let systemWideElement: AXUIElement = AXUIElementCreateSystemWide()

    // MARK: - Lifecycle

    init() {
        findDockPID()
    }

    deinit {
        stopMonitoring()
    }

    // MARK: - Public Methods

    func startMonitoring() {
        guard globalMoveMonitor == nil else { return }

        findDockPID()

        // Monitor global mouse moved events
        globalMoveMonitor = NSEvent.addGlobalMonitorForEvents(
            matching: [.mouseMoved]
        ) { [weak self] event in
            self?.handleMouseMoved(event)
        }

        // Monitor global mouse clicks — dismiss preview on click outside dock
        globalClickMonitor = NSEvent.addGlobalMonitorForEvents(
            matching: [.leftMouseDown, .rightMouseDown]
        ) { [weak self] event in
            self?.handleMouseClick(event)
        }

        NSLog("[MacPeek] DockHoverMonitor started (Dock PID: \(dockPID))")
    }

    func stopMonitoring() {
        if let monitor = globalMoveMonitor {
            NSEvent.removeMonitor(monitor)
            globalMoveMonitor = nil
        }
        if let monitor = globalClickMonitor {
            NSEvent.removeMonitor(monitor)
            globalClickMonitor = nil
        }
        debouncer.cancel()
        lastHoveredAppName = nil
        isShowingPreview = false
        currentDockItem = nil
        NSLog("[MacPeek] DockHoverMonitor stopped")
    }

    // MARK: - Private Methods

    private func findDockPID() {
        let dockApps = NSRunningApplication.runningApplications(
            withBundleIdentifier: "com.apple.dock"
        )
        if let dock = dockApps.first {
            dockPID = dock.processIdentifier
        }
    }

    /// Get the primary screen height for AX coordinate conversion.
    /// AX coordinates always use the PRIMARY screen's height (the screen with origin 0,0),
    /// NOT NSScreen.main (which is the screen with keyboard focus).
    private var primaryScreenHeight: CGFloat {
        NSScreen.screens.first?.frame.height ?? 900
    }

    private func handleMouseMoved(_ event: NSEvent) {
        // Get mouse position in screen coordinates (bottom-left origin, NSEvent)
        let mouseLocation = NSEvent.mouseLocation

        // Convert to top-left origin for Accessibility API
        // CRITICAL: Use PRIMARY screen height, not NSScreen.main!
        // AX coordinate system origin is top-left of the primary display.
        let axX = Float(mouseLocation.x)
        let axY = Float(primaryScreenHeight - mouseLocation.y)

        // Query the accessibility element at the mouse position
        var element: AXUIElement?
        let error = AXUIElementCopyElementAtPosition(systemWideElement, axX, axY, &element)

        guard error == .success, let foundElement = element else {
            handleMouseLeftDock()
            return
        }

        // Check if this element belongs to the Dock
        var pid: pid_t = 0
        AXUIElementGetPid(foundElement, &pid)

        guard pid == dockPID else {
            handleMouseLeftDock()
            return
        }

        // Get the role of the element (we want AXDockItem)
        guard let role = getAXAttribute(foundElement, attribute: kAXRoleAttribute) as? String else {
            handleMouseLeftDock()
            return
        }

        // Dock items have role "AXDockItem" or subrole indicating an app
        guard isDockAppItem(element: foundElement, role: role) else {
            handleMouseLeftDock()
            return
        }

        // Get the title (app name) of the dock item
        guard let title = getAXAttribute(foundElement, attribute: kAXTitleAttribute) as? String,
              !title.isEmpty else {
            handleMouseLeftDock()
            return
        }

        // Get the position and size of the dock icon for popup positioning
        let iconFrame = getElementFrame(foundElement)

        // Check if we're hovering over a new app
        if title != lastHoveredAppName {
            lastHoveredAppName = title
            isShowingPreview = false

            // Debounce: wait 300ms before triggering the hover callback
            debouncer.debounce { [weak self] in
                guard let self = self else { return }

                // Find the running app matching this dock item
                let runningApps = NSWorkspace.shared.runningApplications
                let matchingApp = runningApps.first { app in
                    app.localizedName == title ||
                    app.bundleIdentifier?.components(separatedBy: ".").last?.lowercased() == title.lowercased()
                }

                let dockItem = DockItemInfo(
                    appName: title,
                    bundleIdentifier: matchingApp?.bundleIdentifier,
                    pid: matchingApp?.processIdentifier ?? 0,
                    iconPosition: CGPoint(
                        x: CGFloat(axX),
                        y: mouseLocation.y
                    ),
                    iconFrame: iconFrame
                )

                DispatchQueue.main.async {
                    self.isShowingPreview = true
                    self.currentDockItem = dockItem
                    self.onDockItemHovered?(dockItem)
                }
            }
        }
    }

    private func handleMouseClick(_ event: NSEvent) {
        // If preview is showing, clicking anywhere should dismiss it
        guard isShowingPreview else { return }

        // Check if the click is on the Dock (user clicking to open the app normally)
        let mouseLocation = NSEvent.mouseLocation

        // Use primary screen height for AX coordinate conversion
        let axX = Float(mouseLocation.x)
        let axY = Float(primaryScreenHeight - mouseLocation.y)

        var element: AXUIElement?
        let error = AXUIElementCopyElementAtPosition(systemWideElement, axX, axY, &element)

        if error == .success, let foundElement = element {
            var pid: pid_t = 0
            AXUIElementGetPid(foundElement, &pid)

            // If clicking on a Dock item, dismiss and let macOS handle it
            if pid == dockPID {
                dismissPreview()
                return
            }
        }

        // Click anywhere else → dismiss preview
        dismissPreview()
    }

    private func dismissPreview() {
        debouncer.cancel()
        lastHoveredAppName = nil
        isShowingPreview = false
        currentDockItem = nil
        DispatchQueue.main.async { [weak self] in
            self?.onDockItemUnhovered?()
        }
    }

    private func handleMouseLeftDock() {
        guard lastHoveredAppName != nil || isShowingPreview else { return }

        debouncer.cancel()
        lastHoveredAppName = nil

        if isShowingPreview {
            isShowingPreview = false
            currentDockItem = nil
            DispatchQueue.main.async { [weak self] in
                self?.onDockItemUnhovered?()
            }
        }
    }

    /// Check if the dock element is an application item (not a separator, trash, etc.)
    private func isDockAppItem(element: AXUIElement, role: String) -> Bool {
        // The Dock's accessibility tree typically has:
        // - AXDockItem for regular items
        // - AXGroup for item groups
        // Check the subrole to distinguish apps from other dock items
        let subrole = getAXAttribute(element, attribute: kAXSubroleAttribute) as? String

        // Accept dock items and button subroles (application icons)
        if role == "AXDockItem" {
            return true
        }

        // Some versions expose dock items as buttons
        if role == "AXButton" && subrole == "AXDockItem" {
            return true
        }

        return false
    }

    /// Get an accessibility attribute value from an element.
    private func getAXAttribute(_ element: AXUIElement, attribute: String) -> CFTypeRef? {
        var value: CFTypeRef?
        let error = AXUIElementCopyAttributeValue(
            element,
            attribute as CFString,
            &value
        )
        return error == .success ? value : nil
    }

    /// Get the frame (position + size) of an accessibility element.
    private func getElementFrame(_ element: AXUIElement) -> CGRect {
        var position = CGPoint.zero
        var size = CGSize.zero

        // Get position
        if let posValue = getAXAttribute(element, attribute: kAXPositionAttribute) {
            var point = CGPoint.zero
            if AXValueGetValue(posValue as! AXValue, .cgPoint, &point) {
                position = point
            }
        }

        // Get size
        if let sizeValue = getAXAttribute(element, attribute: kAXSizeAttribute) {
            var s = CGSize.zero
            if AXValueGetValue(sizeValue as! AXValue, .cgSize, &s) {
                size = s
            }
        }

        return CGRect(origin: position, size: size)
    }
}
