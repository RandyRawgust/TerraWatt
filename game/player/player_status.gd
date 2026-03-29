# SYSTEM: Player Status
# AGENT: Player Agent
# PURPOSE: Tracks wet, fire, suffocation; air meter and health; signals for UI.

extends Node

class_name PlayerStatus

var is_wet: bool = false
var is_on_fire: bool = false
var is_suffocating: bool = false

var air_level: float = 1.0
const AIR_DRAIN_RATE: float = 0.1
const AIR_REFILL_RATE: float = 0.3

var health: float = 100.0
const MAX_HEALTH: float = 100.0
const FIRE_DAMAGE_RATE: float = 10.0

@onready var player: CharacterBody2D = get_parent()


func _physics_process(delta: float) -> void:
	_check_environment()
	_apply_status_effects(delta)
	_update_air(delta)


func _check_environment() -> void:
	var player_tile: Vector2i = player.get_world_tile_pos()
	var cell: Dictionary = SimManager.get_cell(player_tile.x, player_tile.y)
	var mat_id: int = int(cell.get("material_id", 0))
	is_wet = mat_id == MaterialRegistry.MAT_WATER
	is_on_fire = mat_id == MaterialRegistry.MAT_FIRE
	is_suffocating = mat_id == MaterialRegistry.MAT_SMOKE
	status_changed.emit(is_wet, is_on_fire, is_suffocating, air_level, health)


func _apply_status_effects(delta: float) -> void:
	if is_on_fire:
		health -= FIRE_DAMAGE_RATE * delta
		health = max(health, 0.0)
	if air_level <= 0.0:
		health -= 5.0 * delta


func _update_air(delta: float) -> void:
	if is_suffocating:
		air_level -= AIR_DRAIN_RATE * delta
		air_level = max(air_level, 0.0)
	else:
		air_level = min(air_level + AIR_REFILL_RATE * delta, 1.0)


signal status_changed(wet: bool, on_fire: bool, suffocating: bool, air: float, health: float)
