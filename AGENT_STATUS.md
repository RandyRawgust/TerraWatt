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

## World Gen Agent — [DATE]
STATUS: NOT STARTED
COMPLETED: —
IN PROGRESS: —
BLOCKED ON: Pixel Sim Agent (SimManager stubs acceptable)
EXPORTS:
  - autoload: WorldData.get_tile(x, y) → int (tile_id)
  - autoload: WorldData.set_tile(x, y, tile_id)
  - autoload: WorldData.get_surface_y(x) → int
  - signal: WorldData.chunk_loaded(chunk_pos)
  - scene: res://world/world_renderer.tscn

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

## UI & Creatures Agent — [DATE]
STATUS: NOT STARTED
COMPLETED: —
IN PROGRESS: —
BLOCKED ON: Player Agent (Player.item_collected signal)
EXPORTS:
  - autoload: Inventory.add_item(type, amount)
  - autoload: Inventory.has_item(type, amount) → bool
  - scene: res://ui/hud.tscn
  - scene: res://creatures/wolf.tscn
  - scene: res://creatures/rabbit.tscn

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
