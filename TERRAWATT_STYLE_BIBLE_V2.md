# TERRA.WATT — STYLE BIBLE
## Version 2.0 | The Visual Law
## Every piece of art in this game traces back to this document.
## Last updated: after logo analysis session

---

## THE ONE-SENTENCE STYLE RULE

> Terra.Watt looks like **the left half of the logo becoming the right half — nature turning into industry, one tier at a time.**

When in doubt about any visual decision, look at the logo.
Left half = how the world starts. Right half = where it ends.
The game is the journey between them.

---

## THE LOGO IS YOUR REFERENCE

Two logo files live in `workshop/raw_assets/logo/`:
- `logo_pixel.png` — the small pixel art version. This is your in-game visual target.
- `logo_full.png` — the large illustrated version. This is marketing art.

**Read the logo like a map:**
```
LEFT SIDE (Terra):              RIGHT SIDE (Watt):
  Warm stone lettering            Cold electric blue lettering
  Moss and roots growing          Pipes and gears bolted on
  Natural waterfall crystal       Engineered copper/steel
  Living earth, warm browns       Built machine, dark iron
  Sky above = clean               Smokestacks above = industry
  = TIER 0-1 visual language      = TIER 4-7 visual language
```

**The lightning bolt separator** = the game's core tension.
Amber-gold, explosive energy. Every power plant you build is
trying to capture that bolt. It's the motif you can use for
power indicators, UI elements, and milestone moments.

**The crystal dot (·)** = the conduit between worlds.
Cyan/ice blue. Appears on the player's hardhat, in ore veins,
in water crystals. It represents raw natural energy waiting
to be converted.

---

## COLOUR PALETTE — EXTRACTED FROM LOGO

### Primary Palette (the 12 most important colours)

```
EARTH SIDE (left half of logo — Tier 0-2):
  Stone warm:      #8B6914   ← Terra lettering base
  Stone highlight: #C8A870   ← Terra lettering light
  Deep earth:      #6B4A10   ← shadow/depth
  Moss green:      #4A7C2F   ← foliage dominant
  Bright grass:    #6BA84A   ← foliage highlight
  Crystal cyan:    #88DDFF   ← the dot separator, water crystals
  Crystal glow:    #CCF0FF   ← crystal bright core

INDUSTRIAL SIDE (right half of logo — Tier 3-7):
  Electric blue:   #00AAFF   ← Watt lettering dominant
  Electric glow:   #44CCFF   ← Watt lettering light/glow
  Dark iron:       #2A2A2A   ← machine bodies
  Steel grey:      #8899AA   ← structural metal
  Copper pipe:     #B87333   ← all pipe/fitting elements

UNIVERSAL (both sides — always available):
  Lightning amber: #FFB300   ← the bolt, power indicators, amber eyes
  Lightning core:  #FFFFFF   ← bolt bright core, hottest points
  Smoke white:     #DDDDDD   ← steam, smoke (never pure white)
  Warm dark:       #1A1005   ← shadows (never pure black)
  Cool dark:       #0A0A1A   ← deep underground, night sky
```

### Extended Palette (full reference)

```
EARTH & TERRAIN
  Deep soil:       #6B4A10
  Warm dirt:       #8B6914
  Sandy dirt:      #9C7A3C
  Clay ochre:      #A0785A
  Dark stone:      #4A4A55
  Mid stone:       #6B6B7A
  Light stone:     #8A8A9A

NATURE
  Deep grass:      #2E5A1E
  Mid grass:       #4A7C2F
  Light grass:     #6BA84A
  Tree bark:       #5C3D1A
  Leaf dark:       #2A4A1A

INDUSTRIAL
  Cast iron:       #2A2A2A
  Dark iron:       #3A3A3A
  Mid iron:        #4A4A4A
  Steel:           #8899AA
  Copper:          #B87333
  Copper bright:   #D4943A
  Brass:           #C9A84C
  Rust:            #8B3A1A

ENERGY & LIGHT
  Amber deep:      #8B5500
  Amber mid:       #C47A00
  Amber bright:    #FFB300   ← lightning bolt
  Fire orange:     #FF6A00
  Fire yellow:     #FFD700
  Hearth glow:     #FF8C42
  Crystal cyan:    #88DDFF   ← the dot motif
  Electric blue:   #00AAFF   ← Watt side
  Electric bright: #44CCFF

SKIN & ORGANIC
  Warm tan:        #C68642
  Mid skin:        #B07030
  Shadow skin:     #8B5520

ATMOSPHERE
  Night sky:       #0A0A1A
  Nebula:          #1A0A2A
  Pollution haze:  #3D2A0A
  Smog:            #2A1E0A

UI & HUD
  Panel dark:      #1A1A2E
  Panel mid:       #252535
  Copper accent:   #B87333
  Text bright:     #F5E6C8
  Text dim:        #8A7A60
```

---

## RESOLUTION & SCALE (LOCKED)

```
World tiles:       16×16 pixels  — solid background, tileable
Player character:  24×40 pixels  — transparent background
Large creatures:   32×20 pixels  — wolf, bear (transparent)
Small creatures:   16×16 pixels  — rabbit (transparent)
Tiny critters:     12×10 pixels  — bird (transparent)
Power structures:  32×48 pixels  — tall machines (transparent)
                   48×32 pixels  — wide machines (transparent)
Power poles:       16×64 pixels  — tall/narrow (transparent)
UI hotbar slot:    40×40 pixels  — transparent
Status icons:      16×16 pixels  — transparent
Backgrounds:       320×180 pixels per parallax layer
```

---

## LIGHTING MODEL (LOCKED)

All sprites lit from **upper-left, 45 degrees.** Always.

```
Highlight:  upper-left face — brightest
Mid tone:   front-facing surfaces
Shadow:     lower-right and bottom — warm dark, not grey
Deep:       concave areas — barely used, very sparingly
```

**Shadow colour rule:**
Shadows on warm materials (earth, wood, skin) → dark amber/brown
Shadows on cool materials (iron, stone, steel) → dark blue-grey
Never use grey shadows on warm materials. Never use brown on metal.

---

## OUTLINE RULES (LOCKED)

**Tiles:** NO outlines. Tiles are seamless. Use internal edge detail only.
**Characters:** Dark outline in the darkest variant of adjacent body colour.

```
Player outline:   #3D2010  (dark warm brown — never pure black)
Wolf outline:     #1A1A1A  (near-black — wolf is dark)
Rabbit outline:   #6B4A30  (dark warm brown)
Bird outline:     #3D2010  (dark warm brown)
Structures:       #1A1A1A  (near-black iron feel)
```

---

## TIER VISUAL PROGRESSION

The world changes as the player advances. Left logo → right logo.

```
TIER 0 — PRIMITIVE
  Player sees:    Pure nature. Warm, clean, alive.
  Background:     Deep greens, clear sky, birds
  Dominant tones: #8B6914 #4A7C2F #88DDFF
  Mood:           The left side of the logo

TIER 1 — COAL & STEAM
  First change:   One smokestack silhouette on horizon
  Air:            Slight amber haze when coal burns
  New colours:    #2A2A2A (iron) enters the palette
  Mood:           Nature + first machines side by side

TIER 2 — OIL & HYDRO
  New elements:   Derrick silhouettes, concrete dam
  Sky:            Slightly more amber at sunset
  New colours:    #B87333 (copper) becomes prominent
  Mood:           Industry beginning to dominate landscape

TIER 3 — GAS & GRID
  New elements:   Power lines on horizon, city lights at night
  Sky:            Amber-tinted, pollution visible
  New colours:    #8899AA (steel) dominates built structures
  Mood:           The balance point of the logo

TIER 4 — NUCLEAR
  New elements:   Cooling tower silhouettes, red warning lights
  Contamination:  Permanent red haze where meltdown occurred
  New colours:    Sickly green contamination zones
  Mood:           Moving toward the right side of the logo

TIER 5 — RENEWABLES
  New elements:   Wind turbines, solar glint
  Sky:            Begins clearing as renewables grow
  New colours:    #00AAFF (electric blue) becomes common
  Mood:           The right logo side, but clean/hopeful

TIER 6-7 — ENDGAME
  New elements:   Orbital lights at night, smart towers
  Sky:            Clear, cities bright, world transformed
  Dominant tones: #00AAFF #8899AA #B87333
  Mood:           Full right side of the logo — built world
```

---

## CHARACTER STYLE RULES

### Player — The Industrial Miner

Reads as: **working class, practical, capable. Not heroic.**

```
Silhouette priorities (most important first):
  1. Yellow vest     #FFB300  ← first thing eye sees
  2. Brown hardhat   #8B5E3C  ← distinctive shape
  3. Cyan headlamp   #88DDFF  ← the crystal motif
  4. Grey armour     #8899AA  ← recedes behind vest
  5. Dark pants      #6B4A10  ← recedes further

The cyan headlamp gem connects the player to the crystal/energy
motif of the logo dot. It's a subtle visual echo.
```

### Creatures by Tier Feel

```
Tier 0 creatures:  warm, natural, organic colours
  Wolf:  dark grey (threat in the natural world)
  Rabbit: light browns (harmless, part of nature)
  Bird:  warm browns (ambient, background life)

Tier 4+ irradiated variants:
  Same creature, but: desaturated body + sickly green glow
  on eyes and skin. Use sparingly for contamination zones.
```

---

## TILE STYLE RULES

### The 5 Rules of a Good Terra.Watt Tile

```
1. READABLE AT GAME SCALE — clear at 16×16, AND at 64×64 display
2. TILEABLE — no seam in 2×2 grid
3. THREE VISIBLE VALUES — highlight, mid, shadow at minimum
4. NO REGULAR PATTERNS — nature is irregular. Break it up.
5. SOLID — every pixel filled. No transparency in terrain tiles.
```

### Depth Colour Shift (applied in code, not separate PNGs)

```
Surface (Y 0-10):      Full warmth, full saturation
Shallow (Y 10-60):     -5% saturation, -3% brightness
Mid (Y 60-150):        -15% saturation, slightly blue shift
Deep (Y 150-280):      -25% saturation, blue-grey
Abyss (Y 280+):        -40% saturation, near dark blue
```

---

## PIXELLAB PROMPT TEMPLATE (USE THIS EXACTLY)

Every PixelLab generation starts with this exact header block.
Copy it verbatim. Fill in the [VARIABLES]. Never skip sections.

```
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
GAME: Terra.Watt
STYLE: Medium-detail pixel art (Terraria level)
MOOD: Warm earthy frontier, 1880s industrial era
LIGHTING: Upper-left 45°. Warm shadows. Amber highlights.
REFERENCE: The "Terra" (left) half of the Terra.Watt logo.
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

SUBJECT: [describe exactly what to draw]
SIZE: [W]×[H] pixels — exact, no larger, no smaller

[FOR CHARACTER MASTERS ONLY:]
POSE: Idle, side view facing right. Neutral standing.
CHARACTER RULES:
  - Silhouette must be instantly readable at this size
  - Dominant colour is [MOST VISIBLE COLOUR HEX]
  - Transparent background
  - Dark outline using [OUTLINE COLOUR from Style Bible]
  - Terraria proportions: chunky, readable, not realistic

[FOR TILES ONLY:]
TILE RULES:
  - Solid background (no transparency)
  - Tileable — no visible seam at edges
  - Upper-left lighting baked into texture
  - 3+ visible value levels (highlight, mid, shadow)
  - Natural/irregular texture — avoid mathematical patterns

PALETTE (use ONLY these colours):
  [LIST 4-8 COLOURS FROM MASTER PALETTE]

STYLE REQUIREMENTS:
  - Chunky pixel art, Terraria level of detail
  - Warm earthy feel, not cold or clinical
  - [tiles: solid fill] OR [characters: transparent PNG]
  - No anti-aliasing, no photorealistic rendering
  - If unsure, look at the Terra side of the Terra.Watt logo

SAVE TO: [EXACT PATH]
```

---

## MASTER SPRITE RULE (NON-NEGOTIABLE)

```
For every animated character:
  1. Generate ONE master PNG via PixelLab (idle pose only)
  2. Store at: workshop/raw_assets/characters/[name]_master.png
  3. ALL animation frames derived from master via derive_frames.py
  4. NEVER generate animation frames via PixelLab
  5. To improve animation: edit frames in Aseprite, save to raw_assets,
     run pipeline.py --assemble-only

This guarantees 100% visual consistency across all animation frames.
```

---

## FILE NAMING (LOCKED)

```
Master sprites:   [name]_master.png         wolf_master.png
Animation frames: [name]_[pose].png         wolf_walk1.png
Assembled sheets: [name]_sheet.png          wolf_sheet.png
Aseprite source:  [name].aseprite           wolf.aseprite
Tiles:            tile_[name].png           tile_coal_ore.png
Backgrounds:      bg_[name].png             bg_sky.png
Power:            power_[name].png          power_furnace.png
UI:               ui_[name].png             ui_hotbar_slot.png
Logo reference:   logo_pixel.png / logo_full.png
```

---

## WHAT NEVER CHANGES

These are locked. Agents cannot modify them. Art passes cannot change them.
If a change is needed, it requires updating this document with a version bump.

```
1.  Tile size:              16×16px
2.  Player size:            24×40px
3.  Lighting direction:     upper-left 45°
4.  Tiles:                  solid background
5.  Characters:             transparent background
6.  Texture filter Godot:   2D Pixel (nearest neighbour) — always
7.  Outline:                never pure #000000 — always a dark colour variant
8.  Shadow colour:          warm on warm materials, cool on cold materials
9.  The crystal motif:      #88DDFF cyan — appears on player, ores, water
10. The lightning motif:    #FFB300 amber — appears on power indicators, UI
11. Master sprite rule:     one PixelLab generation per character, derive rest
12. The logo is the ref:    left = nature/early, right = industry/late
```

---

*Terra.Watt Style Bible v2.0*
*Update version number on any change to locked values*
*Both copies must match: workshop/TERRAWATT_STYLE_BIBLE.md and .cursor/rules/TERRAWATT_STYLE_BIBLE.md*
