# MacPeek

![macOS 14+](https://img.shields.io/badge/macOS-14%2B-111111?logo=apple)
![Swift 5.9](https://img.shields.io/badge/Swift-5.9-F05138?logo=swift&logoColor=white)
![License GPL-3.0](https://img.shields.io/badge/license-GPL--3.0-blue)
![Latest release](https://img.shields.io/github/v/release/dangvanhai13091989/MacPeek)

MacPeek adds Windows-style window previews to the macOS Dock. Hover over a running app, see its open windows, then click a thumbnail to switch directly to it.

**[Download the latest notarized DMG](https://github.com/dangvanhai13091989/MacPeek/releases/latest/download/MacPeek.dmg)** · [Website](https://macpeek.pages.dev) · [Support development](https://vanhaimagic.gumroad.com/l/macpeek)

MacPeek is free and open source. Donations are optional and never unlock additional features.

## Features

- Dock window previews after a short hover delay
- Multi-window grid with pagination
- Click a thumbnail to focus that exact window
- Close individual windows from the preview
- Bottom, left, and right Dock positioning
- Multi-monitor support
- Launch at login
- Signed automatic updates through Sparkle and GitHub Releases
- 18 localizations with an English fallback
- No analytics, advertising, or screen-content uploads

## Installation

1. Download [`MacPeek.dmg`](https://github.com/dangvanhai13091989/MacPeek/releases/latest/download/MacPeek.dmg).
2. Open it and drag MacPeek into Applications.
3. Launch MacPeek and follow the permission setup.

The release is signed with a Developer ID certificate and notarized by Apple. MacPeek is distributed outside the Mac App Store because its Dock integration depends on Accessibility APIs that are incompatible with the App Store sandbox.

## Permissions

MacPeek requires two macOS permissions:

- **Accessibility** identifies the Dock item under the pointer and raises or closes the selected window.
- **Screen Recording** creates local thumbnails of visible windows.

Thumbnails are held briefly in memory, are never written to disk, and are never uploaded. See [PRIVACY.md](PRIVACY.md) for details.

## Automatic updates

MacPeek uses [Sparkle 2](https://sparkle-project.org/) to check the signed [`appcast.xml`](appcast.xml) once per day. Every update archive is protected by an EdDSA signature in addition to Apple's Developer ID signature and notarization. A manual **Check for Updates…** command is available from the menu bar.

## Building from source

Requirements:

- macOS 14 or later
- Xcode 16 or later
- [XcodeGen](https://github.com/yonaskolb/XcodeGen)

```bash
git clone https://github.com/dangvanhai13091989/MacPeek.git
cd MacPeek
xcodegen generate
xcodebuild -project MacPeek.xcodeproj -scheme MacPeek -configuration Debug build CODE_SIGNING_ALLOWED=NO
```

The Xcode project is generated from [`project.yml`](project.yml). Avoid editing generated project settings without updating that file.

## Architecture

- `DockHoverMonitor` uses the macOS Accessibility API to detect Dock hover events.
- `WindowCaptureService` enumerates windows and captures thumbnails with ScreenCaptureKit.
- `PopupWindowController` hosts the SwiftUI preview in a nonactivating floating panel.
- `UpdateManager` owns the Sparkle update lifecycle.

## Contributing

Bug reports, pull requests, performance profiling, and translations are welcome. Read [CONTRIBUTING.md](CONTRIBUTING.md) before submitting a change. Please report security issues using the process in [SECURITY.md](SECURITY.md).

## Support

If MacPeek saves you time, you can [support ongoing development](https://vanhaimagic.gumroad.com/l/macpeek). You can also help by starring the repository, reporting reproducible bugs, or improving a translation.

## License

MacPeek is licensed under the [GNU General Public License v3.0](LICENSE).
