TERRAWATT — VISUAL OVERHAUL AGENT V2: PIPELINE BUILDER
Single command: Paste into Cursor Composer Agent. Run SECOND and ALONE after V1 completes.

━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

## MISSION: Build the automated asset pipeline. Every future sprite flows through this system.

You are building the engine that V3, V4, and V5 will all use.
Get this right and the art agents become simple and safe.

---

## PHASE 0: RECON

```powershell
git pull origin main
Get-ChildItem -Path "." | Select-Object Name
Get-ChildItem -Path "workshop\raw_assets" -Recurse -Filter "*.png" | Select-Object FullName, Length
```

Confirm V1 Restructure is complete — game/ and workshop/ both exist.
Report all existing raw PNGs found in workshop/raw_assets/.

---

## PHASE 1: CREATE THE ASSET MANIFEST

The manifest is the single source of truth for every asset.
It tracks: what's needed, what's been generated, what's assembled, what's in Godot.

Create `workshop/pipeline/manifest.json`:

```json
{
  "version": "1.0",
  "aseprite_path": "C:\\Program Files\\Aseprite\\Aseprite.exe",
  "godot_assets_path": "game/assets",
  "raw_assets_path": "workshop/raw_assets",
  
  "characters": {
    "player": {
      "frame_w": 24, "frame_h": 40,
      "output": "game/assets/player/player_sheet.png",
      "frames": {
        "idle":    {"file": "player_idle.png",   "status": "needed", "pixellab_spec": "player_idle"},
        "walk1":   {"file": "player_walk1.png",  "status": "needed", "pixellab_spec": "player_walk1"},
        "walk2":   {"file": "player_walk2.png",  "status": "needed", "pixellab_spec": "player_walk2"},
        "walk3":   {"file": "player_walk3.png",  "status": "needed", "pixellab_spec": "player_walk3"},
        "walk4":   {"file": "player_walk4.png",  "status": "needed", "pixellab_spec": "player_walk4"},
        "jump":    {"file": "player_jump.png",   "status": "needed", "pixellab_spec": "player_jump"}
      },
      "sheet_layout": ["idle", "walk1", "walk2", "walk3", "walk4", "jump"],
      "sheet_status": "needed"
    },
    "wolf": {
      "frame_w": 32, "frame_h": 20,
      "output": "game/assets/creatures/wolf_sheet.png",
      "frames": {
        "idle":    {"file": "wolf_idle.png",     "status": "needed", "pixellab_spec": "wolf_idle"},
        "walk1":   {"file": "wolf_walk1.png",    "status": "needed", "pixellab_spec": "wolf_walk1"},
        "walk2":   {"file": "wolf_walk2.png",    "status": "needed", "pixellab_spec": "wolf_walk2"},
        "walk3":   {"file": "wolf_walk3.png",    "status": "needed", "pixellab_spec": "wolf_walk3"},
        "walk4":   {"file": "wolf_walk4.png",    "status": "needed", "pixellab_spec": "wolf_walk4"},
        "attack":  {"file": "wolf_attack.png",   "status": "needed", "pixellab_spec": "wolf_attack"}
      },
      "sheet_layout": ["idle", "walk1", "walk2", "walk3", "walk4", "attack"],
      "sheet_status": "needed"
    },
    "rabbit": {
      "frame_w": 16, "frame_h": 16,
      "output": "game/assets/creatures/rabbit_sheet.png",
      "frames": {
        "idle":    {"file": "rabbit_idle.png",   "status": "needed", "pixellab_spec": "rabbit_idle"},
        "hop1":    {"file": "rabbit_hop1.png",   "status": "needed", "pixellab_spec": "rabbit_hop1"},
        "hop2":    {"file": "rabbit_hop2.png",   "status": "needed", "pixellab_spec": "rabbit_hop2"}
      },
      "sheet_layout": ["idle", "hop1", "hop2"],
      "sheet_status": "needed"
    },
    "bird": {
      "frame_w": 12, "frame_h": 10,
      "output": "game/assets/creatures/bird_sheet.png",
      "frames": {
        "perched": {"file": "bird_perched.png",  "status": "needed", "pixellab_spec": "bird_perched"},
        "flap1":   {"file": "bird_flap1.png",    "status": "needed", "pixellab_spec": "bird_flap1"},
        "flap2":   {"file": "bird_flap2.png",    "status": "needed", "pixellab_spec": "bird_flap2"}
      },
      "sheet_layout": ["perched", "flap1", "flap2"],
      "sheet_status": "needed"
    }
  },

  "tiles": {
    "dirt":       {"file": "tile_dirt.png",       "status": "needed", "output": "game/assets/tiles/terrain/dirt.png"},
    "grass_dirt": {"file": "tile_grass_dirt.png", "status": "needed", "output": "game/assets/tiles/terrain/grass_dirt.png"},
    "stone":      {"file": "tile_stone.png",      "status": "needed", "output": "game/assets/tiles/terrain/stone.png"},
    "clay":       {"file": "tile_clay.png",       "status": "needed", "output": "game/assets/tiles/terrain/clay.png"},
    "coal_ore":   {"file": "tile_coal_ore.png",   "status": "needed", "output": "game/assets/tiles/ores/coal_ore.png"},
    "copper_ore": {"file": "tile_copper_ore.png", "status": "needed", "output": "game/assets/tiles/ores/copper_ore.png"},
    "iron_ore":   {"file": "tile_iron_ore.png",   "status": "needed", "output": "game/assets/tiles/ores/iron_ore.png"},
    "wood_plank": {"file": "tile_wood_plank.png", "status": "needed", "output": "game/assets/tiles/structures/wood_plank.png"}
  },

  "backgrounds": {
    "bg_sky":          {"file": "bg_sky.png",          "status": "needed", "output": "game/assets/backgrounds/bg_sky.png"},
    "bg_industrial":   {"file": "bg_industrial.png",   "status": "needed", "output": "game/assets/backgrounds/bg_industrial_tier1.png"}
  },

  "power": {
    "coal_furnace":   {"file": "power_furnace.png",   "status": "needed", "output": "game/assets/power/tier1/furnace.png"},
    "water_boiler":   {"file": "power_boiler.png",    "status": "needed", "output": "game/assets/power/tier1/water_boiler.png"},
    "steam_turbine":  {"file": "power_turbine.png",   "status": "needed", "output": "game/assets/power/tier1/steam_turbine.png"},
    "power_pole":     {"file": "power_pole.png",      "status": "needed", "output": "game/assets/power/tier1/power_pole.png"}
  },

  "ui": {
    "hotbar_slot":    {"file": "ui_hotbar_slot.png",  "status": "needed", "output": "game/assets/ui/hotbar_slot.png"},
    "status_icon_base":{"file": "ui_status_icon.png", "status": "needed", "output": "game/assets/ui/status_icon_base.png"},
    "light_radial":   {"file": "ui_light_radial.png", "status": "needed", "output": "game/assets/ui/light_radial.png"}
  }
}
```

---

## PHASE 2: BUILD THE PIPELINE ORCHESTRATOR

Create `workshop/pipeline/pipeline.py` — the master automation script:

```python
#!/usr/bin/env python3
"""
Terra.Watt Asset Pipeline
Orchestrates PixelLab → raw storage → Aseprite assembly → Godot assets

Usage:
  python pipeline.py                    # process all needed assets
  python pipeline.py --check            # audit status only, no generation
  python pipeline.py --character player # process one character only
  python pipeline.py --assemble-only    # skip PixelLab, just run Aseprite
"""

import json
import os
import sys
import shutil
import subprocess
import argparse
from pathlib import Path
from PIL import Image

# ── CONFIG ────────────────────────────────────────────────────────────────────
MANIFEST_PATH   = Path("workshop/pipeline/manifest.json")
RAW_PATH        = Path("workshop/raw_assets")
ASEPRITE        = Path(r"C:\Program Files\Aseprite\Aseprite.exe")
MIN_VALID_BYTES = 500  # files under this are failed downloads

# ── UTILITIES ─────────────────────────────────────────────────────────────────

def load_manifest():
    with open(MANIFEST_PATH) as f:
        return json.load(f)

def save_manifest(data):
    with open(MANIFEST_PATH, "w") as f:
        json.dump(data, f, indent=2)
    print("Manifest saved.")

def validate_png(path: Path) -> tuple[bool, str]:
    """Check a PNG is valid and large enough."""
    if not path.exists():
        return False, "file not found"
    size = path.stat().st_size
    if size < MIN_VALID_BYTES:
        return False, f"too small ({size} bytes — likely failed download)"
    try:
        img = Image.open(path)
        img.verify()
        return True, f"ok ({size} bytes, {img.size[0]}x{img.size[1]})"
    except Exception as e:
        return False, f"corrupt: {e}"

def run_aseprite(*args) -> bool:
    """Run Aseprite in batch (headless) mode."""
    if not ASEPRITE.exists():
        print(f"ERROR: Aseprite not found at {ASEPRITE}")
        return False
    cmd = [str(ASEPRITE), "--batch"] + [str(a) for a in args]
    result = subprocess.run(cmd, capture_output=True, text=True)
    if result.returncode != 0:
        print(f"Aseprite error: {result.stderr[:200]}")
        return False
    return True

def ensure_dir(path: Path):
    path.mkdir(parents=True, exist_ok=True)

# ── SHEET ASSEMBLY ─────────────────────────────────────────────────────────────

def assemble_character_sheet(name: str, char_data: dict) -> bool:
    """
    Assembles individual frame PNGs into a horizontal sprite sheet.
    Validates each frame, resizes to exact dimensions, stitches together.
    Also creates an .aseprite source file for manual editing.
    """
    frame_w = char_data["frame_w"]
    frame_h = char_data["frame_h"]
    layout  = char_data["sheet_layout"]
    frames  = char_data["frames"]
    output  = Path(char_data["output"])

    print(f"\nAssembling sheet: {name} ({frame_w}x{frame_h}, {len(layout)} frames)")

    frame_images = []
    all_valid = True

    for frame_id in layout:
        frame_info = frames[frame_id]
        raw_path   = RAW_PATH / "characters" / frame_info["file"]
        valid, msg = validate_png(raw_path)

        if not valid:
            print(f"  ❌ {frame_id}: {msg}")
            all_valid = False
            # Use a magenta placeholder so missing frames are obvious
            placeholder = Image.new("RGBA", (frame_w, frame_h), (255, 0, 255, 180))
            frame_images.append(placeholder)
        else:
            img = Image.open(raw_path).convert("RGBA")
            # Resize to exact frame dimensions using nearest neighbour (pixel art)
            img = img.resize((frame_w, frame_h), Image.NEAREST)
            frame_images.append(img)
            print(f"  ✅ {frame_id}: {msg}")

    # Stitch horizontal strip
    total_w = frame_w * len(frame_images)
    sheet   = Image.new("RGBA", (total_w, frame_h), (0, 0, 0, 0))
    for i, frame in enumerate(frame_images):
        sheet.paste(frame, (i * frame_w, 0))

    ensure_dir(output.parent)
    sheet.save(str(output), "PNG")
    sheet_size = output.stat().st_size
    print(f"  Sheet saved: {output} ({total_w}x{frame_h}px, {sheet_size} bytes)")

    # Create .aseprite source file for manual editing
    ase_path = output.with_suffix(".aseprite")
    if run_aseprite(str(output), "--save-as", str(ase_path)):
        print(f"  Aseprite source: {ase_path}")
    
    return all_valid

def copy_simple_asset(raw_file: str, output_path: str) -> bool:
    """Copy a single-frame asset (tile, UI, background) to Godot assets."""
    # Try multiple raw subfolders
    src = None
    for subdir in ["tiles", "backgrounds", "ui", "power", "characters", ""]:
        candidate = RAW_PATH / subdir / raw_file if subdir else RAW_PATH / raw_file
        if candidate.exists():
            src = candidate
            break

    if not src:
        print(f"  ❌ {raw_file}: not found in raw_assets/")
        return False

    valid, msg = validate_png(src)
    if not valid:
        print(f"  ❌ {raw_file}: {msg}")
        return False

    dest = Path(output_path)
    ensure_dir(dest.parent)
    shutil.copy2(str(src), str(dest))
    print(f"  ✅ {raw_file} → {dest}")
    return True

# ── STATUS AUDIT ──────────────────────────────────────────────────────────────

def audit(manifest: dict):
    """Print full status of all assets without making changes."""
    print("\n" + "="*60)
    print("TERRA.WATT ASSET PIPELINE — STATUS AUDIT")
    print("="*60)

    needed = complete = missing = 0

    print("\nCHARACTERS:")
    for name, data in manifest["characters"].items():
        print(f"  {name} ({data['frame_w']}x{data['frame_h']}):")
        for frame_id, info in data["frames"].items():
            raw = RAW_PATH / "characters" / info["file"]
            valid, msg = validate_png(raw)
            status = "✅" if valid else "❌"
            print(f"    {status} {frame_id}: {msg}")
            if valid: complete += 1
            else: missing += 1

    print("\nTILES:")
    for name, info in manifest["tiles"].items():
        raw = RAW_PATH / "tiles" / info["file"]
        valid, msg = validate_png(raw)
        print(f"  {'✅' if valid else '❌'} {name}: {msg}")
        if valid: complete += 1
        else: missing += 1

    print("\nBACKGROUNDS:")
    for name, info in manifest["backgrounds"].items():
        raw = RAW_PATH / "backgrounds" / info["file"]
        valid, msg = validate_png(raw)
        print(f"  {'✅' if valid else '❌'} {name}: {msg}")
        if valid: complete += 1
        else: missing += 1

    print("\nPOWER STRUCTURES:")
    for name, info in manifest["power"].items():
        raw = RAW_PATH / "power" / info["file"]
        valid, msg = validate_png(raw)
        print(f"  {'✅' if valid else '❌'} {name}: {msg}")
        if valid: complete += 1
        else: missing += 1

    print("\nUI ELEMENTS:")
    for name, info in manifest["ui"].items():
        raw = RAW_PATH / "ui" / info["file"]
        valid, msg = validate_png(raw)
        print(f"  {'✅' if valid else '❌'} {name}: {msg}")
        if valid: complete += 1
        else: missing += 1

    total = complete + missing
    print(f"\nSUMMARY: {complete}/{total} raw assets valid")
    print(f"  Missing/invalid: {missing}")
    print(f"  PixelLab generations still needed: {missing}")
    print("="*60)

# ── ASSEMBLE ALL ──────────────────────────────────────────────────────────────

def assemble_all(manifest: dict):
    """Assemble all sprite sheets and copy all simple assets to game/."""
    print("\nAssembling all assets to game/...")

    # Characters → sprite sheets
    for name, data in manifest["characters"].items():
        assemble_character_sheet(name, data)

    # Tiles → direct copy
    print("\nCopying tiles...")
    for name, info in manifest["tiles"].items():
        copy_simple_asset(info["file"], info["output"])

    # Backgrounds → direct copy
    print("\nCopying backgrounds...")
    for name, info in manifest["backgrounds"].items():
        copy_simple_asset(info["file"], info["output"])

    # Power structures → direct copy
    print("\nCopying power structures...")
    for name, info in manifest["power"].items():
        copy_simple_asset(info["file"], info["output"])

    # UI elements → direct copy
    print("\nCopying UI elements...")
    for name, info in manifest["ui"].items():
        copy_simple_asset(info["file"], info["output"])

    print("\nAssembly complete. Open Godot to reimport.")

# ── ENTRY POINT ───────────────────────────────────────────────────────────────

if __name__ == "__main__":
    parser = argparse.ArgumentParser(description="Terra.Watt Asset Pipeline")
    parser.add_argument("--check", action="store_true", help="Audit only")
    parser.add_argument("--assemble-only", action="store_true", help="Skip PixelLab, just assemble")
    parser.add_argument("--character", help="Process one character only")
    args = parser.parse_args()

    manifest = load_manifest()

    if args.check:
        audit(manifest)
    elif args.assemble_only or args.character:
        if args.character:
            char = manifest["characters"].get(args.character)
            if char:
                assemble_character_sheet(args.character, char)
            else:
                print(f"Unknown character: {args.character}")
        else:
            assemble_all(manifest)
    else:
        audit(manifest)
        print("\nRun with --assemble-only to build sheets from existing raw assets.")
        print("Art agents (V3/V4/V5) will generate missing PixelLab frames first.")
```

---

## PHASE 3: CREATE THE VALIDATE SCRIPT

Create `workshop/pipeline/validate.py` — quick health check:

```python
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
                ok.append(f"✅ {p.name} ({w}x{h}, {size}b)")
        except Exception as e:
            errors.append(f"CORRUPT: {path_str} — {e}")

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

    print(f"\n✅ Valid: {len(ok)}")
    for line in ok:
        print(f"  {line}")

    if errors:
        print(f"\n❌ Errors: {len(errors)}")
        for line in errors:
            print(f"  {line}")
    else:
        print("\nAll assets valid. Ready for Godot import.")

if __name__ == "__main__":
    check_all()
```

---

## PHASE 4: INSTALL PILLOW AND TEST

```powershell
pip install Pillow

# Test the pipeline runs
python workshop/pipeline/pipeline.py --check
```

Report the full audit output. This shows exactly how many PixelLab
generations V3/V4/V5 need to make.

---

## PHASE 5: COMMIT

```powershell
git add workshop/pipeline/manifest.json
git add workshop/pipeline/pipeline.py
git add workshop/pipeline/validate.py
git status
git commit -m "[Pipeline] feat: asset manifest + pipeline orchestrator + validate script"
git push origin main
```

---

## FINAL REPORT

```
PIPELINE BUILDER — FINAL REPORT

✅ manifest.json created: [N] assets tracked
✅ pipeline.py created: orchestrates raw→sheet→godot flow
✅ validate.py created: health check for game/assets/
✅ Pillow installed
✅ pipeline.py --check runs successfully

Audit results:
  Characters needing PixelLab: [N] frames
  Tiles needing PixelLab: [N]
  Backgrounds needing PixelLab: [N]
  Power needing PixelLab: [N]
  UI needing PixelLab: [N]
  TOTAL generations needed: [N]

Self-Audit Complete. Pipeline ready. V3/V4/V5 can now run.
```
