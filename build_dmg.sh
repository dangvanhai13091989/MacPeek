#!/bin/bash
set -euo pipefail

PROJECT_DIR="$(cd "$(dirname "$0")" && pwd)"
BUILD_DIR="${PROJECT_DIR}/build"
ARCHIVE_PATH="${BUILD_DIR}/MacPeek.xcarchive"
EXPORT_DIR="${BUILD_DIR}/export"
IDENTITY="${IDENTITY:-Developer ID Application: Hai Dang Van (84253AGHK5)}"
NOTARY_PROFILE="${NOTARY_PROFILE:-MacPeek-Notary}"
REPOSITORY="${REPOSITORY:-dangvanhai13091989/MacPeek}"

VERSION="$(/usr/libexec/PlistBuddy -c 'Print :CFBundleShortVersionString' "${PROJECT_DIR}/MacPeek/Info.plist")"
BUILD_NUMBER="$(/usr/libexec/PlistBuddy -c 'Print :CFBundleVersion' "${PROJECT_DIR}/MacPeek/Info.plist")"
DMG_FILE="${BUILD_DIR}/MacPeek.dmg"
UPDATE_DIR="${BUILD_DIR}/updates"

if [[ "${BUILD_DIR}" != "${PROJECT_DIR}/build" ]]; then
    echo "Refusing to clean an unexpected build directory: ${BUILD_DIR}" >&2
    exit 1
fi

echo "Building MacPeek ${VERSION} (${BUILD_NUMBER})"
rm -rf "${BUILD_DIR}"
mkdir -p "${BUILD_DIR}"

cd "${PROJECT_DIR}"
xcodegen generate

xcodebuild \
    -project MacPeek.xcodeproj \
    -scheme MacPeek \
    -configuration Release \
    -archivePath "${ARCHIVE_PATH}" \
    CODE_SIGN_IDENTITY="${IDENTITY}" \
    DEVELOPMENT_TEAM="84253AGHK5" \
    ENABLE_HARDENED_RUNTIME=YES \
    archive

xcodebuild \
    -exportArchive \
    -archivePath "${ARCHIVE_PATH}" \
    -exportPath "${EXPORT_DIR}" \
    -exportOptionsPlist "${PROJECT_DIR}/ExportOptions.plist"

APP_PATH="${EXPORT_DIR}/MacPeek.app"
if [[ ! -d "${APP_PATH}" ]]; then
    echo "Archive did not contain MacPeek.app" >&2
    exit 1
fi

codesign --verify --deep --strict --verbose=2 "${APP_PATH}"

APP_ZIP="${BUILD_DIR}/MacPeek-${VERSION}.zip"
ditto -c -k --keepParent "${APP_PATH}" "${APP_ZIP}"
xcrun notarytool submit "${APP_ZIP}" --keychain-profile "${NOTARY_PROFILE}" --wait
xcrun stapler staple "${APP_PATH}"
xcrun stapler validate "${APP_PATH}"

DMG_STAGING="${BUILD_DIR}/dmg-staging"
mkdir -p "${DMG_STAGING}"
ditto "${APP_PATH}" "${DMG_STAGING}/MacPeek.app"
ln -s /Applications "${DMG_STAGING}/Applications"

hdiutil create \
    -volname "MacPeek" \
    -srcfolder "${DMG_STAGING}" \
    -ov \
    -format UDZO \
    "${DMG_FILE}"

rm -rf "${DMG_STAGING}"
codesign --force --sign "${IDENTITY}" "${DMG_FILE}"
xcrun notarytool submit "${DMG_FILE}" --keychain-profile "${NOTARY_PROFILE}" --wait
xcrun stapler staple "${DMG_FILE}"
xcrun stapler validate "${DMG_FILE}"
spctl --assess --type open --context context:primary-signature --verbose=2 "${DMG_FILE}"

SPARKLE_BIN_DIR="$(dirname "$(find "${BUILD_DIR}" /Users/dangvanhai/Library/Developer/Xcode/DerivedData -path '*/SourcePackages/artifacts/sparkle/Sparkle/bin/generate_appcast' -print -quit)")"
if [[ ! -x "${SPARKLE_BIN_DIR}/generate_appcast" ]]; then
    echo "Sparkle release tools were not found" >&2
    exit 1
fi

mkdir -p "${UPDATE_DIR}"
cp "${DMG_FILE}" "${UPDATE_DIR}/MacPeek.dmg"
cp "${PROJECT_DIR}/RELEASE_NOTES.md" "${UPDATE_DIR}/MacPeek.md"
if [[ -f "${PROJECT_DIR}/appcast.xml" ]]; then
    cp "${PROJECT_DIR}/appcast.xml" "${UPDATE_DIR}/appcast.xml"
fi

"${SPARKLE_BIN_DIR}/generate_appcast" \
    --download-url-prefix "https://github.com/${REPOSITORY}/releases/download/v${VERSION}/" \
    --full-release-notes-url "https://github.com/${REPOSITORY}/releases/tag/v${VERSION}" \
    --link "https://dangvanhai13091989.github.io/MacPeek/" \
    --embed-release-notes \
    --maximum-versions 10 \
    --maximum-deltas 0 \
    -o "${PROJECT_DIR}/appcast.xml" \
    "${UPDATE_DIR}"

(cd "${BUILD_DIR}" && shasum -a 256 MacPeek.dmg > MacPeek.dmg.sha256)

echo "Release artifacts are ready:"
echo "  ${DMG_FILE}"
echo "  ${BUILD_DIR}/MacPeek.dmg.sha256"
echo "  ${PROJECT_DIR}/appcast.xml"
