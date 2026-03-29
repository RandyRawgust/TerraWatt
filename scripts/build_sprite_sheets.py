from PIL import Image
import os

def make_sprite_sheet(source_path, output_path, frame_w, frame_h, num_frames):
    """Take a single image and tile it into a horizontal sprite sheet."""
    if not os.path.exists(source_path):
        print(f"MISSING: {source_path}")
        return False

    src = Image.open(source_path).convert("RGBA")
    # Resize source to exact frame dimensions
    src = src.resize((frame_w, frame_h), Image.NEAREST)

    # Build horizontal strip
    sheet = Image.new("RGBA", (frame_w * num_frames, frame_h), (0, 0, 0, 0))
    for i in range(num_frames):
        sheet.paste(src, (i * frame_w, 0))

    os.makedirs(os.path.dirname(output_path), exist_ok=True)
    sheet.save(output_path, compress_level=0)
    size = os.path.getsize(output_path)
    print(f"Created: {output_path} ({size} bytes, {num_frames} frames)")
    return True


# Player: 6 frames of 24x40
make_sprite_sheet(
    "assets/player/player_raw.png",
    "assets/player/player_sheet.png",
    24, 40, 6
)

# Wolf: 6 frames of 24x16
make_sprite_sheet(
    "assets/creatures/wolf_raw.png",
    "assets/creatures/wolf_sheet.png",
    24, 16, 6
)

# Rabbit: 3 frames of 12x12
make_sprite_sheet(
    "assets/creatures/rabbit_raw.png",
    "assets/creatures/rabbit_sheet.png",
    12, 12, 3
)

# Bird: 3 frames of 10x8
make_sprite_sheet(
    "assets/creatures/bird_raw.png",
    "assets/creatures/bird_sheet.png",
    10, 8, 3
)

print("Done. Open Godot and reimport assets/.")
