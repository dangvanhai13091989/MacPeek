import Foundation
import Cocoa
import CoreGraphics

/// Represents a captured thumbnail image of an application window.
struct WindowThumbnail {
    /// The captured thumbnail image, already resized for display.
    let image: NSImage

    /// Title of the captured window.
    let windowTitle: String

    /// Name of the owning application.
    let appName: String

    /// The CGWindowID of the captured window.
    let windowID: CGWindowID

    /// Timestamp when this thumbnail was captured.
    let capturedAt: Date
}
