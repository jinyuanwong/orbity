#!/usr/bin/env python3
"""Generate WiFi status icons for the SwiftBar latency plugin."""

from pathlib import Path
import os

from PIL import Image, ImageDraw


ROOT = Path(__file__).resolve().parent
OUT = Path(os.environ.get("SWIFTBAR_LATENCY_ICONS", ROOT / "icons")).expanduser()
OUT.mkdir(parents=True, exist_ok=True)

SS = 4
SIZE = 36
PAD = 0.22

COLORS = {
    "green": "#30d158",
    "orange": "#ff9f0a",
    "red": "#ff453a",
    "gray": "#8e8e93",
}


def draw_icon(color: str, path: Path) -> None:
    width = SIZE * SS
    image = Image.new("RGBA", (width, width), (0, 0, 0, 0))
    draw = ImageDraw.Draw(image)

    pad = width * PAD
    cx = width / 2
    cy = width - pad
    line_width = max(1, int(width * 0.085))

    for radius in (width * 0.18, width * 0.33, width * 0.48):
        draw.arc(
            [cx - radius, cy - radius, cx + radius, cy + radius],
            start=225,
            end=315,
            fill=color,
            width=line_width,
        )

    dot_radius = width * 0.055
    draw.ellipse(
        [cx - dot_radius, cy - dot_radius, cx + dot_radius, cy + dot_radius],
        fill=color,
    )

    image = image.resize((SIZE, SIZE), Image.LANCZOS)
    image.save(path)


for name, color in COLORS.items():
    draw_icon(color, OUT / f"{name}.png")
    print(f"{name}.png ({color})")

print(f"Icon directory: {OUT}")
