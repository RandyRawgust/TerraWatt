#!/usr/bin/env python3
"""Produce warmer/brighter 'operating' variants for tier-1 power sprites."""
from __future__ import annotations

import shutil
from pathlib import Path

from PIL import Image, ImageEnhance

ROOT = Path(__file__).resolve().parents[2]
RAW = ROOT / "workshop" / "raw_assets" / "power"
DEST = ROOT / "game" / "assets" / "power" / "tier1"


def make_active(src: Path, dest: Path, warmth: int = 12, brightness: float = 1.15) -> None:
    """Create an 'active/operating' variant — warmer and slightly brighter."""
    img = Image.open(src).convert("RGBA")
    r, g, b, a = img.split()
    r = r.point(lambda x: min(x + warmth, 255))
    merged = Image.merge("RGBA", (r, g, b, a))
    enhancer = ImageEnhance.Brightness(merged)
    result = enhancer.enhance(brightness)
    dest.parent.mkdir(parents=True, exist_ok=True)
    result.save(str(dest), "PNG")
    print(f"Active variant: {dest.name} ({dest.stat().st_size}b)")


def main() -> None:
    DEST.mkdir(parents=True, exist_ok=True)

    for name, dest_name in [
        ("power_furnace.png", "furnace.png"),
        ("power_boiler.png", "water_boiler.png"),
        ("power_turbine.png", "steam_turbine.png"),
        ("power_pole.png", "power_pole.png"),
    ]:
        src = RAW / name
        if src.exists():
            shutil.copy2(str(src), str(DEST / dest_name))
            print(f"Copied: {dest_name}")

    if (RAW / "power_furnace.png").exists():
        make_active(RAW / "power_furnace.png", DEST / "furnace_active.png", warmth=20, brightness=1.2)
    if (RAW / "power_boiler.png").exists():
        make_active(RAW / "power_boiler.png", DEST / "boiler_active.png", warmth=10, brightness=1.1)
    if (RAW / "power_turbine.png").exists():
        make_active(RAW / "power_turbine.png", DEST / "turbine_active.png", warmth=8, brightness=1.15)


if __name__ == "__main__":
    main()
