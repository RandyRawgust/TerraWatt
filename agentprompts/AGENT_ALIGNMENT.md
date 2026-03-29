TERRAWATT — MASTER ALIGNMENT AGENT
Single command: Paste this entire block into a Cursor Composer Agent tab and press Enter.
Run this simultaneously with COWORK_INSTRUCTIONS.md after PC restart.

━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

## MISSION: Full project audit. Verify every asset exists and is wired. Fix all lag. No placeholders.

You are the ALIGNMENT AGENT. You do not add new gameplay.
You make everything that was built actually work correctly.
Cowork is running alongside you opening Godot and giving visual feedback.
Check ALIGNMENT_REPORT.md periodically — Cowork will write findings there.

---

## PHASE 0: DOCTRINE + FULL RECON (MANDATORY — DO NOT SKIP)

1. Read `TERRAWATT_DOCTRINE.md` in full.
2. Read `AGENT_STATUS.md` — understand what every agent claimed to deliver.
3. Read `ALIGNMENT_REPORT.md` if it exists — Cowork may have already found issues.

Then run this full recon — READ ACTUAL FILES, do not assume:
```bash
git pull origin main
git log --oneline -15
git status
```

Build a complete picture of what is on disk vs what scenes reference.

---

## PHASE 1: ASSET AUDIT — VERIFY EVERY PNG

Check every asset directory. For each PNG found, verify file size.
A file under 200 bytes is a failed PixelLab download — flag it.

```powershell
# Windows — check all PNGs and their sizes
Get-ChildItem -Path "." -Recurse -Filter "*.png" | Select-Object FullName, Length | Sort-Object FullName
```

Build this table from the output and report it:

```
ASSET AUDIT TABLE
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
PATH                                          SIZE    STATUS
res://assets/player/player_sheet.png          ????    ✅/❌
res://assets/creatures/wolf_sheet.png         ????    ✅/❌
res://assets/creatures/rabbit_sheet.png       ????    ✅/❌
res://assets/creatures/bird_sheet.png         ????    ✅/❌
res://assets/backgrounds/bg_industrial_tier1.png ??? ✅/❌
res://assets/power/tier1/furnace.png          ????    ✅/❌
res://assets/power/tier1/water_boiler.png     ????    ✅/❌
res://assets/power/tier1/steam_turbine.png    ????    ✅/❌
res://assets/power/tier1/power_pole.png       ????    ✅/❌
res://assets/tiles/terrain/dirt.png           ????    ✅/❌
res://assets/tiles/terrain/stone.png          ????    ✅/❌
res://assets/tiles/terrain/grass_dirt.png     ????    ✅/❌
res://assets/tiles/ores/coal_ore.png          ????    ✅/❌
res://assets/tiles/ores/copper_ore.png        ????    ✅/❌
res://assets/tiles/ores/iron_ore.png          ????    ✅/❌
```

Mark ✅ if size > 200 bytes. Mark ❌ if missing or under 200 bytes.
For every ❌ — add it to a REGENERATION LIST at the end of Phase 1.
Do NOT regenerate yet — audit everything first, then regenerate in batch.

---

## PHASE 2: IMPORT METADATA AUDIT

Godot requires a `.import` file alongside every PNG.
These live in `res://.godot/imported/`.

For each ✅ PNG from Phase 1, check if its import file exists:
```powershell
Get-ChildItem -Path ".godot/imported" -Filter "*.png*" | Select-Object Name
```

If a PNG exists on disk but has NO matching entry in `.godot/imported/`,
it has never been imported by Godot and will fail to load at runtime.

IMPORTANT: You cannot force Godot to import from the command line reliably.
Write these unimported files to `ALIGNMENT_REPORT.md` under a section called
"NEEDS GODOT REIMPORT" — Cowork will handle the import step in the editor.

---

## PHASE 3: WIRING AUDIT — VERIFY ASSETS ARE ACTUALLY USED

For each ✅ and imported PNG, verify it is actually referenced in code or scenes.

Check these critical wirings:

### Player sprite
Read `res://player/player.gd` — find `_setup_sprite_frames()`.
Confirm it loads `res://assets/player/player_sheet.png`.
Confirm it creates animations: idle (1 frame), walk (4 frames), jump (1 frame).
Confirm `texture_filter = CanvasItem.TEXTURE_FILTER_NEAREST` is set.

### Wolf sprite
Read `res://creatures/wolf.gd` — find `_setup_sprite()` or equivalent.
Confirm it loads `res://assets/creatures/wolf_sheet.png`.
Confirm animations: idle, walk, attack.
Confirm TEXTURE_FILTER_NEAREST.

### Rabbit sprite
Read `res://creatures/rabbit.gd`.
Confirm it loads `res://assets/creatures/rabbit_sheet.png`.
Confirm animations: idle, hop, flee.
Confirm TEXTURE_FILTER_NEAREST.

### Bird sprite
Read `res://creatures/bird.gd`.
Confirm it loads `res://assets/creatures/bird_sheet.png`.
Confirm animations: perched, fly.
Confirm TEXTURE_FILTER_NEAREST.

### Tile sprites
Read `res://world/world_renderer.gd` and `res://scripts/create_tileset.gd`.
Confirm tile PNGs are referenced and the TileSet source IDs match WorldData constants.

For any wiring that is BROKEN or MISSING — add to a WIRING FIX LIST.

---

## PHASE 4: LAG FIX — STOP ALL ANIMATION SPAM

This is the #1 performance issue. Find and fix every instance of
unchecked animation calls that fire every frame when sprites are missing.

Search for every `.play(` call in creatures and player:
```powershell
Select-String -Path ".\res\creatures\*.gd",".\res\player\*.gd" -Pattern "\.play\(" | Select-Object LineNumber, Line, Filename
```

For EVERY `.play(` call found, wrap it with a has_animation guard:

```gdscript
# BEFORE (crashes and spams when animation missing):
$AnimatedSprite2D.play("fly")

# AFTER (safe — silently skips if animation not loaded yet):
var _spr := $AnimatedSprite2D
if _spr.sprite_frames and _spr.sprite_frames.has_animation("fly"):
    _spr.play("fly")
```

Also add a ResourceLoader.exists() guard at the top of EVERY
sprite setup function:

```gdscript
func _setup_sprite_frames() -> void:
    var path := "res://assets/creatures/bird_sheet.png"
    if not ResourceLoader.exists(path):
        push_warning(name + ": sprite sheet not found at " + path)
        return
    # ... rest of setup
```

Apply this pattern to: bird.gd, rabbit.gd, wolf.gd, player.gd.
This stops ALL animation-related lag regardless of import state.

---

## PHASE 5: ANIMATION CONSISTENCY STANDARD

All walking entities must conform to this standard.
Audit each one and fix any that deviate.

```
ENTITY    SHEET SIZE       FRAME SIZE   ANIMATIONS REQUIRED      FPS
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
Player    144×40px total   24×40px      idle(1) walk(4) jump(1)  8fps walk
Wolf      144×16px total   24×16px      idle(1) walk(4) attack(1) 8fps walk
Rabbit     36×12px total   12×12px      idle(1) hop(2)            6fps hop
Bird       30×8px total    10×8px       perched(1) fly(2)         8fps fly
```

For each entity, verify the AtlasTexture regions in the setup function
match the frame dimensions above exactly.

Wolf frame regions (24×16 each, horizontal strip):
  idle:   Rect2(0,  0, 24, 16)
  walk_1: Rect2(24, 0, 24, 16)
  walk_2: Rect2(48, 0, 24, 16)
  walk_3: Rect2(72, 0, 24, 16)
  walk_4: Rect2(96, 0, 24, 16)
  attack: Rect2(120,0, 24, 16)

Rabbit frame regions (12×12 each):
  idle:   Rect2(0,  0, 12, 12)
  hop_1:  Rect2(12, 0, 12, 12)
  hop_2:  Rect2(24, 0, 12, 12)

Bird frame regions (10×8 each):
  perched: Rect2(0,  0, 10, 8)
  fly_1:   Rect2(10, 0, 10, 8)
  fly_2:   Rect2(20, 0, 10, 8)

Player frame regions (24×40 each):
  idle:   Rect2(0,   0, 24, 40)
  walk_1: Rect2(24,  0, 24, 40)
  walk_2: Rect2(48,  0, 24, 40)
  walk_3: Rect2(72,  0, 24, 40)
  walk_4: Rect2(96,  0, 24, 40)
  jump:   Rect2(120, 0, 24, 40)

Fix any that are wrong. These exact regions are the contract.

---

## PHASE 6: REGENERATE FAILED ASSETS (PixelLab MCP)

For every ❌ in the Phase 1 audit table — regenerate NOW using PixelLab MCP.
Use the exact specifications from the Tier 1 Sprites agent prompt.
After each generation, immediately verify file size > 200 bytes.
If still bad after one retry — note it in ALIGNMENT_REPORT.md and move on.
Do not retry more than once per asset.

Write to ALIGNMENT_REPORT.md:
```
## REGENERATED ASSETS
[list each one with new file size]

## STILL MISSING (needs manual attention)
[list any that failed twice]
```

---

## PHASE 7: WRITE ALIGNMENT_REPORT.md

Create or update `ALIGNMENT_REPORT.md` in the project root.
This is the handoff document to Cowork for the Godot import step.

```markdown
# TERRAWATT — ALIGNMENT REPORT
Generated by: Alignment Agent
Date: [date]

## ASSET STATUS
[paste the full audit table from Phase 1]

## NEEDS GODOT REIMPORT
These files exist on disk but need Godot editor to import them.
Open Godot, let FileSystem panel refresh, then run the game.

[list every PNG that was missing from .godot/imported/]

## WIRING STATUS
[list each entity and whether its sprite wiring is confirmed ✅ or fixed ⚠️]

## LAG FIXES APPLIED
[list every file where animation guards were added]

## STILL NEEDS ATTENTION
[anything that requires Cowork visual confirmation]
```

---

## PHASE 8: COMMIT

```powershell
git add res/creatures/bird.gd
git add res/creatures/rabbit.gd
git add res/creatures/wolf.gd
git add res/player/player.gd
git add ALIGNMENT_REPORT.md
# Add any regenerated assets:
git add res/assets/creatures/
git add res/assets/player/
git add res/assets/backgrounds/
git status   # confirm only intended files staged
git commit -m "[Alignment] fix: animation guards, wiring audit, asset verification complete"
git push origin main
```

---

## FINAL REPORT FORMAT

```
ALIGNMENT AGENT — FINAL REPORT

ASSET AUDIT:     [N] valid | [N] regenerated | [N] still missing
IMPORT STATUS:   [N] confirmed imported | [N] flagged for Cowork reimport
WIRING:          [N] confirmed correct | [N] fixed
LAG FIXES:       [N] animation guards added across [N] files
ANIMATION STD:   Player ✅/⚠️ | Wolf ✅/⚠️ | Rabbit ✅/⚠️ | Bird ✅/⚠️

ALIGNMENT_REPORT.md written — Cowork can now handle Godot import step.

[list any remaining blockers]

Self-Audit Complete. Codebase aligned. Cowork to confirm visually.
```
