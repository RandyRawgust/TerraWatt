# TERRAWATT — AGENT STATUS BOARD
# All agents read and update this file after every commit.
# Format: ## [AgentName] — [Date] | STATUS | COMPLETED | IN PROGRESS | BLOCKED | EXPORTS

---

## INSTRUCTIONS
After every git commit, update your section below.
Other agents depend on this file to know what they can use.
If you are blocked, say so here — do not just sit idle.

---

## Preflight Agent (Tier 1) — March 29, 2026
STATUS: COMPLETE
COMPLETED:
  - RigidBody2D sleeping bug fixed (collectibles fall into holes)
  - Creature CharacterBody2D gravity and move_and_slide unified (wolf, rabbit; bird stays Node2D aerial)
  - GDExtension built Windows x86_64 debug — DLL at res://bin/ (local artifact, gitignored); terrawatt_sim.gdextension committed
  - Static tile_id_to_source_id and TileMap set_cell atlas coords already correct in world_renderer.gd / world_data.gd (no code change)
  - project.godot [gdextension] singletons entry restored after build
IN PROGRESS: —
BLOCKED ON: —
EXPORTS:
  - SimManager is REAL when `libterrawatt_sim.windows.template_debug.x86_64.dll` is present: get_cell() returns C++ sim state; add_particle / set_cell forward to TerrawattSimNode
  - Build: from repo root, `py -3 -m pip install scons` then `cd simulation/gdextension` and `py -3 -m SCons platform=windows target=template_debug arch=x86_64`
  - Godot F5 verification not run in agent shell; confirm locally: SimManager prints C++ extension loaded successfully
NOTE:
  - Tier 1 agents that read SimManager can use meaningful sim data after building the DLL (macOS/Linux: add matching .gdextension library lines and compile on those platforms).

---

## Foundation Agent — March 28, 2026
STATUS: COMPLETE
COMPLETED:
  - Godot 4 project.godot configured with all autoloads
  - Full folder structure created
  - All 5 autoload stubs created and compilable
  - main.tscn and main.gd stub created
  - .gitignore, AGENT.md, .cursor/rules/ configured
  - Initial commit pushed to main
IN PROGRESS: —
BLOCKED ON: —
EXPORTS:
  - All autoloads registered (SimManager, WorldData, Inventory, PowerGrid, MaterialRegistry)
  - res://main.tscn — runnable stub scene
  - All folder paths created and ready for other agents

---

## Pixel Sim Agent — March 28, 2026
STATUS: COMPLETE (build C++ locally — see simulation/gdextension/SConstruct)
COMPLETED:
  - GDExtension sources: simulation/gdextension/src/ (SimCore, TerrawattSimNode, materials)
  - sim_manager.gd integrated with TerrawattSimNode + physics step
  - sim_renderer.gd + simulation/test_sim.tscn integration test
  - MaterialRegistry: MAT_COAL_DUST, MAT_EMBERS + colors
IN PROGRESS: —
BLOCKED ON: —
EXPORTS:
  - autoload: SimManager.get_cell(x, y) → Dictionary {material_id, temperature, flags}
  - autoload: SimManager.set_cell(x, y, material_id)
  - autoload: SimManager.add_particle(x, y, material_id)
  - autoload: SimManager.get_sim_width() / get_sim_height() / get_sim_node()
  - signal: SimManager.cell_changed(x, y, material_id)
  - scene: res://simulation/test_sim.tscn
  - C++ class: TerrawattSimNode (after scons build + DLL in res://bin/)

---

## World Gen Agent — March 28, 2026
STATUS: COMPLETE
COMPLETED:
  - world_data.gd: FastNoiseLite terrain/caves/ores, 32×32 chunks, load/unload streaming
  - world_renderer.gd / world_renderer.tscn: TileMap + placeholder atlas (MaterialRegistry colors)
  - spawn_locator.gd: surface-based spawn in pixel coords
  - main.tscn wires WorldRenderer + Camera2D; main.gd initializes seed and camera follow
  - tests/world_gen_test.gd: headless checks (run with Godot -s res://tests/world_gen_test.gd)
IN PROGRESS: —
BLOCKED ON: —
EXPORTS:
  - autoload: WorldData.get_tile(x, y) → int (tile_id)
  - autoload: WorldData.set_tile(x, y, tile_id)
  - autoload: WorldData.get_surface_y(x) → int
  - signal: WorldData.chunk_loaded(chunk_pos)
  - signal: WorldData.chunk_unloaded(chunk_pos)
  - signal: WorldData.tile_changed(pos, old_id, new_id)
  - scene: res://world/world_renderer.tscn
  - static: SpawnLocator.find_spawn_point(world_x) → Vector2

---

## Player Agent — March 28, 2026
STATUS: COMPLETE
COMPLETED:
  - res://player/player.gd — movement, jump, mining tool, signals tile_mined / item_collected
  - res://player/player.tscn — AnimatedSprite2D, capsule collision, headlamp, camera, MiningSystem, PlayerStatus
  - res://mining/mining_system.gd — click-hold mine, range, tool speed, spawns collectibles
  - res://mining/mine_progress_indicator.gd — arc progress
  - res://mining/collectible_item.gd + .tscn — bobbing pickup, Inventory.add_item
  - res://player/player_status.gd — wet/fire/smoke, air, health, status_changed
  - res://main.tscn — instances WorldRenderer + Player; main.gd seeds WorldData and spawns player above surface
  - Placeholder art: res://assets/player/player_frames.png, res://assets/ui/light_radial.png, res://assets/tiles/ores/*_icon.png
  - world_renderer.gd — TileSet physics + two extra placeholder tile colors (ids 8–9); removed .gdignore from asset folders so textures import
IN PROGRESS: —
BLOCKED ON: —
EXPORTS:
  - signal: Player.tile_mined(tile_pos, tile_id)
  - signal: Player.item_collected(item_type, amount)
  - scene: res://player/player.tscn

---

## Visual & Art Agent — March 28, 2026
STATUS: COMPLETE
COMPLETED:
  - 9× terrain/ore/structure tiles via PixelLab MCP (`create_tiles_pro`); parallax + light radial via `create_map_object`
  - PNGs under `res://assets/tiles/`, `res://assets/backgrounds/`, `res://assets/ui/light_radial.png`
  - `scripts/create_tileset.gd` (EditorScript) builds `terrawatt_tileset.tres` — run once in Godot File → Run
  - `world/background.tscn` + `background.gd`; `world/lighting.tscn` + `lighting.gd` (darkness + ore glow)
  - `res://assets/ASSET_MANIFEST.md` listing all assets
  - `main.tscn` wires background + lighting; `WorldRenderer` + `WorldData` tile_id 8–9 (wood plank, stone brick)
IN PROGRESS: —
BLOCKED ON: —
EXPORTS:
  - All tile sprites in res://assets/tiles/
  - scene: res://world/background.tscn
  - scene: res://world/lighting.tscn
  - Completed asset list in res://assets/ASSET_MANIFEST.md

---

## UI & Creatures Agent — March 28, 2026
STATUS: COMPLETE
COMPLETED:
  - res://ui/hud.tscn — CanvasLayer HUD (power meter, health, air, status icons, hotbar)
  - res://ui/hotbar.gd, power_meter.gd, health_bar.gd, air_bar.gd, status_icons.gd, status_icon.tscn
  - res://player/player_status.gd — status_changed signal for HUD; res://player/player.gd stub (group + take_damage)
  - res://creatures/wolf.tscn + wolf.gd — hostile, chases player in range, melee damage
  - res://creatures/rabbit.tscn + rabbit.gd — passive hop, flees within 120px
  - res://creatures/bird.tscn + bird.gd — horizontal flight, respawns off-screen
  - res://scripts/creature_sprite_util.gd — flat-color SpriteFrames until art PNGs land
  - main.tscn — HUD instance, Player + Camera2D + PlayerStatus, ground plane, demo creatures
IN PROGRESS: —
BLOCKED ON: —
EXPORTS:
  - autoload: Inventory (item_added / item_removed) — hotbar listens
  - scene: res://ui/hud.tscn
  - scene: res://creatures/wolf.tscn, rabbit.tscn, bird.tscn
  - PlayerStatus.status_changed(wet, on_fire, suffocating, air, health)
  - PixelLab MCP art: optional drop-in paths per GDD (res://assets/ui/, res://assets/creatures/) — runtime placeholders active

---

## Sprites Agent (Tier 1) — March 29, 2026
STATUS: COMPLETE
COMPLETED:
  - `player_sheet.png` generated (PixelLab map object `b504e3d4-9a33-40e9-a905-4a56b8bdfebe`) and wired in `player/player.gd` — 6×24×40 atlas, idle / walk / jump
  - `wolf_sheet.png`, `rabbit_sheet.png`, `bird_sheet.png` generated and wired in `creatures/*.gd` — `AnimatedSprite2D` + `TEXTURE_FILTER_NEAREST`, silhouettes hidden when sheets load
  - `assets/ASSET_MANIFEST.md` updated with player + creature strips and TODO list
IN PROGRESS: —
BLOCKED ON: —
EXPORTS:
  - `res://assets/player/player_sheet.png`
  - `res://assets/creatures/wolf_sheet.png`
  - `res://assets/creatures/rabbit_sheet.png`
  - `res://assets/creatures/bird_sheet.png`

---

## Power Tier 0 Agent — March 28, 2026
STATUS: COMPLETE
COMPLETED:
  - PowerGrid: source registration, totals, get_local_power (10-tile radius), stale entry cleanup, power_updated signal
  - PowerSourceBase: max/current output, grid registration, operating flag
  - WaterWheel: SimManager water-cell sampling, 0–50W, placeholder AnimatedSprite2D frames
  - Windmill: sinusoidal wind, 5–80W when surface-valid (tile Y <= WorldData.get_surface_y + 5)
  - SteamEngine: wood/water consumption, steam/smoke particles via SimManager, idle/operate animation
  - Scenes: water_wheel.tscn, windmill.tscn, steam_engine.tscn (collision + sprites; placeholder texture res://assets/power/placeholder_8x8.png)
IN PROGRESS: —
BLOCKED ON: —
EXPORTS:
  - autoload: PowerGrid.get_local_power(pos) → float (watts)
  - autoload: PowerGrid.register_source(node, watts), unregister_source, update_source_output
  - signal: PowerGrid.power_updated(generation, demand)
  - class: PowerSourceBase — extend for Tier 0 generators
  - scene: res://power/sources/water_wheel.tscn
  - scene: res://power/sources/windmill.tscn
  - scene: res://power/sources/steam_engine.tscn

---

## Coal Power Agent (Tier 1) — March 29, 2026
STATUS: COMPLETE
COMPLETED:
  - MaterialRegistry: `fuel_value` on Coal (30) and Wood (15); Wood `ignition_temp` aligned with fuels
  - `power/tier1/coal_furnace.gd` + `coal_furnace.tscn` — burn timer, heat output, smoke particles, groups `machines` + `coal_furnaces`, `PollutionTracker.report_coal_burned()` per unit consumed
  - `power/tier1/water_boiler.gd` + `water_boiler.tscn` — heat link, water → steam pressure, steam particles, pressure needle
  - `power/tier1/steam_turbine.gd` + `steam_turbine.tscn` — `PowerSourceBase` → `PowerGrid`, steam efficiency, spin animation
  - `player/machine_interactor.gd` + `player.tscn` — **E**: load coal, link boiler↔furnace + water bucket, link turbine↔boiler (128px chain range)
  - `crafting/recipe_registry.gd` — Tier 1 workbench recipes (furnace / boiler / turbine)
IN PROGRESS: —
BLOCKED ON: —
EXPORTS:
  - scenes: `res://power/tier1/coal_furnace.tscn`, `water_boiler.tscn`, `steam_turbine.tscn`
  - class_name: `CoalFurnace`, `WaterBoiler`, `SteamTurbine` — group `machines` (furnace also `coal_furnaces`)
  - recipes: `RecipeRegistry`-pattern script at `res://crafting/recipe_registry.gd` (preload for `RECIPES`)
NOTE:
  - Machine body textures use ore placeholders until `res://assets/power/tier1/` PixelLab art is dropped in.

---

## Pollution Agent (Tier 1) — March 29, 2026
STATUS: COMPLETE
COMPLETED:
  - `res://world/pollution_tracker.gd` autoload — global 0–1 pollution, dissipation, acid rain threshold / signals
  - `CoalFurnace`: `add_to_group("coal_furnaces")`, `PollutionTracker.report_coal_burned()` on each coal unit burned
  - `res://world/pollution_overlay.tscn` + `pollution_overlay.gd` — full-screen haze (CanvasLayer layer 5)
  - `background.gd` / `background.tscn` — `IndustrialLayer` (smokestack art) visible when pollution > 10%; parallax + day/night modulate
  - `res://assets/backgrounds/bg_industrial_tier1.png` — placeholder (copy of mid layer until PixelLab silhouette is dropped in)
  - `res://world/soot_system.gd` — darkens `structures` group near burning `coal_furnaces` (`get_heat_output() > 0`)
  - `lighting.gd` — sky tint blends with pollution smog for coordinated haze
  - `main.tscn` — PollutionOverlay + SootSystem; `project.godot` — PollutionTracker autoload
IN PROGRESS: —
BLOCKED ON: —
EXPORTS:
  - autoload: PollutionTracker.global_pollution_level, report_coal_burned(), signals pollution_changed / acid_rain_*
  - scene: res://world/pollution_overlay.tscn
  - groups: coal_furnaces (soot + sim), structures (soot targets)

---

## Conveyors Agent — March 29, 2026
STATUS: COMPLETE
COMPLETED:
  - `res://structures/conveyor_belt.gd` + `conveyor_belt.tscn` — belt speed, direction enum, item carry list, `get_push_vector()`, Tier-1 placement overlap rule enforced from player
  - `res://structures/belt_inserter.gd` + `belt_inserter.tscn` — `Area2D` delivers `coal` collectibles to `coal_furnaces` / `machines` with `add_coal()` within 24px (scene must be instanced; no hotbar hook yet)
  - Player: R / scroll wheel cycles belt direction; right-click with `conveyor_belt` hotbar + inventory places snapped 16px; conveyor push when standing on belt
  - `mining/collectible_item.gd` — registers/unregisters with conveyors by proximity
  - `hotbar.gd` — `get_selected_item_name()`, group `hotbar`
  - Input `rotate_structure` (R) in `project.godot` and `main.gd` `_ensure_input_actions` fallback
  - `res://assets/structures/conveyor_belt_sheet.png` — 64×8 strip (4×16×8) procedural PNG; code falls back if missing
IN PROGRESS: —
BLOCKED ON: —
EXPORTS:
  - `class_name ConveyorBelt`, group `conveyors`
  - Place with inventory key `conveyor_belt` (give via `Inventory.add_item` for tests)
  - Belt inserter scene path: `res://structures/belt_inserter.tscn`
NOTE:
  - Coal furnace scene: `res://power/tier1/coal_furnace.tscn`; inserter calls `add_coal` when a `coal_furnaces` member is nearby

---

## Electrical Grid Agent (Tier 1) — March 29, 2026
STATUS: COMPLETE
COMPLETED:
  - `power/power_grid.gd` — pole registration, union-find networks, per-network feed from sources within `PowerPole.CONNECTION_RANGE`, capacity = poles × 500 W (GDD §6 wooden pole), `has_power_at()`, `get_pole_network_watts()`, `get_local_power()` merges mechanical + distribution; `pole_registered` signal
  - `power/tier1/power_pole.gd` + `power_pole.tscn` — `class_name PowerPole`, sag wire drawing, powered tint via grid
  - Player — `place` action places `power_pole` when hotbar item selected; solid tile below required; uses `_place_structure_at`
  - `ui/power_meter.gd` + `hud.tscn` — Gen/Dem progress bars, status light (green/yellow/red), kW formatting
  - `ui/hotbar.gd` — icon fallback `res://assets/power/tier1/<item>.png` for non-ore items
  - `main.gd` — `Inventory.add_item("power_pole", 5)` for smoke test
  - Placeholder PNGs: `assets/power/tier1/power_pole.png`, `wire_segment.png` (replace with PixelLab art as needed)
IN PROGRESS: —
BLOCKED ON: —
EXPORTS:
  - `PowerGrid.register_pole` / `unregister_pole` — Node2D poles
  - `PowerGrid.has_power_at(world_pos)`, `get_pole_network_watts(pole)`, `get_local_power(pos)` (Tier 0 + Tier 1)
  - `signal pole_registered(pole: Node2D)`
  - `class_name PowerPole` — `CAPACITY_WATTS` 500, `CONNECTION_RANGE` 160, `DISTRIBUTION_RADIUS` 80
  - `res://power/tier1/power_pole.tscn`, inventory id `power_pole`

---

## Integration Agent — March 29, 2026 (Tier 1 wiring)
STATUS: COMPLETE
COMPLETED:
  - main.tscn: SimRenderer, WorldRenderer, BackgroundLayer, LightingManager, Player, GameCamera, DayNightCycle, CreatureSpawner, PollutionOverlay, SootSystem, HUD (CanvasLayer)
  - main.gd: WORLD_SEED, SpawnLocator, camera follow, world renderer + lighting + HUD wiring, creature_spawner.set_player, input actions (mine/place/hotbar_*/rotate_structure fallback), day/night blend to LightingManager + BackgroundLayer
  - main.gd: PollutionTracker.acid_rain_started/stopped → BackgroundLayer modulate tint (green-grey / reset)
  - project.godot [input]: mine (LMB), place (RMB), interact (E), hotbar_1–9 + hotbar_0 (keys 1–9, 0); PollutionTracker autoload
  - player/machine_interactor.gd: uses Input action `interact` (remappable) instead of raw KEY_E
  - creatures/creature_spawner.gd: wolves at night (30+ tiles), rabbits day (40–80), birds (20–60), caps + despawn >100 tiles
  - world/day_night_cycle.gd: 10 min day / 5 min night, get_night_blend + is_night
  - world/lighting.tscn + lighting.gd: SkyTint for cycle; background.gd: set_cycle_night_factor + industrial layer @ pollution > 10%
  - simulation/sim_renderer.tscn; player Camera2D current=false for root GameCamera
IN PROGRESS: —
BLOCKED ON: —
EXPORTS:
  - Runnable game from res://main.tscn; Tier 1 systems spawned/placed in-world (structures, poles, conveyors) — not hardcoded in main.tscn
NOTE:
  - Tier 1 30-point play checklist in `agentprompts/t-1/AGENTS_T1_3456_REMAINING.md` — run F5 locally (Godot not on agent PATH); DLL optional for Scope 1 regression with C++ sim message
