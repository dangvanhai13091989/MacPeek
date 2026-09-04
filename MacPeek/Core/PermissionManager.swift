import Foundation
import Cocoa
import ApplicationServices
import Combine
import os.log

/// Manages permission checks for Accessibility and Screen Recording.
/// Uses polling to detect when the user grants permissions in System Settings.
final class PermissionManager: ObservableObject {

    static let shared = PermissionManager()

    // MARK: - Published State

    @Published var accessibilityGranted: Bool = false
    @Published var screenRecordingGranted: Bool = false
    @Published var allPermissionsGranted: Bool = false

    /// Indicates that Screen Recording was toggled but app needs restart
    @Published var screenRecordingNeedsRestart: Bool = false

    /// Indicates a permission mismatch (user thinks they enabled it, but AX returns false)
    /// This happens when the app's code signature changed (debug rebuild) or
    /// when the TCC database entry doesn't match the current binary.
    @Published var accessibilityNeedsReAdd: Bool = false

    // MARK: - Private

    private var pollTimer: Timer?
    /// Poll quickly when permissions not yet granted, slowly after
    private let fastPollInterval: TimeInterval = 2.0
    private let slowPollInterval: TimeInterval = 10.0

    /// Track whether we've already shown the Accessibility prompt this session
    private var hasPromptedAccessibility = false

    /// Track the initial screen recording state to detect changes
    private var initialScreenRecordingState: Bool?

    /// Count consecutive false results while user reports "enabled" — triggers mismatch state
    private var consecutiveAccessibilityFalseCount: Int = 0

    private let logger = Logger(subsystem: "com.macpeek.MacPeek", category: "Permissions")

    private init() {
        let bundleID = Bundle.main.bundleIdentifier ?? "unknown"
        let pid = ProcessInfo.processInfo.processIdentifier

        logger.info("[PermissionManager] Initializing...")
        logger.info("[PermissionManager] Bundle ID: \(bundleID)")
        logger.info("[PermissionManager] Process ID: \(pid)")

        // Immediately check and log
        let axTrusted = AXIsProcessTrusted()
        logger.info("[PermissionManager] AXIsProcessTrusted() = \(axTrusted)")

        // If not trusted, trigger the system prompt immediately
        if !axTrusted {
            logger.warning("[PermissionManager] Accessibility NOT granted — triggering system prompt")
            let options = [kAXTrustedCheckOptionPrompt.takeUnretainedValue() as String: true] as CFDictionary
            let result = AXIsProcessTrustedWithOptions(options)
            logger.info("[PermissionManager] AXIsProcessTrustedWithOptions (prompt=true) = \(result)")
            hasPromptedAccessibility = true
        }

        checkAllPermissions()

        // Save initial screen recording state
        initialScreenRecordingState = screenRecordingGranted

        startPolling()
    }

    deinit {
        stopPolling()
    }

    // MARK: - Permission Checks

    /// Check if Accessibility permission is granted.
    /// Uses AXIsProcessTrusted() which returns true if the app is in the Accessibility list.
    func checkAccessibility() -> Bool {
        let trusted = AXIsProcessTrusted()
        logger.debug("[PermissionManager] checkAccessibility: AXIsProcessTrusted() = \(trusted)")

        let previousValue = accessibilityGranted

        DispatchQueue.main.async {
            self.accessibilityGranted = trusted

            // If trusted, clear mismatch state and reset counter
            if trusted {
                self.accessibilityNeedsReAdd = false
                self.consecutiveAccessibilityFalseCount = 0
            }

            self.updateAllPermissions()
        }

        // Log state changes
        if trusted != previousValue {
            logger.info("[PermissionManager] 🔄 Accessibility changed: \(previousValue) → \(trusted)")
        }

        return trusted
    }

    /// Check if Screen Recording permission is granted.
    /// Uses multiple detection methods for reliability.
    func checkScreenRecording() -> Bool {
        let granted = checkScreenRecordingPermission()

        let previousValue = screenRecordingGranted

        DispatchQueue.main.async {
            self.screenRecordingGranted = granted
            self.updateAllPermissions()
        }

        // Detect if user toggled Screen Recording (needs restart)
        if granted != previousValue {
            logger.info("[PermissionManager] 🔄 Screen Recording changed: \(previousValue) → \(granted)")
        }

        return granted
    }

    /// Request Accessibility permission by showing the system prompt.
    func requestAccessibility() {
        logger.info("[PermissionManager] Requesting Accessibility permission (prompt)")
        let options = [kAXTrustedCheckOptionPrompt.takeUnretainedValue() as String: true] as CFDictionary
        let result = AXIsProcessTrustedWithOptions(options)
        logger.info("[PermissionManager] AXIsProcessTrustedWithOptions result: \(result)")
    }

    /// Open System Settings to the Accessibility pane.
    func openAccessibilitySettings() {
        logger.info("[PermissionManager] Opening Accessibility settings")
        // Try the modern URL first (macOS 13+)
        if let url = URL(string: "x-apple.systempreferences:com.apple.preference.security?Privacy_Accessibility") {
            NSWorkspace.shared.open(url)
        }
    }

    /// Open System Settings to the Screen Recording pane.
    func openScreenRecordingSettings() {
        let url = URL(string: "x-apple.systempreferences:com.apple.preference.security?Privacy_ScreenCapture")!
        NSWorkspace.shared.open(url)
    }

    /// Reset Accessibility permission via tccutil and re-prompt.
    /// This clears the TCC database entry for this app, forcing a fresh permission request.
    func resetAndRequestAccessibility() {
        let bundleID = Bundle.main.bundleIdentifier ?? "com.macpeek.MacPeek"
        logger.info("[PermissionManager] Resetting Accessibility for \(bundleID)")

        // Run tccutil reset in background
        let task = Process()
        task.launchPath = "/usr/bin/tccutil"
        task.arguments = ["reset", "Accessibility", bundleID]
        task.launch()
        task.waitUntilExit()

        logger.info("[PermissionManager] tccutil reset completed with status: \(task.terminationStatus)")

        DispatchQueue.main.async {
            self.accessibilityNeedsReAdd = false
            self.consecutiveAccessibilityFalseCount = 0
        }

        // Re-prompt after a short delay
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
            self.requestAccessibility()
            self.openAccessibilitySettings()
        }
    }

    /// Called when user explicitly reports they have toggled Accessibility ON
    /// but AXIsProcessTrusted() still returns false.
    func reportAccessibilityMismatch() {
        logger.warning("[PermissionManager] User reports Accessibility mismatch!")
        DispatchQueue.main.async {
            self.accessibilityNeedsReAdd = true
        }
    }

    /// Restart the application to apply Screen Recording permission changes.
    func restartApp() {
        logger.info("[PermissionManager] Restarting app to apply Screen Recording permission")

        let url = URL(fileURLWithPath: Bundle.main.resourcePath!)
        let path = url.deletingLastPathComponent().deletingLastPathComponent().absoluteString
        let task = Process()
        task.launchPath = "/usr/bin/open"
        task.arguments = [path]
        task.launch()

        NSApp.terminate(nil)
    }

    // MARK: - Polling

    func startPolling() {
        stopPolling()
        let interval = allPermissionsGranted ? slowPollInterval : fastPollInterval
        logger.info("[PermissionManager] Starting permission polling (interval: \(interval)s)")
        pollTimer = Timer.scheduledTimer(withTimeInterval: interval, repeats: true) { [weak self] _ in
            self?.checkAllPermissions()
        }
    }

    func stopPolling() {
        pollTimer?.invalidate()
        pollTimer = nil
    }

    /// Adjust polling speed based on permission state
    private func adjustPollingSpeed() {
        if allPermissionsGranted {
            // Slow down polling — permissions already granted
            stopPolling()
            pollTimer = Timer.scheduledTimer(withTimeInterval: slowPollInterval, repeats: true) { [weak self] _ in
                self?.checkAllPermissions()
            }
        }
    }

    // MARK: - Private

    private func checkAllPermissions() {
        _ = checkAccessibility()
        _ = checkScreenRecording()
    }

    private func updateAllPermissions() {
        // Screen Recording is considered granted if:
        // 1. The check returns true (app has active permission), OR
        // 2. The user has toggled it on (needs restart) — we detect this from system
        let screenOK = screenRecordingGranted || screenRecordingNeedsRestart
        let all = accessibilityGranted && screenOK
        if allPermissionsGranted != all {
            allPermissionsGranted = all
            // Adjust polling speed when state changes
            adjustPollingSpeed()
        }
    }

    /// Mark Screen Recording as "needs restart" — called when user confirms they toggled it.
    func markScreenRecordingToggled() {
        DispatchQueue.main.async {
            self.screenRecordingNeedsRestart = true
            self.updateAllPermissions()
        }
    }

    /// Checks Screen Recording permission using CGWindowListCopyWindowInfo.
    /// This is a PASSIVE check — it does NOT trigger any system permission dialogs.
    /// If the app has Screen Recording permission, we can read kCGWindowName from other apps.
    /// If not, window names will be nil/missing for other processes.
    ///
    /// ⚠️ DO NOT use SCShareableContent here — it triggers the permission dialog every call!
    private func checkScreenRecordingPermission() -> Bool {
        // macOS 15+: Use CGPreflightScreenCaptureAccess if available
        if #available(macOS 15.0, *) {
            return CGPreflightScreenCaptureAccess()
        }

        guard let windowList = CGWindowListCopyWindowInfo(
            [.optionOnScreenOnly, .excludeDesktopElements],
            kCGNullWindowID
        ) as? [[String: Any]] else {
            return false
        }

        let myPID = ProcessInfo.processInfo.processIdentifier

        for window in windowList {
            guard let ownerPID = window[kCGWindowOwnerPID as String] as? pid_t else { continue }

            // Skip our own process
            if ownerPID == myPID { continue }

            // Skip system processes that may not expose window names regardless of permission
            let ownerName = window[kCGWindowOwnerName as String] as? String ?? ""
            let systemProcesses = [
                "Dock", "SystemUIServer", "Window Server", "WindowManager",
                "Control Center", "Notification Center", "Spotlight",
                "loginwindow", "universalaccessd"
            ]
            if systemProcesses.contains(ownerName) { continue }

            // Skip windows with zero area (invisible)
            if let bounds = window[kCGWindowBounds as String] as? [String: CGFloat] {
                let w = bounds["Width"] ?? 0
                let h = bounds["Height"] ?? 0
                if w * h < 100 { continue }
            }

            // If we can read the window name of a normal app, we have permission
            if let name = window[kCGWindowName as String] as? String, !name.isEmpty {
                return true
            }
        }

        return false
    }
}
