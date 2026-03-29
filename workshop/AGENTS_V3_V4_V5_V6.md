━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
TERRAWATT — VISUAL OVERHAUL AGENT V3: CHARACTERS
Single command: Paste into Cursor Composer Agent tab.
Run simultaneously with V4 and V5 after V2 Pipeline is complete.
PIXELLAB BUDGET: 18 generations (player×6, wolf×6, rabbit×3, bird×3)
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

## MISSION: Generate all character frame PNGs via PixelLab. Assemble into sprite sheets.

CRITICAL EFFICIENCY RULES:
- Check manifest.json and raw_assets/ BEFORE generating anything
- If a raw PNG already exists and is valid (>500 bytes) — DO NOT regenerate it
- Generate only what is truly missing
- After ALL frames for a character are ready → run pipeline.py to assemble

---

## PHASE 0: RECON

```powershell
git pull origin main
python workshop/pipeline/pipeline.py --check
Get-ChildItem -Path "workshop\raw_assets\characters" -Filter "*.png" | Select-Object Name, Length
```

Report exactly which character frames already exist vs are missing.
Only generate what is missing.

---

## PHASE 1: CONSISTENCY PALETTE REFERENCE

Every character frame MUST use these exact colours.
Copy this into EVERY PixelLab prompt as the palette section.

```
PLAYER PALETTE (use for ALL player frames):
  Hardhat:    #8B5E3C (brown) with #00AAFF gem
  Vest:       #FFB300 (amber yellow)
  Armour:     #8899AA (steel grey)
  Pants:      #6B4A10 (dark leather brown)
  Boots:      #5C3D1A (very dark brown)
  Skin:       #C68642 (warm tan)
  Backpack:   #8B6914 (worn brown leather)

WOLF PALETTE (use for ALL wolf frames):
  Body:       #3A3A3A (dark grey)
  Highlight:  #5A5A5A (lighter grey)
  Eyes:       #FFB300 (amber)
  Teeth:      #F5F5F5 (off-white)
  Nose:       #1A1A1A (near black)

RABBIT PALETTE (use for ALL rabbit frames):
  Body:       #C8A882 (light brown)
  Belly:      #F5E6D3 (cream)
  Eyes:       #2A1A0A (very dark brown)
  Nose:       #E8928C (pink)
  Inner ear:  #E8928C (pink)

BIRD PALETTE (use for ALL bird frames):
  Body:       #8B6914 (warm brown)
  Wings:      #5C3D1A (dark brown)
  Belly:      #C8A882 (lighter tan)
  Beak/legs:  #F5C842 (yellow)
  Eyes:       #1A1A0A (near black)
```

---

## PHASE 2: GENERATE PLAYER FRAMES (6 generations)

For EACH missing player frame, use this exact prompt structure.
Generate one at a time. Validate size after each before moving on.

IMPORTANT CONSISTENCY LINE — include in every player prompt:
"Same character as previous frames: brown hardhat, yellow vest, grey armour,
brown pants, dark boots, backpack. Exact same proportions and palette."

### player_idle.png
```
Generate pixel art for Terra.Watt game, 24x40 pixels exactly.
Industrial miner standing idle, side view facing right.
Brown hardhat with small cyan gem. Yellow hi-vis safety vest over
grey armoured chest with rivets. Brown leather work pants.
Heavy dark brown boots. Small brown backpack on back.
Weight resting on left foot, relaxed stance, hands at sides.
Palette: hardhat #8B5E3C, vest #FFB300, armour #8899AA,
pants #6B4A10, boots #5C3D1A, skin #C68642.
Style: chunky pixel art, Terraria proportions, transparent background,
no outlines, warm lighting from above left.
Save to: workshop/raw_assets/characters/player_idle.png
```

### player_walk1.png
```
Generate pixel art for Terra.Watt game, 24x40 pixels exactly.
Same character as player_idle: brown hardhat, yellow vest, grey armour,
brown pants, dark boots, backpack. Exact same palette.
Walking pose frame 1: left foot forward, right foot back,
torso leaning very slightly forward, left arm back, right arm forward.
Transparent background, chunky pixel art style.
Save to: workshop/raw_assets/characters/player_walk1.png
```

### player_walk2.png
```
[same header and palette as above]
Walking pose frame 2: mid-stride, feet coming together,
body upright, arms crossing at center.
Save to: workshop/raw_assets/characters/player_walk2.png
```

### player_walk3.png
```
[same header and palette]
Walking pose frame 3: right foot forward, left foot back,
torso leaning slightly forward opposite to frame 1.
Save to: workshop/raw_assets/characters/player_walk3.png
```

### player_walk4.png
```
[same header and palette]
Walking pose frame 4: feet returning to center, mid recovery,
arms returning to neutral.
Save to: workshop/raw_assets/characters/player_walk4.png
```

### player_jump.png
```
[same header and palette]
Jumping pose: both legs bent and tucked, arms raised slightly
for balance, body slightly compressed. Mid-air feeling.
Save to: workshop/raw_assets/characters/player_jump.png
```

After ALL 6 player frames generated, validate:
```powershell
Get-ChildItem "workshop\raw_assets\characters\player_*.png" | Select-Object Name, Length
```
Every file must be over 500 bytes. Flag any that are not.

---

## PHASE 3: GENERATE WOLF FRAMES (6 generations)

CONSISTENCY LINE for all wolf prompts:
"Same wolf as previous frames: dark grey body #3A3A3A, lighter grey highlights
#5A5A5A, amber eyes #FFB300, white teeth. Low predatory stance. Same proportions."

### wolf_idle.png
```
Generate pixel art creature for Terra.Watt, 32x20 pixels exactly.
Dark grey wolf, side view facing right, standing alert.
Ears up, tail low, amber eyes glowing slightly.
Body #3A3A3A, highlights #5A5A5A, eyes #FFB300, teeth #F5F5F5.
Low predatory stance, weight slightly forward.
Chunky pixel art, transparent background, no outlines.
Save to: workshop/raw_assets/characters/wolf_idle.png
```

### wolf_walk1.png through wolf_walk4.png
Follow same pattern as player walk frames.
Wolf gait: front left and back right move together (diagonal pairs).
```
wolf_walk1: front left paw and back right paw forward
wolf_walk2: mid stride, paws near center
wolf_walk3: front right and back left paw forward
wolf_walk4: mid recovery
```

### wolf_attack.png
```
[same header and palette]
Attack pose: lunging forward aggressively, front paws extended,
mouth open showing teeth, ears pinned back, eyes focused.
Save to: workshop/raw_assets/characters/wolf_attack.png
```

---

## PHASE 4: GENERATE RABBIT FRAMES (3 generations)

CONSISTENCY LINE: "Same rabbit: light brown body #C8A882, cream belly #F5E6D3,
dark eyes #2A1A0A, pink nose. Same proportions."

### rabbit_idle.png
```
Generate pixel art creature for Terra.Watt, 16x16 pixels exactly.
Small fluffy rabbit sitting upright, slight 3/4 view.
Light brown body, cream belly patch, big round dark eyes, pink nose.
Ears standing straight up. Tiny paws in front.
Palette: body #C8A882, belly #F5E6D3, eyes #2A1A0A, nose/ears #E8928C.
Cute chunky pixel art, transparent background.
Save to: workshop/raw_assets/characters/rabbit_idle.png
```

### rabbit_hop1.png
```
[same header and palette]
Mid-hop pose: airborne, back legs fully extended downward,
front paws tucked in, ears streaming back from speed.
Body slightly stretched. Clearly in the air.
Save to: workshop/raw_assets/characters/rabbit_hop1.png
```

### rabbit_hop2.png
```
[same header and palette]
Landing pose: front paws touching ground, back legs still high,
body compressed slightly on impact, ears forward.
Save to: workshop/raw_assets/characters/rabbit_hop2.png
```

---

## PHASE 5: GENERATE BIRD FRAMES (3 generations)

CONSISTENCY LINE: "Same bird: warm brown body #8B6914, dark brown wings #5C3D1A,
cream belly #C8A882, yellow beak and legs #F5C842."

### bird_perched.png
```
Generate pixel art creature for Terra.Watt, 12x10 pixels exactly.
Tiny sparrow perched, side view facing right. Round body, tiny beak.
Warm brown body, darker wing tips, yellow beak and twig legs.
Palette: body #8B6914, wings #5C3D1A, belly #C8A882, beak/legs #F5C842.
Cute minimal pixel art, transparent background.
Save to: workshop/raw_assets/characters/bird_perched.png
```

### bird_flap1.png
```
[same header and palette]
Wings raised up pose: wings lifted above body at peak of flap,
body slightly lowered. In flight.
Save to: workshop/raw_assets/characters/bird_flap1.png
```

### bird_flap2.png
```
[same header and palette]
Wings down pose: wings fully extended downward at bottom of flap,
body slightly raised. Propulsion moment.
Save to: workshop/raw_assets/characters/bird_flap2.png
```

---

## PHASE 6: ASSEMBLE ALL CHARACTER SHEETS

Once ALL frames for a character are validated (>500 bytes each):

```powershell
# Assemble all character sheets
python workshop/pipeline/pipeline.py --assemble-only

# Verify output sheets
python workshop/pipeline/validate.py
```

Expected outputs in game/assets/:
```
player/player_sheet.png    — 144×40px (6 frames × 24px)
creatures/wolf_sheet.png   — 192×20px (6 frames × 32px)
creatures/rabbit_sheet.png —  48×16px (3 frames × 16px)
creatures/bird_sheet.png   —  36×10px (3 frames × 12px)
```

---

## PHASE 7: UPDATE CREATURE CODE FOR NEW DIMENSIONS

Wolf changed from 24×16 to 32×20. Update wolf.gd frame regions:
```gdscript
# In wolf.gd _setup_sprite() — update AtlasTexture regions:
# Each frame is 32×20px
# idle:    Rect2(0,   0, 32, 20)
# walk_1:  Rect2(32,  0, 32, 20)
# walk_2:  Rect2(64,  0, 32, 20)
# walk_3:  Rect2(96,  0, 32, 20)
# walk_4:  Rect2(128, 0, 32, 20)
# attack:  Rect2(160, 0, 32, 20)
```

Rabbit changed to 16×16. Update rabbit.gd:
```gdscript
# Each frame 16×16px
# idle:  Rect2(0,  0, 16, 16)
# hop_1: Rect2(16, 0, 16, 16)
# hop_2: Rect2(32, 0, 16, 16)
```

Bird changed to 12×10. Update bird.gd:
```gdscript
# Each frame 12×10px
# perched: Rect2(0,  0, 12, 10)
# fly_1:   Rect2(12, 0, 12, 10)
# fly_2:   Rect2(24, 0, 12, 10)
```

---

## PHASE 8: COMMIT

```powershell
git add workshop/raw_assets/characters/
git add game/assets/player/player_sheet.png game/assets/player/player.aseprite
git add game/assets/creatures/
git add game/creatures/wolf.gd game/creatures/rabbit.gd game/creatures/bird.gd
git add workshop/pipeline/manifest.json
git status
git commit -m "[V3-Characters] feat: all character frames generated, sheets assembled"
git push origin main
```

---

## FINAL REPORT

```
V3 CHARACTERS — FINAL REPORT

PixelLab generations used: [N]/18
Raw frames valid:
  Player:  [N]/6 ✅
  Wolf:    [N]/6 ✅
  Rabbit:  [N]/3 ✅
  Bird:    [N]/3 ✅

Sheets assembled:
  player_sheet.png:  ✅/❌ [dimensions] [size]
  wolf_sheet.png:    ✅/❌ [dimensions] [size]
  rabbit_sheet.png:  ✅/❌ [dimensions] [size]
  bird_sheet.png:    ✅/❌ [dimensions] [size]

Frame dimensions updated in code: ✅/❌

Self-Audit Complete. Character art pipeline complete.
```

━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
TERRAWATT — VISUAL OVERHAUL AGENT V4: WORLD ART
Single command: Paste into Cursor Composer Agent tab.
Run simultaneously with V3 and V5.
PIXELLAB BUDGET: 10 generations (tiles×8, backgrounds×2)
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

## MISSION: Generate all world tiles and backgrounds. Wire into TileSet.

---

## PHASE 0: RECON

```powershell
git pull origin main
python workshop/pipeline/pipeline.py --check
Get-ChildItem "workshop\raw_assets\tiles" -Filter "*.png" | Select-Object Name, Length
Get-ChildItem "workshop\raw_assets\backgrounds" -Filter "*.png" | Select-Object Name, Length
```

Only generate what is missing from raw_assets/.

---

## PHASE 1: TILE CONSISTENCY RULES

All tiles are 16×16px. All use this style guide:
```
Style: painterly pixel art tile, detailed natural texture,
no hard outlines, subtle subsurface lighting from above,
slightly gritty, Terra.Watt industrial era feel.
Background: solid colour (NOT transparent) — tiles fill space completely.
```

---

## PHASE 2: GENERATE TERRAIN TILES (4 generations)

### tile_dirt.png
```
Generate pixel art terrain tile for Terra.Watt, 16x16 pixels exactly.
Dirt/soil tile. Warm brown cracked earth.
Varied texture — some darker clumps, lighter patches, tiny pebbles.
Palette: base #8B6914, dark clumps #6B4A10, light patches #9C7A3C,
tiny rocks #7A6A50.
Style: painterly, detailed, no outlines, lit from above.
Solid background (no transparency). Tileable.
Save to: workshop/raw_assets/tiles/tile_dirt.png
```

### tile_grass_dirt.png
```
Terrain tile 16x16px. Grass-topped dirt.
Top 4 pixels: bright green grass blades #4A7C2F with slight variation.
Bottom 12 pixels: dirt (same as dirt tile).
Grass blades have slight variation in height and shade.
Clearly readable as grass-covered earth. Solid background.
Palette: grass #4A7C2F, dark grass #2E5A1E, roots #6B4A10.
Save to: workshop/raw_assets/tiles/tile_grass_dirt.png
```

### tile_stone.png
```
Terrain tile 16x16px. Natural stone/granite.
Grey rocky texture with natural crack lines, slight blue-grey tint.
Subtle variation — some lighter areas, some darker veins.
Palette: base #6B6B6B, cracks #4A4A4A, highlights #8A8A8A, blue tint #555566.
Solid background. Painterly texture.
Save to: workshop/raw_assets/tiles/tile_stone.png
```

### tile_clay.png
```
Terrain tile 16x16px. Clay deposit.
Smooth reddish-ochre clay with layered horizontal bands.
Slightly glossy texture compared to stone.
Palette: base #A0785A, bands #8B6040, highlight #C09070.
Solid background.
Save to: workshop/raw_assets/tiles/tile_clay.png
```

---

## PHASE 3: GENERATE ORE TILES (4 generations)

Ore tiles = stone base with visible ore deposits embedded.

### tile_coal_ore.png
```
Terrain tile 16x16px. Coal ore embedded in stone.
Stone base (#6B6B6B) with 3-4 chunks of glossy near-black coal.
Coal chunks: irregular shapes, slightly reflective, #1A1A1A to #2A2A2A.
Coal makes up roughly 30% of the tile surface.
No outlines. Painterly. Solid background.
Save to: workshop/raw_assets/tiles/tile_coal_ore.png
```

### tile_copper_ore.png
```
Terrain tile 16x16px. Copper ore in stone.
Stone base with copper-orange vein flecks and small nuggets.
Copper colour: warm orange-brown #B87333 with #D4943A highlights.
Veins are thin and branching, nuggets are small clusters.
Solid background.
Save to: workshop/raw_assets/tiles/tile_copper_ore.png
```

### tile_iron_ore.png
```
Terrain tile 16x16px. Iron ore in stone.
Stone base with metallic silver-blue iron deposits.
Iron: blue-grey metallic streaks #8A8A9A with #AAAACC highlights.
Deposits look like flat metallic sheets embedded in rock.
Solid background.
Save to: workshop/raw_assets/tiles/tile_iron_ore.png
```

### tile_wood_plank.png
```
Terrain tile 16x16px. Wooden plank (placed/built material).
Horizontal wood grain, visible boards with gaps, small nail heads.
Warm brown #8B6914 with darker grain lines #6B4A10.
Lighter knot highlights #9C7A3C.
Looks like rough-hewn construction lumber. Solid background.
Save to: workshop/raw_assets/tiles/tile_wood_plank.png
```

After generating, validate all 8 tile PNGs > 500 bytes.

---

## PHASE 4: GENERATE BACKGROUNDS (2 generations)

### bg_sky.png
```
Generate pixel art background for Terra.Watt, 320x180 pixels.
Deep night sky with stars — this is the far background layer.
Dark navy gradient from #0A0A1A (top) to #151525 (bottom).
Scattered white and pale blue star points, varying sizes.
2-3 faint purple-blue nebula wisps barely visible.
Very faint distant mountain silhouette at bottom edge #0D0D1F.
Style: painterly, atmospheric, hand-painted feel.
Save to: workshop/raw_assets/backgrounds/bg_sky.png
```

### bg_industrial.png
```
Background layer for Terra.Watt Tier 1, 320x180 pixels, transparent background.
Dark industrial silhouette — composited over the sky layer.
One large brick smokestack (dominant, slightly left of center).
Faint smoke wisps rising from it.
Two smaller factory building silhouettes in background.
Distant power line poles on the right.
Colour: very dark #1A1005 silhouette, slight amber haze #3D2A0A near horizon.
Painterly, ominous, industrial era. PNG with transparency.
Save to: workshop/raw_assets/backgrounds/bg_industrial.png
```

---

## PHASE 5: COPY TO GODOT VIA PIPELINE

```powershell
# Copy all tiles and backgrounds to game/assets/
python workshop/pipeline/pipeline.py --assemble-only

# Verify
python workshop/pipeline/validate.py
```

---

## PHASE 6: UPDATE TILESET RESOURCE

In `game/scripts/create_tileset.gd` (or wherever the TileSet is built),
verify each tile ID maps to the correct new PNG path.

The mapping must match WorldData constants exactly:
```
TILE_AIR=0        → no texture (transparent)
TILE_DIRT=1       → game/assets/tiles/terrain/dirt.png
TILE_STONE=2      → game/assets/tiles/terrain/stone.png
TILE_GRASS_DIRT=3 → game/assets/tiles/terrain/grass_dirt.png
TILE_COAL=4       → game/assets/tiles/ores/coal_ore.png
TILE_COPPER_ORE=5 → game/assets/tiles/ores/copper_ore.png
TILE_IRON_ORE=6   → game/assets/tiles/ores/iron_ore.png
TILE_CLAY=7       → game/assets/tiles/terrain/clay.png
```

Update any paths that reference old locations.

---

## COMMIT

```powershell
git add workshop/raw_assets/tiles/
git add workshop/raw_assets/backgrounds/
git add game/assets/tiles/
git add game/assets/backgrounds/
git add game/scripts/create_tileset.gd
git add workshop/pipeline/manifest.json
git status
git commit -m "[V4-World] feat: all tile and background art generated and wired"
git push origin main
```

---

## FINAL REPORT

```
V4 WORLD ART — FINAL REPORT

PixelLab generations used: [N]/10
Tiles: [N]/8 valid ✅
Backgrounds: [N]/2 valid ✅
TileSet paths updated: ✅/❌

Self-Audit Complete. World art pipeline complete.
```

━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
TERRAWATT — VISUAL OVERHAUL AGENT V5: UI & POWER ART
Single command: Paste into Cursor Composer Agent tab.
Run simultaneously with V3 and V4.
PIXELLAB BUDGET: 7 generations (power×4, UI×3)
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

## MISSION: Generate power structure sprites and UI elements. Wire into scenes.

---

## PHASE 0: RECON

```powershell
git pull origin main
python workshop/pipeline/pipeline.py --check
Get-ChildItem "workshop\raw_assets\power" -Filter "*.png" | Select-Object Name, Length
Get-ChildItem "workshop\raw_assets\ui" -Filter "*.png" | Select-Object Name, Length
```

---

## PHASE 1: POWER STRUCTURE SPRITES (4 generations)

All power structures use this style:
```
Style: 1880s industrial era machinery. Cast iron, copper fittings,
brass details. Painterly pixel art. Warm lamp-lit shadows.
Transparent background (PNG with alpha).
```

### power_furnace.png
```
Generate pixel art machine for Terra.Watt, 32x48 pixels exactly.
Coal-fired furnace. 1880s industrial cast iron boiler.
Brick-lined firebox at bottom with iron door showing orange glow.
Short iron chimney at top with heat shimmer.
Copper pipe fittings on sides. Pressure gauge dial on front.
Palette: iron body #2A2A2A, brick lining #8B4513, 
fire glow #FF6A00, copper #B87333, gauge face #F5F5DC.
Transparent background. Detailed painterly pixel art.
Save to: workshop/raw_assets/power/power_furnace.png
```

### power_boiler.png
```
Generate pixel art machine for Terra.Watt, 32x48 pixels exactly.
Water boiler / steam pressure vessel. Round iron cylinder, riveted seams.
Pressure gauge on front face (large and prominent).
Water inlet pipe on top. Steam outlet pipe on side with valve.
Slight condensation drips on surface.
Palette: iron body #3A3A3A, rivets #4A4A4A, 
gauge face #F5F5DC, copper pipes #B87333, steam #DDEEFF.
Transparent background.
Save to: workshop/raw_assets/power/power_boiler.png
```

### power_turbine.png
```
Generate pixel art machine for Terra.Watt, 48x32 pixels exactly.
Steam turbine + generator unit. Horizontal orientation.
Left side: turbine housing with spinning blade slots (motion lines).
Right side: generator housing with output terminals and amber warning light.
Connected by iron shaft in center.
Palette: iron housing #2E2E2E, copper terminals #B87333,
amber light #FFB300, blade glimpse #8899AA.
Transparent background.
Save to: workshop/raw_assets/power/power_turbine.png
```

### power_pole.png
```
Generate pixel art structure for Terra.Watt, 16x64 pixels exactly.
Wooden utility power pole. Tall and narrow.
Creosote-stained dark brown wood grain.
Cross-arm near top with 2 ceramic insulators.
Small amber bulb glow at very top.
Wire attachment points on cross-arm.
Palette: wood #3D1F0A, cross-arm #4A2810, 
insulators #C8B89A, amber glow #FFB300.
Transparent background.
Save to: workshop/raw_assets/power/power_pole.png
```

---

## PHASE 2: USE ASEPRITE TO CREATE ANIMATED VARIANTS

The furnace, boiler, and turbine need animated versions.
Use Aseprite CLI to create 2-frame "operating" animations:

```python
# workshop/pipeline/animate_power.py
import subprocess
from pathlib import Path
from PIL import Image, ImageEnhance

ASEPRITE = Path(r"C:\Program Files\Aseprite\Aseprite.exe")
RAW = Path("workshop/raw_assets/power")

def create_glow_variant(source_path: Path, output_path: Path, glow_intensity: float = 0.2):
    """Creates a slightly brightened/warmer 'active' variant of a power structure."""
    img = Image.open(source_path).convert("RGBA")
    # Slightly boost brightness for the "active" frame
    enhancer = ImageEnhance.Brightness(img)
    active = enhancer.enhance(1.0 + glow_intensity)
    # Add slight warm tint to non-transparent pixels
    r, g, b, a = active.split()
    r = r.point(lambda x: min(x + 15, 255))  # slight red/warm boost
    active = Image.merge("RGBA", (r, g, b, a))
    active.save(str(output_path))
    print(f"Created active variant: {output_path}")

# Furnace: idle and burning variants
create_glow_variant(
    RAW / "power_furnace.png",
    Path("game/assets/power/tier1/furnace_active.png"),
    glow_intensity=0.3
)
# Boiler: idle and pressurised variants  
create_glow_variant(
    RAW / "power_boiler.png",
    Path("game/assets/power/tier1/boiler_active.png"),
    glow_intensity=0.2
)
# Turbine: idle and spinning variants
create_glow_variant(
    RAW / "power_turbine.png",
    Path("game/assets/power/tier1/turbine_active.png"),
    glow_intensity=0.25
)
```

```powershell
python workshop/pipeline/animate_power.py
```

---

## PHASE 3: UI ELEMENTS (3 generations)

### ui_hotbar_slot.png
```
Generate pixel art UI element for Terra.Watt, 40x40 pixels exactly.
Hotbar inventory slot. Industrial steampunk aesthetic.
Dark background #1A1A2E with subtle copper border #B87333.
Riveted corner details (tiny copper dots at corners).
Slightly recessed panel look — inner shadow.
No fantasy elements. Worn metal equipment panel feel.
Transparent background (the slot itself has alpha where items show).
Save to: workshop/raw_assets/ui/ui_hotbar_slot.png
```

### ui_status_icon_base.png
```
Generate pixel art UI element for Terra.Watt, 16x16 pixels exactly.
Status icon background circle/badge for above-player icons.
Dark semi-transparent circle, thin coloured border.
Should work as a base for overlaid status symbols.
Dark fill #1A1A2E at 80% opacity. Thin border 1px #B87333.
Transparent background outside the circle.
Save to: workshop/raw_assets/ui/ui_status_icon.png
```

### ui_light_radial.png
```
Generate a soft radial light gradient, 128x128 pixels exactly.
White/pale yellow centre fading to completely transparent edges.
Used as PointLight2D texture for player headlamp in Godot.
Pure gradient — no shapes, no details.
Centre: #FFFDF0 (warm white), edges: fully transparent.
Smooth falloff. PNG with alpha.
Save to: workshop/raw_assets/ui/ui_light_radial.png
```

---

## PHASE 4: COPY ALL TO GODOT VIA PIPELINE

```powershell
python workshop/pipeline/pipeline.py --assemble-only
python workshop/pipeline/validate.py
```

Then copy power active variants (these bypass pipeline since they're script-generated):
```powershell
Copy-Item "workshop/raw_assets/power/power_furnace.png" "game/assets/power/tier1/furnace.png" -Force
Copy-Item "workshop/raw_assets/power/power_boiler.png"  "game/assets/power/tier1/water_boiler.png" -Force
Copy-Item "workshop/raw_assets/power/power_turbine.png" "game/assets/power/tier1/steam_turbine.png" -Force
Copy-Item "workshop/raw_assets/power/power_pole.png"    "game/assets/power/tier1/power_pole.png" -Force
```

---

## COMMIT

```powershell
git add workshop/raw_assets/power/ workshop/raw_assets/ui/
git add game/assets/power/ game/assets/ui/
git add workshop/pipeline/animate_power.py
git add workshop/pipeline/manifest.json
git status
git commit -m "[V5-UI-Power] feat: power structures and UI elements generated and wired"
git push origin main
```

---

## FINAL REPORT

```
V5 UI & POWER — FINAL REPORT

Power structures: [N]/4 ✅
Active variants created via Aseprite: ✅/❌
UI elements: [N]/3 ✅
All copied to game/assets/: ✅/❌

Self-Audit Complete. UI and power art complete.
```

━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
TERRAWATT — VISUAL OVERHAUL AGENT V6: VERIFY
Single command: Paste into Cursor Composer Agent tab.
Run LAST after V3, V4, and V5 all show COMPLETE in AGENT_STATUS.md
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

## MISSION: Final validation. Ensure everything is in Godot and working.

---

## PHASE 0: WAIT FOR ALL ART AGENTS

```powershell
git pull origin main
grep "STATUS:" workshop/AGENT_STATUS.md
```

All three (V3, V4, V5) must show COMPLETE before proceeding.
Poll every 3 minutes if not ready.

---

## PHASE 1: RUN FULL PIPELINE VALIDATION

```powershell
python workshop/pipeline/validate.py
python workshop/pipeline/pipeline.py --check
```

Report: how many assets valid, how many still missing.
For anything still missing — generate or fix NOW before Godot step.

---

## PHASE 2: TELL DEVELOPER TO DO GODOT IMPORT

Write clear instructions for the developer:

```
DEVELOPER ACTION REQUIRED — ~5 minutes manual:

1. Open Godot 4
2. Open project from: TerraWattv2/game/project.godot
3. Let the FileSystem panel finish loading
4. For EACH of these PNG files, single-click it in FileSystem,
   click the Import tab on the left, change Preset to "2D Pixel",
   click Reimport:

   game/assets/player/player_sheet.png
   game/assets/creatures/wolf_sheet.png
   game/assets/creatures/rabbit_sheet.png
   game/assets/creatures/bird_sheet.png
   game/assets/tiles/terrain/dirt.png
   game/assets/tiles/terrain/grass_dirt.png
   game/assets/tiles/terrain/stone.png
   game/assets/tiles/terrain/clay.png
   game/assets/tiles/ores/coal_ore.png
   game/assets/tiles/ores/copper_ore.png
   game/assets/tiles/ores/iron_ore.png

5. Press F5 to run the game
6. Report back what you see
```

---

## PHASE 3: UPDATE AGENT_STATUS.md

```markdown
## Visual Overhaul (V1-V6) — [DATE]
STATUS: COMPLETE — AWAITING GODOT IMPORT CONFIRMATION

COMPLETED:
  - Folder restructure: game/ and workshop/ separated
  - Asset pipeline: manifest.json + pipeline.py + validate.py
  - Character art: player (6 frames), wolf (6), rabbit (3), bird (3)
  - Tile art: 8 terrain/ore tiles
  - Background art: sky + industrial tier1
  - Power art: furnace, boiler, turbine, pole + active variants
  - UI art: hotbar slot, status icon, light radial
  - All sheets assembled via Aseprite pipeline
  - All assets in game/assets/ ready for Godot import

TOTAL PIXELLAB GENERATIONS USED: [N]/35

EXPORTS:
  game/assets/player/player_sheet.png    — 144×40px, 6 frames
  game/assets/creatures/wolf_sheet.png   — 192×20px, 6 frames
  game/assets/creatures/rabbit_sheet.png —  48×16px, 3 frames
  game/assets/creatures/bird_sheet.png   —  36×10px, 3 frames
  game/assets/tiles/                     — 8 tiles ready
  game/assets/backgrounds/               — 2 backgrounds ready
  game/assets/power/tier1/               — 4 structures + active variants
  game/assets/ui/                        — 3 UI elements ready
```

---

## FINAL REPORT

```
V6 VERIFY — FINAL REPORT

Pipeline validation:
  Assets valid in game/assets/: [N]/35
  Missing or invalid: [N]

Godot import:
  ⏳ Awaiting developer to set 2D Pixel presets and confirm F5

Visual checklist (to be confirmed by developer):
  [ ] Player has real miner sprite (not taco)
  [ ] Wolf has real wolf sprite (not square)
  [ ] Rabbit has real rabbit sprite (not square)
  [ ] World tiles are painterly (not flat colour)
  [ ] No performance lag
  [ ] Power structures visible when placed
  [ ] Backgrounds render with parallax

Self-Audit Complete. Visual overhaul delivered.
Ball is in Godot's court — set 2D Pixel presets and press F5.
```
