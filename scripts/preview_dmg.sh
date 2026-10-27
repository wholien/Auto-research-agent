#!/bin/zsh
# Package an existing app without building, signing, notarizing, or launching it.
set -euo pipefail
PROJECT_ROOT="${0:A:h:h}"
if (( $# != 2 )); then
  echo "Usage: $0 PATH_TO_APP OUTPUT.dmg" >&2
  exit 2
fi
APP="${1:A}"
DMG="${2:A}"
[[ -f "$APP/Contents/Info.plist" ]] || { echo "Not an app bundle: $APP" >&2; exit 1; }
[[ ! -e "$DMG" ]] || { echo "Output already exists: $DMG" >&2; exit 1; }
mkdir -p "${DMG:h}"
STAGING=$(mktemp -d "${DMG:h}/dmg-preview.XXXXXX")
trap 'rm -rf "$STAGING"' EXIT
ditto "$APP" "$STAGING/Auto Research.app"
ln -s /Applications "$STAGING/Applications"
cp "$PROJECT_ROOT/Resources/DMG-Readme.txt" "$STAGING/Read me.txt"
"$PROJECT_ROOT/scripts/create_dmg.sh" "$STAGING" "$DMG" 'Auto Research Preview'
hdiutil verify "$DMG"
echo "Preview only (disk image is not signed or notarized): $DMG"
