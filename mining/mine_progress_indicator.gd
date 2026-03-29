# SYSTEM: Mining UI
# AGENT: Player Agent
# PURPOSE: Circular arc progress while mining a tile.

extends Node2D

class_name MineProgressIndicator

var _progress: float = 0.0


func set_progress(value: float) -> void:
	_progress = clampf(value, 0.0, 1.0)
	queue_redraw()


func _draw() -> void:
	var start_angle: float = -PI * 0.5
	var end_angle: float = start_angle + _progress * TAU
	draw_arc(Vector2.ZERO, 12.0, start_angle, end_angle, 48, Color(0.2, 0.85, 0.35, 1.0), 2.0, true)
