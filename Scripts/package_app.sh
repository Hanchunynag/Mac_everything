#!/usr/bin/env bash
set -euo pipefail

ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
CONFIGURATION="release"
SHOULD_OPEN=0

for argument in "$@"; do
  case "$argument" in
    --debug)
      CONFIGURATION="debug"
      ;;
    --release)
      CONFIGURATION="release"
      ;;
    --open)
      SHOULD_OPEN=1
      ;;
    *)
      echo "Unknown argument: $argument" >&2
      echo "Usage: bash Scripts/package_app.sh [--debug|--release] [--open]" >&2
      exit 2
      ;;
  esac
done

APP_DIR="$ROOT_DIR/.build/MacEverything.app"
CONTENTS_DIR="$APP_DIR/Contents"
MACOS_DIR="$CONTENTS_DIR/MacOS"
RESOURCES_DIR="$CONTENTS_DIR/Resources"

signing_identity() {
  local identity
  identity="$(security find-identity -v -p codesigning 2>/dev/null \
    | sed -n 's/.*"\(Apple Development:[^"]*\)".*/\1/p' \
    | head -n 1)"

  if [[ -n "$identity" ]]; then
    printf '%s' "$identity"
  else
    printf '-'
  fi
}

cd "$ROOT_DIR"
swift build -c "$CONFIGURATION"

rm -rf "$APP_DIR"
mkdir -p "$MACOS_DIR" "$RESOURCES_DIR"

cp "$ROOT_DIR/.build/$CONFIGURATION/MacEverything" "$MACOS_DIR/MacEverything"
cp "$ROOT_DIR/Resources/Info.plist" "$CONTENTS_DIR/Info.plist"
printf 'APPL????' > "$CONTENTS_DIR/PkgInfo"
chmod +x "$MACOS_DIR/MacEverything"

xattr -cr "$APP_DIR" 2>/dev/null || true
IDENTITY="$(signing_identity)"
codesign --force --deep --options runtime --sign "$IDENTITY" "$APP_DIR" >/dev/null

echo "$APP_DIR"
echo "Signed with: $IDENTITY"

if [[ "$SHOULD_OPEN" -eq 1 ]]; then
  echo "Launching executable directly. The hand-built .app bundle is experimental."
  exec "$ROOT_DIR/.build/$CONFIGURATION/MacEverything"
fi
