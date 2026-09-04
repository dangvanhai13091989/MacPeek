import SwiftUI

/// Onboarding window that guides users through permission setup.
/// Supports multiple languages via Localizable.strings (en, vi).
struct OnboardingView: View {
    @EnvironmentObject var permissionManager: PermissionManager
    @State private var currentStep = 0

    private let accentGradient = LinearGradient(
        colors: [Color(hex: "6C5CE7"), Color(hex: "A29BFE")],
        startPoint: .topLeading,
        endPoint: .bottomTrailing
    )

    var body: some View {
        ZStack {
            VisualEffectBlur(material: .sidebar, blendingMode: .behindWindow)
                .ignoresSafeArea()

            VStack(spacing: 0) {
                TabView(selection: $currentStep) {
                    welcomeStep.tag(0)
                    accessibilityStep.tag(1)
                    screenRecordingStep.tag(2)
                    completionStep.tag(3)
                }
                .tabViewStyle(.automatic)
                .padding(.top, 20)

                bottomControls
                    .padding(.horizontal, 32)
                    .padding(.bottom, 24)
            }
        }
        .onChange(of: permissionManager.allPermissionsGranted) { _, granted in
            if granted && currentStep < 3 {
                withAnimation(.easeInOut(duration: 0.3)) {
                    currentStep = 3
                }
            }
        }
        .onChange(of: permissionManager.screenRecordingNeedsRestart) { _, needsRestart in
            if needsRestart && permissionManager.accessibilityGranted && currentStep < 3 {
                withAnimation(.easeInOut(duration: 0.3)) {
                    currentStep = 3
                }
            }
        }
    }

    // MARK: - Step 0: Welcome

    private var welcomeStep: some View {
        VStack(spacing: 24) {
            Spacer()

            ZStack {
                Circle()
                    .fill(accentGradient)
                    .frame(width: 80, height: 80)
                    .shadow(color: Color(hex: "6C5CE7").opacity(0.4), radius: 20, y: 8)

                Image(systemName: "eye.fill")
                    .font(.system(size: 36, weight: .medium))
                    .foregroundStyle(.white)
            }

            Text(L10n.tr("onboarding.welcome.title"))
                .font(.system(size: 26, weight: .bold, design: .rounded))
                .foregroundStyle(.primary)

            Text(L10n.tr("onboarding.welcome.subtitle"))
                .font(.system(size: 14, weight: .regular))
                .foregroundStyle(.secondary)
                .multilineTextAlignment(.center)
                .lineSpacing(4)

            VStack(spacing: 12) {
                featureRow(icon: "rectangle.on.rectangle", text: L10n.tr("onboarding.welcome.feature1"))
                featureRow(icon: "bolt.fill", text: L10n.tr("onboarding.welcome.feature2"))
                featureRow(icon: "lock.shield.fill", text: L10n.tr("onboarding.welcome.feature3"))
            }
            .padding(.top, 8)

            Spacer()
        }
        .padding(.horizontal, 40)
    }

    // MARK: - Step 1: Accessibility

    private var accessibilityStep: some View {
        VStack(spacing: 20) {
            Spacer()

            permissionIcon(
                systemName: "hand.raised.fill",
                granted: permissionManager.accessibilityGranted
            )

            Text(L10n.tr("onboarding.accessibility.title"))
                .font(.system(size: 22, weight: .bold, design: .rounded))

            Text(LocalizedStringKey(L10n.tr("onboarding.accessibility.subtitle")))
                .font(.system(size: 13))
                .foregroundStyle(.secondary)
                .multilineTextAlignment(.center)
                .lineSpacing(4)

            if permissionManager.accessibilityGranted {
                permissionGrantedBadge
            } else if permissionManager.accessibilityNeedsReAdd {
                // Permission mismatch state — user bật rồi nhưng AX vẫn false
                accessibilityMismatchView
            } else {
                VStack(spacing: 16) {
                    VStack(alignment: .leading, spacing: 8) {
                        Text(L10n.tr("onboarding.accessibility.guide_title"))
                            .font(.system(size: 13, weight: .semibold))

                        instructionRow(step: "1", text: LocalizedStringKey(L10n.tr("onboarding.accessibility.step1")))
                        instructionRow(step: "2", text: LocalizedStringKey(L10n.tr("onboarding.accessibility.step2")))
                        instructionRow(step: "3", text: LocalizedStringKey(L10n.tr("onboarding.accessibility.step3")))
                        instructionRow(step: "4", text: LocalizedStringKey(L10n.tr("onboarding.accessibility.step4")))
                    }
                    .padding(14)
                    .background(.ultraThinMaterial, in: RoundedRectangle(cornerRadius: 10))

                    HStack(spacing: 12) {
                        Button(action: {
                            permissionManager.requestAccessibility()
                        }) {
                            Label(L10n.tr("button.request_permission"), systemImage: "checkmark.shield.fill")
                                .font(.system(size: 13, weight: .semibold))
                                .padding(.vertical, 8)
                                .padding(.horizontal, 16)
                        }
                        .buttonStyle(.borderedProminent)
                        .tint(Color(hex: "6C5CE7"))

                        Button(action: {
                            permissionManager.openAccessibilitySettings()
                        }) {
                            Label(L10n.tr("button.open_settings"), systemImage: "gear")
                                .font(.system(size: 13, weight: .semibold))
                                .padding(.vertical, 8)
                                .padding(.horizontal, 16)
                        }
                        .buttonStyle(.bordered)
                    }

                    // "I already enabled it" button — triggers mismatch detection
                    Button(action: {
                        permissionManager.reportAccessibilityMismatch()
                    }) {
                        Text(L10n.tr("button.already_enabled_accessibility"))
                            .font(.system(size: 12))
                            .foregroundStyle(.secondary)
                    }
                    .buttonStyle(.plain)
                }
            }

            Spacer()
        }
        .padding(.horizontal, 36)
    }

    // MARK: - Accessibility Mismatch View

    /// Shown when user says they enabled Accessibility but AXIsProcessTrusted() returns false.
    /// Guides them to remove and re-add the app.
    private var accessibilityMismatchView: some View {
        VStack(spacing: 16) {
            // Warning badge
            HStack(spacing: 6) {
                Image(systemName: "exclamationmark.triangle.fill")
                    .foregroundStyle(Color(hex: "FDCB6E"))
                Text(L10n.tr("onboarding.accessibility.mismatch_title"))
                    .font(.system(size: 13, weight: .medium))
                    .foregroundStyle(Color(hex: "FDCB6E"))
            }
            .padding(.horizontal, 16)
            .padding(.vertical, 8)
            .background(Color(hex: "FDCB6E").opacity(0.12), in: Capsule())

            VStack(alignment: .leading, spacing: 8) {
                Text(L10n.tr("onboarding.accessibility.mismatch_guide"))
                    .font(.system(size: 13, weight: .semibold))

                instructionRow(step: "1", text: LocalizedStringKey(L10n.tr("onboarding.accessibility.mismatch_step1")))
                instructionRow(step: "2", text: LocalizedStringKey(L10n.tr("onboarding.accessibility.mismatch_step2")))
                instructionRow(step: "3", text: LocalizedStringKey(L10n.tr("onboarding.accessibility.mismatch_step3")))
            }
            .padding(14)
            .background(.ultraThinMaterial, in: RoundedRectangle(cornerRadius: 10))

            HStack(spacing: 12) {
                Button(action: {
                    permissionManager.resetAndRequestAccessibility()
                }) {
                    Label(L10n.tr("button.reset_permissions"), systemImage: "arrow.counterclockwise")
                        .font(.system(size: 13, weight: .semibold))
                        .padding(.vertical, 8)
                        .padding(.horizontal, 16)
                }
                .buttonStyle(.borderedProminent)
                .tint(Color(hex: "E17055"))

                Button(action: {
                    permissionManager.openAccessibilitySettings()
                }) {
                    Label(L10n.tr("button.open_settings"), systemImage: "gear")
                        .font(.system(size: 13, weight: .semibold))
                        .padding(.vertical, 8)
                        .padding(.horizontal, 16)
                }
                .buttonStyle(.bordered)
            }
        }
    }

    // MARK: - Step 2: Screen Recording

    private var screenRecordingStep: some View {
        VStack(spacing: 20) {
            Spacer()

            permissionIcon(
                systemName: "rectangle.dashed.badge.record",
                granted: permissionManager.screenRecordingGranted || permissionManager.screenRecordingNeedsRestart
            )

            Text(L10n.tr("onboarding.screenrecording.title"))
                .font(.system(size: 22, weight: .bold, design: .rounded))

            Text(LocalizedStringKey(L10n.tr("onboarding.screenrecording.subtitle")))
                .font(.system(size: 13))
                .foregroundStyle(.secondary)
                .multilineTextAlignment(.center)
                .lineSpacing(4)

            if permissionManager.screenRecordingGranted {
                permissionGrantedBadge
            } else if permissionManager.screenRecordingNeedsRestart {
                VStack(spacing: 12) {
                    HStack(spacing: 6) {
                        Image(systemName: "checkmark.circle.fill")
                            .foregroundStyle(Color(hex: "00B894"))
                        Text(L10n.tr("onboarding.screenrecording.toggled"))
                            .font(.system(size: 13, weight: .medium))
                            .foregroundStyle(Color(hex: "00B894"))
                    }
                    .padding(.horizontal, 16)
                    .padding(.vertical, 8)
                    .background(Color(hex: "00B894").opacity(0.1), in: Capsule())

                    VStack(spacing: 8) {
                        Text(L10n.tr("onboarding.screenrecording.restart_title"))
                            .font(.system(size: 13, weight: .semibold))
                            .foregroundStyle(Color(hex: "FDCB6E"))

                        Text(L10n.tr("onboarding.screenrecording.restart_subtitle"))
                            .font(.system(size: 12))
                            .foregroundStyle(.secondary)
                            .multilineTextAlignment(.center)
                    }
                    .padding(14)
                    .background(.ultraThinMaterial, in: RoundedRectangle(cornerRadius: 10))

                    Button(action: {
                        permissionManager.restartApp()
                    }) {
                        Label(L10n.tr("button.restart_app"), systemImage: "arrow.clockwise")
                            .font(.system(size: 13, weight: .semibold))
                            .padding(.vertical, 8)
                            .padding(.horizontal, 16)
                    }
                    .buttonStyle(.borderedProminent)
                    .tint(Color(hex: "00B894"))
                }
            } else {
                VStack(spacing: 16) {
                    VStack(alignment: .leading, spacing: 8) {
                        Text(L10n.tr("onboarding.screenrecording.guide_title"))
                            .font(.system(size: 13, weight: .semibold))

                        instructionRow(step: "1", text: LocalizedStringKey(L10n.tr("onboarding.screenrecording.step1")))
                        instructionRow(step: "2", text: LocalizedStringKey(L10n.tr("onboarding.screenrecording.step2")))
                        instructionRow(step: "3", text: LocalizedStringKey(L10n.tr("onboarding.screenrecording.step3")))
                        instructionRow(step: "4", text: LocalizedStringKey(L10n.tr("onboarding.screenrecording.step4")))
                    }
                    .padding(14)
                    .background(.ultraThinMaterial, in: RoundedRectangle(cornerRadius: 10))

                    HStack(spacing: 12) {
                        Button(action: {
                            permissionManager.openScreenRecordingSettings()
                        }) {
                            Label(L10n.tr("button.open_settings"), systemImage: "gear")
                                .font(.system(size: 13, weight: .semibold))
                                .padding(.vertical, 8)
                                .padding(.horizontal, 16)
                        }
                        .buttonStyle(.borderedProminent)
                        .tint(Color(hex: "6C5CE7"))

                        Button(action: {
                            permissionManager.markScreenRecordingToggled()
                        }) {
                            Label(L10n.tr("button.already_enabled"), systemImage: "checkmark")
                                .font(.system(size: 13, weight: .semibold))
                                .padding(.vertical, 8)
                                .padding(.horizontal, 16)
                        }
                        .buttonStyle(.bordered)
                    }
                }
            }

            Spacer()
        }
        .padding(.horizontal, 36)
    }

    // MARK: - Step 3: Complete

    private var completionStep: some View {
        VStack(spacing: 24) {
            Spacer()

            // Show different icon based on whether ALL permissions are truly granted
            if permissionManager.accessibilityGranted {
                ZStack {
                    Circle()
                        .fill(
                            LinearGradient(
                                colors: [Color(hex: "00B894"), Color(hex: "55EFC4")],
                                startPoint: .topLeading,
                                endPoint: .bottomTrailing
                            )
                        )
                        .frame(width: 80, height: 80)
                        .shadow(color: Color(hex: "00B894").opacity(0.4), radius: 20, y: 8)

                    Image(systemName: "checkmark")
                        .font(.system(size: 36, weight: .bold))
                        .foregroundStyle(.white)
                }
            } else {
                // Accessibility NOT granted — show warning icon
                ZStack {
                    Circle()
                        .fill(
                            LinearGradient(
                                colors: [Color(hex: "E17055"), Color(hex: "FDCB6E")],
                                startPoint: .topLeading,
                                endPoint: .bottomTrailing
                            )
                        )
                        .frame(width: 80, height: 80)
                        .shadow(color: Color(hex: "E17055").opacity(0.4), radius: 20, y: 8)

                    Image(systemName: "exclamationmark.triangle.fill")
                        .font(.system(size: 36, weight: .bold))
                        .foregroundStyle(.white)
                }
            }

            if permissionManager.accessibilityGranted {
                Text(L10n.tr("onboarding.complete.title"))
                    .font(.system(size: 26, weight: .bold, design: .rounded))
            } else {
                Text(L10n.tr("onboarding.complete.missing_title"))
                    .font(.system(size: 22, weight: .bold, design: .rounded))
                    .foregroundStyle(Color(hex: "E17055"))
            }

            if !permissionManager.accessibilityGranted {
                // Accessibility NOT granted — show warning + action buttons
                Text(L10n.tr("onboarding.complete.missing_subtitle"))
                    .font(.system(size: 14))
                    .foregroundStyle(.secondary)
                    .multilineTextAlignment(.center)
                    .lineSpacing(4)
            } else if permissionManager.screenRecordingNeedsRestart && !permissionManager.screenRecordingGranted {
                Text(LocalizedStringKey(L10n.tr("onboarding.complete.restart_subtitle")))
                    .font(.system(size: 14))
                    .foregroundStyle(.secondary)
                    .multilineTextAlignment(.center)
                    .lineSpacing(4)
            } else {
                Text(L10n.tr("onboarding.complete.subtitle"))
                    .font(.system(size: 14))
                    .foregroundStyle(.secondary)
                    .multilineTextAlignment(.center)
                    .lineSpacing(4)
            }

            VStack(spacing: 8) {
                statusRow(
                    icon: "hand.raised.fill",
                    label: L10n.tr("permission.accessibility"),
                    granted: permissionManager.accessibilityGranted
                )
                statusRow(
                    icon: "rectangle.dashed.badge.record",
                    label: L10n.tr("permission.screen_recording"),
                    granted: permissionManager.screenRecordingGranted || permissionManager.screenRecordingNeedsRestart
                )
            }
            .padding(16)
            .background(.ultraThinMaterial, in: RoundedRectangle(cornerRadius: 12))

            // Action buttons based on state
            if !permissionManager.accessibilityGranted {
                // Accessibility missing — show fix buttons
                HStack(spacing: 12) {
                    Button(action: {
                        permissionManager.resetAndRequestAccessibility()
                    }) {
                        Label(L10n.tr("button.reset_permissions"), systemImage: "arrow.counterclockwise")
                            .font(.system(size: 13, weight: .semibold))
                            .padding(.vertical, 8)
                            .padding(.horizontal, 16)
                    }
                    .buttonStyle(.borderedProminent)
                    .tint(Color(hex: "E17055"))

                    Button(action: {
                        permissionManager.openAccessibilitySettings()
                    }) {
                        Label(L10n.tr("button.open_settings"), systemImage: "gear")
                            .font(.system(size: 13, weight: .semibold))
                            .padding(.vertical, 8)
                            .padding(.horizontal, 16)
                    }
                    .buttonStyle(.bordered)
                }
            } else if permissionManager.screenRecordingNeedsRestart && !permissionManager.screenRecordingGranted {
                Button(action: {
                    permissionManager.restartApp()
                }) {
                    Label(L10n.tr("button.restart_app"), systemImage: "arrow.clockwise")
                        .font(.system(size: 14, weight: .semibold))
                        .padding(.vertical, 10)
                        .padding(.horizontal, 20)
                }
                .buttonStyle(.borderedProminent)
                .tint(Color(hex: "00B894"))
            }

            Spacer()
        }
        .padding(.horizontal, 40)
    }

    // MARK: - Bottom Navigation

    private var bottomControls: some View {
        HStack {
            if currentStep > 0 && currentStep < 3 {
                Button(L10n.tr("button.back")) {
                    withAnimation(.easeInOut(duration: 0.3)) {
                        currentStep -= 1
                    }
                }
                .buttonStyle(.plain)
                .foregroundStyle(.secondary)
            }

            Spacer()

            HStack(spacing: 8) {
                ForEach(0..<4) { index in
                    Circle()
                        .fill(index == currentStep ? Color(hex: "6C5CE7") : Color.gray.opacity(0.3))
                        .frame(width: 8, height: 8)
                        .scaleEffect(index == currentStep ? 1.2 : 1.0)
                        .animation(.easeInOut(duration: 0.2), value: currentStep)
                }
            }

            Spacer()

            if currentStep < 3 {
                Button(L10n.tr("button.continue")) {
                    withAnimation(.easeInOut(duration: 0.3)) {
                        currentStep += 1
                    }
                }
                .buttonStyle(.borderedProminent)
                .tint(Color(hex: "6C5CE7"))
            } else {
                Button(L10n.tr("button.close")) {
                    NSApp.keyWindow?.close()
                }
                .buttonStyle(.borderedProminent)
                .tint(Color(hex: "00B894"))
            }
        }
    }

    // MARK: - UI Components

    private func featureRow(icon: String, text: String) -> some View {
        HStack(spacing: 12) {
            Image(systemName: icon)
                .font(.system(size: 14))
                .foregroundStyle(accentGradient)
                .frame(width: 24)

            Text(text)
                .font(.system(size: 13))
                .foregroundStyle(.primary)

            Spacer()
        }
        .padding(.horizontal, 20)
    }

    private func instructionRow(step: String, text: LocalizedStringKey) -> some View {
        HStack(alignment: .top, spacing: 8) {
            Text(step)
                .font(.system(size: 11, weight: .bold, design: .rounded))
                .foregroundStyle(.white)
                .frame(width: 20, height: 20)
                .background(Color(hex: "6C5CE7"), in: Circle())

            Text(text)
                .font(.system(size: 12))
                .foregroundStyle(.primary)
                .fixedSize(horizontal: false, vertical: true)
        }
    }

    private func permissionIcon(systemName: String, granted: Bool) -> some View {
        ZStack {
            Circle()
                .fill(
                    granted
                    ? LinearGradient(colors: [Color(hex: "00B894"), Color(hex: "55EFC4")], startPoint: .topLeading, endPoint: .bottomTrailing)
                    : accentGradient
                )
                .frame(width: 72, height: 72)
                .shadow(
                    color: (granted ? Color(hex: "00B894") : Color(hex: "6C5CE7")).opacity(0.4),
                    radius: 16, y: 6
                )

            Image(systemName: systemName)
                .font(.system(size: 30, weight: .medium))
                .foregroundStyle(.white)
        }
    }

    private var permissionGrantedBadge: some View {
        HStack(spacing: 6) {
            Image(systemName: "checkmark.circle.fill")
                .foregroundStyle(Color(hex: "00B894"))
            Text(L10n.tr("permission.status.granted"))
                .font(.system(size: 13, weight: .medium))
                .foregroundStyle(Color(hex: "00B894"))
        }
        .padding(.horizontal, 16)
        .padding(.vertical, 8)
        .background(Color(hex: "00B894").opacity(0.1), in: Capsule())
    }

    private func statusRow(icon: String, label: String, granted: Bool) -> some View {
        HStack(spacing: 10) {
            Image(systemName: icon)
                .font(.system(size: 14))
                .foregroundStyle(granted ? Color(hex: "00B894") : .red)
                .frame(width: 20)

            Text(label)
                .font(.system(size: 13))

            Spacer()

            Image(systemName: granted ? "checkmark.circle.fill" : "xmark.circle.fill")
                .foregroundStyle(granted ? Color(hex: "00B894") : .red)
        }
    }
}

// MARK: - Color Extension

extension Color {
    init(hex: String) {
        let hex = hex.trimmingCharacters(in: CharacterSet.alphanumerics.inverted)
        var int: UInt64 = 0
        Scanner(string: hex).scanHexInt64(&int)
        let a, r, g, b: UInt64
        switch hex.count {
        case 3: // RGB (12-bit)
            (a, r, g, b) = (255, (int >> 8) * 17, (int >> 4 & 0xF) * 17, (int & 0xF) * 17)
        case 6: // RGB (24-bit)
            (a, r, g, b) = (255, int >> 16, int >> 8 & 0xFF, int & 0xFF)
        case 8: // ARGB (32-bit)
            (a, r, g, b) = (int >> 24, int >> 16 & 0xFF, int >> 8 & 0xFF, int & 0xFF)
        default:
            (a, r, g, b) = (255, 0, 0, 0)
        }
        self.init(
            .sRGB,
            red: Double(r) / 255,
            green: Double(g) / 255,
            blue: Double(b) / 255,
            opacity: Double(a) / 255
        )
    }
}
