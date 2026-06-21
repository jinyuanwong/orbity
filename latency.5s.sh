#!/bin/bash
# SwiftBar plugin: show current network quality in the macOS menu bar.
# It measures latency, packet loss, and jitter. Tiny, boring, useful.

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
ICONS="${SWIFTBAR_LATENCY_ICONS:-"$SCRIPT_DIR/icons"}"
PING_TARGET="${SWIFTBAR_PING_TARGET:-1.1.1.1}"
PING_COUNT="${SWIFTBAR_PING_COUNT:-3}"
PING_TIMEOUT_MS="${SWIFTBAR_PING_TIMEOUT_MS:-1000}"

icon_arg() {
  local icon_path="$ICONS/$1.png"
  if [ -f "$icon_path" ]; then
    printf ' | image=%s' "$(base64 -i "$icon_path")"
  fi
}

wifi_name() {
  local device="$1"
  local name
  [ -z "$device" ] && return 0
  name=$(networksetup -getairportnetwork "$device" 2>/dev/null | sed 's/^Current Wi-Fi Network: //')
  case "$name" in
    ""|"You are not associated with an AirPort network.") return 0 ;;
    *) printf '%s\n' "$name" ;;
  esac
}

local_ip() {
  local device="$1"
  [ -z "$device" ] && return 0
  ipconfig getifaddr "$device" 2>/dev/null
}

wifi_device() {
  networksetup -listallhardwareports 2>/dev/null | awk '
    /Hardware Port: Wi-Fi|Hardware Port: AirPort/ { found=1; next }
    found && /Device:/ { print $2; exit }
  '
}

PING_OUT=$(ping -c "$PING_COUNT" -W "$PING_TIMEOUT_MS" "$PING_TARGET" 2>/dev/null)
LOSS=$(printf '%s\n' "$PING_OUT" | awk -F',' '/packet loss/{gsub(/[^0-9.]/, "", $3); print $3; exit}')
STATS=$(printf '%s\n' "$PING_OUT" | awk -F'= ' '/min\/avg\/max|round-trip/{print $2; exit}' | awk '{print $1}')
MIN_MS=$(printf '%s' "$STATS" | cut -d/ -f1)
AVG_MS=$(printf '%s' "$STATS" | cut -d/ -f2)
MAX_MS=$(printf '%s' "$STATS" | cut -d/ -f3)
JITTER_MS=$(printf '%s' "$STATS" | cut -d/ -f4)
WIFI_DEVICE=$(wifi_device)
SSID=$(wifi_name "$WIFI_DEVICE")
IP_ADDR=$(local_ip "$WIFI_DEVICE")

if [ -z "$AVG_MS" ]; then
  printf 'Offline%s\n' "$(icon_arg gray)"
  echo "---"
  echo "Status: ping failed"
  echo "Target: ${PING_TARGET}"
  [ -n "$WIFI_DEVICE" ] && echo "Wi-Fi device: ${WIFI_DEVICE}"
  [ -n "$SSID" ] && echo "Wi-Fi: ${SSID}"
  [ -n "$IP_ADDR" ] && echo "Local IP: ${IP_ADDR}"
  echo "Refresh | refresh=true"
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
echo "Average latency: ${AVG_MS} ms"
echo "Packet loss: ${LOSS:-0}%"
echo "Jitter: ${JITTER_MS:-0} ms"
echo "Range: ${MIN_MS:-?} - ${MAX_MS:-?} ms"
echo "---"
echo "Target: ${PING_TARGET}"
echo "Samples: ${PING_COUNT}"
echo "Timeout: ${PING_TIMEOUT_MS} ms"
[ -n "$WIFI_DEVICE" ] && echo "Wi-Fi device: ${WIFI_DEVICE}"
[ -n "$SSID" ] && echo "Wi-Fi: ${SSID}"
[ -n "$IP_ADDR" ] && echo "Local IP: ${IP_ADDR}"
echo "---"
echo "Meaning: latency is response speed, not download bandwidth"
echo "Colors: green <80ms, orange 80-150ms/loss, red >150ms/heavy loss, gray = failed"
echo "Refresh | refresh=true"
if command -v speedtest >/dev/null 2>&1; then
  echo "Run speedtest | bash=speedtest terminal=true"
else
  echo "Install speedtest CLI | href=https://www.speedtest.net/apps/cli"
fi
echo "Open Network Settings | bash=open param1='x-apple.systempreferences:com.apple.Network-Settings.extension' terminal=false"
