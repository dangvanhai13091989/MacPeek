import Foundation
import CoreGraphics

/// Represents information about a Dock icon that the mouse is hovering over.
struct DockItemInfo {
    /// Display name of the application.
    let appName: String

    /// Bundle identifier of the application (e.g., "com.apple.Safari").
    let bundleIdentifier: String?

    /// Process ID of the running application.
    let pid: pid_t

    /// Screen position of the mouse when hovering (in screen coordinates, bottom-left origin).
    let iconPosition: CGPoint

    /// Frame of the Dock icon element (in Accessibility coordinates, top-left origin).
    let iconFrame: CGRect
}
