# TERRAWATT — AGENT STATUS BOARD
# All agents read and update this file after every commit.
# Format: ## [AgentName] — [Date] | STATUS | COMPLETED | IN PROGRESS | BLOCKED | EXPORTS

---

## INSTRUCTIONS
After every git commit, update your section below.
Other agents depend on this file to know what they can use.
If you are blocked, say so here — do not just sit idle.

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

## Player Agent — [DATE]
STATUS: NOT STARTED
COMPLETED: —
IN PROGRESS: —
BLOCKED ON: World Gen Agent (WorldData stubs acceptable)
EXPORTS:
  - signal: Player.tile_mined(tile_pos, tile_id)
  - signal: Player.item_collected(item_type, amount)
  - scene: res://player/player.tscn

---

## Visual & Art Agent — [DATE]
STATUS: NOT STARTED
COMPLETED: —
IN PROGRESS: —
BLOCKED ON: World Gen Agent (for TileMap setup)
EXPORTS:
  - All tile sprites in res://assets/tiles/
  - All player sprites in res://assets/player/
  - scene: res://world/background.tscn
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

## Integration Agent — [DATE]
STATUS: WAITING (runs last, after all others reach COMPLETE)
COMPLETED: —
IN PROGRESS: —
BLOCKED ON: All other agents
EXPORTS: The working game.
