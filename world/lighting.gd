# SYSTEM: Lighting
# AGENT: Visual & Art Agent
# PURPOSE: Underground darkness overlay, player torch hook, ore proximity glow.

extends Node2D

class_name LightingManager

const ORE_RADIUS_TILES: int = 8
const ORE_LIGHT_ENERGY: float = 0.22
const ORE_LIGHT_SCALE: float = 0.35

const _ORE_COLORS: Dictionary = {
	WorldData.TILE_COAL: Color(0.35, 0.36, 0.4, 1.0),
	WorldData.TILE_COPPER_ORE: Color(1.0, 0.52, 0.22, 1.0),
	WorldData.TILE_IRON_ORE: Color(0.72, 0.78, 0.95, 1.0),
}

@onready var darkness_overlay: ColorRect = $DarkCanvas/DarknessOverlay
@onready var sky_tint: ColorRect = $DarkCanvas/SkyTint
@onready var _ore_container: Node2D = $OreGlowLights

var player_light: PointLight2D = null
var _cycle_night_factor: float = 0.0

const DARK_START_Y: int = 10
const DARK_FULL_Y: int = 80
const MAX_DARKNESS: float = 0.92

var _ore_lights: Dictionary = {}  # Vector2i tile -> PointLight2D
var _glow_texture: Texture2D


func _ready() -> void:
	_glow_texture = load("res://assets/ui/light_radial.png") as Texture2D


func set_player_light(light: PointLight2D) -> void:
	player_light = light


func set_cycle_night_factor(f: float) -> void:
	_cycle_night_factor = clamp(f, 0.0, 1.0)


func _process(_delta: float) -> void:
	_update_darkness()
	_update_ore_glow()
	_update_sky_tint()


func _update_darkness() -> void:
	var player: Node2D = get_tree().get_first_node_in_group("player") as Node2D
	if player == null:
		return
	var player_tile_y: float = player.global_position.y / float(WorldData.TILE_SIZE)
	var darkness_t: float = clamp(
		(player_tile_y - float(DARK_START_Y)) / float(DARK_FULL_Y - DARK_START_Y),
		0.0,
		1.0
	)
	darkness_overlay.color = Color(0, 0, 0, darkness_t * MAX_DARKNESS)


func _update_sky_tint() -> void:
	if sky_tint == null:
		return
	# Cool night wash over the screen (subtle; underground darkness is separate).
	sky_tint.color = Color(0.07, 0.1, 0.22, 0.14 * _cycle_night_factor)


func _update_ore_glow() -> void:
	var player: Node2D = get_tree().get_first_node_in_group("player") as Node2D
	if player == null:
		return
	var px: int = int(floor(player.global_position.x / float(WorldData.TILE_SIZE)))
	var py: int = int(floor(player.global_position.y / float(WorldData.TILE_SIZE)))
	var want: Dictionary = {}
	for dy in range(-ORE_RADIUS_TILES, ORE_RADIUS_TILES + 1):
		for dx in range(-ORE_RADIUS_TILES, ORE_RADIUS_TILES + 1):
			var wx: int = px + dx
			var wy: int = py + dy
			var tid: int = WorldData.get_tile(wx, wy)
			if _ORE_COLORS.has(tid):
				want[Vector2i(wx, wy)] = tid
	var to_remove: Array[Vector2i] = []
	for tile_key in _ore_lights.keys():
		if not want.has(tile_key):
			to_remove.append(tile_key)
	for tile_key in to_remove:
		var old_pl: PointLight2D = _ore_lights[tile_key]
		_ore_lights.erase(tile_key)
		if old_pl != null and is_instance_valid(old_pl):
			old_pl.queue_free()
	for tile_key in want.keys():
		if _ore_lights.has(tile_key):
			continue
		var pl2 := PointLight2D.new()
		pl2.color = _ORE_COLORS.get(want[tile_key], Color.WHITE)
		pl2.energy = ORE_LIGHT_ENERGY
		pl2.texture = _glow_texture
		pl2.texture_scale = ORE_LIGHT_SCALE
		pl2.position = Vector2(
			float(tile_key.x) * float(WorldData.TILE_SIZE) + float(WorldData.TILE_SIZE) * 0.5,
			float(tile_key.y) * float(WorldData.TILE_SIZE) + float(WorldData.TILE_SIZE) * 0.5
		)
		_ore_container.add_child(pl2)
		_ore_lights[tile_key] = pl2
