#!/bin/bash
set -euo pipefail

ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PLUGIN_DIR="${SWIFTBAR_PLUGIN_DIR:-"$HOME/.swiftbar"}"

mkdir -p "$PLUGIN_DIR/icons"
rm -f "$PLUGIN_DIR/latency.5s.sh"
cp "$ROOT/orbity.10s.sh" "$PLUGIN_DIR/orbity.10s.sh"
cp "$ROOT/icons/"*.png "$PLUGIN_DIR/icons/"
chmod +x "$PLUGIN_DIR/orbity.10s.sh"

echo "Installed to: $PLUGIN_DIR/orbity.10s.sh"
echo "Refresh SwiftBar or restart it if the plugin does not appear."
