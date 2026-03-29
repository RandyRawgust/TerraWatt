# SYSTEM: World Rendering
# AGENT: World Gen Agent
# PURPOSE: Renders the tile layer using Godot TileMap.
# Listens to WorldData signals to update tiles when they change.

extends Node2D

class_name WorldRenderer

@onready var tile_map: TileMap = $TileMap

@export var render_radius_chunks: int = 4
@export var unload_extra_chunks: int = 2

var _camera_ref: Camera2D = null


func _ready() -> void:
	tile_map.tile_set = _build_placeholder_tileset()
	tile_map.collision_layer = 1
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
	var img := Image.create(16 * colors.size(), 16, false, Image.FORMAT_RGBA8)
	for i in colors.size():
		var c: Color = colors[i]
		for ox in range(16):
			for oy in range(16):
				img.set_pixel(i * 16 + ox, oy, c)
	var tex := ImageTexture.create_from_image(img)
	var atlas := TileSetAtlasSource.new()
	atlas.texture = tex
	atlas.texture_region_size = Vector2i(16, 16)
	for i in colors.size():
		atlas.create_tile(Vector2i(i, 0))
	var ts := TileSet.new()
	ts.add_physics_layer(1, 0xFFFFFFFF, null)
	ts.add_source(atlas, 0)
	for i in colors.size():
		if i == 0:
			continue
		var td: TileData = atlas.get_tile_data(Vector2i(i, 0), 0)
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


func _on_chunk_unloaded(chunk_pos: Vector2i) -> void:
	var base_x: int = chunk_pos.x * WorldData.CHUNK_SIZE
	var base_y: int = chunk_pos.y * WorldData.CHUNK_SIZE
	for local_y in range(WorldData.CHUNK_SIZE):
		for local_x in range(WorldData.CHUNK_SIZE):
			tile_map.erase_cell(0, Vector2i(base_x + local_x, base_y + local_y))
