#!/usr/bin/env python3
"""Generate Orbity brand art and SwiftBar status icons."""

from pathlib import Path
import os

from PIL import Image, ImageDraw


ROOT = Path(__file__).resolve().parent
ICON_OUT = Path(os.environ.get("SWIFTBAR_LATENCY_ICONS", ROOT / "icons")).expanduser()
ASSET_OUT = ROOT / "assets"
ICON_OUT.mkdir(parents=True, exist_ok=True)
ASSET_OUT.mkdir(parents=True, exist_ok=True)

SS = 4
SIZE = 36
PAD = 0.22

COLORS = {
    "green": "#30d158",
    "orange": "#ff9f0a",
    "red": "#ff453a",
    "gray": "#8e8e93",
}


def draw_status_icon(color: str, path: Path) -> None:
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


def draw_brand_icon(path: Path) -> None:
    size = 1024
    scale = 4
    canvas = size * scale
    image = Image.new("RGBA", (canvas, canvas), (0, 0, 0, 0))
    draw = ImageDraw.Draw(image)

    bg = "#10131a"
    orange = "#ff9f0a"
    amber = "#ffd166"
    cyan = "#44d7ff"
    white = "#f7f4ea"

    margin = int(canvas * 0.08)
    radius = int(canvas * 0.22)
    draw.rounded_rectangle(
        [margin, margin, canvas - margin, canvas - margin],
        radius=radius,
        fill=bg,
    )

    cx = cy = canvas / 2
    orbit_width = int(canvas * 0.035)
    wifi_width = int(canvas * 0.045)

    orbit_box = [
        canvas * 0.21,
        canvas * 0.31,
        canvas * 0.79,
        canvas * 0.69,
    ]
    draw.arc(orbit_box, start=198, end=522, fill=orange, width=orbit_width)
    draw.arc(
        [
            canvas * 0.28,
            canvas * 0.18,
            canvas * 0.72,
            canvas * 0.82,
        ],
        start=25,
        end=205,
        fill=cyan,
        width=int(canvas * 0.022),
    )

    satellite_radius = canvas * 0.045
    satellite_x = canvas * 0.765
    satellite_y = canvas * 0.362
    draw.ellipse(
        [
            satellite_x - satellite_radius,
            satellite_y - satellite_radius,
            satellite_x + satellite_radius,
            satellite_y + satellite_radius,
        ],
        fill=amber,
    )

    base_y = canvas * 0.64
    for radius_factor in (0.16, 0.25, 0.34):
        radius_px = canvas * radius_factor
        draw.arc(
            [
                cx - radius_px,
                base_y - radius_px,
                cx + radius_px,
                base_y + radius_px,
            ],
            start=220,
            end=320,
            fill=white,
            width=wifi_width,
        )

    dot_radius = canvas * 0.045
    draw.ellipse(
        [
            cx - dot_radius,
            base_y - dot_radius,
            cx + dot_radius,
            base_y + dot_radius,
        ],
        fill=white,
    )

    image = image.resize((size, size), Image.LANCZOS)
    image.save(path)


for name, color in COLORS.items():
    draw_status_icon(color, ICON_OUT / f"{name}.png")
    print(f"{name}.png ({color})")

draw_brand_icon(ASSET_OUT / "orbity-icon.png")
print(f"orbity-icon.png")
print(f"Status icon directory: {ICON_OUT}")
print(f"Brand asset directory: {ASSET_OUT}")
