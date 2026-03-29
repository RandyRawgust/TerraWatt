TERRAWATT — WORLD GENERATION AGENT
Single command: Paste this entire block into a Cursor Composer Agent tab and press Enter.
Run SIMULTANEOUSLY with Pixel Sim, Player, Visual, UI, and Power agents after Foundation Agent completes.

━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

## MISSION: Build the procedural world generation system.

You are the WORLD GEN AGENT. You generate the world the player inhabits —
its terrain, caves, ore veins, underground layers, and chunk management system.
Performance matters: the world is infinite horizontally and you must use chunked
streaming so only nearby chunks are loaded.

---

## PHASE 0: READ YOUR DOCTRINE (MANDATORY FIRST STEP)

1. Read `TERRAWATT_DOCTRINE.md` — your operating rules.
2. Read `TERRAWATT_GDD.md` — Section 3 (World Generation) and Section 16 (folder structure).
3. Read `AGENT_STATUS.md` — confirm Foundation Agent is COMPLETE.
4. Read `res://world/world_data.gd` — you are replacing this stub.
5. Read `res://simulation/material_registry.gd` — use tile ID constants from here.

If Foundation Agent is NOT COMPLETE, poll every 3 minutes:
```bash
git pull origin main && cat AGENT_STATUS.md
```
While waiting: design and pseudocode your generation algorithms.

---

## PHASE 1: ARCHITECTURE PLAN

Before coding, document your approach (max 50 lines):
- How will you use Godot's FastNoiseLite for terrain generation?
- How will the chunk system work? (32×32 tiles, dict keyed by Vector2i)
- How will you stream chunks as the player moves?
- How will you distribute ore veins (noise-based thresholds per layer)?

---

## PHASE 2: WORLD DATA SYSTEM (REPLACE STUB)

Replace `res://world/world_data.gd` with the full implementation:

```gdscript
# SYSTEM: World Generation
# AGENT: World Gen Agent
# PURPOSE: Procedural world generation, chunk management, tile access.

extends Node

class_name WorldData

const CHUNK_SIZE: int = 32       # tiles per chunk side
const TILE_SIZE:  int = 16       # pixels per tile (for rendering)

# Tile type constants — must match MaterialRegistry exactly
const TILE_AIR:        int = 0
const TILE_DIRT:       int = 1
const TILE_STONE:      int = 2
const TILE_GRASS_DIRT: int = 3
const TILE_COAL:       int = 4
const TILE_COPPER_ORE: int = 5
const TILE_IRON_ORE:   int = 6
const TILE_CLAY:       int = 7

# World layer Y boundaries (in tile coordinates, Y increases downward)
const SURFACE_Y:         int = 0
const SHALLOW_START_Y:   int = 10
const MID_UNDERGROUND_Y: int = 60
const DEEP_UNDERGROUND_Y:int = 150
const ABYSS_Y:           int = 280

# Noise generators
var terrain_noise:   FastNoiseLite
var cave_noise:      FastNoiseLite
var ore_noise_coal:  FastNoiseLite
var ore_noise_copper:FastNoiseLite
var ore_noise_iron:  FastNoiseLite
var clay_noise:      FastNoiseLite

# Chunk storage: Vector2i(chunk_x, chunk_y) → PackedInt32Array (CHUNK_SIZE*CHUNK_SIZE tiles)
var loaded_chunks: Dictionary = {}

var world_seed: int = 0

func _ready() -> void:
    _init_noise()

func initialize(seed_value: int) -> void:
    world_seed = seed_value
    _init_noise()
    print("WorldData: Initialized with seed %d" % seed_value)
```

Implement these methods fully:

**`_init_noise()`** — sets up all FastNoiseLite generators with different seeds derived from world_seed:
- terrain_noise: FBM, 3 octaves, frequency 0.005 — drives surface height variation
- cave_noise: Domain Warped, frequency 0.03 — drives cave cavern shapes
- ore_noise_coal through iron: frequency 0.08-0.12 — drives ore pocket placement
- clay_noise: frequency 0.02 — drives clay pocket placement

**`get_tile(x, y)`** — returns tile at world tile position. Generates chunk if not loaded.

**`set_tile(x, y, tile_id)`** — sets tile, marks chunk dirty, emits tile_changed signal.

**`get_surface_y(x)`** — returns the Y of the topmost non-air tile at column x. Uses terrain_noise.

**`_generate_chunk(chunk_pos: Vector2i)`** — THE CORE GENERATION FUNCTION:

Generation rules per Y layer:
```
Y < SHALLOW_START_Y:
    → AIR (sky)

Y == get_surface_y(world_x):
    → GRASS_DIRT (surface top)

SHALLOW_START_Y ≤ Y < MID_UNDERGROUND_Y:
    → Base: DIRT
    → Cave: if cave_noise > 0.35 → AIR
    → Ore:  if ore_noise_coal > 0.65 → COAL (coal found shallowest)
    → Clay: if clay_noise > 0.60 → CLAY

MID_UNDERGROUND_Y ≤ Y < DEEP_UNDERGROUND_Y:
    → Base: STONE
    → Cave: if cave_noise > 0.40 → AIR
    → Ore:  if ore_noise_coal > 0.70 → COAL
            if ore_noise_copper > 0.68 → COPPER_ORE
            if ore_noise_iron > 0.72 → IRON_ORE

DEEP_UNDERGROUND_Y ≤ Y:
    → Base: STONE (denser)
    → Cave: if cave_noise > 0.45 → AIR
    → Ore:  if ore_noise_iron > 0.65 → IRON_ORE (more common deeper)
```

Surface terrain height variation:
- terrain_noise at each x column produces a float
- Map it to ±8 tiles variation from SURFACE_Y
- This creates rolling hills

**`_get_chunk_key(tile_x, tile_y) → Vector2i`** — converts tile coords to chunk key
**`_get_local_tile_index(tile_x, tile_y) → int`** — index within chunk array
**`load_chunks_near(center_tile_pos: Vector2i, radius: int)`** — loads all chunks within radius chunks of position
**`unload_distant_chunks(center_tile_pos: Vector2i, keep_radius: int)`** — removes chunks beyond keep_radius from memory

---

## PHASE 3: WORLD RENDERER

Create `res://world/world_renderer.gd` and `res://world/world_renderer.tscn`:

The renderer uses a Godot 4 TileMap node to display the tile layer.
The TileMap's tileset must reference sprite resources from `res://assets/tiles/`.

```gdscript
# SYSTEM: World Rendering
# AGENT: World Gen Agent
# PURPOSE: Renders the tile layer using Godot TileMap.
# Listens to WorldData signals to update tiles when they change.

extends Node2D

class_name WorldRenderer

@onready var tile_map: TileMap = $TileMap

# Camera-based chunk loading bounds
@export var render_radius_chunks: int = 4

var _camera_ref: Camera2D = null

func _ready() -> void:
    WorldData.tile_changed.connect(_on_tile_changed)
    WorldData.chunk_loaded.connect(_on_chunk_loaded)

func set_camera(camera: Camera2D) -> void:
    _camera_ref = camera

func _process(_delta: float) -> void:
    if _camera_ref:
        var cam_tile_pos: Vector2i = Vector2i(
            int(_camera_ref.global_position.x / WorldData.TILE_SIZE),
            int(_camera_ref.global_position.y / WorldData.TILE_SIZE)
        )
        WorldData.load_chunks_near(cam_tile_pos, render_radius_chunks)
        _render_visible_chunks(cam_tile_pos)

func _render_visible_chunks(center: Vector2i) -> void:
    # Update TileMap cells for all loaded chunks near center
    for chunk_pos in WorldData.loaded_chunks:
        _render_chunk(chunk_pos)

func _render_chunk(chunk_pos: Vector2i) -> void:
    var base_x: int = chunk_pos.x * WorldData.CHUNK_SIZE
    var base_y: int = chunk_pos.y * WorldData.CHUNK_SIZE
    for local_y in range(WorldData.CHUNK_SIZE):
        for local_x in range(WorldData.CHUNK_SIZE):
            var world_x: int = base_x + local_x
            var world_y: int = base_y + local_y
            var tile_id: int = WorldData.get_tile(world_x, world_y)
            tile_map.set_cell(0, Vector2i(world_x, world_y), 0, Vector2i(tile_id, 0))

func _on_tile_changed(pos: Vector2i, _old_id: int, new_id: int) -> void:
    tile_map.set_cell(0, pos, 0, Vector2i(new_id, 0))

func _on_chunk_loaded(chunk_pos: Vector2i) -> void:
    _render_chunk(chunk_pos)
```

Scene structure for world_renderer.tscn:
- Node2D (root, script: world_renderer.gd)
  - TileMap (node name: "TileMap", layer 0 for terrain)

---

## PHASE 4: SPAWN POINT

Create `res://world/spawn_locator.gd`:
```gdscript
# Finds a safe spawn position for the player at world start.
# Returns a Vector2 in world pixel coordinates.
static func find_spawn_point(world_x: int = 200) -> Vector2:
    var surface_y: int = WorldData.get_surface_y(world_x)
    # Spawn 2 tiles above surface (in air)
    return Vector2(
        world_x * WorldData.TILE_SIZE,
        (surface_y - 2) * WorldData.TILE_SIZE
    )
```

---

## PHASE 5: TEST AND VERIFY

Write a simple test: generate a world with seed 12345, check that:
- Surface Y at x=200 is between 8-18 (reasonable surface)
- get_tile(200, 100) returns STONE (deep enough to be stone)
- get_tile(200, 5) returns AIR (sky)
- Cave pockets exist (at least 1 AIR tile in y=20-60 range)

Run the test in Godot. If generation crashes, use Claude Code:
```bash
claude "My Godot WorldData._generate_chunk() is crashing with: [error].
        Code: [paste function]. Fix it."
```

---

## PHASE 6: COMMIT SEQUENCE

After each working piece:
```bash
git add -A && git commit -m "[WorldGen] feat: [description]" && git push origin main
```

Update AGENT_STATUS.md as you complete each section.

---

## FINAL REPORT FORMAT

```
WORLD GEN AGENT — FINAL REPORT

✅ WorldData.gd stub replaced — full chunk-based generation
✅ Generation verified: surface, caves, ore veins all generating correctly
✅ World seed system working — seed 12345 produces consistent results
✅ WorldRenderer.tscn renders TileMap from WorldData
✅ Chunk streaming working — loads near camera, unloads distant
✅ SpawnLocator finds valid surface spawn point
✅ All commits pushed: [latest commit hash]
✅ AGENT_STATUS.md updated

Self-Audit Complete. World generation verified and functional.
```
