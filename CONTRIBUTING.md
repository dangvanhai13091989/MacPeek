# Contributing to MacPeek

Thank you for helping improve MacPeek.

## Before opening an issue

- Search existing issues and test the latest release.
- Include your macOS version, Mac model, Dock position, and monitor arrangement.
- Describe expected and actual behavior with concise reproduction steps.
- Do not include sensitive screen contents in screenshots or logs.

## Development setup

Install Xcode and XcodeGen, then run:

```bash
xcodegen generate
xcodebuild -project MacPeek.xcodeproj -scheme MacPeek -configuration Debug build CODE_SIGNING_ALLOWED=NO
```

Grant Accessibility and Screen Recording permission to the locally built application when testing Dock previews.

## Pull requests

- Keep changes focused and explain the user-facing behavior.
- Update `project.yml` when changing project configuration.
- Add or update localized strings for user-visible text. English is the required fallback.
- Verify a clean Debug build before opening the pull request.
- Do not commit signing certificates, private keys, passwords, notarization credentials, or captured user content.

By contributing, you agree that your contribution is licensed under GPL-3.0.
