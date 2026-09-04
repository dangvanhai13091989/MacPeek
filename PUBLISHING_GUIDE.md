# Publishing MacPeek

MacPeek is distributed as a free, open-source, Developer ID-signed application through GitHub Releases. Sparkle reads `appcast.xml` from the default branch and installs only updates carrying the configured EdDSA signature.

## One-time setup

1. Install XcodeGen.
2. Install a valid `Developer ID Application` certificate in the login Keychain.
3. Store Apple notarization credentials in Keychain under `MacPeek-Notary`:

   ```bash
   xcrun notarytool store-credentials "MacPeek-Notary" \
     --apple-id "YOUR_APPLE_ID" \
     --team-id "YOUR_TEAM_ID" \
     --password "YOUR_APP_SPECIFIC_PASSWORD"
   ```

4. Generate the Sparkle EdDSA key once using Sparkle's `generate_keys` tool. Keep the private key in Keychain and commit only the public key in `Info.plist`.

Never put an Apple password, private update key, certificate export, or GitHub token in this repository.

## Prepare a release

1. Update `MARKETING_VERSION` and `CURRENT_PROJECT_VERSION` in `project.yml`.
2. Update `CFBundleShortVersionString` and `CFBundleVersion` in `MacPeek/Info.plist`.
3. Update `RELEASE_NOTES.md`.
4. Run a clean build.
5. Run the signed release pipeline:

   ```bash
   ./build_dmg.sh
   ```

The script archives and exports the app using `ExportOptions.plist` so Sparkle's nested helpers receive valid Developer ID signatures. It then verifies the nested signatures, notarizes and staples the app, creates and notarizes `build/MacPeek.dmg`, and generates a signed `appcast.xml`.

## Publish

Commit and push the source and newly generated appcast before publishing the release:

```bash
git add .
git commit -m "Release MacPeek VERSION"
git push
gh release create "vVERSION" \
  build/MacPeek.dmg \
  build/MacPeek.dmg.sha256 \
  --title "MacPeek VERSION" \
  --notes-file RELEASE_NOTES.md
```

The stable public download URL is:

```text
https://github.com/dangvanhai13091989/MacPeek/releases/latest/download/MacPeek.dmg
```

## Verify

```bash
codesign --verify --deep --strict build/export/MacPeek.app
xcrun stapler validate build/MacPeek.dmg
spctl --assess --type open --context context:primary-signature --verbose=2 build/MacPeek.dmg
shasum -a 256 -c build/MacPeek.dmg.sha256
```

Install the previous public version when testing a real Sparkle upgrade. A newly added updater cannot update installations that predate Sparkle, so users of version 1.0.0 must manually install version 1.1.0 once.
