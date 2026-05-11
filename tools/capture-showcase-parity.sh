#!/usr/bin/env bash
set -euo pipefail

ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
SECTION="${1:-field}"
OUT="${2:-/tmp/showcase-capture.png}"
THEME="${3:-light}"
URL="http://127.0.0.1:4321/#${SECTION}"

if ! command -v osascript >/dev/null 2>&1; then
  echo "osascript not found; this helper requires macOS Safari." >&2
  exit 1
fi

if ! command -v screencapture >/dev/null 2>&1; then
  echo "screencapture not found; this helper requires macOS." >&2
  exit 1
fi

if [[ "$THEME" != "light" && "$THEME" != "dark" ]]; then
  echo "Theme must be 'light' or 'dark'." >&2
  exit 1
fi

mkdir -p "$(dirname "$OUT")"

run_safari_js() {
  local js="$1"

  osascript <<OSA
tell application "Safari"
  do JavaScript "$js" in front document
end tell
OSA
}

osascript <<OSA
tell application "Safari"
  activate
  if (count of windows) = 0 then
    make new document
  end if
  set bounds of front window to {40, 60, 1360, 980}
  set URL of front document to "$URL"
end tell
OSA

sleep 3

if run_safari_js "'ok'" >/dev/null 2>&1; then
  CAN_JS=1
else
  CAN_JS=0
fi

if [[ "$CAN_JS" -eq 1 ]]; then
  run_safari_js "
    try {
      localStorage.setItem('sb-theme', '$THEME');
    } catch (e) {}
    document.documentElement.dataset.theme = '$THEME';
    document.documentElement.dataset.themeMode = '$THEME';
    window.location.hash = '$SECTION';
    window.location.reload();
  " >/dev/null
elif [[ "$THEME" == "dark" ]]; then
  echo "Safari JavaScript automation is disabled. Enable 'Allow JavaScript from Apple Events' to capture dark-mode showcase reviews." >&2
  exit 1
else
  echo "Warning: Safari JavaScript automation is disabled; capturing the current light-mode showcase state." >&2
fi

sleep 3

if [[ "$CAN_JS" -eq 1 ]]; then
  run_safari_js "
    var target = document.getElementById('$SECTION');
    if (target) {
      target.scrollIntoView({ block: 'start' });
      window.scrollBy(0, -16);
    } else {
      window.scrollTo(0, 0);
    }
  " >/dev/null 2>&1 || true
fi

sleep 2

osascript -e 'tell application "Safari" to activate' >/dev/null
window_id="$(osascript -e 'tell application "Safari" to get id of front window')"
screencapture -x -l "$window_id" "$OUT"
echo "Captured $OUT"
