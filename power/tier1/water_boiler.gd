# SYSTEM: Power / Tier 1
# AGENT: Coal Power Agent
# PURPOSE: Converts furnace heat + water into high-pressure steam.

extends StaticBody2D

class_name WaterBoiler

const MAX_WATER: float = 20.0
const WATER_PER_STEAM: float = 0.5
const MIN_HEAT_TO_BOIL: float = 100.0
const STEAM_OUTPUT_MAX: float = 500.0

var water_level: float = 0.0
var steam_pressure: float = 0.0
var _heat_source: Node = null

@onready var pressure_gauge: Node2D = $PressureGauge
@onready var steam_emitter: Marker2D = $SteamEmitter


func _ready() -> void:
	add_to_group("machines")


func _physics_process(delta: float) -> void:
	_update_boiling(delta)
	_update_pressure_gauge()


func connect_heat_source(furnace: Node) -> void:
	_heat_source = furnace


func add_water(amount: float) -> float:
	var space: float = MAX_WATER - water_level
	var added: float = minf(amount, space)
	water_level += added
	return added


func get_steam_output() -> float:
	return steam_pressure


func _update_boiling(delta: float) -> void:
	var current_heat: float = 0.0
	if _heat_source and _heat_source.has_method("get_heat_output"):
		current_heat = _heat_source.get_heat_output()

	if current_heat >= MIN_HEAT_TO_BOIL and water_level > 0.0:
		water_level -= WATER_PER_STEAM * delta
		water_level = maxf(water_level, 0.0)
		steam_pressure = STEAM_OUTPUT_MAX * (current_heat / 150.0)
		if randf() < 0.25:
			var pos := Vector2i(
				int(steam_emitter.global_position.x / 16.0),
				int(steam_emitter.global_position.y / 16.0)
			)
			SimManager.add_particle(pos.x, pos.y, MaterialRegistry.MAT_STEAM)
	else:
		steam_pressure = maxf(steam_pressure - 50.0 * delta, 0.0)


func _update_pressure_gauge() -> void:
	if not pressure_gauge:
		return
	var fraction: float = steam_pressure / STEAM_OUTPUT_MAX if STEAM_OUTPUT_MAX > 0.0 else 0.0
	pressure_gauge.rotation = lerpf(-1.2, 1.2, clampf(fraction, 0.0, 1.0))
