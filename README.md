# MacEverything

MacEverything is a small native macOS file search app inspired by Everything on Windows.
It keeps the familiar workflow: type a filename, get a fast table of results, press Enter
to open, or Command-Enter to reveal in Finder.

## Current MVP

- Native SwiftUI macOS app.
- Spotlight-backed search through `/usr/bin/mdfind`.
- Name, path, and content search modes.
- Everything-style query operators.
- Scope filters for all indexed locations, Home, Desktop, Documents, and Downloads.
- Result columns for name, path, kind, size, and modification time.
- Keyboard-first interactions: Enter opens, Command-Enter reveals, Command-R refreshes.
- Context menu actions for opening, revealing, and copying a path.

Version history is recorded in [CHANGELOG.md](CHANGELOG.md). Each completed
development step should update that file, commit, and push to GitHub.

## Testing

```bash
make test
make stress
```

See [TESTING.md](TESTING.md) for the full automated and manual test checklist.
See [DISTRIBUTION.md](DISTRIBUTION.md) for demo packaging and release options.

## Query syntax

Plain words are combined with AND, so `report final` searches for both words.
Use quotes for a phrase with spaces: `"final report"`.

Supported operators:

- `name:paper` or `n:paper`
- `path:Downloads` or `p:Downloads`
- `content:invoice` or `text:invoice`
- `ext:pdf` or `ext:pdf,docx`
- `size:>10mb`, `size:<500kb`, `size:>=1gb`
- `date:today`, `date:yesterday`, `date:week`, `date:month`, `date:year`
- `date:>2026-01-01` or `modified:<2026-06-01`
- `type:folder` or `type:file`

Examples:

```text
论文 ext:pdf
path:Downloads ext:zip size:>100mb
name:report date:week
content:"orbital elements" ext:pdf
```

## Run

```bash
make run-app
```

The first build may take a moment. This builds the app artifacts and opens the
signed app bundle at `.build/MacEverything.app`.

## Package

```bash
bash Scripts/package_app.sh --release
```

Generated artifacts:

- `.build/MacEverything.app`: signed app bundle for one-click local launch.
- `.build/MacEverything.command`: verified one-click local launcher.
- `.build/Standalone/MacEverything`: standalone executable used by the launcher.

Use `.build/MacEverything.command` only as a fallback if local macOS security
policy blocks the development-signed `.app`.

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
- Add a dedicated local file indexer using FSEvents for locations where Spotlight is not enough.
- Add preferences for hotkey, ignored folders, and launch at login.
