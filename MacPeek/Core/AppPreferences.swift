import Foundation

enum AppPreferences {
    static let enabledKey = "macpeek.enabled"

    static var isEnabled: Bool {
        UserDefaults.standard.object(forKey: enabledKey) == nil ||
            UserDefaults.standard.bool(forKey: enabledKey)
    }
}

extension Notification.Name {
    static let macPeekEnabledChanged = Notification.Name("MacPeekEnabledChanged")
}
