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
import argparse
import sys

RAW = Path("workshop/raw_assets/characters")

# Final master dimensions (PixelLab map objects may be larger — center-cropped)
EXPECTED = {
    "player": (24, 40),
    "wolf": (32, 20),
    "rabbit": (16, 16),
    "bird": (12, 10),
}


def _fit_to_expected(img: Image.Image, tw: int, th: int) -> Image.Image:
    """Scale to cover (uniform), then center-crop to exact pixel dimensions."""
    w, h = img.size
    if w == tw and h == th:
        return img
    scale = max(tw / w, th / h)
    nw = max(1, int(round(w * scale)))
    nh = max(1, int(round(h * scale)))
    img = img.resize((nw, nh), Image.NEAREST)
    left = (nw - tw) // 2
    top = (nh - th) // 2
    return img.crop((left, top, left + tw, top + th))


def load_master(name: str) -> Image.Image:
    p = RAW / f"{name}_master.png"
    if not p.exists():
        raise FileNotFoundError(f"Master missing: {p}\nRun PixelLab generation first.")
    size = p.stat().st_size
    if size < 350:
        raise ValueError(f"Master too small ({size}b) - likely failed download: {p}")
    img = Image.open(p).convert("RGBA")
    tw, th = EXPECTED[name]
    img = _fit_to_expected(img, tw, th)
    print(f"  Loaded: {p.name} ({img.width}x{img.height}, {size}b)")
    return img


def save_frame(img: Image.Image, name: str, pose: str) -> Path:
    p = RAW / f"{name}_{pose}.png"
    img.save(str(p), "PNG")
    print(f"  -> {p.name} ({p.stat().st_size}b)")
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
    print("  Player: 6 frames OK")


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
    print("  Wolf: 6 frames OK")


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
    print("  Rabbit: 3 frames OK")


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
    print("  Bird: 3 frames OK")


# ── STATUS CHECK ──────────────────────────────────────────────────────────────

def check():
    print("\nFrame Deriver Status Check")
    print("=" * 40)
    chars = {
        "player": ["idle", "walk1", "walk2", "walk3", "walk4", "jump"],
        "wolf": ["idle", "walk1", "walk2", "walk3", "walk4", "attack"],
        "rabbit": ["idle", "hop1", "hop2"],
        "bird": ["perched", "flap1", "flap2"],
    }
    for char, frames in chars.items():
        master = RAW / f"{char}_master.png"
        m_status = f"OK {master.stat().st_size}b" if master.exists() and master.stat().st_size > 350 else "MISSING"
        print(f"\n{char} - master: {m_status}")
        for frame in frames:
            p = RAW / f"{char}_{frame}.png"
            status = f"OK {p.stat().st_size}b" if p.exists() else "NO"
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
        "bird": bird_frames,
    }

    if args.char:
        if args.char in targets:
            try:
                targets[args.char]()
            except (FileNotFoundError, ValueError) as e:
                print(f"ERROR: {e}")
        else:
            print(f"Unknown character: {args.char}")
            print(f"Available: {list(targets.keys())}")
    else:
        errors = []
        for name, fn in targets.items():
            try:
                fn()
            except (FileNotFoundError, ValueError) as e:
                print(f"  WARN Skipped {name}: {e}")
                errors.append(name)

        print("\n" + "=" * 40)
        if errors:
            print(f"WARN {len(errors)} characters need masters first: {errors}")
        else:
            print("OK All frames derived.")
            print("Next: python pipeline.py --assemble-only")
