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
