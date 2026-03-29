TERRAWATT — GRAPHICS OVERHAUL AGENT V2: MASTER SPRITES
Single command: Paste into Cursor Composer Agent. Run after V1 Setup is COMPLETE.
PIXELLAB BUDGET: 4 generations only (one master per character)

━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

## MISSION: Generate one perfect master sprite per character. Derive all frames from it.

THE RULE: PixelLab makes masters only. Python makes frames. Aseprite makes sheets.
This is how we guarantee consistency — every frame is the same pixels, different pose.

---

## PHASE 0: READ THE STYLE BIBLE FIRST

Open and read `workshop/TERRAWATT_STYLE_BIBLE.md` completely before generating anything.
The PixelLab prompts below are built from it. Understanding the why makes
better judgement calls when something looks off.

```powershell
git pull origin main
# Check which masters already exist and are valid (>500 bytes)
Get-ChildItem "workshop\raw_assets\characters" -Filter "*_master.png" |
    Select-Object Name, Length
```

Skip any master that already exists with size > 500 bytes.

---

## PHASE 1: GENERATE MASTER SPRITES

Generate one at a time. Validate after each before moving to the next.
Use the Style Bible prompt template exactly as written below.

### PLAYER MASTER — 1 generation

```
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
GAME: Terra.Watt
STYLE: Medium-detail pixel art (Terraria level)
MOOD: Warm earthy frontier, 1880s industrial era
LIGHTING: Upper-left 45°. Warm shadows. Amber highlights.
REFERENCE: The "Terra" (left) half of the Terra.Watt logo.
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

SUBJECT: Industrial miner player character, idle standing pose
SIZE: 24×40 pixels exactly
POSE: Neutral idle. Weight on left foot. Arms relaxed at sides.
      Side view facing right.

CHARACTER RULES:
  - DOMINANT COLOUR is yellow vest #FFB300 — this is what the eye
    sees first at small size. Make it unambiguous.
  - Hardhat shape is the most distinctive silhouette element.
    It must read clearly even at 24px width.
  - Small cyan crystal gem #88DDFF on the front of the hardhat.
    This is the player's connection to the game's energy motif.
  - Backpack bump visible on the back right side.
  - Terraria proportions: large-ish head (~8px tall), medium torso,
    shorter legs. Chunky not realistic.
  - Transparent background.
  - Outline colour: #3D2010 (dark warm brown — never pure black)

PALETTE:
  Hardhat:      #8B5E3C base, #A07848 highlight, #6B4A2A shadow
  Crystal gem:  #88DDFF with #CCF0FF bright core
  Vest:         #FFB300 base, #FFD060 highlight, #C47A00 shadow
  Chest armour: #8899AA base, #AABBCC highlight, #667788 shadow
  Pants:        #6B4A10 base, #8B6020 highlight, #4A3008 shadow
  Boots:        #5C3D1A base, #7A5028 highlight
  Skin:         #C68642 base, #D89A58 highlight, #A06830 shadow
  Backpack:     #8B6914 worn brown leather

STYLE REQUIREMENTS:
  - Chunky readable pixel art, Terraria level of detail
  - Warm earthy feel throughout
  - Transparent PNG, no background
  - Upper-left lighting baked into shading
  - No anti-aliasing, no dithering
  - Every colour from the palette list above only

SAVE TO: workshop/raw_assets/characters/player_master.png
```

Validate immediately:
```powershell
(Get-Item "workshop\raw_assets\characters\player_master.png").Length
```
Must be > 500 bytes. If not — regenerate once. If still failing — note it and continue.

---

### WOLF MASTER — 1 generation

```
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
GAME: Terra.Watt
STYLE: Medium-detail pixel art (Terraria level)
MOOD: Warm earthy frontier, 1880s industrial era
LIGHTING: Upper-left 45°. Warm shadows. Amber highlights.
REFERENCE: The "Terra" (left) half of the Terra.Watt logo.
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

SUBJECT: Hostile wolf creature, alert standing pose
SIZE: 32×20 pixels exactly
POSE: Low predatory stance. Weight forward. Ears up. Tail level.
      Side view facing right. Reads as THREAT — not cute.

CHARACTER RULES:
  - Dark grey body — this creature lives in shadow
  - Amber eyes #FFB300 are the ONLY bright element — they draw
    the eye immediately. Make them small but vivid.
  - Silhouette must read as wolf at 32px wide: four legs visible,
    pointed ears, tail, snout pointing forward.
  - Body is low to the ground, not tall and noble.
  - Transparent background.
  - Outline: #1A1A1A (near-black, not pure black)

PALETTE:
  Body:         #3A3A3A base, #5A5A5A highlight on back/head
  Underbelly:   #4A4A4A slightly lighter
  Eyes:         #FFB300 amber — small but unmissable
  Nose:         #1A1A1A dark
  Teeth:        #E8E8E8 barely visible hint
  Claws:        #2A2A2A dark
  Outline:      #1A1A1A

STYLE REQUIREMENTS:
  - Clearly recognisable as a wolf at 32×20px
  - Four legs visible and distinct
  - Predatory body language in the silhouette itself
  - Transparent PNG
  - Warm upper-left lighting even on dark grey (subtle highlights)

SAVE TO: workshop/raw_assets/characters/wolf_master.png
```

---

### RABBIT MASTER — 1 generation

```
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
GAME: Terra.Watt
STYLE: Medium-detail pixel art (Terraria level)
MOOD: Warm earthy frontier, 1880s industrial era
LIGHTING: Upper-left 45°. Warm shadows.
REFERENCE: The "Terra" (left) half of the Terra.Watt logo.
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

SUBJECT: Passive rabbit critter, sitting upright
SIZE: 16×16 pixels exactly
POSE: Sitting idle. Front paws tucked to chest.
      Ears straight up. Slight 3/4 angle.
      Reads as HARMLESS — round, soft, slightly startled.

CHARACTER RULES:
  - At 16×16 every pixel matters. Silhouette first.
  - Round body shape — no sharp angles anywhere.
  - Big dark eyes relative to head size (2×2 pixels minimum).
  - Ears take up roughly top 6px and are the tallest element.
  - Cream belly patch visible on front.
  - Transparent background.
  - Outline: #6B4A30 (dark warm brown)

PALETTE:
  Body:      #C8A882 warm light brown
  Belly:     #F5E6D3 cream patch
  Ear inner: #E8928C pink
  Nose:      #E8928C small pink dot
  Eyes:      #2A1A0A very dark, 2×2px
  Shadow:    #A07858 darker brown on lower/right
  Outline:   #6B4A30

STYLE REQUIREMENTS:
  - 16×16px — iconic simple silhouette
  - More cute than detailed — soft, round, readable
  - Transparent PNG

SAVE TO: workshop/raw_assets/characters/rabbit_master.png
```

---

### BIRD MASTER — 1 generation

```
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
GAME: Terra.Watt
STYLE: Medium-detail pixel art (Terraria level)
MOOD: Warm earthy frontier, 1880s industrial era
LIGHTING: Upper-left 45°.
REFERENCE: The "Terra" (left) half of the Terra.Watt logo.
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

SUBJECT: Tiny ambient sparrow critter, perched
SIZE: 12×10 pixels exactly
POSE: Perched still on flat surface. Side view facing right.
      Reads as AMBIENT — background life, not important.

CHARACTER RULES:
  - At 12×10px this is a TINY sprite. Silhouette only.
  - Round compact body. Short twig legs. Tiny sharp beak.
  - Wing fold visible as darker region on body.
  - Transparent background.
  - Outline: #3D2010

PALETTE:
  Body:     #8B6914 warm brown
  Wing:     #5C3D1A darker brown
  Belly:    #C8A882 lighter tan
  Beak:     #F5C842 yellow, 1-2px
  Legs:     #F5C842 yellow, twig thin
  Eye:      #1A1A0A single dark pixel
  Outline:  #3D2010

SAVE TO: workshop/raw_assets/characters/bird_master.png
```

---

## PHASE 2: BUILD derive_frames.py

Create `workshop/pipeline/derive_frames.py`:

```python
#!/usr/bin/env python3
"""
Terra.Watt Frame Deriver v2
Generates all animation frames from master sprites.
Consistency guaranteed — every frame is the same pixels, different pose.

Usage:
  python derive_frames.py              # derive all characters
  python derive_frames.py --char wolf  # derive one character only
  python derive_frames.py --check      # list what exists
"""

from PIL import Image, ImageChops
from pathlib import Path
import argparse, sys

RAW = Path("workshop/raw_assets/characters")

def load_master(name: str) -> Image.Image:
    p = RAW / f"{name}_master.png"
    if not p.exists():
        raise FileNotFoundError(f"Master missing: {p}\nRun PixelLab generation first.")
    img = Image.open(p).convert("RGBA")
    size = p.stat().st_size
    if size < 500:
        raise ValueError(f"Master too small ({size}b) — likely failed download: {p}")
    print(f"  Loaded: {p.name} ({img.width}x{img.height}, {size}b)")
    return img

def save_frame(img: Image.Image, name: str, pose: str) -> Path:
    p = RAW / f"{name}_{pose}.png"
    img.save(str(p), "PNG")
    print(f"  → {p.name} ({p.stat().st_size}b)")
    return p

def shift(img: Image.Image, dx=0, dy=0) -> Image.Image:
    """Shift entire image."""
    return ImageChops.offset(img, dx, dy)

def shift_slice(img: Image.Image, y1: int, y2: int, dx=0, dy=0) -> Image.Image:
    """Shift a horizontal slice (y1 to y2) of the image."""
    out = img.copy()
    slc = img.crop((0, y1, img.width, y2))
    slc = ImageChops.offset(slc, dx, dy)
    out.paste(slc, (0, y1))
    return out

# ── PLAYER (24×40) ────────────────────────────────────────────────────────────
# Zones: head 0-10, torso/arms 10-28, legs 28-40

def player_frames():
    print("\nPlayer frames:")
    m = load_master("player")
    save_frame(m.copy(), "player", "idle")

    # Walk: bob body 1px, shift legs alternately
    w1 = shift_slice(m, 28, 40, dx=2)   # legs right
    w1 = shift_slice(w1, 0, 28, dy=-1)  # body up
    save_frame(w1, "player", "walk1")

    save_frame(m.copy(), "player", "walk2")  # neutral

    w3 = shift_slice(m, 28, 40, dx=-2)  # legs left
    w3 = shift_slice(w3, 0, 28, dy=-1)  # body up
    save_frame(w3, "player", "walk3")

    w4 = shift_slice(m, 0, 28, dy=1)    # body down (recovery)
    save_frame(w4, "player", "walk4")

    j = shift_slice(m, 28, 40, dy=-4)   # legs tucked up
    j = shift_slice(j, 10, 28, dy=-1)   # torso up slightly
    save_frame(j, "player", "jump")
    print("  Player: 6 frames ✅")

# ── WOLF (32×20) ──────────────────────────────────────────────────────────────
# Zones: head/back 0-9, body 9-16, legs 16-20

def wolf_frames():
    print("\nWolf frames:")
    m = load_master("wolf")
    save_frame(m.copy(), "wolf", "idle")

    w1 = shift_slice(m, 14, 20, dx=3)   # back legs forward
    w1 = shift_slice(w1, 0, 14, dy=-1)  # body up
    save_frame(w1, "wolf", "walk1")

    save_frame(m.copy(), "wolf", "walk2")

    w3 = shift_slice(m, 14, 20, dx=-3)  # back legs back
    w3 = shift_slice(w3, 0, 14, dy=-1)
    save_frame(w3, "wolf", "walk3")

    w4 = shift_slice(m, 0, 14, dy=1)    # recovery
    save_frame(w4, "wolf", "walk4")

    atk = shift(m, dx=3)                # lunge forward
    atk = shift_slice(atk, 0, 9, dy=2)  # head lunges down
    save_frame(atk, "wolf", "attack")
    print("  Wolf: 6 frames ✅")

# ── RABBIT (16×16) ────────────────────────────────────────────────────────────
# Zones: ears 0-6, body 6-13, feet 13-16

def rabbit_frames():
    print("\nRabbit frames:")
    m = load_master("rabbit")
    save_frame(m.copy(), "rabbit", "idle")

    hop1 = shift(m, dy=-3)              # whole body up (airborne)
    hop1 = shift_slice(hop1, 10, 16, dy=2)  # legs extend down
    save_frame(hop1, "rabbit", "hop1")

    hop2 = shift(m, dy=1)              # body down (landing compress)
    save_frame(hop2, "rabbit", "hop2")
    print("  Rabbit: 3 frames ✅")

# ── BIRD (12×10) ──────────────────────────────────────────────────────────────
# Zones: wings/back 0-5, belly/legs 5-10

def bird_frames():
    print("\nBird frames:")
    m = load_master("bird")
    save_frame(m.copy(), "bird", "perched")

    flap1 = shift_slice(m, 0, 5, dy=-2)  # wings raise
    save_frame(flap1, "bird", "flap1")

    flap2 = shift_slice(m, 0, 5, dy=1)   # wings lower
    flap2 = shift_slice(flap2, 5, 10, dy=-1)  # body lifts
    save_frame(flap2, "bird", "flap2")
    print("  Bird: 3 frames ✅")

# ── STATUS CHECK ──────────────────────────────────────────────────────────────

def check():
    print("\nFrame Deriver Status Check")
    print("="*40)
    chars = {
        "player": ["idle","walk1","walk2","walk3","walk4","jump"],
        "wolf":   ["idle","walk1","walk2","walk3","walk4","attack"],
        "rabbit": ["idle","hop1","hop2"],
        "bird":   ["perched","flap1","flap2"]
    }
    for char, frames in chars.items():
        master = RAW / f"{char}_master.png"
        m_status = f"✅ {master.stat().st_size}b" if master.exists() and master.stat().st_size > 500 else "❌ MISSING"
        print(f"\n{char} — master: {m_status}")
        for frame in frames:
            p = RAW / f"{char}_{frame}.png"
            status = f"✅ {p.stat().st_size}b" if p.exists() else "❌"
            print(f"  {frame}: {status}")

# ── MAIN ──────────────────────────────────────────────────────────────────────

if __name__ == "__main__":
    parser = argparse.ArgumentParser()
    parser.add_argument("--char", help="Process one character only")
    parser.add_argument("--check", action="store_true")
    args = parser.parse_args()

    if args.check:
        check()
        sys.exit(0)

    print("Terra.Watt Frame Deriver v2")
    print("Deriving animation frames from master sprites...\n")

    targets = {
        "player": player_frames,
        "wolf": wolf_frames,
        "rabbit": rabbit_frames,
        "bird": bird_frames
    }

    if args.char:
        if args.char in targets:
            try:
                targets[args.char]()
            except (FileNotFoundError, ValueError) as e:
                print(f"❌ {e}")
        else:
            print(f"Unknown character: {args.char}")
            print(f"Available: {list(targets.keys())}")
    else:
        errors = []
        for name, fn in targets.items():
            try:
                fn()
            except (FileNotFoundError, ValueError) as e:
                print(f"  ⚠️  Skipped {name}: {e}")
                errors.append(name)

        print("\n" + "="*40)
        if errors:
            print(f"⚠️  {len(errors)} characters need masters first: {errors}")
        else:
            print("✅ All frames derived.")
            print("Next: python pipeline.py --assemble-only")
```

---

## PHASE 3: BUILD pipeline.py

Create `workshop/pipeline/pipeline.py`:

```python
#!/usr/bin/env python3
"""
Terra.Watt Asset Pipeline v2
Assembles sprite sheets and copies assets to game/assets/

Usage:
  python pipeline.py --check           # audit all assets
  python pipeline.py --assemble-only   # build sheets from existing frames
  python pipeline.py --char player     # assemble one character
"""

import json, shutil, subprocess, argparse, sys
from pathlib import Path
from PIL import Image

MANIFEST = Path("workshop/pipeline/manifest.json")
ASEPRITE = Path(r"C:\Program Files\Aseprite\Aseprite.exe")
MIN_BYTES = 500

def load_manifest():
    with open(MANIFEST) as f:
        return json.load(f)

def validate(path: Path):
    if not path.exists(): return False, "missing"
    size = path.stat().st_size
    if size < MIN_BYTES: return False, f"too small ({size}b)"
    try:
        Image.open(path).verify()
        return True, f"{size}b"
    except Exception as e:
        return False, f"corrupt: {e}"

def assemble_sheet(name: str, data: dict):
    fw, fh = data["frame_w"], data["frame_h"]
    frames_list = data["frames"]
    raw = Path(load_manifest()["paths"]["raw_characters"])
    dest = Path(data.get("dest", f"game/assets/creatures/{name}_sheet.png"))
    if name == "player":
        dest = Path("game/assets/player/player_sheet.png")

    print(f"\nAssembling {name} ({fw}x{fh}, {len(frames_list)} frames):")

    images = []
    for pose in frames_list:
        p = raw / f"{name}_{pose}.png"
        ok, msg = validate(p)
        if ok:
            img = Image.open(p).convert("RGBA").resize((fw, fh), Image.NEAREST)
            images.append(img)
            print(f"  ✅ {pose}: {msg}")
        else:
            print(f"  ❌ {pose}: {msg} — using magenta placeholder")
            images.append(Image.new("RGBA", (fw, fh), (255, 0, 255, 180)))

    sheet = Image.new("RGBA", (fw * len(images), fh), (0, 0, 0, 0))
    for i, img in enumerate(images):
        sheet.paste(img, (i * fw, 0))

    dest.parent.mkdir(parents=True, exist_ok=True)
    sheet.save(str(dest), "PNG")
    size = dest.stat().st_size

    # Create editable .aseprite source
    ase = dest.with_suffix(".aseprite")
    if ASEPRITE.exists():
        subprocess.run([str(ASEPRITE), "--batch", str(dest),
                       "--save-as", str(ase)], capture_output=True)
        print(f"  Aseprite source: {ase.name}")

    print(f"  Sheet: {dest} ({fw*len(images)}x{fh}px, {size}b)")

def copy_asset(src_path: str, dest_path: str, label: str):
    src = Path(src_path)
    dest = Path(dest_path)
    ok, msg = validate(src)
    if ok:
        dest.parent.mkdir(parents=True, exist_ok=True)
        shutil.copy2(str(src), str(dest))
        print(f"  ✅ {label}: {msg}")
    else:
        print(f"  ❌ {label}: {msg}")

def audit(m: dict):
    print("\n" + "="*50)
    print("TERRA.WATT ASSET PIPELINE — AUDIT")
    print("="*50)
    raw_chars = Path(m["paths"]["raw_characters"])

    print("\nCHARACTERS (masters):")
    for name, data in m["characters"].items():
        p = raw_chars / data["master"]
        ok, msg = validate(p)
        print(f"  {'✅' if ok else '❌'} {name}_master: {msg}")

    for cat in ["tiles", "backgrounds", "power", "ui"]:
        print(f"\n{cat.upper()}:")
        for name, info in m[cat].items():
            raw_subdir = cat if cat != "backgrounds" else "backgrounds"
            src = Path(m["paths"][f"raw_{raw_subdir}"] if f"raw_{raw_subdir}" in m["paths"]
                      else f"workshop/raw_assets/{cat}") / info["file"]
            ok, msg = validate(src)
            print(f"  {'✅' if ok else '❌'} {name}: {msg}")

def assemble_all(m: dict):
    raw_base = "workshop/raw_assets"
    for name, data in m["characters"].items():
        assemble_sheet(name, data)
    print("\nSIMPLE ASSETS:")
    for cat in ["tiles", "backgrounds", "power", "ui"]:
        for name, info in m[cat].items():
            src = f"{raw_base}/{cat}/{info['file']}"
            copy_asset(src, info["dest"], name)

if __name__ == "__main__":
    parser = argparse.ArgumentParser()
    parser.add_argument("--check", action="store_true")
    parser.add_argument("--assemble-only", action="store_true")
    parser.add_argument("--char", help="Assemble one character sheet")
    args = parser.parse_args()

    m = load_manifest()

    if args.check:
        audit(m)
    elif args.char:
        if args.char in m["characters"]:
            assemble_sheet(args.char, m["characters"][args.char])
        else:
            print(f"Unknown: {args.char}")
    elif args.assemble_only:
        assemble_all(m)
    else:
        audit(m)
        print("\nRun --assemble-only to build from existing raws.")
```

---

## PHASE 4: RUN AND VALIDATE

```powershell
# Check what masters exist
python workshop/pipeline/derive_frames.py --check

# Derive frames from any masters that exist
python workshop/pipeline/derive_frames.py

# Assemble sheets
python workshop/pipeline/pipeline.py --assemble-only

# Full audit
python workshop/pipeline/pipeline.py --check
```

---

## PHASE 5: COMMIT

```powershell
git add workshop/raw_assets/characters/
git add workshop/pipeline/derive_frames.py
git add workshop/pipeline/pipeline.py
git add game/assets/player/
git add game/assets/creatures/
git add workshop/pipeline/manifest.json
git status
git commit -m "[Overhaul-V2] feat: master sprites + derive_frames pipeline, sheets assembled"
git push origin main
```

---

## FINAL REPORT

```
OVERHAUL V2 MASTER SPRITES — FINAL REPORT

PixelLab generations used: [N]/4

Masters:
  player_master.png:  ✅/❌ [size]
  wolf_master.png:    ✅/❌ [size]
  rabbit_master.png:  ✅/❌ [size]
  bird_master.png:    ✅/❌ [size]

Frames derived:
  Player  6/6  Wolf  6/6  Rabbit  3/3  Bird  3/3

Sheets assembled:
  player_sheet.png:  [W]×[H]px ✅/❌
  wolf_sheet.png:    [W]×[H]px ✅/❌
  rabbit_sheet.png:  [W]×[H]px ✅/❌
  bird_sheet.png:    [W]×[H]px ✅/❌

Self-Audit Complete. 100% consistent — all frames derived from masters.
Proceed to V3 World Art.
```
