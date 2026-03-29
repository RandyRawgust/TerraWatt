# SYSTEM: World Rendering
# AGENT: World Gen Agent
# PURPOSE: Renders the tile layer using Godot TileMap.
# Listens to WorldData signals to update tiles when they change.

extends Node2D

class_name WorldRenderer

@onready var tile_map: TileMap = $TileMap

const TERRAWATT_TILESET_PATH: String = "res://assets/tiles/terrawatt_tileset.tres"

@export var render_radius_chunks: int = 4
@export var unload_extra_chunks: int = 2

var _camera_ref: Camera2D = null
var _use_multi_source_tileset: bool = false


func _ready() -> void:
	if ResourceLoader.exists(TERRAWATT_TILESET_PATH):
		var ts: TileSet = load(TERRAWATT_TILESET_PATH) as TileSet
		if ts != null:
			tile_map.tile_set = ts
			_use_multi_source_tileset = ts.get_source_count() > 1
	if tile_map.tile_set == null:
		tile_map.tile_set = _build_placeholder_tileset()
		_use_multi_source_tileset = false
	WorldData.tile_changed.connect(_on_tile_changed)
	WorldData.chunk_loaded.connect(_on_chunk_loaded)
	WorldData.chunk_unloaded.connect(_on_chunk_unloaded)


func set_camera(camera: Camera2D) -> void:
	_camera_ref = camera


func _process(_delta: float) -> void:
	if _camera_ref == null:
		return
	var cam_tile_pos := Vector2i(
		int(floor(_camera_ref.global_position.x / float(WorldData.TILE_SIZE))),
		int(floor(_camera_ref.global_position.y / float(WorldData.TILE_SIZE)))
	)
	WorldData.load_chunks_near(cam_tile_pos, render_radius_chunks)
	var keep: int = render_radius_chunks + unload_extra_chunks
	WorldData.unload_distant_chunks(cam_tile_pos, keep)


func _build_placeholder_tileset() -> TileSet:
	# colors[tile_id] for 1..9; index 0 unused (air).
	var colors: Array[Color] = [
		Color(0, 0, 0, 0),
		Color(0.55, 0.42, 0.24),
		Color(0.42, 0.42, 0.42),
		Color(0.29, 0.49, 0.18),
		Color(0.16, 0.16, 0.16),
		Color(0.72, 0.45, 0.20),
		Color(0.54, 0.54, 0.60),
		Color(0.65, 0.48, 0.35),
		Color(0.45, 0.32, 0.18),
		Color(0.48, 0.46, 0.44),
	]
	var cols: int = 9
	var img := Image.create(16 * cols, 16, false, Image.FORMAT_RGBA8)
	for tid in range(1, 10):
		var c: Color = colors[tid]
		for ox in range(16):
			for oy in range(16):
				img.set_pixel((tid - 1) * 16 + ox, oy, c)
	var tex := ImageTexture.create_from_image(img)
	var atlas := TileSetAtlasSource.new()
	atlas.texture = tex
	atlas.texture_region_size = Vector2i(16, 16)
	for tid in range(1, 10):
		atlas.create_tile(Vector2i(tid - 1, 0))
	var ts := TileSet.new()
	ts.add_physics_layer()
	ts.set_physics_layer_collision_layer(0, 1)
	ts.set_physics_layer_collision_mask(0, 1)
	ts.add_source(atlas, 0)
	for tid in range(1, 10):
		var td: TileData = atlas.get_tile_data(Vector2i(tid - 1, 0), 0)
		td.add_collision_polygon(0)
		td.set_collision_polygon_points(
			0,
			0,
			PackedVector2Array([
				Vector2(0, 0),
				Vector2(16, 0),
				Vector2(16, 16),
				Vector2(0, 16),
			])
		)
	return ts


func _paint_cell(layer: int, pos: Vector2i, tile_id: int) -> void:
	if tile_id == WorldData.TILE_AIR:
		tile_map.erase_cell(layer, pos)
		return
	if _use_multi_source_tileset:
		var sid: int = WorldData.tile_id_to_source_id(tile_id)
		tile_map.set_cell(layer, pos, sid, Vector2i(0, 0))
	else:
		tile_map.set_cell(layer, pos, 0, Vector2i(tile_id - 1, 0))


func _render_chunk(chunk_pos: Vector2i) -> void:
	var base_x: int = chunk_pos.x * WorldData.CHUNK_SIZE
	var base_y: int = chunk_pos.y * WorldData.CHUNK_SIZE
	for local_y in range(WorldData.CHUNK_SIZE):
		for local_x in range(WorldData.CHUNK_SIZE):
			var world_x: int = base_x + local_x
			var world_y: int = base_y + local_y
			var tile_id: int = WorldData.get_tile(world_x, world_y)
			_paint_cell(0, Vector2i(world_x, world_y), tile_id)


func _on_tile_changed(pos: Vector2i, _old_id: int, new_id: int) -> void:
	_paint_cell(0, pos, new_id)


func _on_chunk_loaded(chunk_pos: Vector2i) -> void:
	_render_chunk(chunk_pos)


func _on_chunk_unloaded(chunk_pos: Vector2i) -> void:
	var base_x: int = chunk_pos.x * WorldData.CHUNK_SIZE
	var base_y: int = chunk_pos.y * WorldData.CHUNK_SIZE
	for local_y in range(WorldData.CHUNK_SIZE):
		for local_x in range(WorldData.CHUNK_SIZE):
			tile_map.erase_cell(0, Vector2i(base_x + local_x, base_y + local_y))
