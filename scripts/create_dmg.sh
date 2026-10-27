#!/bin/zsh
# Shared presentation for release and unsigned preview disk images.
set -euo pipefail
PROJECT_ROOT="${0:A:h:h}"
if (( $# < 2 || $# > 3 )); then
  echo "Usage: $0 STAGING_DIRECTORY OUTPUT.dmg [VOLUME_NAME]" >&2
  exit 2
fi
STAGING="${1:A}"
DMG="${2:A}"
VOLUME_NAME="${3:-Auto-research agent}"
if ! command -v create-dmg >/dev/null 2>&1; then
  echo 'Install create-dmg first: brew install create-dmg (tested with 1.3.0).' >&2
  exit 1
fi
[[ -d "$STAGING/Auto Research.app" ]] || { echo 'Missing Auto Research.app in staging.' >&2; exit 1; }
[[ -f "$STAGING/Read me.txt" ]] || { echo 'Missing Read me.txt in staging.' >&2; exit 1; }
[[ -L "$STAGING/Applications" && "$(readlink "$STAGING/Applications")" == /Applications ]] || { echo 'Missing Applications shortcut in staging.' >&2; exit 1; }
[[ ! -e "$DMG" ]] || { echo "Output already exists: $DMG" >&2; exit 1; }
mkdir -p "${DMG:h}"
TEMP_DIR=$(mktemp -d "${TMPDIR:-/tmp/}auto-research-dmg.XXXXXX")
trap 'rm -rf "$TEMP_DIR"' EXIT
MODULE_CACHE="${CLANG_MODULE_CACHE_PATH:-$PROJECT_ROOT/build-cache/clang}"
mkdir -p "$MODULE_CACHE"
swift -module-cache-path "$MODULE_CACHE" "$PROJECT_ROOT/scripts/make_dmg_background.swift" "$TEMP_DIR/background.tiff"
create-dmg \
  --volname "$VOLUME_NAME" \
  --background "$TEMP_DIR/background.tiff" \
  --window-pos 200 120 \
  --window-size 660 488 \
  --icon-size 80 \
  --text-size 14 \
  --icon 'Auto Research.app' 160 235 \
  --hide-extension 'Auto Research.app' \
  --icon 'Applications' 500 235 \
  --icon 'Read me.txt' 330 375 \
  --format UDZO \
  "$DMG" "$STAGING"
