import Foundation

/// Convenience wrapper for NSLocalizedString.
/// Usage: L10n.tr("onboarding.welcome.title")
enum L10n {
    /// Get localized string by key
    static func tr(_ key: String) -> String {
        localizedString(for: key)
    }

    /// Get localized string with format args
    static func tr(_ key: String, _ args: CVarArg...) -> String {
        String(format: localizedString(for: key), arguments: args)
    }

    private static func localizedString(for key: String) -> String {
        let localized = NSLocalizedString(key, comment: "")
        guard localized == key,
              let path = Bundle.main.path(forResource: "en", ofType: "lproj"),
              let englishBundle = Bundle(path: path) else {
            return localized
        }

        return NSLocalizedString(key, bundle: englishBundle, comment: "")
    }
}
