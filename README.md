# Orbity

<img src="assets/orbity-icon.png" alt="Orbity icon" width="160">

A tiny macOS menu bar plugin for [SwiftBar](https://swiftbar.app/) that shows current network latency with a WiFi-style status icon.

It answers one boring but useful question:

```text
Is my internet actually slow, or am I just blaming the router again?
```

## What It Does

- Pings `1.1.1.1` every 10 seconds.
- Shows latency directly in the macOS menu bar.
- Uses one fast ping by default, so the plugin itself does not make your menu bar feel sticky.
- Keeps packet loss and jitter available when you opt into multiple samples.
- Uses color to make the network state obvious at a glance.
- Opens a small dropdown with target, timeout, refresh, detailed ping, speedtest, and network settings.
- Ships with generated PNG icons, so users can install it without building anything.

```text
Mac -> 1 fast ping -> latency/status -> menu bar

Mac
 |
 |  ping 1.1.1.1 x 1
 v
Internet
 |
 v
SwiftBar shows: 80.218ms · GOOD + colored WiFi icon
```

Important: Orbity measures network response speed, not download bandwidth.

```text
Latency = how fast the network answers you
Bandwidth = how much data can move per second

Fast answer, small road:
  low latency + low bandwidth

Slow answer, big road:
  high latency + high bandwidth
```

So yes, your internet can feel bad even when a speed-test says "big number". The network is not lying. It is just being annoying with math.

## Menu Display

The menu bar title looks like this:

```text
91.743ms · OK
```

The dropdown shows:

| Field | Meaning |
| --- | --- |
| Quality | Overall state: `GOOD`, `OK`, `SLOW`, or `LOSS` |
| Latency | Ping response time |
| Packet loss | Only shown when `SWIFTBAR_PING_COUNT` is greater than `1` |
| Jitter | Only shown when `SWIFTBAR_PING_COUNT` is greater than `1` |
| Range | Only shown when `SWIFTBAR_PING_COUNT` is greater than `1` |
| Target | Host being pinged |
| Samples | Number of ping attempts per refresh |
| Timeout | Max wait time per ping |

## Color Rules

| State | Latency | Meaning |
| --- | --- | --- |
| Green | `< 80ms` | Good |
| Orange | `80-150ms` or some packet loss | Okay, but watch it |
| Red | `> 150ms` or heavy packet loss | Slow or unstable |
| Gray | ping failed | Offline or blocked |

## Install

1. Install SwiftBar: <https://swiftbar.app/>
2. Clone this repo:

```bash
git clone https://github.com/jinyuanwong/orbity.git
cd orbity
```

3. Install the plugin into your SwiftBar plugin folder:

```bash
./install.sh
```

4. Refresh SwiftBar.

By default, the installer copies files to:

```text
~/.swiftbar/orbity.10s.sh
~/.swiftbar/icons/
```

If your SwiftBar plugin folder is somewhere else:

```bash
SWIFTBAR_PLUGIN_DIR="/path/to/your/swiftbar/plugins" ./install.sh
```

## Configuration

Change the ping target:

```bash
SWIFTBAR_PING_TARGET=8.8.8.8 ~/.swiftbar/orbity.10s.sh
```

Change ping timeout:

```bash
SWIFTBAR_PING_TIMEOUT_MS=600 ~/.swiftbar/orbity.10s.sh
```

Change sample count:

```bash
SWIFTBAR_PING_COUNT=5 ~/.swiftbar/orbity.10s.sh
```

Default is `1`. Keep it there if you want the fastest menu bar. Use `3` or `5` only when you want loss/jitter detail.

Change icon folder:

```bash
SWIFTBAR_LATENCY_ICONS="/path/to/icons" ~/.swiftbar/orbity.10s.sh
```

## Regenerate Images

Images are already included. Regenerate them only if you want to change size, color, or shape.

```bash
python3 -m venv .venv
source .venv/bin/activate
pip install -r requirements.txt
python make_icons.py
```

Generated files:

```text
assets/orbity-icon.png  # 1024x1024 project icon
icons/*.png             # 36x36 SwiftBar status icons
```

## Why This Exists

Most network tools are too much when you only need a quick answer.

This plugin is intentionally small:

- no account
- no analytics
- no dashboard
- no background service
- no mystery meat menu bar monster

It checks latency quickly, then tells you whether the network is healthy.

## Future AI-Friendly Improvements

This repo is deliberately simple so future AI agents can safely improve it.

Good next tasks:

- Support multiple ping targets.
- Add a settings file.
- Add automatic target fallback when `1.1.1.1` is blocked.
- Add a clean demo screenshot without private desktop content.
- Add a Homebrew install option.
- Add tests for parsing ping output.
- Add optional bandwidth testing through `speedtest` without making it a hard dependency.
- Add a tiny cache so the title can stay instant even when the network stalls.

Suggested prompt for another AI agent:

```text
Read this repository first. Keep it a small SwiftBar plugin. Improve one thing at a time, preserve the install flow, and update README when behavior changes.
```

## Project Shape

```text
.
├── assets/           # Project icon and larger visual assets
├── orbity.10s.sh     # SwiftBar plugin, runs every 10 seconds
├── icons/            # Menu bar PNG icons
├── make_icons.py     # Regenerates project icon and status icons
├── install.sh        # Copies plugin files to SwiftBar plugin folder
├── requirements.txt  # Python dependency for icon generation
└── README.md
```

## License

MIT
