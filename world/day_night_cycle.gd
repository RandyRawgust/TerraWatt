# SYSTEM: World
# AGENT: Integration Agent
# PURPOSE: Day/night timing for atmosphere and creature spawning.

extends Node

const DAY_DURATION_SEC: float = 600.0
const NIGHT_DURATION_SEC: float = 300.0
const TRANSITION_SEC: float = 60.0

var _phase_time: float = 0.0
var _cycle_len: float = DAY_DURATION_SEC + NIGHT_DURATION_SEC


func _ready() -> void:
	_cycle_len = DAY_DURATION_SEC + NIGHT_DURATION_SEC


func _process(delta: float) -> void:
	_phase_time += delta
	while _phase_time >= _cycle_len:
		_phase_time -= _cycle_len


func is_night() -> bool:
	return _phase_time >= DAY_DURATION_SEC


## 0 = full day look, 1 = full night look (smooth across dusk/dawn).
func get_night_blend() -> float:
	var d: float = DAY_DURATION_SEC
	var n: float = NIGHT_DURATION_SEC
	var p: float = _phase_time
	# Dusk: last TRANSITION_SEC of day
	if p < d - TRANSITION_SEC:
		return 0.0
	if p < d:
		return (p - (d - TRANSITION_SEC)) / TRANSITION_SEC
	# Night body
	if p < d + n - TRANSITION_SEC:
		return 1.0
	# Dawn: last TRANSITION_SEC of cycle (end of night)
	return 1.0 - (p - (d + n - TRANSITION_SEC)) / TRANSITION_SEC
