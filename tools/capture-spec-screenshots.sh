#!/usr/bin/env bash
set -euo pipefail

ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
OUT_DIR="$ROOT_DIR/docs/component-specs/_screenshots"
MODE="${1:-all}"
if [[ $# -gt 0 ]]; then
  shift
fi
SLUG_ARGS=("$@")

mkdir -p "$OUT_DIR"

if ! command -v osascript >/dev/null 2>&1; then
  echo "osascript not found; this helper requires macOS Safari." >&2
  exit 1
fi

if ! command -v screencapture >/dev/null 2>&1; then
  echo "screencapture not found; this helper requires macOS." >&2
  exit 1
fi

if [[ "$MODE" != "seed" && "$MODE" != "high-risk" && "$MODE" != "all" ]]; then
  SLUG_ARGS=("$MODE" "${SLUG_ARGS[@]-}")
  MODE="explicit"
fi

if [[ "$MODE" == "explicit" ]] && [[ ${#SLUG_ARGS[@]} -eq 0 ]]; then
  echo "Usage: bash tools/capture-spec-screenshots.sh [seed|high-risk|all|<slug> ...]" >&2
  exit 1
fi

maybe_run_safari_js() {
  local js="$1"

  if ! osascript <<OSA
tell application "Safari"
  do JavaScript "$js" in front document
end tell
OSA
  then
    echo "Warning: Safari 'Allow JavaScript from Apple Events' is disabled; using raw page capture." >&2
  fi
}

remote_specs=(
  "alert-description|https://ui.shadcn.com/docs/components/alert"
  "alert-title|https://ui.shadcn.com/docs/components/alert"
  "alert|https://ui.shadcn.com/docs/components/alert"
  "badge|https://ui.shadcn.com/docs/components/badge"
  "body|https://ui.shadcn.com/blocks"
  "button|https://ui.shadcn.com/docs/components/button"
  "card-content|https://ui.shadcn.com/docs/components/card"
  "card-description|https://ui.shadcn.com/docs/components/card"
  "card-footer|https://ui.shadcn.com/docs/components/card"
  "card-header|https://ui.shadcn.com/docs/components/card"
  "card-title|https://ui.shadcn.com/docs/components/card"
  "card|https://ui.shadcn.com/docs/components/card"
  "checkbox|https://ui.shadcn.com/docs/components/checkbox"
  "empty|https://ui.shadcn.com/blocks"
  "field-description|https://ui.shadcn.com/docs/components/input"
  "field-group|https://ui.shadcn.com/docs/components/input"
  "field-invalid|https://ui.shadcn.com/docs/components/input"
  "field-label|https://ui.shadcn.com/docs/components/input"
  "field-legend|https://ui.shadcn.com/docs/components/input"
  "field-set|https://ui.shadcn.com/docs/components/input"
  "field|https://ui.shadcn.com/docs/components/input"
  "header|https://ui.shadcn.com/blocks"
  "icon|https://ui.shadcn.com/docs/components/button"
  "nav-item|https://ui.shadcn.com/docs/components/sidebar"
  "nav|https://ui.shadcn.com/docs/components/sidebar"
  "page|https://ui.shadcn.com/blocks"
  "select|https://ui.shadcn.com/docs/components/select"
  "separator|https://ui.shadcn.com/docs/components/separator"
  "sidebar|https://ui.shadcn.com/docs/components/sidebar"
  "skeleton|https://ui.shadcn.com/docs/components/skeleton"
  "slider|https://ui.shadcn.com/docs/components/slider"
  "spinner|https://ui.shadcn.com/docs/components/skeleton"
  "switch|https://ui.shadcn.com/docs/components/switch"
  "tab|https://ui.shadcn.com/docs/components/tabs"
  "tabs|https://ui.shadcn.com/docs/components/tabs"
  "textarea|https://ui.shadcn.com/docs/components/textarea"
  "value-box|https://ui.shadcn.com/blocks"
)

local_specs=(
  "dark-mode-toggle|http://127.0.0.1:4321/#theme"
  "input-group-addon|http://127.0.0.1:4321/#field"
  "input-group|http://127.0.0.1:4321/#field"
  "theme|http://127.0.0.1:4321/#theme"
)

seed_specs=(button card select tabs)
high_risk_specs=(badge checkbox dark-mode-toggle nav-item sidebar switch textarea)

contains() {
  local needle="$1"
  shift
  local item
  for item in "$@"; do
    if [[ "$item" == "$needle" ]]; then
      return 0
    fi
  done
  return 1
}

should_capture() {
  local slug="$1"
  if [[ "$MODE" == "explicit" ]]; then
    contains "$slug" "${SLUG_ARGS[@]}"
    return
  fi
  case "$MODE" in
    seed)
      contains "$slug" "${seed_specs[@]}"
      ;;
    high-risk)
      contains "$slug" "${high_risk_specs[@]}"
      ;;
    all)
      return 0
      ;;
  esac
}

capture_remote() {
  local slug="$1"
  local url="$2"
  local output="$OUT_DIR/$slug.png"
  local window_id

  osascript <<OSA
tell application "Safari"
  activate
  if (count of windows) = 0 then
    make new document
  end if
  set bounds of front window to {40, 60, 1360, 980}
  set URL of front document to "$url"
end tell
OSA

  sleep 4

  maybe_run_safari_js "
    try {
      localStorage.setItem('theme', 'light');
    } catch (e) {}
    window.scrollTo(0, 0);
    var cleanup = [
      'header',
      'nav',
      '[data-slot=\"sidebar\"]',
      '[data-radix-scroll-area-viewport]'
    ];
    cleanup.forEach(function(sel) {
      document.querySelectorAll(sel).forEach(function(el) {
        if (el.closest('main')) return;
        el.style.display = 'none';
      });
    });
  "

  sleep 2
  window_id="$(osascript -e 'tell application "Safari" to get id of front window')"
  screencapture -x -l "$window_id" "$output"
  echo "Captured $output"
}

capture_local() {
  local slug="$1"
  local url="$2"
  local output="$OUT_DIR/$slug.png"
  local window_id

  osascript <<OSA
tell application "Safari"
  activate
  if (count of windows) = 0 then
    make new document
  end if
  set bounds of front window to {40, 60, 1360, 980}
  set URL of front document to "$url"
end tell
OSA

  sleep 3

  maybe_run_safari_js "
    try {
      localStorage.setItem('theme', 'light');
    } catch (e) {}
    var hash = window.location.hash;
    if (hash) {
      var target = document.querySelector(hash);
      if (target) {
        target.scrollIntoView({ block: 'start' });
        window.scrollBy(0, -16);
      }
    } else {
      window.scrollTo(0, 0);
    }
  "

  sleep 2
  window_id="$(osascript -e 'tell application "Safari" to get id of front window')"
  screencapture -x -l "$window_id" "$output"
  echo "Captured $output"
}

for item in "${remote_specs[@]}"; do
  IFS="|" read -r slug url <<<"$item"
  if should_capture "$slug"; then
    capture_remote "$slug" "$url"
  fi
done

for item in "${local_specs[@]}"; do
  IFS="|" read -r slug url <<<"$item"
  if should_capture "$slug"; then
    capture_local "$slug" "$url"
  fi
done
