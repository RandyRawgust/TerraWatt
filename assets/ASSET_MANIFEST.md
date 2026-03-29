# Terra.Watt — Asset manifest (Visual & Art Agent)

All paths are `res://` unless noted. PixelLab job IDs are from generation on 2026-03-29.

## Terrain tiles (16×16 PNG)

| File | PixelLab | Used by |
|------|----------|---------|
| `assets/tiles/terrain/dirt.png` | tiles-pro `9f89f084-970d-49d5-b0c6-d594c72ca8fc` tile_0 | `WorldData.TILE_DIRT` (1), `terrawatt_tileset` |
| `assets/tiles/terrain/stone.png` | tile_1 | `TILE_STONE` (2) |
| `assets/tiles/terrain/grass_dirt.png` | tile_2 | `TILE_GRASS_DIRT` (3) |
| `assets/tiles/terrain/clay.png` | Regenerated: tiles-pro `1f1c6d8e-ca01-4e79-99cc-a0caed737411` tile_0 (original batch tile_6 was corrupt) | `TILE_CLAY` (7) |

## Ore tiles (16×16 PNG)

| File | PixelLab | Used by |
|------|----------|---------|
| `assets/tiles/ores/coal_ore.png` | tile_3 | `TILE_COAL` (4) |
| `assets/tiles/ores/copper_ore.png` | tile_4 | `TILE_COPPER_ORE` (5) |
| `assets/tiles/ores/iron_ore.png` | tile_5 | `TILE_IRON_ORE` (6) |

## Structure tiles (16×16 PNG)

| File | PixelLab | Used by |
|------|----------|---------|
| `assets/tiles/structures/wood_plank.png` | Regenerated: tiles-pro `1f1c6d8e-ca01-4e79-99cc-a0caed737411` tile_1 | `TILE_WOOD_PLANK` (8) |
| `assets/tiles/structures/stone_brick.png` | tile_8 | `TILE_STONE_BRICK` (9) |

## TileSet resource

| File | Purpose |
|------|---------|
| `assets/tiles/terrawatt_tileset.tres` | Godot `TileSet`: 9 atlas sources (IDs 0–8), physics layer 0 full 16×16 rect per solid tile. **Generate in Godot:** open `scripts/create_tileset.gd` → **File → Run**. |

`WorldRenderer` loads this path when present; otherwise it uses the built-in color placeholder strip.

## Parallax backgrounds (PixelLab `create_map_object`)

| File | Object ID | Size (actual) | Used by |
|------|-----------|---------------|---------|
| `assets/backgrounds/bg_layer_far.png` | `e589e977-92ec-4451-9178-a7dcc2710b38` | 320×320 (scaled to viewport) | `world/background.tscn` `LayerFar` |
| `assets/backgrounds/bg_layer_mid.png` | `d760b7c3-56ad-448d-a50d-558b591b2c91` | 320×320 | `LayerMid` |
| `assets/backgrounds/bg_layer_near.png` | `09ec6ee4-3255-4ae7-9958-5ae46eefeeef` | 320×320 | `LayerNear` |

## UI / lighting

| File | Object ID | Size | Used by |
|------|-----------|------|---------|
| `assets/ui/light_radial.png` | `00976caf-3cac-4524-b042-d8b96e493965` | 128×128 | `player/player.tscn` `Headlamp`, `world/lighting.gd` ore glow |

## Scenes / scripts

| Path | Role |
|------|------|
| `world/background.tscn`, `world/background.gd` | 3-layer parallax; `Main` calls `update_parallax` each frame |
| `world/lighting.tscn`, `world/lighting.gd` | Screen darkness by depth; ore proximity `PointLight2D` pool |
| `scripts/create_tileset.gd` | EditorScript: writes `terrawatt_tileset.tres` |
