#!/usr/bin/env python3
"""Create slightly brighter 'active' variants for tier-1 power structures (PIL)."""
from pathlib import Path

from PIL import Image, ImageEnhance

ROOT = Path(__file__).resolve().parents[2]
RAW = ROOT / "workshop" / "raw_assets" / "power"
OUT_DIR = ROOT / "game" / "assets" / "power" / "tier1"


def create_glow_variant(source_path: Path, output_path: Path, glow_intensity: float = 0.2) -> None:
    img = Image.open(source_path).convert("RGBA")
    enhancer = ImageEnhance.Brightness(img)
    active = enhancer.enhance(1.0 + glow_intensity)
    r, g, b, a = active.split()
    r = r.point(lambda x: min(x + 15, 255))
    active = Image.merge("RGBA", (r, g, b, a))
    output_path.parent.mkdir(parents=True, exist_ok=True)
    active.save(str(output_path))
    print(f"Created active variant: {output_path}")


def main() -> None:
    create_glow_variant(RAW / "power_furnace.png", OUT_DIR / "furnace_active.png", glow_intensity=0.3)
    create_glow_variant(RAW / "power_boiler.png", OUT_DIR / "boiler_active.png", glow_intensity=0.2)
    create_glow_variant(RAW / "power_turbine.png", OUT_DIR / "turbine_active.png", glow_intensity=0.25)


if __name__ == "__main__":
    main()
