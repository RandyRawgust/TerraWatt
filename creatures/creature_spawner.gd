# SYSTEM: Creatures
# AGENT: Integration Agent
# PURPOSE: Ambient spawns by day/night rules; despawns far from player.

extends Node

const WOLF_MAX: int = 3
const RABBIT_MAX: int = 5
const BIRD_MAX: int = 4
const DESPAWN_TILES: float = 100.0
const TRY_INTERVAL_SEC: float = 1.1

const WOLF_SCENE: PackedScene = preload("res://creatures/wolf.tscn")
const RABBIT_SCENE: PackedScene = preload("res://creatures/rabbit.tscn")
const BIRD_SCENE: PackedScene = preload("res://creatures/bird.tscn")

var _player: Node2D = null
var _wolves: Array[Node] = []
var _rabbits: Array[Node] = []
var _birds: Array[Node] = []
var _tick: float = 0.0
var _day_night: Node = null


func _ready() -> void:
	_day_night = get_parent().get_node_or_null("DayNightCycle")


func set_player(p: Node2D) -> void:
	_player = p


func _process(delta: float) -> void:
	_tick += delta
	if _tick >= TRY_INTERVAL_SEC:
		_tick = 0.0
		_try_spawns()
	_purge_invalid()
	if _player != null and is_instance_valid(_player):
		var max_d: float = DESPAWN_TILES * float(WorldData.TILE_SIZE)
		_wolves = _despawn_bucket(_wolves, max_d)
		_rabbits = _despawn_bucket(_rabbits, max_d)
		_birds = _despawn_bucket(_birds, max_d)


func _try_spawns() -> void:
	if _player == null or not is_instance_valid(_player):
		return
	var night: bool = _day_night != null and _day_night.has_method("is_night") and bool(_day_night.call("is_night"))
	var pt := _player_tile()
	# Night: wolves (surface, 30+ tiles from player)
	if night and _wolves.size() < WOLF_MAX:
		var pos := _random_surface_pos_wolf(pt)
		if pos != Vector2.ZERO:
			_spawn(WOLF_SCENE, pos, _wolves)
	# Day: rabbits (40–80 tile radius)
	if not night and _rabbits.size() < RABBIT_MAX:
		var pos2 := _random_surface_pos_ring(pt, 40, 80)
		if pos2 != Vector2.ZERO:
			_spawn(RABBIT_SCENE, pos2, _rabbits)
	# Birds: 20–60 tile radius, surface
	if _birds.size() < BIRD_MAX and randf() < 0.5:
		var pos3 := _random_surface_pos_ring(pt, 20, 60)
		if pos3 != Vector2.ZERO:
			_spawn(BIRD_SCENE, pos3, _birds)


func _player_tile() -> Vector2i:
	var ts: float = float(WorldData.TILE_SIZE)
	return Vector2i(
		int(floor(_player.global_position.x / ts)),
		int(floor(_player.global_position.y / ts))
	)


func _random_surface_pos_ring(player_tile: Vector2i, min_r: int, max_r: int) -> Vector2:
	var ts: float = float(WorldData.TILE_SIZE)
	var ang: float = randf() * TAU
	var dist_t: int = randi_range(min_r, max_r)
	var ox: int = int(round(cos(ang) * float(dist_t)))
	var tx: int = player_tile.x + ox
	var surface_y: int = WorldData.get_surface_y(tx)
	var ty: int = surface_y - 2
	return Vector2(
		float(tx) * ts + ts * 0.5,
		float(ty) * ts + ts * 0.5
	)


func _random_surface_pos_wolf(player_tile: Vector2i) -> Vector2:
	var ts: float = float(WorldData.TILE_SIZE)
	var pworld := Vector2(
		float(player_tile.x) * ts + ts * 0.5,
		float(player_tile.y) * ts + ts * 0.5
	)
	for _i in range(28):
		var ang: float = randf() * TAU
		var dist_t: int = randi_range(30, 100)
		var ox: int = int(round(cos(ang) * float(dist_t)))
		var tx: int = player_tile.x + ox
		var surface_y: int = WorldData.get_surface_y(tx)
		var ty: int = surface_y - 2
		var pos := Vector2(
			float(tx) * ts + ts * 0.5,
			float(ty) * ts + ts * 0.5
		)
		if pos.distance_to(pworld) >= 30.0 * ts:
			return pos
	return Vector2.ZERO


func _spawn(scene: PackedScene, pos: Vector2, bucket: Array[Node]) -> void:
	var inst: Node = scene.instantiate()
	inst.global_position = pos
	add_child(inst)
	bucket.append(inst)


func _purge_invalid() -> void:
	_wolves = _filter_alive(_wolves)
	_rabbits = _filter_alive(_rabbits)
	_birds = _filter_alive(_birds)


func _filter_alive(arr: Array[Node]) -> Array[Node]:
	var out: Array[Node] = []
	for n in arr:
		if is_instance_valid(n):
			out.append(n)
	return out


func _despawn_bucket(bucket: Array[Node], max_d: float) -> Array[Node]:
	var keep: Array[Node] = []
	for n in bucket:
		if not is_instance_valid(n):
			continue
		var n2: Node2D = n as Node2D
		if _player.global_position.distance_to(n2.global_position) > max_d:
			n.queue_free()
		else:
			keep.append(n)
	return keep
