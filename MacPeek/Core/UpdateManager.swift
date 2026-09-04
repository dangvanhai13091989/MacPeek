import Foundation
import Sparkle

/// Owns Sparkle's updater for the lifetime of the menu bar application.
@MainActor
final class UpdateManager {
    static let shared = UpdateManager()

    private let updaterController: SPUStandardUpdaterController

    private init() {
        updaterController = SPUStandardUpdaterController(
            startingUpdater: true,
            updaterDelegate: nil,
            userDriverDelegate: nil
        )
    }

    func start() {
        // Accessing the singleton starts Sparkle and its scheduled update cycle.
    }

    func checkForUpdates() {
        updaterController.updater.checkForUpdates()
    }
}
