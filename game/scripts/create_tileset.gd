# SYSTEM: Tools / TileSet builder
# AGENT: Visual & Art Agent
# PURPOSE: Build res://assets/tiles/terrawatt_tileset.tres from PNGs. Run once in Godot:
#   Script Editor → open this file → File → Run (or attach as EditorScript).

extends EditorScript

const TILE_SIZE: Vector2i = Vector2i(16, 16)

# WorldData tile_id → PNG (source_id = tile_id - 1). Must stay in sync with world_data.gd.
# TILE_DIRT=1, TILE_STONE=2, TILE_GRASS_DIRT=3, TILE_COAL=4, TILE_COPPER_ORE=5,
# TILE_IRON_ORE=6, TILE_CLAY=7, TILE_WOOD_PLANK=8, TILE_STONE_BRICK=9
const _SOURCES: Array[String] = [
	"res://assets/tiles/terrain/dirt.png",
	"res://assets/tiles/terrain/stone.png",
	"res://assets/tiles/terrain/grass_dirt.png",
	"res://assets/tiles/ores/coal_ore.png",
	"res://assets/tiles/ores/copper_ore.png",
	"res://assets/tiles/ores/iron_ore.png",
	"res://assets/tiles/terrain/clay.png",
	"res://assets/structures/wood_plank.png",
	"res://assets/structures/stone_brick.png",
]


func _run() -> void:
	var ts: TileSet = _build_tile_set()
	var err: Error = ResourceSaver.save(ts, "res://assets/tiles/terrawatt_tileset.tres")
	if err != OK:
		push_error("create_tileset: save failed: %s" % error_string(err))
	else:
		print("create_tileset: wrote res://assets/tiles/terrawatt_tileset.tres")


static func _build_tile_set() -> TileSet:
	var tile_set: TileSet = TileSet.new()
	tile_set.add_physics_layer()
	tile_set.set_physics_layer_collision_layer(0, 1)
	tile_set.set_physics_layer_collision_mask(0, 1)
	var rect: PackedVector2Array = PackedVector2Array([
		Vector2(0, 0),
		Vector2(TILE_SIZE.x, 0),
		Vector2(TILE_SIZE.x, TILE_SIZE.y),
		Vector2(0, TILE_SIZE.y),
	])
	for i in _SOURCES.size():
		var path: String = _SOURCES[i]
		if not ResourceLoader.exists(path):
			push_error("create_tileset: missing texture %s" % path)
			continue
		var tex: Texture2D = load(path) as Texture2D
		if tex == null:
			push_error("create_tileset: could not load %s" % path)
			continue
		var src: TileSetAtlasSource = TileSetAtlasSource.new()
		src.texture = tex
		src.texture_region_size = TILE_SIZE
		tile_set.add_source(src, i)
		src.create_tile(Vector2i(0, 0))
		var td: TileData = src.get_tile_data(Vector2i(0, 0), 0)
		td.add_collision_polygon(0)
		td.set_collision_polygon_points(0, 0, rect)
	return tile_set
