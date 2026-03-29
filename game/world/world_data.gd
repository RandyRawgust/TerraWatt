# SYSTEM: World Generation
# AGENT: World Gen Agent
# PURPOSE: Procedural world generation, chunk management, tile access.
#
# Architecture (brief):
# - FastNoiseLite: terrain 1D height (FBM), cave/ore/clay 2D thresholds; seeds derived from world_seed.
# - Chunks: Vector2i → PackedInt32Array of CHUNK_SIZE² tile IDs; load_chunks_near / unload_distant_chunks for streaming.
# - Column surface_y from terrain noise (rolling hills); sky above surface_y; grass at surface; depth bands for shallow/mid/deep.

extends Node

const CHUNK_SIZE: int = 32
const TILE_SIZE: int = 16

const TILE_AIR: int = 0
const TILE_DIRT: int = 1
const TILE_STONE: int = 2
const TILE_GRASS_DIRT: int = 3
const TILE_COAL: int = 4
const TILE_COPPER_ORE: int = 5
const TILE_IRON_ORE: int = 6
const TILE_CLAY: int = 7
const TILE_WOOD_PLANK: int = 8
const TILE_STONE_BRICK: int = 9

const SURFACE_Y: int = 0
const SHALLOW_START_Y: int = 10
const MID_UNDERGROUND_Y: int = 60
const DEEP_UNDERGROUND_Y: int = 150

signal chunk_loaded(chunk_pos: Vector2i)
signal chunk_unloaded(chunk_pos: Vector2i)
signal tile_changed(pos: Vector2i, old_id: int, new_id: int)

var terrain_noise: FastNoiseLite
var cave_noise: FastNoiseLite
var ore_noise_coal: FastNoiseLite
var ore_noise_copper: FastNoiseLite
var ore_noise_iron: FastNoiseLite
var clay_noise: FastNoiseLite

var loaded_chunks: Dictionary = {}
var dirty_chunks: Dictionary = {}

var world_seed: int = 0

## terrawatt_tileset: one TileSetAtlasSource per ID; source_id == tile_id - 1 for 1..9.
## Instance method (not static) so autoload calls resolve cleanly vs. analyzer warnings.
func tile_id_to_source_id(tile_id: int) -> int:
	return tile_id - 1


func _ready() -> void:
	_init_noise()


func initialize(seed_value: int) -> void:
	world_seed = seed_value
	loaded_chunks.clear()
	dirty_chunks.clear()
	_init_noise()
	print("WorldData: Initialized with seed %d" % seed_value)


func _init_noise() -> void:
	var s: int = world_seed
	terrain_noise = FastNoiseLite.new()
	terrain_noise.seed = s
	terrain_noise.noise_type = FastNoiseLite.TYPE_PERLIN
	terrain_noise.frequency = 0.005
	terrain_noise.fractal_type = FastNoiseLite.FRACTAL_FBM
	terrain_noise.fractal_octaves = 3

	cave_noise = FastNoiseLite.new()
	cave_noise.seed = s + 1001
	cave_noise.noise_type = FastNoiseLite.TYPE_PERLIN
	cave_noise.frequency = 0.03
	cave_noise.fractal_type = FastNoiseLite.FRACTAL_FBM
	cave_noise.fractal_octaves = 4
	cave_noise.domain_warp_enabled = true
	cave_noise.domain_warp_amplitude = 40.0
	cave_noise.domain_warp_frequency = 0.015

	ore_noise_coal = FastNoiseLite.new()
	ore_noise_coal.seed = s + 2002
	ore_noise_coal.noise_type = FastNoiseLite.TYPE_PERLIN
	ore_noise_coal.frequency = 0.10

	ore_noise_copper = FastNoiseLite.new()
	ore_noise_copper.seed = s + 3003
	ore_noise_copper.noise_type = FastNoiseLite.TYPE_PERLIN
	ore_noise_copper.frequency = 0.09

	ore_noise_iron = FastNoiseLite.new()
	ore_noise_iron.seed = s + 4004
	ore_noise_iron.noise_type = FastNoiseLite.TYPE_PERLIN
	ore_noise_iron.frequency = 0.12

	clay_noise = FastNoiseLite.new()
	clay_noise.seed = s + 5005
	clay_noise.noise_type = FastNoiseLite.TYPE_PERLIN
	clay_noise.frequency = 0.02


func _chunk_coord(v: int) -> int:
	return int(floor(float(v) / float(CHUNK_SIZE)))


func _get_chunk_key(tile_x: int, tile_y: int) -> Vector2i:
	return Vector2i(_chunk_coord(tile_x), _chunk_coord(tile_y))


func _get_local_tile_index(tile_x: int, tile_y: int) -> int:
	var lx: int = posmod(tile_x, CHUNK_SIZE)
	var ly: int = posmod(tile_y, CHUNK_SIZE)
	return ly * CHUNK_SIZE + lx


func get_surface_y(x: int) -> int:
	var n: float = terrain_noise.get_noise_1d(float(x))
	# Rolling hills: baseline aligns with shallow layer; ~8–18 typical for n in [-1, 1]
	return clampi(SURFACE_Y + 13 + int(round(n * 5)), -32, 64)


func get_tile(x: int, y: int) -> int:
	var key: Vector2i = _get_chunk_key(x, y)
	if not loaded_chunks.has(key):
		_generate_chunk(key)
	var chunk: PackedInt32Array = loaded_chunks[key]
	var idx: int = _get_local_tile_index(x, y)
	return chunk[idx]


func set_tile(x: int, y: int, tile_id: int) -> void:
	var key: Vector2i = _get_chunk_key(x, y)
	if not loaded_chunks.has(key):
		_generate_chunk(key)
	var chunk: PackedInt32Array = loaded_chunks[key]
	var idx: int = _get_local_tile_index(x, y)
	var old_id: int = chunk[idx]
	if old_id == tile_id:
		return
	chunk[idx] = tile_id
	dirty_chunks[key] = true
	tile_changed.emit(Vector2i(x, y), old_id, tile_id)


func load_chunks_near(center_tile_pos: Vector2i, radius: int) -> void:
	var cx: int = _chunk_coord(center_tile_pos.x)
	var cy: int = _chunk_coord(center_tile_pos.y)
	for dcx in range(-radius, radius + 1):
		for dcy in range(-radius, radius + 1):
			var cp := Vector2i(cx + dcx, cy + dcy)
			if not loaded_chunks.has(cp):
				_generate_chunk(cp)


func unload_distant_chunks(center_tile_pos: Vector2i, keep_radius: int) -> void:
	var cx: int = _chunk_coord(center_tile_pos.x)
	var cy: int = _chunk_coord(center_tile_pos.y)
	var to_remove: Array[Vector2i] = []
	for key in loaded_chunks.keys():
		if absi(key.x - cx) > keep_radius or absi(key.y - cy) > keep_radius:
			to_remove.append(key)
	for k in to_remove:
		chunk_unloaded.emit(k)
		loaded_chunks.erase(k)
		dirty_chunks.erase(k)


func _generate_chunk(chunk_pos: Vector2i) -> void:
	var data := PackedInt32Array()
	data.resize(CHUNK_SIZE * CHUNK_SIZE)
	var base_x: int = chunk_pos.x * CHUNK_SIZE
	var base_y: int = chunk_pos.y * CHUNK_SIZE

	for local_y in range(CHUNK_SIZE):
		for local_x in range(CHUNK_SIZE):
			var world_x: int = base_x + local_x
			var world_y: int = base_y + local_y
			var idx: int = local_y * CHUNK_SIZE + local_x
			data[idx] = _generate_tile(world_x, world_y)

	loaded_chunks[chunk_pos] = data
	chunk_loaded.emit(chunk_pos)


func _generate_tile(world_x: int, world_y: int) -> int:
	var surface: int = get_surface_y(world_x)

	if world_y < surface:
		return TILE_AIR
	if world_y == surface:
		return TILE_GRASS_DIRT

	var cave_n: float = cave_noise.get_noise_2d(float(world_x), float(world_y))

	if world_y >= SHALLOW_START_Y and world_y < MID_UNDERGROUND_Y:
		var tile: int = TILE_DIRT
		if cave_n > 0.35:
			return TILE_AIR
		var cn: float = ore_noise_coal.get_noise_2d(float(world_x), float(world_y))
		var cln: float = clay_noise.get_noise_2d(float(world_x), float(world_y))
		if cn > 0.65:
			return TILE_COAL
		if cln > 0.60:
			return TILE_CLAY
		return tile

	if world_y >= MID_UNDERGROUND_Y and world_y < DEEP_UNDERGROUND_Y:
		var mid_tile: int = TILE_STONE
		if cave_n > 0.40:
			return TILE_AIR
		var nc: float = ore_noise_coal.get_noise_2d(float(world_x), float(world_y))
		var ncu: float = ore_noise_copper.get_noise_2d(float(world_x), float(world_y))
		var ni: float = ore_noise_iron.get_noise_2d(float(world_x), float(world_y))
		if ni > 0.72:
			return TILE_IRON_ORE
		if ncu > 0.68:
			return TILE_COPPER_ORE
		if nc > 0.70:
			return TILE_COAL
		return mid_tile

	if world_y >= DEEP_UNDERGROUND_Y:
		if cave_n > 0.45:
			return TILE_AIR
		var ni2: float = ore_noise_iron.get_noise_2d(float(world_x), float(world_y))
		if ni2 > 0.65:
			return TILE_IRON_ORE
		return TILE_STONE

	# Between surface+1 and SHALLOW_START_Y: topsoil
	if world_y < SHALLOW_START_Y:
		if cave_n > 0.35:
			return TILE_AIR
		return TILE_DIRT

	return TILE_DIRT
