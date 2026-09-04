import SwiftUI

@main
struct MacPeekApp: App {
    @NSApplicationDelegateAdaptor(AppDelegate.self) var appDelegate
    @StateObject private var permissionManager = PermissionManager.shared

    var body: some Scene {
        MenuBarExtra {
            MenuBarView()
                .environmentObject(permissionManager)
        } label: {
            Label("MacPeek", systemImage: "eye.fill")
        }
        .menuBarExtraStyle(.window)
    }
}
