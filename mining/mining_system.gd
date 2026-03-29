# SYSTEM: Mining
# AGENT: Player Agent
# PURPOSE: Handles tile mining on click, progress tracking, item spawning.

extends Node2D

class_name MiningSystem

signal tile_mined(tile_pos: Vector2i, tile_id: int)

const MAX_MINE_DISTANCE: int = 4
const MINE_TIME_DEFAULT: float = 1.0

var _active_tool: String = "hammer"
var _mining_tile: Vector2i = Vector2i(-9999, -9999)
var _mine_progress: float = 0.0
var _mine_duration: float = 0.0
var _is_mining: bool = false

@onready var _player: CharacterBody2D = get_parent()
@onready var _progress_indicator: Node2D = $MineProgressIndicator


func _ready() -> void:
	pass


func set_active_tool(tool_name: String) -> void:
	_active_tool = tool_name


func _process(delta: float) -> void:
	_handle_mining_input(delta)


func _handle_mining_input(delta: float) -> void:
	if Input.is_mouse_button_pressed(MOUSE_BUTTON_LEFT):
		var mouse_tile: Vector2i = _get_mouse_tile_pos()
		if _is_tile_in_range(mouse_tile) and _is_solid_tile(mouse_tile):
			if mouse_tile != _mining_tile:
				_start_mining(mouse_tile)
			else:
				_continue_mining(delta)
		else:
			_cancel_mining()
	else:
		_cancel_mining()


func _get_mouse_tile_pos() -> Vector2i:
	var world: Vector2 = get_global_mouse_position()
	return Vector2i(
		int(floor(world.x / float(WorldData.TILE_SIZE))),
		int(floor(world.y / float(WorldData.TILE_SIZE)))
	)


func _is_tile_in_range(tile_pos: Vector2i) -> bool:
	var player_tile: Vector2i = _player.get_world_tile_pos()
	var dist: float = Vector2(tile_pos - player_tile).length()
	return dist <= float(MAX_MINE_DISTANCE)


func _is_solid_tile(tile_pos: Vector2i) -> bool:
	var tile_id: int = WorldData.get_tile(tile_pos.x, tile_pos.y)
	return tile_id != WorldData.TILE_AIR


func _start_mining(tile_pos: Vector2i) -> void:
	_mining_tile = tile_pos
	_mine_progress = 0.0
	var tile_id: int = WorldData.get_tile(tile_pos.x, tile_pos.y)
	var mat: Dictionary = MaterialRegistry.get_material(tile_id)
	_mine_duration = float(mat.get("mine_time", MINE_TIME_DEFAULT))
	_mine_duration = _apply_tool_bonus(_mine_duration)
	_is_mining = true
	_progress_indicator.visible = true
	_progress_indicator.global_position = Vector2(tile_pos) * WorldData.TILE_SIZE + Vector2(
		float(WorldData.TILE_SIZE) * 0.5,
		float(WorldData.TILE_SIZE) * 0.5
	)


func _continue_mining(delta: float) -> void:
	_mine_progress += delta
	_progress_indicator.call("set_progress", _mine_progress / _mine_duration)
	if _mine_progress >= _mine_duration:
		_complete_mining()


func _complete_mining() -> void:
	var tile_id: int = WorldData.get_tile(_mining_tile.x, _mining_tile.y)
	var item_type: String = MaterialRegistry.get_display_name(tile_id).to_lower().replace(" ", "_")
	WorldData.set_tile(_mining_tile.x, _mining_tile.y, WorldData.TILE_AIR)
	_spawn_collectible(_mining_tile, tile_id, item_type)
	tile_mined.emit(_mining_tile, tile_id)
	_cancel_mining()


func _apply_tool_bonus(base_time: float) -> float:
	match _active_tool:
		"stone_pickaxe":
			return base_time * 0.75
		"iron_pickaxe":
			return base_time * 0.5
		_:
			return base_time


func _spawn_collectible(tile_pos: Vector2i, tile_id: int, item_type: String) -> void:
	var collectible_scene: PackedScene = preload("res://mining/collectible_item.tscn")
	var item: Node2D = collectible_scene.instantiate()
	item.set("item_type", item_type)
	item.set("source_tile_id", tile_id)
	item.global_position = Vector2(tile_pos) * WorldData.TILE_SIZE + Vector2(
		float(WorldData.TILE_SIZE) * 0.5,
		float(WorldData.TILE_SIZE) * 0.5
	)
	if _player:
		item.connect("item_collected", Callable(_player, "_on_collectible_item_collected"))
	get_tree().current_scene.add_child(item)


func _cancel_mining() -> void:
	_is_mining = false
	_mine_progress = 0.0
	_mining_tile = Vector2i(-9999, -9999)
	_progress_indicator.visible = false
