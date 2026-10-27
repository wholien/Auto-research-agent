# DMG installation layout

The disk image opens in Finder with Auto Research on the left, an arrow in the
background, and the Applications shortcut on the right. The readme remains
available below the installation row.

## Requirements

Use macOS with the Xcode command line tools and a logged-in Finder session.
Install [create-dmg](https://github.com/create-dmg/create-dmg) with
`brew install create-dmg` (tested with 1.3.0). macOS may ask the terminal for
permission to control Finder. A headless build that skips Finder customization
will not validate this layout.

## Preview without release credentials

From the repository's configured workspace, package an existing app bundle:

```sh
./scripts/preview_dmg.sh '/path/to/Auto Research.app' "$PWD/build/layout-preview.dmg"
open build/layout-preview.dmg
```

This copies the supplied app into temporary staging, adds the same readme and
layout used by the release, and verifies the resulting disk image. It does not
build, launch, re-sign, or notarize the app. The preview disk image is unsigned
and has a distinct volume name, `Auto Research Preview`. Choose a new output
filename for each iteration; existing output files are never overwritten.

## Release and artwork

`scripts/package_dmg.sh` uses `scripts/create_dmg.sh` after app notarization and
before disk-image signing and notarization. Release credentials and the existing
workspace requirements still apply. Remove or archive a previous output before
rebuilding the same release version.

`scripts/make_dmg_background.swift` is the editable artwork source. It produces
a TIFF with 1x and 2x representations for Retina displays. Its coordinates and
the icon positions in `create_dmg.sh` are in points. Finder stores the window
settings and icon positions in the image's hidden `.DS_Store`; the background
is copied into `.background` by create-dmg.

## Visual verification

- Mount the preview and check that the instruction, arrow, icons, and labels are
  legible, aligned, and fully visible without scrolling.
- Open the readme and confirm the Applications shortcut points to `/Applications`.
- Eject and reopen the image to confirm the saved presentation survives remounting.
- For an official release, run the existing signing, notarization, stapling, and
  disk-image verification steps in `package_dmg.sh`.
