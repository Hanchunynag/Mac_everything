# MacEverything

MacEverything is a small native macOS file search app inspired by Everything on Windows.
It keeps the familiar workflow: type a filename, get a fast table of results, press Enter
to open, or Command-Enter to reveal in Finder.

## Current MVP

- Native SwiftUI macOS app.
- Spotlight-backed search through `/usr/bin/mdfind`.
- Name, path, and content search modes.
- Scope filters for all indexed locations, Home, Desktop, Documents, and Downloads.
- Result columns for name, path, kind, size, and modification time.
- Keyboard-first interactions: Enter opens, Command-Enter reveals, Command-R refreshes.
- Context menu actions for opening, revealing, and copying a path.

## Run

```bash
swift run MacEverything
```

The first build may take a moment. Once the app window opens, type in the search field.

## Package as an app

```bash
Scripts/package_app.sh
open .build/MacEverything.app
```

The generated app lives at `.build/MacEverything.app`.

## macOS Permissions

This MVP uses Spotlight, so it can only return files that Spotlight can see and index.
For best results, grant the terminal or built app Full Disk Access:

1. Open System Settings.
2. Go to Privacy & Security.
3. Open Full Disk Access.
4. Add Terminal, iTerm, or the packaged app.

If Spotlight indexing is disabled for a folder, results from that folder will be missing.

## Roadmap

- Package as a signed `.app` bundle.
- Add custom folder scopes.
- Add Everything-like query operators such as `ext:pdf`, `size:>10mb`, and date filters.
- Add a dedicated local file indexer using FSEvents for locations where Spotlight is not enough.
- Add preferences for hotkey, ignored folders, and launch at login.
