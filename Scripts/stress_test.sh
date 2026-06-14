#!/usr/bin/env bash
set -euo pipefail

ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
cd "$ROOT_DIR"

echo "== clean test run =="
swift package clean
swift test

echo "== debug build =="
swift build

echo "== release build =="
swift build -c release

echo "== repeated test loop =="
for run in 1 2 3; do
  echo "-- loop $run --"
  swift test
done

echo "== launch smoke =="
swift run MacEverything &
pid=$!
sleep 3
kill "$pid" 2>/dev/null || true
wait "$pid" 2>/dev/null || true

echo "stress test complete"
