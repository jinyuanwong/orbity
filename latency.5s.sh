#!/bin/bash
# SwiftBar plugin: show current network latency in the macOS menu bar.
# Color rule: green <80ms, orange 80-150ms, red >150ms, gray = ping failed.

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
ICONS="${SWIFTBAR_LATENCY_ICONS:-"$SCRIPT_DIR/icons"}"
PING_TARGET="${SWIFTBAR_PING_TARGET:-1.1.1.1}"
PING_TIMEOUT_MS="${SWIFTBAR_PING_TIMEOUT_MS:-2000}"

icon_arg() {
  local icon_path="$ICONS/$1.png"
  if [ -f "$icon_path" ]; then
    printf ' | image=%s' "$(base64 -i "$icon_path")"
  fi
}

PING_OUT=$(ping -c 1 -W "$PING_TIMEOUT_MS" "$PING_TARGET" 2>/dev/null)
MS=$(printf '%s\n' "$PING_OUT" | awk -F'time=' '/time=/{split($2,a," "); print a[1]; exit}')

if [ -z "$MS" ]; then
  printf 'Offline%s\n' "$(icon_arg gray)"
  echo "---"
  echo "Ping target: ${PING_TARGET}"
  echo "Status: failed"
  echo "Refresh | refresh=true"
  exit 0
fi

MI=${MS%.*}

if [ "$MI" -lt 80 ]; then
  ICON="green"
  TAG="Good"
elif [ "$MI" -lt 150 ]; then
  ICON="orange"
  TAG="Okay"
else
  ICON="red"
  TAG="Slow"
fi

printf '%sms%s\n' "$MS" "$(icon_arg "$ICON")"
echo "---"
echo "${TAG} latency: ${MS} ms"
echo "Ping target: ${PING_TARGET}"
echo "Colors: green <80ms, orange 80-150ms, red >150ms, gray = failed"
echo "Refresh | refresh=true"
