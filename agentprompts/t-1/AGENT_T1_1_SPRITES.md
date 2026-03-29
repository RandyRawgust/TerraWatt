TERRAWATT — TIER 1 SPRITES AGENT
Single command: Paste this entire block into a Cursor Composer Agent tab and press Enter.
Run simultaneously with other Tier 1 agents after Preflight completes.
Art is fully independent — this agent does not depend on any other Tier 1 agent.

━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

## MISSION: Replace all placeholder art with real PixelLab-generated sprites.

You are the SPRITES AGENT. Your entire job is art replacement.
No gameplay code. No scene rewiring. Pure asset delivery.

---

## PHASE 0: DOCTRINE + RECON (MANDATORY)

1. Read `TERRAWATT_DOCTRINE.md` — specifically:
   - PIXELLAB MCP ART GENERATION section
   - Visual identity in GDD Section 0 (player description)
   - GDD Section 17 (PixelLab prompt parameters and color hex values)
   - RETROSPECTIVE § "Visual art, shell automation, and TileSet workflow"
     KEY LESSON: Validate downloaded files — check file SIZE. Files under
     100 bytes or uniform white are failed downloads. Regenerate those only.

2. Read `res://assets/ASSET_MANIFEST.md` if it exists — note what's already generated.

3. Survey current placeholder state:
```bash
dir res\assets\player       # Windows
dir res\assets\creatures
ls res/assets/player        # Mac/Linux
ls res/assets/creatures
```
Report exactly which files exist vs are missing.

---

## PHASE 1: PLAYER SPRITE

### Generate via PixelLab MCP

```
Generate pixel art sprite sheet for Terra.Watt player character.
Single PNG containing all frames arranged horizontally.

Character description (from GDD):
  Industrial miner. Brown hardhat with mounted headlamp gem (small cyan crystal).
  Yellow safety vest over grey armored chest plate with subtle rivets.
  Brown leather work pants. Heavy brown work boots.
  Backpack visible on back when facing right.
  Rugged, working-class, practical. NOT heroic or fantasy.

Frame layout (left to right, each frame 24x40 pixels):
  Frame 0: idle — standing neutral, slight weight to stance
  Frame 1: walk_1 — left foot forward
  Frame 2: walk_2 — both feet together (mid stride)
  Frame 3: walk_3 — right foot forward
  Frame 4: walk_4 — both feet together (mid stride)
  Frame 5: jump — legs bent, arms slightly out for balance

Total image size: 144x40 pixels (6 frames × 24px wide)

Style: chunky readable pixel art, Starbound-inspired warmth.
Palette:
  Hardhat: #8B5E3C (brown) with #00AAFF gem
  Vest: #FFB300 (amber yellow)
  Armour: #8899AA (steel grey)
  Pants: #6B4A10 (dark leather brown)
  Boots: #5C3D1A (very dark brown)
  Skin: #C68642 (warm tan)
Background: transparent (PNG with alpha)

Save to: res://assets/player/player_sheet.png
```

**Validate immediately after generation:**
```bash
# Windows PowerShell:
(Get-Item "res/assets/player/player_sheet.png").Length
# Mac/Linux:
ls -la res/assets/player/player_sheet.png
```
File must be larger than 500 bytes. If smaller, it is a failed download — regenerate.

### Wire into Godot

In `res://player/player.gd`, replace any PlaceholderTexture or broken reference:

```gdscript
func _ready() -> void:
    add_to_group("player")
    _setup_sprite_frames()

# Sets up AnimatedSprite2D from the generated sprite sheet.
func _setup_sprite_frames() -> void:
    var texture: Texture2D = load("res://assets/player/player_sheet.png")
    if not texture:
        push_warning("Player: sprite sheet not found, using placeholder")
        return

    var frames: SpriteFrames = SpriteFrames.new()

    # Helper: create one animation from frame index in the horizontal strip
    var _add = func(anim_name: String, start: int, end: int, fps: float, loop: bool) -> void:
        frames.add_animation(anim_name)
        frames.set_animation_loop(anim_name, loop)
        frames.set_animation_speed(anim_name, fps)
        for i in range(start, end + 1):
            var atlas: AtlasTexture = AtlasTexture.new()
            atlas.atlas = texture
            atlas.region = Rect2(i * 24, 0, 24, 40)
            frames.add_frame(anim_name, atlas)

    _add.call("idle", 0, 0, 1.0,  true)
    _add.call("walk", 1, 4, 8.0,  true)
    _add.call("jump", 5, 5, 1.0, false)

    $AnimatedSprite2D.sprite_frames = frames
    $AnimatedSprite2D.texture_filter = CanvasItem.TEXTURE_FILTER_NEAREST
    $AnimatedSprite2D.play("idle")
```

---

## PHASE 2: WOLF SPRITE

```
Generate pixel art sprite sheet for Terra.Watt wolf creature.
Single PNG, frames arranged horizontally, each frame 24x16 pixels.

Description:
  Dark grey wolf. Slightly larger than a normal wolf — threatening.
  Low to the ground, predatory posture. Visible teeth when attacking.
  Eyes glow faintly amber in darkness.

Frame layout (left to right):
  Frame 0: idle — standing alert, ears up
  Frame 1: walk_1 — mid stride left
  Frame 2: walk_2 — mid stride right
  Frame 3: walk_3 — other foot forward
  Frame 4: walk_4 — recovery
  Frame 5: attack — lunging forward, mouth open

Total: 144x16 pixels (6 frames × 24px)
Palette: dark grey #3A3A3A body, #6B6B6B highlights, #FFB300 eyes
Background: transparent
Save to: res://assets/creatures/wolf_sheet.png
```

Validate file size > 300 bytes. Regenerate if failed.

In `res://creatures/wolf.gd`, replace ColorRect placeholder:

```gdscript
func _setup_sprite() -> void:
    var texture: Texture2D = load("res://assets/creatures/wolf_sheet.png")
    if not texture:
        return  # ColorRect placeholder remains

    var frames: SpriteFrames = SpriteFrames.new()
    var _add = func(name: String, start: int, end: int, fps: float) -> void:
        frames.add_animation(name)
        frames.set_animation_loop(name, true)
        frames.set_animation_speed(name, fps)
        for i in range(start, end + 1):
            var atlas: AtlasTexture = AtlasTexture.new()
            atlas.atlas = texture
            atlas.region = Rect2(i * 24, 0, 24, 16)
            frames.add_frame(name, atlas)

    _add.call("idle",   0, 0, 1.0)
    _add.call("walk",   1, 4, 8.0)
    _add.call("attack", 5, 5, 4.0)

    var sprite := AnimatedSprite2D.new()
    sprite.sprite_frames = frames
    sprite.texture_filter = CanvasItem.TEXTURE_FILTER_NEAREST
    sprite.play("idle")
    add_child(sprite)

    # Remove ColorRect placeholder if present
    var placeholder := get_node_or_null("ColorRect")
    if placeholder:
        placeholder.queue_free()
```

Call `_setup_sprite()` from `_ready()`.

---

## PHASE 3: RABBIT SPRITE

```
Generate pixel art sprite sheet for Terra.Watt rabbit critter.
Single PNG, frames horizontal, each frame 12x12 pixels.

Description:
  Small fluffy rabbit. Light brown with white belly patch.
  Big dark eyes. Short tail. Looks slightly startled always.
  Endearing and harmless.

Frame layout:
  Frame 0: idle — sitting upright, ears up
  Frame 1: hop_up — launching, ears back
  Frame 2: hop_land — landing, legs splayed

Total: 36x12 pixels (3 frames × 12px)
Palette: #C8A882 body, #F5E6D3 belly, #2A1A0A eyes
Background: transparent
Save to: res://assets/creatures/rabbit_sheet.png
```

In `res://creatures/rabbit.gd`, same pattern as wolf but 12×12 frames.
3 animations: idle (frame 0), hop (frames 0-2, 6fps), flee (frames 1-2, 12fps).

---

## PHASE 4: BIRD SPRITE

```
Generate pixel art sprite sheet for Terra.Watt small bird critter.
Single PNG, frames horizontal, each frame 10x8 pixels.

Description:
  Small sparrow. Warm brown with darker wing tips.
  Tiny beak, round body, twig legs. Cheerful.

Frame layout:
  Frame 0: perched — sitting still
  Frame 1: flap_up — wings raised
  Frame 2: flap_down — wings lowered

Total: 30x8 pixels (3 frames × 10px)
Palette: #8B6914 brown, #5C3D1A dark wings, #F5C842 beak
Background: transparent
Save to: res://assets/creatures/bird_sheet.png
```

In `res://creatures/bird.gd`, 10×8 frames.
2 animations: perched (frame 0), fly (frames 1-2, 8fps loop).

---

## PHASE 5: UPDATE ASSET MANIFEST

Update or create `res://assets/ASSET_MANIFEST.md`:
```markdown
# Terra.Watt Asset Manifest
Last updated: [date]

## Player
- player_sheet.png — 144×40px, 6 frames (idle, walk×4, jump), 24×40 per frame

## Creatures
- wolf_sheet.png   — 144×16px, 6 frames (idle, walk×4, attack), 24×16 per frame
- rabbit_sheet.png —  36×12px, 3 frames (idle, hop×2), 12×12 per frame
- bird_sheet.png   —  30×8px,  3 frames (perched, flap×2), 10×8 per frame

## Tiles (Scope 1, carried forward)
[list existing tiles]

## TODO (future art debt)
- Tier 1 coal furnace sprite
- Tier 1 boiler sprite
- Tier 1 steam turbine sprite
- Tier 1 generator sprite
- Power pole sprites
- Conveyor belt animation
```

---

## PHASE 6: COMMIT (path-scoped only)

```bash
git add res/assets/player/player_sheet.png
git add res/assets/creatures/wolf_sheet.png res/assets/creatures/rabbit_sheet.png res/assets/creatures/bird_sheet.png
git add res/assets/ASSET_MANIFEST.md
git add res/player/player.gd res/creatures/wolf.gd res/creatures/rabbit.gd res/creatures/bird.gd
git status   # confirm ONLY these files staged
git commit -m "[Sprites] feat: real player and creature sprites via PixelLab, wired into scenes"
git push origin main
```

Update AGENT_STATUS.md:
```
## Sprites Agent (Tier 1) — [DATE]
STATUS: COMPLETE
COMPLETED:
  - player_sheet.png generated (144x40, 6 frames) and wired
  - wolf_sheet.png generated (144x16, 6 frames) and wired
  - rabbit_sheet.png generated (36x12, 3 frames) and wired
  - bird_sheet.png generated (30x8, 3 frames) and wired
  - ASSET_MANIFEST.md updated
  - All sprites use TEXTURE_FILTER_NEAREST (no blur)
EXPORTS:
  - res://assets/player/player_sheet.png
  - res://assets/creatures/wolf_sheet.png
  - res://assets/creatures/rabbit_sheet.png
  - res://assets/creatures/bird_sheet.png
```

---

## FINAL REPORT

```
SPRITES AGENT — FINAL REPORT

✅ player_sheet.png: [file size]kb — wired to player.gd AnimatedSprite2D
✅ wolf_sheet.png:   [file size]kb — wired to wolf.gd
✅ rabbit_sheet.png: [file size]kb — wired to rabbit.gd
✅ bird_sheet.png:   [file size]kb — wired to bird.gd
✅ ASSET_MANIFEST.md updated
✅ All sprites TEXTURE_FILTER_NEAREST (crisp pixel art, no blur)
✅ Committed (path-scoped git add)

Self-Audit Complete. Placeholder art eliminated. Game looks like Terra.Watt now.
```
