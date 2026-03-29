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
MIN_VALID_BYTES = 100  # tiny 12x10 pixel PNGs can be ~170b; below this treat as failed/corrupt

# ── UTILITIES ─────────────────────────────────────────────────────────────────

def load_manifest():
    with open(MANIFEST_PATH) as f:
        return json.load(f)


def manifest_output_path(info: dict) -> str:
    """Manifest v2 uses `dest`; v1 used `output`."""
    return info.get("output") or info.get("dest")


def resolve_raw_root(manifest: dict) -> Path:
    rc = manifest.get("paths", {}).get("raw_characters")
    if rc:
        return Path(rc).parent
    p = manifest.get("raw_assets_path")
    return Path(p) if p else RAW_PATH

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
        return False, f"too small ({size} bytes - likely failed download)"
    try:
        with Image.open(path) as img:
            img.verify()
        with Image.open(path) as img:
            img.load()
            w, h = img.size
        return True, f"ok ({size} bytes, {w}x{h})"
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

def assemble_character_sheet_v2(name: str, char_data: dict, manifest: dict) -> bool:
    """
    Manifest v2: frames is a list of pose names; raws are {name}_{pose}.png.
    Player sheet → game/assets/player/player_sheet.png; others → creatures/{name}_sheet.png
    """
    frame_w = char_data["frame_w"]
    frame_h = char_data["frame_h"]
    frames_list = char_data["frames"]
    raw_root = Path(manifest["paths"]["raw_characters"])
    dest = Path(char_data.get("dest", f"game/assets/creatures/{name}_sheet.png"))
    if name == "player":
        dest = Path("game/assets/player/player_sheet.png")

    print(f"\nAssembling sheet (v2): {name} ({frame_w}x{frame_h}, {len(frames_list)} frames)")

    frame_images = []
    all_valid = True
    for pose in frames_list:
        raw_path = raw_root / f"{name}_{pose}.png"
        valid, msg = validate_png(raw_path)
        if not valid:
            print(f"  [X] {pose}: {msg}")
            all_valid = False
            frame_images.append(Image.new("RGBA", (frame_w, frame_h), (255, 0, 255, 180)))
        else:
            img = Image.open(raw_path).convert("RGBA").resize((frame_w, frame_h), Image.NEAREST)
            frame_images.append(img)
            print(f"  [OK] {pose}: {msg}")

    total_w = frame_w * len(frame_images)
    sheet = Image.new("RGBA", (total_w, frame_h), (0, 0, 0, 0))
    for i, frame in enumerate(frame_images):
        sheet.paste(frame, (i * frame_w, 0))

    ensure_dir(dest.parent)
    sheet.save(str(dest), "PNG")
    print(f"  Sheet saved: {dest} ({total_w}x{frame_h}px, {dest.stat().st_size} bytes)")

    ase_path = dest.with_suffix(".aseprite")
    if run_aseprite(str(dest), "--save-as", str(ase_path)):
        print(f"  Aseprite source: {ase_path}")

    return all_valid


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
            print(f"  [X] {frame_id}: {msg}")
            all_valid = False
            # Use a magenta placeholder so missing frames are obvious
            placeholder = Image.new("RGBA", (frame_w, frame_h), (255, 0, 255, 180))
            frame_images.append(placeholder)
        else:
            img = Image.open(raw_path).convert("RGBA")
            # Resize to exact frame dimensions using nearest neighbour (pixel art)
            img = img.resize((frame_w, frame_h), Image.NEAREST)
            frame_images.append(img)
            print(f"  [OK] {frame_id}: {msg}")

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
        print(f"  [X] {raw_file}: not found in raw_assets/")
        return False

    valid, msg = validate_png(src)
    if not valid:
        print(f"  [X] {raw_file}: {msg}")
        return False

    dest = Path(output_path)
    ensure_dir(dest.parent)
    shutil.copy2(str(src), str(dest))
    print(f"  [OK] {raw_file} -> {dest}")
    return True

# ── STATUS AUDIT ──────────────────────────────────────────────────────────────

def audit(manifest: dict):
    """Print full status of all assets without making changes."""
    print("\n" + "="*60)
    print("TERRA.WATT ASSET PIPELINE - STATUS AUDIT")
    print("="*60)

    needed = complete = missing = 0

    print("\nCHARACTERS:")
    for name, data in manifest["characters"].items():
        print(f"  {name} ({data['frame_w']}x{data['frame_h']}):")
        frames = data.get("frames")
        if isinstance(frames, list):
            master = data.get("master")
            if master:
                raw = RAW_PATH / "characters" / master
                valid, msg = validate_png(raw)
                status = "[OK]" if valid else "[X]"
                print(f"    {status} master {master}: {msg}")
                if valid:
                    complete += 1
                else:
                    missing += 1
            for frame_id in frames:
                fr = RAW_PATH / "characters" / f"{name}_{frame_id}.png"
                fv, fm = validate_png(fr)
                st = "[OK]" if fv else "[X]"
                print(f"    {st} {frame_id}: {fm}")
                if fv:
                    complete += 1
                else:
                    missing += 1
        else:
            for frame_id, info in frames.items():
                raw = RAW_PATH / "characters" / info["file"]
                valid, msg = validate_png(raw)
                status = "[OK]" if valid else "[X]"
                print(f"    {status} {frame_id}: {msg}")
                if valid:
                    complete += 1
                else:
                    missing += 1

    print("\nTILES:")
    for name, info in manifest["tiles"].items():
        raw = RAW_PATH / "tiles" / info["file"]
        valid, msg = validate_png(raw)
        out = manifest_output_path(info)
        print(f"  {'[OK]' if valid else '[X]'} {name}: {msg} -> {out}")
        if valid:
            complete += 1
        else:
            missing += 1

    print("\nBACKGROUNDS:")
    for name, info in manifest["backgrounds"].items():
        raw = RAW_PATH / "backgrounds" / info["file"]
        valid, msg = validate_png(raw)
        out = manifest_output_path(info)
        print(f"  {'[OK]' if valid else '[X]'} {name}: {msg} -> {out}")
        if valid:
            complete += 1
        else:
            missing += 1

    print("\nPOWER STRUCTURES:")
    for name, info in manifest["power"].items():
        raw = RAW_PATH / "power" / info["file"]
        valid, msg = validate_png(raw)
        out = manifest_output_path(info)
        print(f"  {'[OK]' if valid else '[X]'} {name}: {msg} -> {out}")
        if valid:
            complete += 1
        else:
            missing += 1

    print("\nUI ELEMENTS:")
    for name, info in manifest["ui"].items():
        raw = RAW_PATH / "ui" / info["file"]
        valid, msg = validate_png(raw)
        out = manifest_output_path(info)
        print(f"  {'[OK]' if valid else '[X]'} {name}: {msg} -> {out}")
        if valid:
            complete += 1
        else:
            missing += 1

    total = complete + missing
    print(f"\nSUMMARY: {complete}/{total} raw assets valid")
    print(f"  Missing/invalid: {missing}")
    print(f"  PixelLab generations still needed: {missing}")
    print("="*60)

# ── ASSEMBLE ALL ──────────────────────────────────────────────────────────────

def assemble_all(manifest: dict):
    """Assemble all sprite sheets and copy all simple assets to game/."""
    print("\nAssembling all assets to game/...")

    # Characters → sprite sheets (v1: dict + sheet_layout; v2: list frames + derive_frames)
    for name, data in manifest["characters"].items():
        if data.get("sheet_layout") and isinstance(data.get("frames"), dict):
            assemble_character_sheet(name, data)
        elif isinstance(data.get("frames"), list):
            assemble_character_sheet_v2(name, data, manifest)
        else:
            print(f"\n[skip] {name}: unknown character manifest shape")

    # Tiles → direct copy
    print("\nCopying tiles...")
    for name, info in manifest["tiles"].items():
        copy_simple_asset(info["file"], manifest_output_path(info))

    # Backgrounds → direct copy
    print("\nCopying backgrounds...")
    for name, info in manifest["backgrounds"].items():
        copy_simple_asset(info["file"], manifest_output_path(info))

    # Power structures → direct copy
    print("\nCopying power structures...")
    for name, info in manifest["power"].items():
        copy_simple_asset(info["file"], manifest_output_path(info))

    # UI elements → direct copy
    print("\nCopying UI elements...")
    for name, info in manifest["ui"].items():
        copy_simple_asset(info["file"], manifest_output_path(info))

    print("\nAssembly complete. Open Godot to reimport.")

# ── ENTRY POINT ───────────────────────────────────────────────────────────────

def main():
    global ASEPRITE, RAW_PATH
    parser = argparse.ArgumentParser(description="Terra.Watt Asset Pipeline")
    parser.add_argument("--check", action="store_true", help="Audit only")
    parser.add_argument("--assemble-only", action="store_true", help="Skip PixelLab, just assemble")
    parser.add_argument("--character", "--char", dest="character", help="Process one character only")
    args = parser.parse_args()

    manifest = load_manifest()
    if manifest.get("aseprite"):
        ASEPRITE = Path(manifest["aseprite"])
    elif manifest.get("aseprite_path"):
        ASEPRITE = Path(manifest["aseprite_path"])
    RAW_PATH = resolve_raw_root(manifest)
    if manifest.get("raw_assets_path") and not manifest.get("paths"):
        RAW_PATH = Path(manifest["raw_assets_path"])

    if args.check:
        audit(manifest)
    elif args.assemble_only or args.character:
        if args.character:
            char = manifest["characters"].get(args.character)
            if char and char.get("sheet_layout") and isinstance(char.get("frames"), dict):
                assemble_character_sheet(args.character, char)
            elif char and isinstance(char.get("frames"), list):
                assemble_character_sheet_v2(args.character, char, manifest)
            elif char:
                print("Character entry has no sheet_layout (v1) or frames list (v2).")
            else:
                print(f"Unknown character: {args.character}")
        else:
            assemble_all(manifest)
    else:
        audit(manifest)
        print("\nRun with --assemble-only to build sheets from existing raw assets.")
        print("Art agents (V3/V4/V5) will generate missing PixelLab frames first.")

if __name__ == "__main__":
    main()
