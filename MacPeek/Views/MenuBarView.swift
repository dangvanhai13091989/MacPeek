import SwiftUI
import ServiceManagement

/// Menu displayed when clicking the MacPeek icon in the Menu Bar.
/// Premium design with blur background, gradient, and micro-animations.
/// Fully localized (EN/VI).
struct MenuBarView: View {
    @EnvironmentObject var permissionManager: PermissionManager
    @AppStorage(AppPreferences.enabledKey) private var isEnabled: Bool = true
    @State private var hoveredButton: String?
    @State private var launchAtLogin: Bool = SMAppService.mainApp.status == .enabled

    private let accentGradient = LinearGradient(
        colors: [Color(hex: "6C5CE7"), Color(hex: "A29BFE")],
        startPoint: .topLeading,
        endPoint: .bottomTrailing
    )

    var body: some View {
        VStack(spacing: 0) {
            headerSection
            Divider().padding(.horizontal, 16)
            toggleSection
            launchAtLoginSection
            Divider().padding(.horizontal, 16)
            communitySection
            Divider().padding(.horizontal, 16)
            permissionsSection
            Divider().padding(.horizontal, 16)
            actionsSection
        }
        .frame(width: 280)
        .padding(.vertical, 8)
    }

    // MARK: - Header

    private var headerSection: some View {
        HStack(spacing: 10) {
            ZStack {
                RoundedRectangle(cornerRadius: 8, style: .continuous)
                    .fill(accentGradient)
                    .frame(width: 32, height: 32)
                    .shadow(color: Color(hex: "6C5CE7").opacity(0.3), radius: 4, y: 2)

                Image(systemName: "eye.fill")
                    .font(.system(size: 14, weight: .semibold))
                    .foregroundStyle(.white)
            }

            VStack(alignment: .leading, spacing: 2) {
                Text("MacPeek")
                    .font(.system(size: 14, weight: .bold, design: .rounded))
                    .foregroundStyle(.primary)

                Text(versionText)
                    .font(.system(size: 10, weight: .medium))
                    .foregroundStyle(.tertiary)
            }

            Spacer()

            statusBadge
        }
        .padding(.horizontal, 16)
        .padding(.vertical, 10)
    }

    private var statusBadge: some View {
        HStack(spacing: 4) {
            Circle()
                .fill(isEnabled && permissionManager.allPermissionsGranted ? Color(hex: "00B894") : Color(hex: "FDCB6E"))
                .frame(width: 6, height: 6)
                .shadow(
                    color: (isEnabled && permissionManager.allPermissionsGranted ? Color(hex: "00B894") : Color(hex: "FDCB6E")).opacity(0.5),
                    radius: 3
                )

            Text(statusText)
                .font(.system(size: 10, weight: .medium))
                .foregroundStyle(.secondary)
        }
        .padding(.horizontal, 8)
        .padding(.vertical, 4)
        .background(.quaternary.opacity(0.5), in: Capsule())
    }

    private var statusText: String {
        if !permissionManager.allPermissionsGranted {
            return L10n.tr("permission.missing")
        }
        return isEnabled ? L10n.tr("menu.running") : L10n.tr("menu.paused")
    }

    // MARK: - Toggle

    private var toggleSection: some View {
        HStack {
            Image(systemName: isEnabled ? "power.circle.fill" : "power.circle")
                .font(.system(size: 14))
                .foregroundStyle(isEnabled ? Color(hex: "00B894") : .secondary)
                .contentTransition(.symbolEffect(.replace))

            Text(L10n.tr("menu.enable"))
                .font(.system(size: 13, weight: .medium))

            Spacer()

            Toggle("", isOn: $isEnabled)
                .toggleStyle(.switch)
                .controlSize(.small)
                .labelsHidden()
                .onChange(of: isEnabled) { _, newValue in
                    NotificationCenter.default.post(
                        name: .macPeekEnabledChanged,
                        object: newValue
                    )
                }
        }
        .padding(.horizontal, 16)
        .padding(.vertical, 8)
    }

    // MARK: - Launch at Login

    private var launchAtLoginSection: some View {
        HStack {
            Image(systemName: "sunrise.fill")
                .font(.system(size: 14))
                .foregroundStyle(launchAtLogin ? Color(hex: "FDCB6E") : .secondary)
                .contentTransition(.symbolEffect(.replace))

            Text(L10n.tr("menu.launch_at_login"))
                .font(.system(size: 13, weight: .medium))

            Spacer()

            Toggle("", isOn: $launchAtLogin)
                .toggleStyle(.switch)
                .controlSize(.small)
                .labelsHidden()
                .onChange(of: launchAtLogin) { _, newValue in
                    do {
                        if newValue {
                            try SMAppService.mainApp.register()
                        } else {
                            try SMAppService.mainApp.unregister()
                        }
                    } catch {
                        NSLog("[MacPeek] Launch at Login error: \(error.localizedDescription)")
                        launchAtLogin = SMAppService.mainApp.status == .enabled
                    }
                }
        }
        .padding(.horizontal, 16)
        .padding(.vertical, 8)
    }

    // MARK: - Community

    private var communitySection: some View {
        VStack(spacing: 4) {
            HStack(spacing: 8) {
                Image(systemName: "lock.open.fill")
                    .font(.system(size: 11))
                    .foregroundStyle(Color(hex: "00B894"))
                    .frame(width: 16)

                Text(L10n.tr("menu.free_open_source"))
                    .font(.system(size: 12, weight: .medium))
                    .foregroundStyle(Color(hex: "00B894"))

                Spacer()
            }
            .padding(.horizontal, 12)
            .padding(.vertical, 5)

            menuButton(
                icon: "heart.fill",
                label: L10n.tr("menu.support_development"),
                id: "support"
            ) {
                openURL("https://vanhaimagic.gumroad.com/l/macpeek")
            }

            menuButton(
                icon: "chevron.left.forwardslash.chevron.right",
                label: L10n.tr("menu.view_source"),
                id: "source"
            ) {
                openURL("https://github.com/dangvanhai13091989/MacPeek")
            }
        }
        .padding(.horizontal, 4)
        .padding(.vertical, 6)
    }

    // MARK: - Permissions

    private var permissionsSection: some View {
        VStack(spacing: 2) {
            permissionRow(
                icon: "hand.raised.fill",
                label: L10n.tr("permission.accessibility"),
                granted: permissionManager.accessibilityGranted
            )
            permissionRow(
                icon: "rectangle.dashed.badge.record",
                label: L10n.tr("permission.screen_recording"),
                granted: permissionManager.screenRecordingGranted
            )

            if !permissionManager.allPermissionsGranted {
                menuButton(
                    icon: "gearshape.fill",
                    label: L10n.tr("menu.permissions_settings"),
                    id: "permissions"
                ) {
                    openOnboarding()
                }
                .padding(.top, 4)
            }
        }
        .padding(.horizontal, 4)
        .padding(.vertical, 6)
    }

    private func permissionRow(icon: String, label: String, granted: Bool) -> some View {
        HStack(spacing: 8) {
            Image(systemName: icon)
                .font(.system(size: 11))
                .foregroundStyle(granted ? Color(hex: "00B894") : Color(hex: "E17055"))
                .frame(width: 16)

            Text(label)
                .font(.system(size: 12))
                .foregroundStyle(.primary)

            Spacer()

            Image(systemName: granted ? "checkmark.circle.fill" : "xmark.circle.fill")
                .font(.system(size: 12))
                .foregroundStyle(granted ? Color(hex: "00B894") : Color(hex: "E17055"))
                .contentTransition(.symbolEffect(.replace))
        }
        .padding(.horizontal, 12)
        .padding(.vertical, 5)
    }

    // MARK: - Actions

    private var actionsSection: some View {
        VStack(spacing: 2) {
            menuButton(icon: "arrow.triangle.2.circlepath", label: L10n.tr("menu.check_updates"), id: "updates") {
                UpdateManager.shared.checkForUpdates()
            }

            menuButton(icon: "info.circle", label: L10n.tr("menu.about"), id: "about") {
                showAbout()
            }

            menuButton(icon: "power", label: L10n.tr("menu.quit"), id: "quit", destructive: true) {
                NSApplication.shared.terminate(nil)
            }
        }
        .padding(.horizontal, 4)
        .padding(.vertical, 6)
    }

    // MARK: - Reusable Button

    private func menuButton(
        icon: String,
        label: String,
        id: String,
        destructive: Bool = false,
        action: @escaping () -> Void
    ) -> some View {
        Button(action: action) {
            HStack(spacing: 8) {
                Image(systemName: icon)
                    .font(.system(size: 11))
                    .foregroundStyle(destructive ? Color(hex: "E17055") : .secondary)
                    .frame(width: 16)

                Text(label)
                    .font(.system(size: 12, weight: .regular))
                    .foregroundStyle(destructive ? Color(hex: "E17055") : .primary)

                Spacer()
            }
            .padding(.horizontal, 12)
            .padding(.vertical, 6)
            .background(
                RoundedRectangle(cornerRadius: 6, style: .continuous)
                    .fill(hoveredButton == id ? AnyShapeStyle(.quaternary) : AnyShapeStyle(Color.clear))
            )
        }
        .buttonStyle(.plain)
        .onHover { isHovered in
            withAnimation(.easeInOut(duration: 0.15)) {
                hoveredButton = isHovered ? id : nil
            }
        }
    }

    // MARK: - Actions

    private func openOnboarding() {
        for window in NSApp.windows {
            if window.title == "MacPeek Setup" {
                window.makeKeyAndOrderFront(nil)
                NSApp.activate(ignoringOtherApps: true)
                return
            }
        }
        let onboardingView = OnboardingView()
            .environmentObject(PermissionManager.shared)
            .frame(width: 520, height: 480)
        let hostingView = NSHostingView(rootView: onboardingView)
        let window = NSWindow(
            contentRect: NSRect(x: 0, y: 0, width: 520, height: 480),
            styleMask: [.titled, .closable, .fullSizeContentView],
            backing: .buffered,
            defer: false
        )
        window.title = "MacPeek Setup"
        window.titlebarAppearsTransparent = true
        window.titleVisibility = .hidden
        window.contentView = hostingView
        window.center()
        window.isReleasedWhenClosed = false
        window.makeKeyAndOrderFront(nil)
        NSApp.activate(ignoringOtherApps: true)
    }

    private func openURL(_ value: String) {
        guard let url = URL(string: value) else { return }
        NSWorkspace.shared.open(url)
    }

    private func showAbout() {
        NSApp.activate(ignoringOtherApps: true)
        NSApp.orderFrontStandardAboutPanel(options: [
            .applicationName: "MacPeek",
            .applicationVersion: Bundle.main.object(forInfoDictionaryKey: "CFBundleShortVersionString") as? String ?? "",
            .version: Bundle.main.object(forInfoDictionaryKey: "CFBundleVersion") as? String ?? "",
            .credits: NSAttributedString(
                string: L10n.tr("about.description"),
                attributes: [
                    .font: NSFont.systemFont(ofSize: 11),
                    .foregroundColor: NSColor.secondaryLabelColor
                ]
            )
        ])
    }

    private var versionText: String {
        let version = Bundle.main.object(forInfoDictionaryKey: "CFBundleShortVersionString") as? String ?? ""
        return "v\(version)"
    }
}
