#!/usr/bin/env python3
"""Quick validation: checks all game/assets/ PNGs are valid and correctly sized."""

import json
from pathlib import Path
from PIL import Image

def check_all():
    manifest_path = Path("workshop/pipeline/manifest.json")
    with open(manifest_path) as f:
        manifest = json.load(f)

    errors = []
    ok = []

    def check(path_str, expected_w=None, expected_h=None):
        p = Path(path_str)
        if not p.exists():
            errors.append(f"MISSING: {path_str}")
            return
        try:
            img = Image.open(p)
            w, h = img.size
            size = p.stat().st_size
            if expected_w and w != expected_w:
                errors.append(f"WRONG WIDTH: {path_str} is {w}px, expected {expected_w}px")
            elif expected_h and h != expected_h:
                errors.append(f"WRONG HEIGHT: {path_str} is {h}px, expected {expected_h}px")
            else:
                ok.append(f"[OK] {p.name} ({w}x{h}, {size}b)")
        except Exception as e:
            errors.append(f"CORRUPT: {path_str} - {e}")

    # Check character sheets
    for name, data in manifest["characters"].items():
        n_frames = len(data["sheet_layout"])
        expected_w = data["frame_w"] * n_frames
        expected_h = data["frame_h"]
        check(data["output"], expected_w, expected_h)

    # Check tiles, backgrounds, power, ui
    for category in ["tiles", "backgrounds", "power", "ui"]:
        for name, info in manifest[category].items():
            check(info["output"])

    print(f"\n[OK] Valid: {len(ok)}")
    for line in ok:
        print(f"  {line}")

    if errors:
        print(f"\n[X] Errors: {len(errors)}")
        for line in errors:
            print(f"  {line}")
    else:
        print("\nAll assets valid. Ready for Godot import.")

if __name__ == "__main__":
    check_all()
