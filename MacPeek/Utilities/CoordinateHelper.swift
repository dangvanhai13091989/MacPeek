import Foundation
import Cocoa

/// Utility for coordinate system conversions between macOS frameworks.
///
/// macOS uses different coordinate origins:
/// - NSEvent / NSWindow: Bottom-left origin (y increases upward)
/// - Accessibility API (AXUIElement): Top-left origin (y increases downward)
/// - CGWindow: Top-left origin
///
/// ⚠️ CRITICAL: AX/CG coordinates use the PRIMARY screen as reference (the screen
/// with origin 0,0), NOT NSScreen.main (which is the screen with keyboard focus).
/// Using NSScreen.main will cause popup positioning errors on multi-monitor setups.
struct CoordinateHelper {

    /// The height of the primary screen (used for ALL coordinate conversions).
    /// Primary screen = NSScreen.screens.first = the screen containing (0,0).
    private static var primaryScreenHeight: CGFloat {
        NSScreen.screens.first?.frame.height ?? 900
    }

    /// Convert NSEvent mouse location (bottom-left origin) to Accessibility coordinates (top-left origin).
    static func nsEventToAccessibility(_ point: CGPoint) -> CGPoint {
        return CGPoint(
            x: point.x,
            y: primaryScreenHeight - point.y
        )
    }

    /// Convert Accessibility coordinates (top-left origin) to NSWindow coordinates (bottom-left origin).
    static func accessibilityToNSWindow(_ point: CGPoint) -> CGPoint {
        return CGPoint(
            x: point.x,
            y: primaryScreenHeight - point.y
        )
    }

    /// Convert an Accessibility frame (top-left origin) to NSWindow frame (bottom-left origin).
    static func accessibilityFrameToNSWindow(_ frame: CGRect) -> CGRect {
        return CGRect(
            x: frame.origin.x,
            y: primaryScreenHeight - frame.origin.y - frame.height,
            width: frame.width,
            height: frame.height
        )
    }

    /// Get the screen containing the given point (in NSEvent/bottom-left coordinates).
    static func screenContaining(point: CGPoint) -> NSScreen? {
        return NSScreen.screens.first { screen in
            screen.frame.contains(point)
        }
    }

    /// Clamp a point to stay within a given rect with padding.
    static func clampToRect(_ point: CGPoint, size: CGSize, bounds: CGRect, padding: CGFloat = 4) -> CGPoint {
        let x = max(bounds.minX + padding, min(point.x, bounds.maxX - size.width - padding))
        let y = max(bounds.minY + padding, min(point.y, bounds.maxY - size.height - padding))
        return CGPoint(x: x, y: y)
    }
}
