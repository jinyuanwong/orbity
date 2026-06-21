# SwiftBar WiFi Latency

A tiny macOS menu bar plugin for [SwiftBar](https://swiftbar.app/) that shows current network latency with a WiFi-style status icon.

It answers one boring but useful question:

```text
Is my internet actually slow, or am I just blaming the router again?
```

## What It Does

- Pings `1.1.1.1` every 5 seconds.
- Shows latency directly in the macOS menu bar.
- Uses color to make the network state obvious at a glance.
- Opens a dropdown with the ping target, current status, and refresh action.
- Ships with generated PNG icons, so users can install it without building anything.

```text
Network -> ping target -> latency -> menu bar

Mac
 |
 |  ping 1.1.1.1
 v
Internet
 |
 v
SwiftBar shows: 80.218ms + colored WiFi icon
```

## Color Rules

| State | Latency | Meaning |
| --- | --- | --- |
| Green | `< 80ms` | Good |
| Orange | `80-150ms` | Okay |
| Red | `> 150ms` | Slow |
| Gray | ping failed | Offline or blocked |

## Install

1. Install SwiftBar: <https://swiftbar.app/>
2. Clone this repo:

```bash
git clone https://github.com/jinyuanwong/swiftbar-wifi-latency.git
cd swiftbar-wifi-latency
```

3. Install the plugin into your SwiftBar plugin folder:

```bash
./install.sh
```

4. Refresh SwiftBar.

By default, the installer copies files to:

```text
~/.swiftbar/latency.5s.sh
~/.swiftbar/icons/
```

If your SwiftBar plugin folder is somewhere else:

```bash
SWIFTBAR_PLUGIN_DIR="/path/to/your/swiftbar/plugins" ./install.sh
```

## Configuration

Change the ping target:

```bash
SWIFTBAR_PING_TARGET=8.8.8.8 ~/.swiftbar/latency.5s.sh
```

Change ping timeout:

```bash
SWIFTBAR_PING_TIMEOUT_MS=1000 ~/.swiftbar/latency.5s.sh
```

Change icon folder:

```bash
SWIFTBAR_LATENCY_ICONS="/path/to/icons" ~/.swiftbar/latency.5s.sh
```

## Regenerate Icons

Icons are already included. Regenerate them only if you want to change size, color, or shape.

```bash
python3 -m venv .venv
source .venv/bin/activate
pip install -r requirements.txt
python make_icons.py
```

## Why This Exists

Most network tools are too much when you only need a quick answer.

This plugin is intentionally small:

- no account
- no analytics
- no dashboard
- no background service
- no mystery meat menu bar monster

It just checks latency and tells you whether the network is healthy.

## Future AI-Friendly Improvements

This repo is deliberately simple so future AI agents can safely improve it.

Good next tasks:

- Add packet loss display.
- Add jitter calculation.
- Support multiple ping targets.
- Add a settings file.
- Add automatic target fallback when `1.1.1.1` is blocked.
- Add a clean screenshot without private desktop content.
- Add a Homebrew install option.
- Add tests for parsing ping output.

Suggested prompt for another AI agent:

```text
Read this repository first. Keep it a small SwiftBar plugin. Improve one thing at a time, preserve the install flow, and update README when behavior changes.
```

## Project Shape

```text
.
├── latency.5s.sh     # SwiftBar plugin, runs every 5 seconds
├── icons/            # Menu bar PNG icons
├── make_icons.py     # Regenerates icons
├── install.sh        # Copies plugin files to SwiftBar plugin folder
├── requirements.txt  # Python dependency for icon generation
└── README.md
```

## License

MIT
