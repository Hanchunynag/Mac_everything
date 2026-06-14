# Changelog

All notable MacEverything changes are recorded here. Each completed step should
be committed and pushed to `origin/main` with the version entry updated.

## 0.2.1 - 2026-06-14

Tag: `v0.2.1`

- Added `make` targets for build, test, package, and app launch.
- Updated packaging instructions to use `bash Scripts/package_app.sh --open`.
- Added `--open`, `--debug`, and `--release` options to the packaging script.
- Clears app bundle extended attributes before ad-hoc signing.

## 0.2.0 - 2026-06-14

Commit: `94474e1`

- Added Everything-style query operators.
- Supports `name:`, `path:`, `content:`, `ext:`, `size:`, `date:` / `modified:`, and `type:`.
- Added query compiler tests.
- Updated app packaging to ad-hoc sign the generated `.app`.

## 0.1.0 - 2026-06-14

Commit: `2ee8725`

- Created the initial native SwiftUI macOS app.
- Added Spotlight-backed search with `/usr/bin/mdfind`.
- Added result columns for name, path, kind, size, and modification time.
- Added keyboard-first open, reveal, refresh, and context-menu actions.
- Added basic `.app` packaging script.
