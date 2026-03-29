TERRAWATT — FOUNDATION AGENT
Single command: Paste this entire block into a Cursor Composer Agent tab and press Enter.

━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

## MISSION: Bootstrap the entire Terra.Watt project structure.

You are the FOUNDATION AGENT. Your job runs FIRST before all other agents.
You set up the Godot 4 project, folder structure, git configuration,
shared files, and the autoload stubs every other agent depends on.
Nothing else can start until you finish.

---

## PHASE 0: READ YOUR DOCTRINE (MANDATORY FIRST STEP)

1. Read `TERRAWATT_DOCTRINE.md` — this governs all your behavior.
2. Read `TERRAWATT_GDD.md` — this is your technical bible. Read Section 16 (folder structure) carefully.
3. Read `AGENT_STATUS.md` — confirm no other agent has already done setup work.

If any of these files do not exist, STOP and report:
"CRITICAL: Required files missing — [list files]. Cannot proceed."

---

## PHASE 1: RECONNAISSANCE

Scan the current directory. Report:
- Is there an existing Godot project? (project.godot present?)
- Is there a .git folder?
- What files already exist?
- What is the git remote URL?

Output a ≤50 line digest of findings before proceeding.

---

## PHASE 2: GODOT PROJECT INITIALIZATION

If no project.godot exists, create it:

Create `project.godot` with these settings:
```ini
; Engine configuration file — Terra.Watt
[application]
config/name="Terra.Watt"
config/description="2D infinite sandbox power generation game"
run/main_scene="res://main.tscn"
config/features=PackedStringArray("4.3", "GL Compatibility")

[autoload]
SimManager="*res://simulation/sim_manager.gd"
WorldData="*res://world/world_data.gd"
Inventory="*res://player/inventory.gd"
PowerGrid="*res://power/power_grid.gd"
MaterialRegistry="*res://simulation/material_registry.gd"

[rendering]
renderer/rendering_method="gl_compatibility"
textures/canvas_textures/default_texture_filter=0

[display]
window/size/viewport_width=1920
window/size/viewport_height=1080
window/stretch/mode="canvas_items"
```

---

## PHASE 3: CREATE FULL FOLDER STRUCTURE

Create ALL of these directories (create a .gdignore placeholder file in each empty dir):

```
res://world/
res://simulation/
res://simulation/materials/
res://simulation/gdextension/
res://simulation/gdextension/src/
res://player/
res://player/tools/
res://mining/
res://power/
res://power/sources/
res://structures/
res://creatures/
res://ui/
res://assets/
res://assets/tiles/
res://assets/tiles/terrain/
res://assets/tiles/ores/
res://assets/tiles/structures/
res://assets/player/
res://assets/creatures/
res://assets/ui/
res://assets/particles/
res://assets/backgrounds/
res://scripts/          ← utility scripts and tools
res://scripts/api/      ← reusable API wrappers
```

---

## PHASE 4: CREATE AUTOLOAD STUBS

These are the shared singletons every agent uses. Create MINIMAL but COMPILABLE stubs now.
Other agents will fill them out. Each stub must:
- Have the correct class_name
- Have correct function signatures (correct types, correct return types)
- Have stub bodies that return valid empty/zero values
- Have detailed comments explaining what the real implementation will do

### res://simulation/sim_manager.gd
```gdscript
# SYSTEM: Pixel Simulation
# AGENT: Pixel Sim Agent (stub created by Foundation Agent)
# PURPOSE: Manages the cellular automata simulation layer.
# The real implementation uses a C++ GDExtension for performance.
# STUB VERSION — replace when Pixel Sim Agent delivers the extension.

extends Node

class_name SimManager

# Called every physics tick to step the simulation forward.
# STUB: does nothing until GDExtension is loaded.
func step_simulation(delta: float) -> void:
    pass

# Returns the simulation cell data at world tile position (x, y).
# Returns material_id=0 (air) until simulation is running.
func get_cell(x: int, y: int) -> Dictionary:
    return {"material_id": 0, "temperature": 0.0, "flags": 0}

# Sets a simulation cell to a specific material.
func set_cell(x: int, y: int, material_id: int) -> void:
    pass

# Spawns a particle of material_id at world position (x, y).
func add_particle(x: int, y: int, material_id: int) -> void:
    pass

# Emitted when a cell's material changes.
signal cell_changed(x: int, y: int, material_id: int)
```

### res://world/world_data.gd
```gdscript
# SYSTEM: World Generation
# AGENT: World Gen Agent (stub created by Foundation Agent)
# PURPOSE: Manages world generation, chunk storage, tile access.
# STUB VERSION — replace when World Gen Agent delivers full generation.

extends Node

class_name WorldData

const CHUNK_SIZE: int = 32
const TILE_AIR: int = 0
const TILE_DIRT: int = 1
const TILE_STONE: int = 2
const TILE_GRASS_DIRT: int = 3
const TILE_COAL: int = 4
const TILE_COPPER_ORE: int = 5
const TILE_IRON_ORE: int = 6
const TILE_CLAY: int = 7

var world_seed: int = 0

# Returns the tile ID at world position (x, y). 0 = air.
func get_tile(x: int, y: int) -> int:
    return TILE_AIR  # STUB

# Sets the tile at world position (x, y) to tile_id.
func set_tile(x: int, y: int, tile_id: int) -> void:
    pass  # STUB

# Returns the Y position of the surface (topmost non-air tile) at X.
func get_surface_y(x: int) -> int:
    return 10  # STUB: flat ground at Y=10

# Emitted when a chunk finishes generating/loading.
signal chunk_loaded(chunk_pos: Vector2i)

# Emitted when a tile changes (mined, placed, destroyed).
signal tile_changed(pos: Vector2i, old_id: int, new_id: int)
```

### res://player/inventory.gd
```gdscript
# SYSTEM: Player Inventory
# AGENT: UI & Creatures Agent (stub created by Foundation Agent)
# PURPOSE: Global inventory singleton. Tracks all collected items.

extends Node

class_name Inventory

# item_name (String) → count (int)
var items: Dictionary = {}

# Add `amount` of `item_type` to inventory.
func add_item(item_type: String, amount: int = 1) -> void:
    if items.has(item_type):
        items[item_type] += amount
    else:
        items[item_type] = amount
    item_added.emit(item_type, amount)

# Remove `amount` of `item_type`. Returns false if not enough.
func remove_item(item_type: String, amount: int = 1) -> bool:
    if not has_item(item_type, amount):
        return false
    items[item_type] -= amount
    if items[item_type] <= 0:
        items.erase(item_type)
    item_removed.emit(item_type, amount)
    return true

# Returns true if player has at least `amount` of `item_type`.
func has_item(item_type: String, amount: int = 1) -> bool:
    return items.get(item_type, 0) >= amount

# Returns count of item_type (0 if none).
func get_count(item_type: String) -> int:
    return items.get(item_type, 0)

signal item_added(item_type: String, amount: int)
signal item_removed(item_type: String, amount: int)
```

### res://power/power_grid.gd
```gdscript
# SYSTEM: Power Grid
# AGENT: Power Tier 0 Agent (stub created by Foundation Agent)
# PURPOSE: Global power management. Tracks generation vs demand.
# STUB VERSION.

extends Node

class_name PowerGrid

var total_generation_watts: float = 0.0
var total_demand_watts: float = 0.0

# Register a power source at world position `pos` generating `watts`.
func register_source(node: Node, watts: float) -> void:
    pass  # STUB

# Unregister a power source.
func unregister_source(node: Node) -> void:
    pass  # STUB

# Get available local power at a world position.
func get_local_power(pos: Vector2) -> float:
    return total_generation_watts  # STUB: no local zones yet

signal power_updated(generation: float, demand: float)
```

### res://simulation/material_registry.gd
```gdscript
# SYSTEM: Material Registry
# AGENT: Pixel Sim Agent (stub created by Foundation Agent)
# PURPOSE: Defines all materials and their properties.
# Maps tile IDs (int) to material definitions (Dictionary).

extends Node

class_name MaterialRegistry

# Material IDs — match WorldData tile constants
const MAT_AIR: int = 0
const MAT_DIRT: int = 1
const MAT_STONE: int = 2
const MAT_GRASS_DIRT: int = 3
const MAT_COAL: int = 4
const MAT_COPPER_ORE: int = 5
const MAT_IRON_ORE: int = 6
const MAT_CLAY: int = 7
# Simulation particle materials (100+)
const MAT_WATER: int = 100
const MAT_STEAM: int = 101
const MAT_FIRE: int = 102
const MAT_SMOKE: int = 103
const MAT_ASH: int = 104
const MAT_MUD: int = 105

# Full material definitions loaded from res://simulation/materials/
var materials: Dictionary = {}

func _ready() -> void:
    _register_defaults()

func get_material(id: int) -> Dictionary:
    return materials.get(id, {})

func get_display_name(id: int) -> String:
    return materials.get(id, {}).get("name", "Unknown")

func get_color(id: int) -> Color:
    return materials.get(id, {}).get("color", Color.MAGENTA)

func _register_defaults() -> void:
    materials[MAT_AIR]        = {"name": "Air",       "category": "GAS",    "color": Color(0,0,0,0),       "flammable": false}
    materials[MAT_DIRT]       = {"name": "Dirt",      "category": "SOLID",  "color": Color(0.55,0.42,0.24), "flammable": false, "mine_time": 0.5}
    materials[MAT_STONE]      = {"name": "Stone",     "category": "SOLID",  "color": Color(0.42,0.42,0.42), "flammable": false, "mine_time": 1.5}
    materials[MAT_GRASS_DIRT] = {"name": "Grass",     "category": "SOLID",  "color": Color(0.29,0.49,0.18), "flammable": false, "mine_time": 0.5}
    materials[MAT_COAL]       = {"name": "Coal",      "category": "SOLID",  "color": Color(0.16,0.16,0.16), "flammable": true,  "mine_time": 1.0, "ignition_temp": 300.0}
    materials[MAT_COPPER_ORE] = {"name": "Copper Ore","category": "SOLID",  "color": Color(0.72,0.45,0.20), "flammable": false, "mine_time": 2.0}
    materials[MAT_IRON_ORE]   = {"name": "Iron Ore",  "category": "SOLID",  "color": Color(0.54,0.54,0.60), "flammable": false, "mine_time": 2.5}
    materials[MAT_CLAY]       = {"name": "Clay",      "category": "SOLID",  "color": Color(0.65,0.48,0.35), "flammable": false, "mine_time": 0.7}
    materials[MAT_WATER]      = {"name": "Water",     "category": "LIQUID", "color": Color(0.20,0.50,0.80,0.8), "flammable": false, "density": 1.0}
    materials[MAT_STEAM]      = {"name": "Steam",     "category": "GAS",    "color": Color(0.85,0.85,0.90,0.5), "flammable": false}
    materials[MAT_FIRE]       = {"name": "Fire",      "category": "ENERGY", "color": Color(1.0,0.45,0.10),  "flammable": false}
    materials[MAT_SMOKE]      = {"name": "Smoke",     "category": "GAS",    "color": Color(0.25,0.25,0.25,0.7), "flammable": false}
    materials[MAT_ASH]        = {"name": "Ash",       "category": "SOLID",  "color": Color(0.50,0.48,0.45), "flammable": false}
    materials[MAT_MUD]        = {"name": "Mud",       "category": "LIQUID", "color": Color(0.40,0.30,0.18,0.9), "flammable": false, "density": 1.8}
```

---

## PHASE 5: CREATE main.tscn AND main.gd STUBS

### res://main.gd
```gdscript
# SYSTEM: Main Game Loop
# AGENT: Integration Agent (stub created by Foundation Agent)
# PURPOSE: Entry point. Initializes all systems and starts the game.

extends Node2D

func _ready() -> void:
    print("Terra.Watt — Initializing...")
    # Systems initialize via their own _ready() calls as autoloads.
    # Main scene wires them together here once all agents deliver.
    print("Terra.Watt — Ready. Open main.tscn in Godot to run.")

func _process(delta: float) -> void:
    pass
```

Create a minimal `main.tscn` that:
- Has a Node2D root named "Main" with script `main.gd`
- Has child nodes for: WorldRenderer, Player, HUD (all empty Node2D stubs for now)
- Saves correctly in Godot scene format

---

## PHASE 6: CREATE PROJECT CONFIGURATION FILES

### .gitignore
```
# Godot
.godot/
*.import
*.translation
export_presets.cfg

# C++ build artifacts
*.o
*.obj
*.a
*.so
*.dll
*.dylib
bin/

# IDE
.cursor/
.vscode/
*.swp

# OS
.DS_Store
Thumbs.db

# Logs
*.log
```

### .cursor/rules/TERRAWATT_DOCTRINE.md
Copy the content of `TERRAWATT_DOCTRINE.md` into this path so Cursor loads it automatically.

### AGENT.md (project manifest for Claude Code)
```markdown
# Terra.Watt — Agent Manifest

## Project
2D sandbox power generation game. Godot 4. GDScript + C++ GDExtension.

## Key Files
- TERRAWATT_GDD.md       — Game Design Document (source of truth)
- AGENT_STATUS.md        — Inter-agent status board (update after every commit)
- .cursor/rules/         — Cursor AI doctrine files

## Autoloads (singletons accessible from anywhere)
- SimManager             — Cellular automata simulation layer
- WorldData              — World generation and tile access
- Inventory              — Player item storage
- PowerGrid              — Power generation/demand tracking
- MaterialRegistry       — All material definitions

## Folder Structure
See TERRAWATT_GDD.md Section 16.

## Build Instructions (GDExtension C++ sim layer)
cd simulation/gdextension && scons platform=<your_platform>

## Git Branch Strategy
main — always runnable. Commit stubs, not broken code.
```

---

## PHASE 7: INITIAL GIT COMMIT

```bash
git add -A
git commit -m "[Foundation] chore: project bootstrap — structure, autoloads, stubs, doctrine"
git push origin main
```

---

## PHASE 8: UPDATE AGENT_STATUS.md

Update the Foundation Agent section:
```
## Foundation Agent — [TODAY'S DATE]
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
```

Commit and push AGENT_STATUS.md.

---

## FINAL REPORT FORMAT

Conclude with:
```
FOUNDATION AGENT — FINAL REPORT

✅ project.godot created with [N] autoloads registered
✅ [N] directories created
✅ [N] autoload stub files created and compilable
✅ main.tscn opens in Godot without errors
✅ .gitignore, AGENT.md, doctrine files in place
✅ Initial commit pushed: [commit hash]
✅ AGENT_STATUS.md updated

Self-Audit Complete. Project structure verified.
Other agents may now begin work simultaneously.
```

If anything fails:
```
🚧 BLOCKED: [describe exact issue]
[list what WAS completed successfully]
[list what failed and why]
[recommended fix for human developer]
```
