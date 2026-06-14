# Changelog

All notable MacEverything changes are recorded here. Each completed step should
be committed and pushed to `origin/main` with the version entry updated.

## 0.3.0 - 2026-06-14

Tag: `v0.3.0`

- Added broader query compiler coverage for modes, operators, quoting, escaping, dates, and size filters.
- Added async search service stress tests for limits and concurrent searches.
- Added `Scripts/stress_test.sh` and `make stress` for repeatable local pressure testing.
- Added `TESTING.md` with quick, stress, and manual UI test instructions.
- Fixed potential `mdfind` pipe deadlock by reading output while the child process is running and terminating after the requested result limit.
- Avoids repeatedly stealing keyboard focus after the search field has received its initial focus.

## 0.2.3 - 2026-06-14

Tag: `v0.2.3`

- Replaced the SwiftUI search box with a native `NSTextField` wrapper.
- Activates the app and makes the search field first responder on launch.
- Fixes the search box not accepting keyboard input when launched through `swift run`.

## 0.2.2 - 2026-06-14

Tag: `v0.2.2`

- Changed `make run-app` to launch through `swift run`, which is the reliable local test path for the SwiftPM app.
- Packaging now prefers an installed Apple Development signing identity.
- Added `PkgInfo` to the generated app bundle.
- Packaging output now reports which signing identity was used.
- Documented that the hand-built `.app` is experimental until a standard Xcode app target is added.
- Changed `bash Scripts/package_app.sh --open` to launch the built executable directly instead of using the experimental `.app` bundle.

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
