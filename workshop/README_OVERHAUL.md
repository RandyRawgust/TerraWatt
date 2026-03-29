# TERRAWATT — VISUAL OVERHAUL KIT
## Complete restructure + automated asset pipeline + all game art
## Version 1.0 | Requires Aseprite at C:\Program Files\Aseprite\Aseprite.exe

---

## WHAT THIS KIT DOES

1. Separates the project into `game/` (Godot only) and `workshop/` (agents only)
2. Builds an automated asset pipeline — request a sprite, it flows through
   PixelLab → raw storage → Aseprite → assembled sheet → Godot assets
3. Generates ALL game art methodically using exactly 35 PixelLab generations
4. Verifies everything imports correctly in Godot with 2D Pixel presets

---

## FILES IN THIS KIT

```
README_OVERHAUL.md          ← this file
AGENT_V1_RESTRUCTURE.md     ← run first, alone — folder reorganization
AGENT_V2_PIPELINE.md        ← run second, alone — builds automation scripts
AGENT_V3_CHARACTERS.md      ← parallel — all character art (18 generations)
AGENT_V4_WORLD.md           ← parallel — tiles + backgrounds (10 generations)
AGENT_V5_UI_POWER.md        ← parallel — UI + power structures (7 generations)
AGENT_V6_VERIFY.md          ← run last — Godot import + final checklist
```

---

## PIXELLAB BUDGET

Total: 35 generations across 3 parallel art agents.
Each agent uses its own allocation — they never duplicate requests.
The manifest.json tracks every generation so nothing is requested twice.

```
V3 Characters:  18 generations (player×6, wolf×6, rabbit×3, bird×3)
V4 World:       10 generations (tiles×8, backgrounds×2)
V5 UI/Power:     7 generations (power×4, UI×3)
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
TOTAL:          35 generations
```

---

## LAUNCH ORDER

### ROUND 1 — Restructure (alone, ~10 min)
Paste `AGENT_V1_RESTRUCTURE.md` into Cursor Agent.
Wait for COMPLETE before anything else.
After it finishes: open Godot, confirm the project still loads from game/project.godot.

### ROUND 2 — Pipeline Builder (alone, ~5 min)  
Paste `AGENT_V2_PIPELINE.md` into Cursor Agent.
This builds the manifest and automation scripts.
Wait for COMPLETE.

### ROUND 3 — Art agents (all three simultaneously)
Open 3 Composer Agent tabs.
Tab 1: paste `AGENT_V3_CHARACTERS.md`
Tab 2: paste `AGENT_V4_WORLD.md`
Tab 3: paste `AGENT_V5_UI_POWER.md`
They coordinate via manifest.json — no duplicated generations.

### ROUND 4 — Verify (alone, after all art agents complete)
Paste `AGENT_V6_VERIFY.md`.
This wires everything into Godot and runs the verification checklist.

---

## AFTER THIS KIT COMPLETES

- `game/` is a clean Godot project with all assets imported correctly
- `workshop/raw_assets/` has every original PixelLab output preserved
- `workshop/pipeline/manifest.json` tracks every asset's status
- `workshop/pipeline/pipeline.py` can generate NEW assets in future using
  the same automated flow — just add an entry to manifest.json and run it

---

## THE PIPELINE FLOW (how future art works)

```
1. Add entry to manifest.json:
   {"id": "player_walk5", "type": "character", "status": "needed"}

2. Run: python workshop/pipeline/pipeline.py

3. Pipeline checks: does raw_assets/characters/player_walk5.png exist?
   NO → calls PixelLab MCP with spec from manifest
   YES → skips PixelLab, uses existing raw

4. Validates raw file (size > 500 bytes, correct dimensions)

5. Calls Aseprite to assemble/update the sprite sheet

6. Copies finished sheet to game/assets/creatures/

7. Updates manifest: status → "complete"
```

---

*Terra.Watt Visual Overhaul Kit — Aseprite at C:\Program Files\Aseprite\Aseprite.exe*
*Engine: Godot 4.4.1 | Python 3.11 | Pillow required*
