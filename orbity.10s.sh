#!/bin/bash
# SwiftBar plugin: show current network latency in the macOS menu bar.
# Default path is intentionally fast: one ping, short timeout, no system scans.

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
ICONS="${SWIFTBAR_LATENCY_ICONS:-"$SCRIPT_DIR/icons"}"
PING_TARGET="${SWIFTBAR_PING_TARGET:-1.1.1.1}"
PING_COUNT="${SWIFTBAR_PING_COUNT:-1}"
PING_TIMEOUT_MS="${SWIFTBAR_PING_TIMEOUT_MS:-600}"

icon_arg() {
  local icon_path="$ICONS/$1.png"
  if [ -f "$icon_path" ]; then
    printf ' | image=%s' "$(base64 -i "$icon_path")"
  fi
}

PING_OUT=$(ping -c "$PING_COUNT" -W "$PING_TIMEOUT_MS" "$PING_TARGET" 2>/dev/null)
LOSS=$(printf '%s\n' "$PING_OUT" | awk -F',' '/packet loss/{gsub(/[^0-9.]/, "", $3); print $3; exit}')
STATS=$(printf '%s\n' "$PING_OUT" | awk -F'= ' '/min\/avg\/max|round-trip/{print $2; exit}' | awk '{print $1}')
MIN_MS=$(printf '%s' "$STATS" | cut -d/ -f1)
AVG_MS=$(printf '%s' "$STATS" | cut -d/ -f2)
MAX_MS=$(printf '%s' "$STATS" | cut -d/ -f3)
JITTER_MS=$(printf '%s' "$STATS" | cut -d/ -f4)

if [ -z "$AVG_MS" ]; then
  printf 'Offline%s\n' "$(icon_arg gray)"
  echo "---"
  echo "Status: ping failed"
  echo "Target: ${PING_TARGET}"
  echo "Timeout: ${PING_TIMEOUT_MS} ms"
  echo "Refresh | refresh=true"
  echo "Detailed ping | bash=ping param1=-c param2=10 param3=${PING_TARGET} terminal=true"
  echo "Open Network Settings | bash=open param1='x-apple.systempreferences:com.apple.Network-Settings.extension' terminal=false"
  exit 0
fi

MI=${AVG_MS%.*}
LOSS_INT=${LOSS%.*}

if [ "${LOSS_INT:-0}" -ge 50 ]; then
  ICON="red"
  TAG="LOSS"
elif [ "${LOSS_INT:-0}" -gt 0 ]; then
  ICON="orange"
  TAG="LOSS"
elif [ "$MI" -lt 80 ]; then
  ICON="green"
  TAG="GOOD"
elif [ "$MI" -lt 150 ]; then
  ICON="orange"
  TAG="OK"
else
  ICON="red"
  TAG="SLOW"
fi

printf '%sms · %s%s\n' "$AVG_MS" "$TAG" "$(icon_arg "$ICON")"
echo "---"
echo "Quality: ${TAG}"
echo "Latency: ${AVG_MS} ms"
if [ "$PING_COUNT" -gt 1 ]; then
  echo "Packet loss: ${LOSS:-0}%"
  echo "Jitter: ${JITTER_MS:-0} ms"
  echo "Range: ${MIN_MS:-?} - ${MAX_MS:-?} ms"
fi
echo "---"
echo "Target: ${PING_TARGET}"
echo "Samples: ${PING_COUNT}"
echo "Timeout: ${PING_TIMEOUT_MS} ms"
echo "---"
echo "Meaning: latency is response speed, not download bandwidth"
echo "Colors: green <80ms, orange 80-150ms/loss, red >150ms/heavy loss"
echo "Refresh | refresh=true"
echo "Detailed ping | bash=ping param1=-c param2=10 param3=${PING_TARGET} terminal=true"
if command -v speedtest >/dev/null 2>&1; then
  echo "Run speedtest | bash=speedtest terminal=true"
else
  echo "Install speedtest CLI | href=https://www.speedtest.net/apps/cli"
fi
echo "Open Network Settings | bash=open param1='x-apple.systempreferences:com.apple.Network-Settings.extension' terminal=false"
