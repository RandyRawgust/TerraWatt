━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
TERRAWATT — GRAPHICS OVERHAUL AGENT V3: WORLD ART
Single command: Paste into Cursor Composer Agent tab.
Run simultaneously with V4 after V2 Master Sprites completes.
PIXELLAB BUDGET: 10 generations (tiles×8, backgrounds×2)
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

## MISSION: Generate all world tiles and both background layers.

---

## PHASE 0: RECON

Read `workshop/TERRAWATT_STYLE_BIBLE.md` first.
Focus on: tile style rules, depth shift system, logo colour extraction.

```powershell
git pull origin main
Get-ChildItem "workshop\raw_assets\tiles" -Filter "*.png" | Select-Object Name, Length
Get-ChildItem "workshop\raw_assets\backgrounds" -Filter "*.png" | Select-Object Name, Length
python workshop/pipeline/pipeline.py --check
```

Skip anything already valid (>500 bytes).

---

## TILE STYLE HEADER (paste at top of every tile prompt)

```
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
GAME: Terra.Watt
STYLE: Medium-detail pixel art (Terraria level)
MOOD: Warm earthy frontier, 1880s industrial era
LIGHTING: Upper-left 45°. Warm shadows. Amber highlights.
REFERENCE: The "Terra" (left) half of the Terra.Watt logo.
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
SIZE: 16×16 pixels exactly
TILE RULES:
  - Solid background — no transparency — every pixel filled
  - Tileable — invisible seam when 4 tiles placed 2×2
  - Three visible values: highlight, mid-tone, shadow
  - Upper-left lighting baked into texture
  - Natural/irregular texture — no mathematical patterns
  - Terraria level of detail — textured but not photorealistic
  - Warm earthy feel throughout
```

---

## PHASE 1: TERRAIN TILES (4 generations)

### tile_dirt.png
```
[PASTE TILE STYLE HEADER]
SUBJECT: Dirt/soil terrain tile
PALETTE:
  Base soil:    #8B6914
  Dark clumps:  #6B4A10
  Light patch:  #9C7A3C
  Small rocks:  #7A6A50
  Highlight:    #A08028
DESCRIPTION: Warm brown cracked earth. Varied texture with
darker clumps, lighter dry patches, occasional tiny pebbles.
Upper-left lit — top-left corner slightly lighter.
Feels like fertile frontier soil, slightly moist.
SAVE TO: workshop/raw_assets/tiles/tile_dirt.png
```

### tile_grass_dirt.png
```
[PASTE TILE STYLE HEADER]
SUBJECT: Grass-topped dirt terrain tile
PALETTE:
  Grass:        #4A7C2F
  Grass light:  #6BA84A
  Grass dark:   #2E5A1E
  Soil base:    #8B6914
  Soil dark:    #6B4A10
  Roots:        #5C3D1A
DESCRIPTION: Top 4-5 pixels are bright grass blades of varying
heights — some taller, some shorter, slight natural variation.
Below: same dirt as tile_dirt.png with root hints near the grass.
The grass-dirt boundary should look organic, not like a straight line.
SAVE TO: workshop/raw_assets/tiles/tile_grass_dirt.png
```

### tile_stone.png
```
[PASTE TILE STYLE HEADER]
SUBJECT: Natural stone/granite terrain tile
PALETTE:
  Stone base:   #6B6B7A
  Crack lines:  #4A4A55
  Highlights:   #8A8A9A
  Blue tint:    #606070
  Deep crack:   #353540
DESCRIPTION: Grey rocky texture with natural crack lines running
in irregular directions. Slight cool blue-grey tint. Some areas
slightly lighter (mineral variation), some darker (shadow/depth).
Feels solid and heavy. Upper-left lit.
SAVE TO: workshop/raw_assets/tiles/tile_stone.png
```

### tile_clay.png
```
[PASTE TILE STYLE HEADER]
SUBJECT: Clay deposit terrain tile
PALETTE:
  Clay base:    #A0785A
  Clay dark:    #8B6040
  Clay light:   #C09070
  Bands:        #906850
DESCRIPTION: Smooth reddish-ochre clay with subtle horizontal
layering bands — clay deposits form in layers underground.
Slightly smoother texture than stone. Small colour variations
suggest moisture variation. Upper-left lit.
SAVE TO: workshop/raw_assets/tiles/tile_clay.png
```

---

## PHASE 2: ORE TILES (4 generations)

All ore tiles = stone base + embedded ore.
Stone base uses tile_stone.png colours as the background.

### tile_coal_ore.png
```
[PASTE TILE STYLE HEADER]
SUBJECT: Coal ore embedded in stone
PALETTE:
  Stone base:   #6B6B7A (same as stone tile)
  Coal vein:    #1A1A1A
  Coal shine:   #2A2A35 (slightly lighter — coal is glossy)
  Coal depth:   #0A0A0F
  Stone cracks: #4A4A55
DESCRIPTION: Stone base with 3-4 irregular chunks of glossy
near-black coal ore. Coal chunks have slightly reflective quality
(a touch lighter on upper-left face). Coal covers ~30% of tile.
Chunks are irregular blobs, not geometric shapes.
SAVE TO: workshop/raw_assets/tiles/tile_coal_ore.png
```

### tile_copper_ore.png
```
[PASTE TILE STYLE HEADER]
SUBJECT: Copper ore embedded in stone
PALETTE:
  Stone base:   #6B6B7A
  Copper:       #B87333
  Copper bright:#D4943A
  Copper dark:  #8B5520
  Stone cracks: #4A4A55
DESCRIPTION: Stone base with warm copper-orange vein flecks and
small nugget clusters. Veins are thin branching lines, nuggets
are small irregular blobs. Copper has warm metallic sheen.
Copper covers ~25% of tile in an irregular vein pattern.
SAVE TO: workshop/raw_assets/tiles/tile_copper_ore.png
```

### tile_iron_ore.png
```
[PASTE TILE STYLE HEADER]
SUBJECT: Iron ore embedded in stone
PALETTE:
  Stone base:   #6B6B7A
  Iron:         #8A8A9A
  Iron bright:  #AAAACC
  Iron dark:    #606070
  Stone cracks: #4A4A55
DESCRIPTION: Stone base with flat metallic silver-blue iron
deposits that look like sheets or plates embedded in rock.
Iron deposits have a cooler, more metallic quality than stone.
Deposits cover ~30% of tile. Less organic than copper veins —
iron ore looks more stratified and structural.
SAVE TO: workshop/raw_assets/tiles/tile_iron_ore.png
```

### tile_wood_plank.png
```
[PASTE TILE STYLE HEADER]
SUBJECT: Wooden plank construction tile
PALETTE:
  Wood base:    #8B6914
  Wood grain:   #6B4A10
  Wood light:   #9C7A3C
  Nail head:    #4A4A4A
  Gap between:  #5C3D1A
DESCRIPTION: Horizontal rough-hewn wooden planks. Two boards
visible, with a thin dark gap between them. Visible wood grain
running horizontally. Small round nail heads at edges.
Warm brown, slightly weathered. Upper-left lit.
SAVE TO: workshop/raw_assets/tiles/tile_wood_plank.png
```

---

## PHASE 3: BACKGROUNDS (2 generations)

### bg_sky.png (far layer — deep space)
```
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
GAME: Terra.Watt
STYLE: Painterly pixel art background
MOOD: Pre-dawn frontier sky, vast and peaceful
LIGHTING: None — this is ambient sky light
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
SUBJECT: Deep night sky, far background parallax layer
SIZE: 320×180 pixels exactly
PALETTE:
  Sky deep:   #0A0A1A (top)
  Sky mid:    #12121E
  Nebula:     #1A0A2A (faint purple wisps)
  Stars:      #E8E8F0 (bright), #888890 (dim), #CCCCDD (medium)
  Horizon:    #151525 fading to very slightly warmer
DESCRIPTION: Dark frontier night sky. Gradient from deep navy
at top to very slightly lighter at bottom horizon. Scattered
stars of 3 sizes — single pixel bright, single pixel dim,
rare 2px cross shape for brightest. 2-3 very faint purple
nebula wisps barely visible. Conveys vastness and isolation.
Painterly, atmospheric. NO hard edges anywhere.
SAVE TO: workshop/raw_assets/backgrounds/bg_sky.png
```

### bg_industrial.png (Tier 1 mid layer — transparent)
```
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
GAME: Terra.Watt
STYLE: Painterly pixel art silhouette
MOOD: Early industrial era, dawn of the machine age
LIGHTING: Distant amber glow from below (furnace light)
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
SUBJECT: Industrial silhouette, Tier 1 background layer
SIZE: 320×180 pixels exactly
BACKGROUND: Transparent — composited over bg_sky.png
PALETTE:
  Silhouette:  #1A1005 (near-black with warm tint)
  Amber haze:  #3D2A0A (glow near horizon)
  Smoke:       #2A1E0A at 60% opacity wisps
DESCRIPTION: Dark silhouette of a distant 1880s industrial scene
against the sky. Elements from left to right:
  - One large brick smokestack (dominant, slightly left of center)
    with faint smoke rising and drifting right
  - Small factory building footprint beside it
  - Two smaller chimneys further right
  - Very faint distant rolling hills at base
Amber/warm glow visible just above horizon line beneath
the smokestacks — furnace light bleeding into the sky.
Silhouette only — no interior detail. Ominous, industrial.
IMPORTANT: Transparent PNG — only the silhouette and haze,
everything else must be fully transparent.
SAVE TO: workshop/raw_assets/backgrounds/bg_industrial.png
```

---

## PHASE 4: COPY TO GAME VIA PIPELINE

```powershell
python workshop/pipeline/pipeline.py --assemble-only
python workshop/pipeline/pipeline.py --check
```

---

## PHASE 5: VALIDATE TILES ARE SEAMLESS

For each tile, run this quick Python check:
```python
# workshop/pipeline/check_seamless.py
from PIL import Image
from pathlib import Path

tiles = list(Path("workshop/raw_assets/tiles").glob("tile_*.png"))
for t in tiles:
    img = Image.open(t).convert("RGBA")
    w, h = img.size
    # Make a 2×2 grid and check there's no obvious seam
    grid = Image.new("RGBA", (w*2, h*2))
    for x in range(2):
        for y in range(2):
            grid.paste(img, (x*w, y*h))
    # Save for visual inspection
    out = Path("workshop/pipeline/seamless_check") / t.name
    out.parent.mkdir(exist_ok=True)
    grid.save(str(out))
    print(f"Check: {out}")
print("Open workshop/pipeline/seamless_check/ to visually inspect tiles.")
```

```powershell
python workshop/pipeline/check_seamless.py
```
Open each result PNG and verify there's no visible grid/seam.

---

## COMMIT

```powershell
git add workshop/raw_assets/tiles/
git add workshop/raw_assets/backgrounds/
git add game/assets/tiles/
git add game/assets/backgrounds/
git add workshop/pipeline/check_seamless.py
git add workshop/pipeline/manifest.json
git status
git commit -m "[Overhaul-V3] feat: all tile and background art generated, seamless verified"
git push origin main
```

---

## FINAL REPORT

```
OVERHAUL V3 WORLD ART — FINAL REPORT

PixelLab used: [N]/10
Terrain tiles:  [N]/4  ✅
Ore tiles:      [N]/4  ✅
Backgrounds:    [N]/2  ✅
Seamless check: ✅/⚠️

Self-Audit Complete. World art done.
```

━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
TERRAWATT — GRAPHICS OVERHAUL AGENT V4: UI & POWER ART
Single command: Paste into Cursor Composer Agent tab.
Run simultaneously with V3 after V2 Master Sprites completes.
PIXELLAB BUDGET: 7 generations (power×4, UI×3)
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

## MISSION: Generate all power structures and UI elements.

---

## PHASE 0: RECON

Read `workshop/TERRAWATT_STYLE_BIBLE.md` — industrial side of the logo.
Focus on: industrial palette, copper/iron colours, the right half of the logo.

```powershell
git pull origin main
Get-ChildItem "workshop\raw_assets\power" -Filter "*.png" | Select-Object Name, Length
Get-ChildItem "workshop\raw_assets\ui" -Filter "*.png" | Select-Object Name, Length
```

---

## POWER STRUCTURE STYLE HEADER (paste at top of each power prompt)

```
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
GAME: Terra.Watt
STYLE: Medium-detail pixel art (Terraria level)
MOOD: 1880s industrial era — cast iron, copper, brick
LIGHTING: Upper-left 45°. Warm lamp-lit shadows.
REFERENCE: The "Watt" (right) half of the Terra.Watt logo.
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
STRUCTURE RULES:
  - Transparent background (PNG with alpha)
  - Dark iron outline: #1A1A1A
  - Copper fittings: #B87333
  - Cast iron body: #2A2A2A to #4A4A4A
  - Warm amber lamp glow where appropriate
  - Upper-left lit — right/bottom faces darker
  - Terraria structure style — chunky, readable, detailed
```

---

## PHASE 1: POWER STRUCTURES (4 generations)

### power_furnace.png
```
[PASTE POWER STRUCTURE STYLE HEADER]
SUBJECT: Coal-fired boiler furnace
SIZE: 32×48 pixels exactly (taller than wide)
PALETTE:
  Iron body:    #2A2A2A base, #3A3A3A highlight
  Brick:        #8B4513 warm brick red
  Fire glow:    #FF6A00 orange, #FFD700 yellow core
  Copper pipe:  #B87333
  Gauge face:   #F5F5DC cream
  Rivet:        #4A4A4A
DESCRIPTION: 1880s cast iron coal furnace.
Bottom third: iron firebox door with orange glow behind it.
Middle: main iron body with visible rivets on seams.
Top: short brick chimney/flue with faint heat shimmer.
Left side: copper pipe fitting (water inlet).
Front: small pressure gauge (cream face, copper frame).
Dark iron dominates. Copper accents catch the eye.
The firebox door glow is the warmest/brightest element.
SAVE TO: workshop/raw_assets/power/power_furnace.png
```

### power_boiler.png
```
[PASTE POWER STRUCTURE STYLE HEADER]
SUBJECT: Steam pressure vessel / water boiler
SIZE: 32×48 pixels exactly
PALETTE:
  Iron body:    #3A3A3A base, #4A4A4A highlight
  Rivets:       #2A2A2A raised, #5A5A5A highlight
  Gauge face:   #F5F5DC cream
  Copper pipe:  #B87333
  Steam wisp:   #DDEEFF pale blue-white
  Water drip:   #3070CC
DESCRIPTION: Round iron pressure vessel, horizontal cylinder.
Prominent riveted seams running around the circumference.
Large pressure gauge on the front face — most important detail.
Water inlet pipe on top (copper). Steam outlet on side with valve.
Slight condensation/water drip at base suggesting water inside.
The pressure gauge face (cream circle) is the visual focal point.
SAVE TO: workshop/raw_assets/power/power_boiler.png
```

### power_turbine.png
```
[PASTE POWER STRUCTURE STYLE HEADER]
SUBJECT: Steam turbine + generator unit
SIZE: 48×32 pixels exactly (wider than tall)
PALETTE:
  Turbine iron:  #2A2A2A
  Generator:     #3A3A3A
  Shaft:         #8899AA steel
  Copper term.:  #B87333
  Amber light:   #FFB300
  Blade glimpse: #8899AA
DESCRIPTION: Horizontal layout — turbine left, generator right.
Left: turbine housing with horizontal vent slots — blades barely
visible through slots (dark + steel glimpse).
Center: iron shaft connecting the two units.
Right: generator housing, boxier, with copper output terminals
on front. Small amber indicator light glowing near top.
Both units have riveted iron construction.
The amber light is the only warm colour — draws the eye to output.
SAVE TO: workshop/raw_assets/power/power_turbine.png
```

### power_pole.png
```
[PASTE POWER STRUCTURE STYLE HEADER]
SUBJECT: 1880s-1920s wooden utility power pole
SIZE: 16×64 pixels exactly (very tall and narrow)
PALETTE:
  Wood pole:    #3D1F0A dark creosote brown
  Cross-arm:    #4A2810 slightly lighter
  Insulators:   #C8B89A ceramic cream
  Amber bulb:   #FFB300 warm glow
  Wire hooks:   #4A4A4A iron
DESCRIPTION: Tall creosote-stained wooden pole.
At roughly 3/4 height: horizontal cross-arm with 2 ceramic
insulators (cream rounded bumps at each end of cross-arm).
Very top: small amber glow suggesting a lamp or indicator.
Wire attachment hooks on the cross-arm (small dark iron shapes).
Wood grain texture running vertically up the pole.
Reads clearly as a utility pole at 16px wide.
SAVE TO: workshop/raw_assets/power/power_pole.png
```

---

## PHASE 2: CREATE ACTIVE VARIANTS WITH PYTHON

Generate "operating" versions of power structures — slightly warmer/brighter.
These are used when the machine is running.

Create `workshop/pipeline/make_active_variants.py`:

```python
from PIL import Image, ImageEnhance, ImageFilter
from pathlib import Path

def make_active(src: Path, dest: Path, warmth: int = 12, brightness: float = 1.15):
    """Create an 'active/operating' variant — warmer and slightly brighter."""
    img = Image.open(src).convert("RGBA")
    r, g, b, a = img.split()
    # Warm it up (boost red slightly)
    r = r.point(lambda x: min(x + warmth, 255))
    # Slightly boost brightness
    merged = Image.merge("RGBA", (r, g, b, a))
    enhancer = ImageEnhance.Brightness(merged)
    result = enhancer.enhance(brightness)
    dest.parent.mkdir(parents=True, exist_ok=True)
    result.save(str(dest), "PNG")
    print(f"Active variant: {dest.name} ({dest.stat().st_size}b)")

RAW = Path("workshop/raw_assets/power")
DEST = Path("game/assets/power/tier1")

# Copy base versions
import shutil
for name, dest_name in [
    ("power_furnace.png", "furnace.png"),
    ("power_boiler.png", "water_boiler.png"),
    ("power_turbine.png", "steam_turbine.png"),
    ("power_pole.png", "power_pole.png")
]:
    src = RAW / name
    if src.exists():
        shutil.copy2(str(src), str(DEST / dest_name))
        print(f"Copied: {dest_name}")

# Create active variants (warmer, operating state)
make_active(RAW / "power_furnace.png",  DEST / "furnace_active.png",  warmth=20, brightness=1.2)
make_active(RAW / "power_boiler.png",   DEST / "boiler_active.png",   warmth=10, brightness=1.1)
make_active(RAW / "power_turbine.png",  DEST / "turbine_active.png",  warmth=8,  brightness=1.15)
```

```powershell
python workshop/pipeline/make_active_variants.py
```

---

## PHASE 3: UI ELEMENTS (3 generations)

### ui_hotbar_slot.png
```
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
GAME: Terra.Watt
STYLE: Pixel art UI element
MOOD: Industrial steampunk equipment panel
LIGHTING: Soft ambient, slight inner glow
REFERENCE: The transition zone of the Terra.Watt logo —
copper and iron aesthetic.
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
SUBJECT: Inventory hotbar slot frame
SIZE: 40×40 pixels exactly
PALETTE:
  Panel dark:   #1A1A2E deep navy-black
  Panel mid:    #252535
  Copper frame: #B87333
  Copper glow:  #D4943A inner highlight
  Rivet:        #8B6914 tiny corner details
DESCRIPTION: Industrial equipment panel slot.
Dark inner area where item icon will show (#1A1A2E).
Copper-coloured border around the edge, 2px thick.
Tiny rivet/bolt details at each corner.
Slight inner shadow on top and left edges of the opening.
Feels like a slot cut into a worn copper-trimmed iron panel.
Transparent background — only the frame, not the background.
SAVE TO: workshop/raw_assets/ui/ui_hotbar_slot.png
```

### ui_status_icon.png
```
[Same style header as hotbar]
SUBJECT: Status icon background badge
SIZE: 16×16 pixels exactly
PALETTE:
  Circle fill:  #1A1A2E at 80% (semi-transparent dark)
  Border:       #B87333 copper, 1px
DESCRIPTION: Small circular badge — dark semi-transparent fill
with thin copper border. Used as the background/badge behind
status icons that float above the player head.
Round, not square. Copper border catches eye.
Transparent outside the circle.
SAVE TO: workshop/raw_assets/ui/ui_status_icon.png
```

### ui_light_radial.png
```
SUBJECT: Soft radial light gradient texture
SIZE: 128×128 pixels exactly
PALETTE:
  Center: #FFFDF0 warm white
  Edge:   fully transparent
DESCRIPTION: Pure soft radial gradient.
Warm white centre (#FFFDF0) fading to completely transparent
at the edges. Used as PointLight2D texture in Godot for
player headlamp. Smooth falloff, no hard edges anywhere.
No shapes, no detail — pure gradient only.
Transparent PNG.
SAVE TO: workshop/raw_assets/ui/ui_light_radial.png
```

---

## PHASE 4: COPY TO GAME VIA PIPELINE

```powershell
python workshop/pipeline/pipeline.py --assemble-only
python workshop/pipeline/make_active_variants.py
# Copy UI directly
Copy-Item "workshop\raw_assets\ui\ui_hotbar_slot.png" "game\assets\ui\hotbar_slot.png" -Force
Copy-Item "workshop\raw_assets\ui\ui_status_icon.png" "game\assets\ui\status_icon_base.png" -Force
Copy-Item "workshop\raw_assets\ui\ui_light_radial.png" "game\assets\ui\light_radial.png" -Force
python workshop/pipeline/pipeline.py --check
```

---

## COMMIT

```powershell
git add workshop/raw_assets/power/ workshop/raw_assets/ui/
git add game/assets/power/ game/assets/ui/
git add workshop/pipeline/make_active_variants.py
git add workshop/pipeline/manifest.json
git status
git commit -m "[Overhaul-V4] feat: power structures + UI elements generated, active variants created"
git push origin main
```

---

## FINAL REPORT

```
OVERHAUL V4 UI & POWER — FINAL REPORT

Power structures: [N]/4 ✅
Active variants:  3 (furnace, boiler, turbine) ✅
UI elements:      [N]/3 ✅
All in game/assets/: ✅

Self-Audit Complete. UI and power art done.
```

━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
TERRAWATT — GRAPHICS OVERHAUL AGENT V5: GODOT INTEGRATION
Single command: Paste into Cursor Composer Agent tab.
Run LAST after V2, V3, V4 all show COMPLETE.
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

## MISSION: Wire all art into Godot. Fix import presets. Run final checklist.

---

## PHASE 0: WAIT AND VERIFY

```powershell
git pull origin main
python workshop/pipeline/pipeline.py --check
```

All assets must show ✅ before proceeding.
If anything is missing — fix it before touching Godot files.

---

## PHASE 1: VERIFY ALL PATHS IN CODE MATCH NEW ASSET LOCATIONS

Search for any hardcoded asset paths that may still point to old locations:
```powershell
Select-String -Path "game\**\*.gd" -Pattern "res://assets/" -Recurse |
    Select-Object LineNumber, Line, Filename
```

For each path found, verify the file actually exists at that path.
Fix any broken references.

---

## PHASE 2: UPDATE TILESET SOURCE

In `game/scripts/create_tileset.gd`, verify tile ID → PNG path mapping:
```gdscript
# Must match exactly:
# TILE_DIRT=1       → res://assets/tiles/terrain/dirt.png
# TILE_STONE=2      → res://assets/tiles/terrain/stone.png
# TILE_GRASS_DIRT=3 → res://assets/tiles/terrain/grass_dirt.png
# TILE_COAL=4       → res://assets/tiles/ores/coal_ore.png
# TILE_COPPER_ORE=5 → res://assets/tiles/ores/copper_ore.png
# TILE_IRON_ORE=6   → res://assets/tiles/ores/iron_ore.png
# TILE_CLAY=7       → res://assets/tiles/terrain/clay.png
```

---

## PHASE 3: WRITE GODOT IMPORT INSTRUCTIONS

Write `workshop/GODOT_IMPORT_STEPS.md` for the developer:

```markdown
# Godot Import Steps — Do This After Every Asset Update

## Step 1 — Open Godot
File → Open Project → navigate to game/project.godot

## Step 2 — Wait for initial scan
The FileSystem panel will scan. Wait for the spinner to stop.

## Step 3 — Set 2D Pixel preset on each sprite sheet
For EACH file in this list:
  - Single click the file in FileSystem panel
  - Click the "Import" tab (top of left panel)
  - Change Preset dropdown to "2D Pixel"
  - Click Reimport

Files to set 2D Pixel on:
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
  game/assets/power/tier1/furnace.png
  game/assets/power/tier1/water_boiler.png
  game/assets/power/tier1/steam_turbine.png
  game/assets/power/tier1/power_pole.png
  game/assets/ui/hotbar_slot.png
  game/assets/ui/light_radial.png

## Step 4 — Press F5 and verify
```

---

## PHASE 4: FINAL VERIFICATION CHECKLIST

Write this to `workshop/ALIGNMENT_REPORT.md` for the developer to check off:

```markdown
# Terra.Watt Graphics Overhaul — Final Checklist
## Developer: check each item in Godot after import

CHARACTERS:
  [ ] Player has real miner sprite — yellow vest visible, hardhat clear
  [ ] Cyan crystal gem on hardhat visible
  [ ] Player walk animation plays (not static or twitching)
  [ ] Wolf has real wolf sprite — dark grey, amber eyes
  [ ] Rabbit has real rabbit sprite — round, brown
  [ ] Bird has real bird sprite — tiny, warm brown

WORLD:
  [ ] Surface tiles show warm brown dirt with green grass tops
  [ ] Stone tiles visible underground — grey, textured
  [ ] Coal ore tiles show black chunks in stone
  [ ] Copper ore shows warm orange veins in stone
  [ ] Iron ore shows blue-grey metallic deposits in stone
  [ ] Background sky layer visible (dark starfield)

PERFORMANCE:
  [ ] No lag or stuttering
  [ ] No animation error spam in Output panel
  [ ] Game runs at smooth framerate

POWER:
  [ ] Furnace sprite visible when placed
  [ ] Boiler sprite visible when placed
  [ ] Turbine sprite visible when placed
  [ ] Power pole sprite visible when placed

UI:
  [ ] Hotbar slots have copper-framed industrial look
  [ ] Player headlamp glows soft warm white underground
  [ ] Power meter shows Gen/Dem values

OVERALL STYLE:
  [ ] Game feels warm and earthy, not cold or clinical
  [ ] Early game looks like the Terra (left) side of the logo
  [ ] Everything reads clearly at game scale
```

---

## COMMIT

```powershell
git add workshop/GODOT_IMPORT_STEPS.md
git add workshop/ALIGNMENT_REPORT.md
git add game/scripts/create_tileset.gd
git status
git commit -m "[Overhaul-V5] chore: integration docs, path verification, final checklist ready"
git push origin main
```

---

## FINAL REPORT

```
OVERHAUL V5 INTEGRATION — FINAL REPORT

Asset paths verified in code: ✅
TileSet mapping confirmed: ✅
GODOT_IMPORT_STEPS.md written: ✅
ALIGNMENT_REPORT.md written: ✅

DEVELOPER ACTION REQUIRED:
1. Open game/project.godot in Godot 4
2. Follow workshop/GODOT_IMPORT_STEPS.md
3. Check off items in workshop/ALIGNMENT_REPORT.md
4. Report back what passes/fails

Total PixelLab generations this overhaul: 21/21
  V2 Characters: 4
  V3 World:      10
  V4 UI/Power:   7

Self-Audit Complete. Graphics overhaul delivered.
```
