import Foundation
import Cocoa

/// Detects the current Dock position (bottom, left, right) and provides
/// utility methods for positioning the preview popup relative to Dock icons.
struct DockPositionHelper {

    enum DockPosition {
        case bottom
        case left
        case right
        case unknown
    }

    // MARK: - Dock Position Detection

    /// Detect the current Dock position by comparing screen frame vs visible frame.
    static func detectDockPosition() -> DockPosition {
        // Primary method: read from user defaults
        if let orientation = UserDefaults(suiteName: "com.apple.dock")?.string(forKey: "orientation") {
            switch orientation.lowercased() {
            case "left": return .left
            case "right": return .right
            case "bottom": return .bottom
            default: break
            }
        }

        // Fallback: compare frames using the screen that has the dock
        // Try all screens to find which one has the dock
        for screen in NSScreen.screens {
            let screenFrame = screen.frame
            let visibleFrame = screen.visibleFrame

            let leftDiff = visibleFrame.minX - screenFrame.minX
            let rightDiff = screenFrame.maxX - visibleFrame.maxX
            let bottomDiff = visibleFrame.minY - screenFrame.minY

            if leftDiff > 1 { return .left }
            if rightDiff > 1 { return .right }
            if bottomDiff > 1 { return .bottom }
        }

        return .bottom // Default assumption
    }

    /// Check if the Dock is set to auto-hide.
    static var isDockAutoHideEnabled: Bool {
        UserDefaults(suiteName: "com.apple.dock")?.bool(forKey: "autohide") ?? false
    }

    /// Get the estimated Dock height/width based on the frame difference.
    /// Uses the screen containing the dock icon point if provided, otherwise checks all screens.
    static func dockSize(on screen: NSScreen? = nil) -> CGFloat {
        let targetScreen = screen ?? screenWithDock() ?? NSScreen.screens.first
        guard let s = targetScreen else { return 70 }

        let screenFrame = s.frame
        let visibleFrame = s.visibleFrame
        let position = detectDockPosition()

        switch position {
        case .bottom:
            let diff = visibleFrame.minY - screenFrame.minY
            return diff > 1 ? diff : 70
        case .left:
            let diff = visibleFrame.minX - screenFrame.minX
            return diff > 1 ? diff : 70
        case .right:
            let diff = screenFrame.maxX - visibleFrame.maxX
            return diff > 1 ? diff : 70
        default:
            return 70 // fallback
        }
    }

    /// Find the screen that currently has the Dock.
    /// In multi-monitor setups, the Dock is on the screen with the largest
    /// difference between frame and visibleFrame (indicating dock presence).
    private static func screenWithDock() -> NSScreen? {
        var bestScreen: NSScreen?
        var bestDiff: CGFloat = 0

        for screen in NSScreen.screens {
            let screenFrame = screen.frame
            let visibleFrame = screen.visibleFrame

            let bottomDiff = visibleFrame.minY - screenFrame.minY
            let leftDiff = visibleFrame.minX - screenFrame.minX
            let rightDiff = screenFrame.maxX - visibleFrame.maxX

            let maxDiff = max(bottomDiff, max(leftDiff, rightDiff))
            if maxDiff > bestDiff {
                bestDiff = maxDiff
                bestScreen = screen
            }
        }

        return bestScreen
    }

    // MARK: - Screen Detection

    /// Find the screen that contains the given point (in global/AX coordinates).
    /// This is critical for multi-monitor setups where the Dock may be on a
    /// different screen than the one with keyboard focus (NSScreen.main).
    static func screenContaining(point: CGPoint) -> NSScreen? {
        // AX coordinates use top-left origin. NSScreen uses bottom-left.
        // Convert the AX point to NSScreen coordinates for each screen.
        let primaryHeight = NSScreen.screens.first?.frame.height ?? 900
        for screen in NSScreen.screens {
            let screenFrame = screen.frame
            // AX global coords: x same, y = primaryScreenHeight - nsY
            let nsPoint = CGPoint(x: point.x, y: primaryHeight - point.y)

            if screenFrame.contains(nsPoint) {
                return screen
            }
        }
        // Fallback: try with raw coordinates (some setups)
        for screen in NSScreen.screens {
            if screen.frame.contains(point) {
                return screen
            }
        }
        return NSScreen.main
    }

    // MARK: - Popup Positioning

    /// Calculate the optimal popup position relative to a Dock icon.
    /// The popup should appear above/beside the icon depending on Dock position.
    /// Uses the screen containing the dock icon, NOT NSScreen.main, to support multi-monitor.
    ///
    /// - Parameters:
    ///   - iconFrame: The accessibility frame of the dock icon (in AX top-left origin coordinates)
    ///   - popupSize: The size of the popup window
    /// - Returns: The origin point for the popup window (in NSWindow bottom-left coordinates)
    static func calculatePopupPosition(
        iconFrame: CGRect,
        popupSize: CGSize
    ) -> CGPoint {
        // Find the screen where the dock icon actually is
        let iconCenter = CGPoint(x: iconFrame.midX, y: iconFrame.midY)
        guard let screen = screenContaining(point: iconCenter) else {
            return CGPoint(x: iconFrame.midX - popupSize.width / 2, y: iconFrame.minY)
        }

        let position = detectDockPosition()
        let screenFrame = screen.frame
        let primaryHeight = NSScreen.screens.first?.frame.height ?? screenFrame.height
        let padding: CGFloat = 8 // Gap between popup and dock icon

        var popupX: CGFloat
        var popupY: CGFloat

        switch position {
        case .bottom:
            // Popup appears above the Dock icon
            // Convert AX Y (top-left origin) to NSWindow Y (bottom-left origin)
            let iconBottomNS = primaryHeight - iconFrame.origin.y - iconFrame.height
            popupX = iconFrame.midX - popupSize.width / 2
            popupY = iconBottomNS + iconFrame.height + padding

        case .left:
            // Popup appears to the right of the Dock icon
            let iconBottomNS = primaryHeight - iconFrame.origin.y - iconFrame.height
            popupX = iconFrame.origin.x + iconFrame.width + padding
            popupY = iconBottomNS + iconFrame.height / 2 - popupSize.height / 2

        case .right:
            // Popup appears to the left of the Dock icon
            let iconBottomNS = primaryHeight - iconFrame.origin.y - iconFrame.height
            popupX = iconFrame.origin.x - popupSize.width - padding
            popupY = iconBottomNS + iconFrame.height / 2 - popupSize.height / 2

        case .unknown:
            // Default to above
            let iconBottomNS = primaryHeight - iconFrame.origin.y - iconFrame.height
            popupX = iconFrame.midX - popupSize.width / 2
            popupY = iconBottomNS + iconFrame.height + padding
        }

        // Clamp to the DOCK's screen bounds (not main screen!)
        popupX = max(screenFrame.minX + 4, min(popupX, screenFrame.maxX - popupSize.width - 4))
        popupY = max(screenFrame.minY + 4, min(popupY, screenFrame.maxY - popupSize.height - 4))

        return CGPoint(x: popupX, y: popupY)
    }
}
