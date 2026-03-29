# SYSTEM: Player
# AGENT: UI & Creatures Agent
# PURPOSE: Player vitals and environmental status. HUD listens to status_changed.

extends Node

class_name PlayerStatus

signal status_changed(wet: bool, on_fire: bool, suffocating: bool, air: float, health: float)

var wet: bool = false
var on_fire: bool = false
var suffocating: bool = false
## 1.0 = full breath; drains in bad air.
var air: float = 1.0
var health: float = 100.0


func _ready() -> void:
	_emit_status()


func set_status(w: bool, fire: bool, suff: bool, air_ratio: float, hp: float) -> void:
	wet = w
	on_fire = fire
	suffocating = suff
	air = clampf(air_ratio, 0.0, 1.0)
	health = clampf(hp, 0.0, 100.0)
	_emit_status()


func apply_damage(amount: float) -> void:
	health = maxf(0.0, health - amount)
	_emit_status()


func _emit_status() -> void:
	status_changed.emit(wet, on_fire, suffocating, air, health)
