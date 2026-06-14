# Testing

MacEverything uses three layers of local testing.

## Quick Test

```bash
make test
```

This runs the Swift test suite:

- Query compiler tests for plain words, search modes, operators, quoting, escaping,
  size filters, date filters, and type filters.
- Search service stress tests for zero limits, bounded result limits, and concurrent
  Spotlight-backed searches.

## Stress Test

```bash
make stress
```

This runs:

- A clean `swift test`.
- Debug and release builds.
- Three repeated test loops.
- A short launch smoke test using `swift run MacEverything`.

The stress suite is intended to catch regressions such as query compiler breakage,
large-result search deadlocks, and launch failures.

## Manual UI Test

```bash
make run-app
```

Then verify:

- The window appears and the search field accepts typing immediately.
- The app shows the MacEverything icon in Finder, Dock, and Command-Tab.
- `README` returns results.
- `README ext:md` filters to Markdown files.
- `path:Downloads`, `size:>10mb`, `date:today`, and `type:folder` do not crash.
- Enter opens the selected result.
- Command-Enter reveals the selected result in Finder.
- Command-R refreshes the current query.

Current note: `make run-app` opens `.build/MacEverything.app`. The command
launcher remains available at `.build/MacEverything.command` as a fallback.
