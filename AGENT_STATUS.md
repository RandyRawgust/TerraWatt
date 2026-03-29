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

## Pixel Sim Agent — [DATE]
STATUS: NOT STARTED
COMPLETED: —
IN PROGRESS: —
BLOCKED ON: —
EXPORTS:
  - autoload: SimManager.get_cell(x, y) → Dictionary {material_id, temperature, flags}
  - autoload: SimManager.set_cell(x, y, material_id)
  - autoload: SimManager.add_particle(x, y, material_id)
  - signal: SimManager.cell_changed(x, y, material_id)

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

## Power Tier 0 Agent — [DATE]
STATUS: NOT STARTED
COMPLETED: —
IN PROGRESS: —
BLOCKED ON: World Gen Agent (tile placement), Pixel Sim Agent (water/steam)
EXPORTS:
  - autoload: PowerGrid.get_local_power(pos) → float (watts)
  - autoload: PowerGrid.register_source(node, watts)
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
