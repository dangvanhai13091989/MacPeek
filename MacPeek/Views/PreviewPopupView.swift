import SwiftUI

/// A SwiftUI view that displays window thumbnail previews with macOS-native styling.
/// Supports two modes:
/// - **Single window**: Large preview with app name
/// - **Multi window**: Grid layout with scroll and page indicator for many windows
///
/// Features rounded corners, drop shadow, blur background, and click-to-activate.
struct PreviewPopupView: View {
    let thumbnails: [WindowThumbnail]
    var onTapWindow: ((WindowThumbnail) -> Void)?
    var onCloseWindow: ((WindowThumbnail) -> Void)?

    @State private var isVisible = false
    @State private var hoveredWindowID: CGWindowID?
    @State private var currentPage: Int = 0

    private var isSingleWindow: Bool { thumbnails.count == 1 }

    /// Maximum thumbnails visible per page in grid mode
    private let maxPerPage: Int = 6
    /// How many columns in grid
    private let gridColumns: Int = 3

    /// Total number of pages for pagination
    private var totalPages: Int {
        max(1, (thumbnails.count + maxPerPage - 1) / maxPerPage)
    }

    /// Thumbnails for the current page
    private var currentPageThumbnails: [WindowThumbnail] {
        let start = currentPage * maxPerPage
        let end = min(start + maxPerPage, thumbnails.count)
        guard start < thumbnails.count else { return [] }
        return Array(thumbnails[start..<end])
    }

    /// Number of windows not shown on current page
    private var hiddenWindowCount: Int {
        let shown = min(maxPerPage, thumbnails.count - currentPage * maxPerPage)
        return max(0, thumbnails.count - (currentPage * maxPerPage + shown))
    }

    var body: some View {
        if isSingleWindow, let thumbnail = thumbnails.first {
            singleWindowView(thumbnail: thumbnail)
        } else {
            multiWindowView
        }
    }

    // MARK: - Single Window Mode

    private func singleWindowView(thumbnail: WindowThumbnail) -> some View {
        VStack(spacing: 0) {
            // App name header
            HStack(spacing: 6) {
                if let appIcon = getAppIcon(for: thumbnail.appName) {
                    Image(nsImage: appIcon)
                        .resizable()
                        .aspectRatio(contentMode: .fit)
                        .frame(width: 16, height: 16)
                }

                Text(thumbnail.appName)
                    .font(.system(size: 12, weight: .semibold))
                    .foregroundStyle(.primary)
                    .lineLimit(1)

                Spacer()

                if !thumbnail.windowTitle.isEmpty && thumbnail.windowTitle != thumbnail.appName {
                    Text(thumbnail.windowTitle)
                        .font(.system(size: 10, weight: .regular))
                        .foregroundStyle(.secondary)
                        .lineLimit(1)
                        .truncationMode(.middle)
                }

                if hoveredWindowID == thumbnail.windowID {
                    Image(systemName: "cursorarrow.click.2")
                        .font(.system(size: 10))
                        .foregroundStyle(.tertiary)
                        .transition(.opacity.combined(with: .scale))
                }
            }
            .padding(.horizontal, 12)
            .padding(.vertical, 8)

            Image(nsImage: thumbnail.image)
                .resizable()
                .aspectRatio(contentMode: .fit)
                .frame(maxWidth: 360, maxHeight: 240)
                .clipShape(
                    UnevenRoundedRectangle(
                        topLeadingRadius: 0,
                        bottomLeadingRadius: 10,
                        bottomTrailingRadius: 10,
                        topTrailingRadius: 0
                    )
                )
        }
        .frame(minWidth: 200)
        .background {
            VisualEffectBlur(material: .hudWindow, blendingMode: .behindWindow)
                .clipShape(RoundedRectangle(cornerRadius: 12, style: .continuous))
        }
        .clipShape(RoundedRectangle(cornerRadius: 12, style: .continuous))
        .shadow(color: .black.opacity(0.3), radius: 16, x: 0, y: 8)
        .shadow(color: .black.opacity(0.15), radius: 4, x: 0, y: 2)
        .scaleEffect(hoveredWindowID == thumbnail.windowID ? 1.02 : (isVisible ? 1.0 : 0.95))
        .brightness(hoveredWindowID == thumbnail.windowID ? 0.03 : 0)
        .opacity(isVisible ? 1.0 : 0.0)
        .onAppear {
            withAnimation(.easeOut(duration: 0.2)) {
                isVisible = true
            }
        }
        .onHover { hovering in
            withAnimation(.easeInOut(duration: 0.15)) {
                hoveredWindowID = hovering ? thumbnail.windowID : nil
            }
            if hovering { NSCursor.pointingHand.push() } else { NSCursor.pop() }
        }
        .onTapGesture {
            onTapWindow?(thumbnail)
        }
    }

    // MARK: - Multi Window Mode

    private var multiWindowView: some View {
        VStack(spacing: 0) {
            // Header with app name + window count + page indicator
            HStack(spacing: 6) {
                if let firstThumb = thumbnails.first,
                   let appIcon = getAppIcon(for: firstThumb.appName) {
                    Image(nsImage: appIcon)
                        .resizable()
                        .aspectRatio(contentMode: .fit)
                        .frame(width: 16, height: 16)
                }

                Text(thumbnails.first?.appName ?? "")
                    .font(.system(size: 12, weight: .semibold))
                    .foregroundStyle(.primary)
                    .lineLimit(1)

                Spacer()

                // Window count badge
                Text(windowCountText)
                    .font(.system(size: 10, weight: .medium))
                    .foregroundStyle(.secondary)
                    .padding(.horizontal, 8)
                    .padding(.vertical, 3)
                    .background(.quaternary.opacity(0.5), in: Capsule())

                // Page navigation (only if multiple pages)
                if totalPages > 1 {
                    HStack(spacing: 4) {
                        Button(action: {
                            withAnimation(.easeInOut(duration: 0.2)) {
                                currentPage = max(0, currentPage - 1)
                            }
                        }) {
                            Image(systemName: "chevron.left")
                                .font(.system(size: 9, weight: .bold))
                                .foregroundStyle(currentPage > 0 ? .primary : .quaternary)
                        }
                        .buttonStyle(.plain)
                        .disabled(currentPage == 0)

                        Text("\(currentPage + 1)/\(totalPages)")
                            .font(.system(size: 9, weight: .medium, design: .rounded))
                            .foregroundStyle(.tertiary)
                            .frame(minWidth: 24)

                        Button(action: {
                            withAnimation(.easeInOut(duration: 0.2)) {
                                currentPage = min(totalPages - 1, currentPage + 1)
                            }
                        }) {
                            Image(systemName: "chevron.right")
                                .font(.system(size: 9, weight: .bold))
                                .foregroundStyle(currentPage < totalPages - 1 ? .primary : .quaternary)
                        }
                        .buttonStyle(.plain)
                        .disabled(currentPage >= totalPages - 1)
                    }
                    .padding(.horizontal, 6)
                    .padding(.vertical, 3)
                    .background(.quaternary.opacity(0.3), in: Capsule())
                }
            }
            .padding(.horizontal, 12)
            .padding(.vertical, 8)

            // Grid of thumbnails (current page)
            LazyVGrid(columns: gridLayout, spacing: 8) {
                ForEach(Array(currentPageThumbnails.enumerated()), id: \.element.windowID) { index, thumb in
                    WindowThumbnailCard(
                        thumbnail: thumb,
                        isSelected: hoveredWindowID == thumb.windowID,
                        showCloseButton: true,
                        onTap: {
                            onTapWindow?(thumb)
                        },
                        onClose: {
                            onCloseWindow?(thumb)
                        }
                    )
                    .transition(.opacity.animation(.easeOut(duration: 0.2).delay(Double(index) * 0.03)))
                }
            }
            .padding(.horizontal, 10)
            .padding(.bottom, totalPages > 1 ? 6 : 10)
            .id(currentPage) // Force re-render on page change

            // Overflow indicator + dot page indicators
            if totalPages > 1 {
                VStack(spacing: 6) {
                    // Overflow badge for remaining windows
                    if hiddenWindowCount > 0 {
                        Text(L10n.tr("preview.more_windows", hiddenWindowCount))
                            .font(.system(size: 10, weight: .medium, design: .rounded))
                            .foregroundStyle(.secondary)
                            .padding(.horizontal, 10)
                            .padding(.vertical, 3)
                            .background(.ultraThinMaterial, in: Capsule())
                    }

                    // Dot indicators
                    HStack(spacing: 5) {
                        ForEach(0..<totalPages, id: \.self) { page in
                            Circle()
                                .fill(page == currentPage ? Color(hex: "6C5CE7") : Color.gray.opacity(0.35))
                                .frame(width: 6, height: 6)
                                .scaleEffect(page == currentPage ? 1.3 : 1.0)
                                .animation(.easeInOut(duration: 0.2), value: currentPage)
                                .onTapGesture {
                                    withAnimation(.easeInOut(duration: 0.2)) {
                                        currentPage = page
                                    }
                                }
                        }
                    }
                }
                .padding(.bottom, 10)
            }
        }
        .frame(minWidth: 220, maxWidth: dynamicMaxWidth)
        .background {
            VisualEffectBlur(material: .hudWindow, blendingMode: .behindWindow)
                .clipShape(RoundedRectangle(cornerRadius: 12, style: .continuous))
        }
        .clipShape(RoundedRectangle(cornerRadius: 12, style: .continuous))
        .shadow(color: .black.opacity(0.3), radius: 16, x: 0, y: 8)
        .shadow(color: .black.opacity(0.15), radius: 4, x: 0, y: 2)
        .scaleEffect(isVisible ? 1.0 : 0.95)
        .opacity(isVisible ? 1.0 : 0.0)
        .onAppear {
            withAnimation(.easeOut(duration: 0.25)) {
                isVisible = true
            }
        }
    }

    // MARK: - Layout Helpers

    private var gridLayout: [GridItem] {
        let count = currentPageThumbnails.count
        let cols = count <= 2 ? count : min(gridColumns, count)
        return Array(repeating: GridItem(.fixed(180), spacing: 8), count: max(1, cols))
    }

    /// Dynamic max width based on actual column count
    private var dynamicMaxWidth: CGFloat {
        let count = currentPageThumbnails.count
        let cols = count <= 2 ? count : min(gridColumns, count)
        return CGFloat(cols) * 188 + 24 // 180 width + 8 spacing + padding
    }

    private var windowCountText: String {
        if thumbnails.count == 1 {
            return L10n.tr("preview.single_window")
        }
        return L10n.tr("preview.windows_count", thumbnails.count)
    }

    // MARK: - Helpers

    private func getAppIcon(for appName: String) -> NSImage? {
        let workspace = NSWorkspace.shared
        let runningApps = workspace.runningApplications
        if let app = runningApps.first(where: { $0.localizedName == appName }) {
            return app.icon
        }
        return nil
    }
}

// MARK: - NSVisualEffectView Bridge

/// A SwiftUI wrapper for NSVisualEffectView to provide native macOS blur effects.
struct VisualEffectBlur: NSViewRepresentable {
    let material: NSVisualEffectView.Material
    let blendingMode: NSVisualEffectView.BlendingMode

    func makeNSView(context: Context) -> NSVisualEffectView {
        let view = NSVisualEffectView()
        view.material = material
        view.blendingMode = blendingMode
        view.state = .active
        view.isEmphasized = true
        return view
    }

    func updateNSView(_ nsView: NSVisualEffectView, context: Context) {
        nsView.material = material
        nsView.blendingMode = blendingMode
    }
}
