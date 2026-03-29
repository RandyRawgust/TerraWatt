# SYSTEM: Pollution
# AGENT: Pollution Agent
# PURPOSE: Tracks accumulated pollution level. Drives visual haze and acid rain.
# NOTE: No class_name — this is an autoload singleton.
# CoalFurnace reports burns via report_coal_burned() (see power/tier1/coal_furnace.gd).

extends Node

signal pollution_changed(level: float)
signal acid_rain_started
signal acid_rain_stopped
signal acid_rain_tick

# 0.0 = clean air, 1.0 = maximum pollution
var global_pollution_level: float = 0.0

const POLLUTION_PER_COAL_BURN: float = 0.0005
const NATURAL_DISSIPATION: float = 0.00002
const ACID_RAIN_THRESHOLD: float = 0.6

var acid_rain_active: bool = false
var _acid_rain_timer: float = 0.0


func _process(delta: float) -> void:
	var prev: float = global_pollution_level
	global_pollution_level = maxf(global_pollution_level - NATURAL_DISSIPATION * delta, 0.0)
	if not is_equal_approx(prev, global_pollution_level):
		pollution_changed.emit(global_pollution_level)
	if global_pollution_level >= ACID_RAIN_THRESHOLD and not acid_rain_active:
		_start_acid_rain()
	elif global_pollution_level < ACID_RAIN_THRESHOLD * 0.8 and acid_rain_active:
		_stop_acid_rain()
	if acid_rain_active:
		_tick_acid_rain(delta)


func report_coal_burned() -> void:
	global_pollution_level = minf(global_pollution_level + POLLUTION_PER_COAL_BURN, 1.0)
	pollution_changed.emit(global_pollution_level)


func _start_acid_rain() -> void:
	acid_rain_active = true
	acid_rain_started.emit()
	print(
		"PollutionTracker: Acid rain begins — pollution at %.0f%%" % (global_pollution_level * 100.0)
	)


func _stop_acid_rain() -> void:
	acid_rain_active = false
	acid_rain_stopped.emit()


func _tick_acid_rain(delta: float) -> void:
	_acid_rain_timer += delta
	if _acid_rain_timer >= 3.0:
		_acid_rain_timer = 0.0
		acid_rain_tick.emit()
