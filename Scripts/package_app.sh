#!/usr/bin/env bash
set -euo pipefail

ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
CONFIGURATION="release"
XCODE_CONFIGURATION="Release"
SHOULD_OPEN=0

for argument in "$@"; do
  case "$argument" in
    --debug)
      CONFIGURATION="debug"
      XCODE_CONFIGURATION="Debug"
      ;;
    --release)
      CONFIGURATION="release"
      XCODE_CONFIGURATION="Release"
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
COMMAND_PATH="$ROOT_DIR/.build/MacEverything.command"
DERIVED_DATA_DIR="$ROOT_DIR/.build/AppDerived"
BUILT_APP_DIR="$DERIVED_DATA_DIR/Build/Products/$XCODE_CONFIGURATION/MacEverything.app"
STANDALONE_DIR="$ROOT_DIR/.build/Standalone"
STANDALONE_EXECUTABLE="$STANDALONE_DIR/MacEverything"

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
IDENTITY="$(signing_identity)"

swift build -c "$CONFIGURATION" >/dev/null

xcodebuild \
  -project MacEverything.xcodeproj \
  -scheme MacEverything \
  -configuration "$XCODE_CONFIGURATION" \
  -destination 'platform=macOS' \
  -derivedDataPath "$DERIVED_DATA_DIR" \
  DEVELOPMENT_TEAM=Z9B2G939GK \
  build >/dev/null

rm -rf "$APP_DIR"
cp -R "$BUILT_APP_DIR" "$APP_DIR"
xattr -cr "$APP_DIR" 2>/dev/null || true
codesign --force --sign "$IDENTITY" "$APP_DIR/Contents/MacOS/MacEverything" >/dev/null
codesign --force --deep --sign "$IDENTITY" "$APP_DIR" >/dev/null

rm -rf "$STANDALONE_DIR"
mkdir -p "$STANDALONE_DIR"
cp "$ROOT_DIR/.build/$CONFIGURATION/MacEverything" "$STANDALONE_EXECUTABLE"
chmod +x "$STANDALONE_EXECUTABLE"

cat > "$COMMAND_PATH" <<'EOF'
#!/usr/bin/env bash
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
exec "$SCRIPT_DIR/Standalone/MacEverything"
EOF
chmod +x "$COMMAND_PATH"

echo "$APP_DIR"
echo "$COMMAND_PATH"
echo "Signed with: $IDENTITY"

if [[ "$SHOULD_OPEN" -eq 1 ]]; then
  open "$APP_DIR"
fi
