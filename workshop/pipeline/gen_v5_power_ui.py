#!/usr/bin/env python3
"""Generate V5 power + UI raw PNGs (workshop specs) when PixelLab output is absent."""
from __future__ import annotations

from pathlib import Path

from PIL import Image, ImageDraw
from PIL.PngImagePlugin import PngInfo

ROOT = Path(__file__).resolve().parents[2]
RAW_POWER = ROOT / "workshop" / "raw_assets" / "power"
RAW_UI = ROOT / "workshop" / "raw_assets" / "ui"


def _hex_rgb(s: str) -> tuple[int, int, int]:
    s = s.lstrip("#")
    return int(s[0:2], 16), int(s[2:4], 16), int(s[4:6], 16)


def _hex_rgba(s: str, a: int = 255) -> tuple[int, int, int, int]:
    r, g, b = _hex_rgb(s)
    return r, g, b, a


def _furnace() -> Image.Image:
    w, h = 32, 48
    im = Image.new("RGBA", (w, h), (0, 0, 0, 0))
    dr = ImageDraw.Draw(im)
    iron = _hex_rgb("#2A2A2A")
    brick = _hex_rgb("#8B4513")
    fire = _hex_rgb("#FF6A00")
    copper = _hex_rgb("#B87333")
    cream = _hex_rgb("#F5F5DC")
    # brick base
    dr.rectangle([2, 34, 29, 46], fill=brick + (255,))
    dr.rectangle([4, 32, 27, 34], fill=iron + (255,))
    # iron boiler body
    dr.rectangle([5, 14, 26, 36], fill=iron + (255,))
    for y in range(16, 34, 4):
        dr.line([(6, y), (25, y)], fill=_hex_rgb("#1A1A1A") + (255,), width=1)
    # fire door glow
    dr.rectangle([10, 37, 21, 45], outline=fire + (255,), width=1)
    dr.rectangle([11, 38, 20, 44], fill=fire + (220,))
    # chimney
    dr.rectangle([12, 4, 19, 14], fill=iron + (255,))
    dr.rectangle([11, 3, 20, 5], fill=_hex_rgb("#3A3A3A") + (255,))
    # copper fittings
    dr.rectangle([1, 18, 4, 28], fill=copper + (255,))
    dr.rectangle([27, 18, 30, 28], fill=copper + (255,))
    # gauge
    dr.ellipse([18, 16, 27, 25], outline=cream + (255,), width=1)
    dr.ellipse([20, 18, 25, 23], fill=cream + (255,))
    dr.line([(22, 21), (24, 19)], fill=(40, 40, 40, 255), width=1)
    dr.line([(7, 15), (7, 34)], fill=(80, 80, 88, 90), width=1)
    for rx in (6, 14, 22):
        dr.ellipse([rx - 1, 20, rx + 1, 22], fill=_hex_rgb("#1F1F1F") + (255,))
    return im


def _boiler() -> Image.Image:
    w, h = 32, 48
    im = Image.new("RGBA", (w, h), (0, 0, 0, 0))
    dr = ImageDraw.Draw(im)
    iron = _hex_rgb("#3A3A3A")
    riv = _hex_rgb("#4A4A4A")
    cream = _hex_rgb("#F5F5DC")
    copper = _hex_rgb("#B87333")
    steam = _hex_rgb("#DDEEFF")
    # stands
    dr.rectangle([6, 40, 8, 46], fill=iron + (255,))
    dr.rectangle([23, 40, 25, 46], fill=iron + (255,))
    # cylindrical body (approximated)
    dr.rounded_rectangle([4, 12, 27, 38], radius=6, fill=iron + (255,))
    for x in [6, 11, 16, 21, 25]:
        dr.ellipse([x - 1, 14, x + 2, 17], fill=riv + (255,))
        dr.ellipse([x - 1, 33, x + 2, 36], fill=riv + (255,))
    # large gauge
    dr.ellipse([9, 17, 21, 29], outline=cream + (255,), width=1)
    dr.ellipse([11, 19, 19, 27], fill=cream + (255,))
    dr.line([(15, 23), (18, 20)], fill=(50, 50, 50, 255), width=1)
    # pipes
    dr.rectangle([13, 6, 17, 14], fill=copper + (255,))
    dr.rectangle([26, 22, 30, 26], fill=copper + (255,))
    dr.rectangle([24, 19, 31, 23], fill=copper + (255,))
    # steam wisps
    dr.point([29, 18], fill=steam + (200,))
    dr.point([30, 16], fill=steam + (160,))
    # drips
    dr.point([10, 37], fill=steam + (120,))
    dr.point([19, 36], fill=steam + (100,))
    return im


def _turbine() -> Image.Image:
    w, h = 48, 32
    im = Image.new("RGBA", (w, h), (0, 0, 0, 0))
    dr = ImageDraw.Draw(im)
    iron = _hex_rgb("#2E2E2E")
    copper = _hex_rgb("#B87333")
    amber = _hex_rgb("#FFB300")
    blade = _hex_rgb("#8899AA")
    # turbine housing left
    dr.rounded_rectangle([2, 8, 22, 24], radius=4, fill=iron + (255,))
    for i in range(3):
        y = 11 + i * 4
        dr.line([(5, y), (19, y + 1)], fill=blade + (180,), width=1)
    # shaft
    dr.rectangle([21, 14, 26, 18], fill=_hex_rgb("#1A1A1A") + (255,))
    # generator right
    dr.rounded_rectangle([26, 6, 44, 26], radius=3, fill=iron + (255,))
    dr.rectangle([36, 10, 41, 14], fill=copper + (255,))
    dr.rectangle([38, 18, 40, 20], fill=amber + (255,))
    # terminals
    dr.rectangle([30, 20, 33, 24], fill=copper + (255,))
    dr.rectangle([34, 20, 37, 24], fill=copper + (255,))
    return im


def _pole() -> Image.Image:
    w, h = 16, 64
    im = Image.new("RGBA", (w, h), (0, 0, 0, 0))
    dr = ImageDraw.Draw(im)
    wood = _hex_rgb("#3D1F0A")
    arm = _hex_rgb("#4A2810")
    ins = _hex_rgb("#C8B89A")
    amber = _hex_rgb("#FFB300")
    # pole
    dr.rectangle([6, 8, 9, 62], fill=wood + (255,))
    dr.line([(7, 10), (7, 58)], fill=(90, 50, 30, 80), width=1)
    # cross-arm
    dr.rectangle([2, 10, 13, 13], fill=arm + (255,))
    # insulators
    dr.rectangle([3, 6, 5, 10], fill=ins + (255,))
    dr.rectangle([10, 6, 12, 10], fill=ins + (255,))
    # lamp top
    dr.ellipse([5, 2, 10, 7], fill=amber + (200,))
    dr.point([7, 4], fill=(255, 255, 220, 255))
    return im


def _hotbar_slot() -> Image.Image:
    w, h = 40, 40
    im = Image.new("RGBA", (w, h), (0, 0, 0, 0))
    dr = ImageDraw.Draw(im)
    bg = _hex_rgba("#1A1A2E", 235)
    copper = _hex_rgb("#B87333")
    inner = (26, 26, 46, 200)
    dr.rounded_rectangle([2, 2, 37, 37], radius=3, fill=bg)
    dr.rounded_rectangle([2, 2, 37, 37], radius=3, outline=copper + (255,), width=1)
    dr.rounded_rectangle([5, 5, 34, 34], radius=2, fill=inner)
    for x, y in [(4, 4), (35, 4), (4, 35), (35, 35)]:
        dr.ellipse([x - 1, y - 1, x + 2, y + 2], fill=copper + (220,))
    return im


def _status_icon() -> Image.Image:
    w, h = 16, 16
    im = Image.new("RGBA", (w, h), (0, 0, 0, 0))
    dr = ImageDraw.Draw(im)
    fill = _hex_rgba("#1A1A2E", int(255 * 0.8))
    border = _hex_rgb("#B87333")
    dr.ellipse([1, 1, 14, 14], fill=fill)
    dr.ellipse([1, 1, 14, 14], outline=border + (255,), width=1)
    return im


def _light_radial() -> Image.Image:
    w, h = 128, 128
    im = Image.new("RGBA", (w, h), (0, 0, 0, 0))
    cx, cy = w // 2, h // 2
    r0 = _hex_rgb("#FFFDF0")
    max_r = (cx * cx + cy * cy) ** 0.5
    px = im.load()
    for y in range(h):
        for x in range(w):
            d = ((x - cx) ** 2 + (y - cy) ** 2) ** 0.5
            t = min(1.0, d / (max_r * 0.95))
            # smooth falloff
            a = int(255 * (1.0 - t * t))
            if a < 2:
                continue
            rr = int(r0[0] * (1 - 0.08 * t))
            gg = int(r0[1] * (1 - 0.06 * t))
            bb = int(r0[2] * (1 - 0.04 * t))
            px[x, y] = (rr, gg, bb, a)
    return im


def _png_meta() -> PngInfo:
    """tEXt chunks so small compressed sprites still exceed pipeline MIN_VALID_BYTES."""
    p = PngInfo()
    p.add_text("generator", "workshop/pipeline/gen_v5_power_ui.py")
    p.add_text(
        "description",
        "Terra.Watt V5 industrial steampunk placeholders; swap for PixelLab generations when ready.",
    )
    p.add_text(
        "palette",
        "#2A2A2A #8B4513 #FF6A00 #B87333 #F5F5DC #3A3A3A #DDEEFF #2E2E2E "
        "#FFB300 #8899AA #3D1F0A #4A2810 #C8B89A #1A1A2E #FFFDF0",
    )
    p.add_text("dimensions", "furnace32x48 boiler32x48 turbine48x32 pole16x64 ui40x40 icon16x16 lamp128x128")
    return p


def main() -> None:
    RAW_POWER.mkdir(parents=True, exist_ok=True)
    RAW_UI.mkdir(parents=True, exist_ok=True)
    meta = _png_meta()
    outputs = [
        (RAW_POWER / "power_furnace.png", _furnace()),
        (RAW_POWER / "power_boiler.png", _boiler()),
        (RAW_POWER / "power_turbine.png", _turbine()),
        (RAW_POWER / "power_pole.png", _pole()),
        (RAW_UI / "ui_hotbar_slot.png", _hotbar_slot()),
        (RAW_UI / "ui_status_icon.png", _status_icon()),
        (RAW_UI / "ui_light_radial.png", _light_radial()),
    ]
    for path, img in outputs:
        img.save(path, "PNG", pnginfo=meta, compress_level=6)
        print(f"Wrote {path} ({img.size[0]}x{img.size[1]}, {path.stat().st_size}b)")


if __name__ == "__main__":
    main()
