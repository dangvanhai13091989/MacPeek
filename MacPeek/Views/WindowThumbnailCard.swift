import SwiftUI

/// A mini thumbnail card used in multi-window preview mode.
/// Shows a small preview of a single window with macOS-style title bar,
/// close button, hover effects, and click-to-activate.
struct WindowThumbnailCard: View {
    let thumbnail: WindowThumbnail
    let isSelected: Bool
    var showCloseButton: Bool = false
    var onTap: (() -> Void)?
    var onClose: (() -> Void)?

    @State private var isHovered = false
    @State private var isCloseHovered = false

    var body: some View {
        VStack(spacing: 0) {
            // macOS-style mini title bar
            HStack(spacing: 4) {
                // Close button (red dot) — only shows when hovering AND showCloseButton is true
                if showCloseButton {
                    Button(action: {
                        onClose?()
                    }) {
                        ZStack {
                            Circle()
                                .fill(isHovered ? Color(hex: "FF5F57") : Color(hex: "FF5F57").opacity(0.4))
                                .frame(width: 10, height: 10)

                            if isCloseHovered {
                                Image(systemName: "xmark")
                                    .font(.system(size: 6, weight: .bold))
                                    .foregroundStyle(.black.opacity(0.7))
                            }
                        }
                    }
                    .buttonStyle(.plain)
                    .onHover { hovering in
                        withAnimation(.easeInOut(duration: 0.1)) {
                            isCloseHovered = hovering
                        }
                    }
                    .help(L10n.tr("preview.close_window"))

                    // Other traffic lights (inactive)
                    Circle()
                        .fill(isHovered ? Color(hex: "FEBC2E") : Color(hex: "FEBC2E").opacity(0.4))
                        .frame(width: 6, height: 6)
                    Circle()
                        .fill(isHovered ? Color(hex: "28C840") : Color(hex: "28C840").opacity(0.4))
                        .frame(width: 6, height: 6)
                } else {
                    // Non-interactive traffic lights
                    HStack(spacing: 3) {
                        Circle().fill(Color(hex: "FF5F57").opacity(isHovered ? 1.0 : 0.4)).frame(width: 6, height: 6)
                        Circle().fill(Color(hex: "FEBC2E").opacity(isHovered ? 1.0 : 0.4)).frame(width: 6, height: 6)
                        Circle().fill(Color(hex: "28C840").opacity(isHovered ? 1.0 : 0.4)).frame(width: 6, height: 6)
                    }
                }

                Spacer()

                Text(thumbnail.windowTitle.isEmpty ? thumbnail.appName : thumbnail.windowTitle)
                    .font(.system(size: 9, weight: .medium))
                    .foregroundStyle(isHovered ? .primary : .secondary)
                    .lineLimit(1)
                    .truncationMode(.middle)

                Spacer()

                // Click hint on hover
                if isHovered {
                    Image(systemName: "cursorarrow.click.2")
                        .font(.system(size: 8))
                        .foregroundStyle(.tertiary)
                        .transition(.opacity.combined(with: .scale))
                } else {
                    // Spacer for alignment
                    Color.clear.frame(width: 12, height: 8)
                }
            }
            .padding(.horizontal, 8)
            .padding(.vertical, 5)
            .background(
                isHovered
                    ? Color(hex: "6C5CE7").opacity(0.08)
                    : Color.clear
            )

            // Thumbnail image
            Image(nsImage: thumbnail.image)
                .resizable()
                .aspectRatio(contentMode: .fit)
                .frame(maxWidth: 180, maxHeight: 120)
                .clipShape(
                    UnevenRoundedRectangle(
                        topLeadingRadius: 0,
                        bottomLeadingRadius: 8,
                        bottomTrailingRadius: 8,
                        topTrailingRadius: 0
                    )
                )
        }
        .frame(width: 180)
        .background {
            RoundedRectangle(cornerRadius: 8, style: .continuous)
                .fill(.ultraThinMaterial)
                .overlay(
                    RoundedRectangle(cornerRadius: 8, style: .continuous)
                        .stroke(
                            isSelected
                                ? Color(hex: "6C5CE7").opacity(0.6)
                                : (isHovered ? Color(hex: "6C5CE7").opacity(0.25) : Color.white.opacity(0.06)),
                            lineWidth: isSelected ? 2 : 1
                        )
                )
        }
        .clipShape(RoundedRectangle(cornerRadius: 8, style: .continuous))
        .shadow(
            color: isHovered ? Color(hex: "6C5CE7").opacity(0.25) : .black.opacity(0.1),
            radius: isHovered ? 10 : 4,
            x: 0,
            y: isHovered ? 4 : 2
        )
        .scaleEffect(isHovered ? 1.05 : 1.0)
        .brightness(isHovered ? 0.04 : 0)
        .animation(.easeInOut(duration: 0.15), value: isHovered)
        .onHover { hovering in
            withAnimation(.easeInOut(duration: 0.15)) {
                isHovered = hovering
            }
            if hovering {
                NSCursor.pointingHand.push()
            } else {
                NSCursor.pop()
                isCloseHovered = false
            }
        }
        .onTapGesture {
            onTap?()
        }
    }
}
