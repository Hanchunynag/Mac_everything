#!/usr/bin/env bash
set -euo pipefail

ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
VERSION="${1:-0.3.3}"
DIST_DIR="$ROOT_DIR/.build/dist"
APP_DIR="$ROOT_DIR/.build/MacEverything.app"
ZIP_PATH="$DIST_DIR/MacEverything-$VERSION-macOS.zip"

cd "$ROOT_DIR"
bash Scripts/package_app.sh --release >/dev/null

rm -rf "$DIST_DIR"
mkdir -p "$DIST_DIR"
ditto -c -k --keepParent "$APP_DIR" "$ZIP_PATH"

echo "$ZIP_PATH"
