# Godot Import Steps — Do This After Every Asset Update

## Step 1 — Open Godot

File → Open Project → navigate to `game/project.godot`

## Step 2 — Wait for initial scan

The FileSystem panel will scan. Wait for the spinner to stop.

## Step 3 — Set 2D Pixel preset on each sprite sheet

For EACH file in this list:

- Single click the file in FileSystem panel
- Click the **Import** tab (top of left panel)
- Change Preset dropdown to **2D Pixel**
- Click **Reimport**

### Files to set 2D Pixel on (core list)

- `game/assets/player/player_sheet.png`
- `game/assets/creatures/wolf_sheet.png`
- `game/assets/creatures/rabbit_sheet.png`
- `game/assets/creatures/bird_sheet.png`
- `game/assets/tiles/terrain/dirt.png`
- `game/assets/tiles/terrain/grass_dirt.png`
- `game/assets/tiles/terrain/stone.png`
- `game/assets/tiles/terrain/clay.png`
- `game/assets/tiles/ores/coal_ore.png`
- `game/assets/tiles/ores/copper_ore.png`
- `game/assets/tiles/ores/iron_ore.png`
- `game/assets/power/tier1/furnace.png`
- `game/assets/power/tier1/water_boiler.png`
- `game/assets/power/tier1/steam_turbine.png`
- `game/assets/power/tier1/power_pole.png`
- `game/assets/ui/hotbar_slot.png`
- `game/assets/ui/light_radial.png`

### Also use 2D Pixel on (referenced elsewhere in the project)

- `game/assets/backgrounds/bg_layer_far.png`
- `game/assets/backgrounds/bg_layer_mid.png`
- `game/assets/backgrounds/bg_layer_near.png`
- `game/assets/backgrounds/bg_industrial_tier1.png`
- `game/assets/backgrounds/bg_sky.png`
- `game/assets/power/tier1/furnace_active.png`
- `game/assets/power/tier1/boiler_active.png`
- `game/assets/power/tier1/turbine_active.png`
- `game/assets/power/tier1/wire_segment.png`
- `game/assets/structures/wood_plank.png`
- `game/assets/structures/stone_brick.png`
- `game/assets/structures/conveyor_belt_sheet.png`
- `game/assets/tiles/ores/*_icon.png` (ore / terrain item icons)
- `game/assets/ui/status_icon_base.png`

## Step 4 — Regenerate the TileSet (after terrain/ore/structure PNG changes)

1. In Godot: **FileSystem** → open `game/scripts/create_tileset.gd`
2. **File → Run** (or run as EditorScript) to write `game/assets/tiles/terrawatt_tileset.tres`

## Step 5 — Press F5 and verify

Run the game and use `workshop/ALIGNMENT_REPORT.md` as a visual checklist.
