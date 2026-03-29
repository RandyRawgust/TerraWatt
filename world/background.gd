# SYSTEM: Visual / Background
# AGENT: Visual & Art Agent
# PURPOSE: 3-layer parallax deep space background. Starbound aesthetic.

extends Node2D

class_name BackgroundLayer

@onready var layer_far: Sprite2D = $LayerFar
@onready var layer_mid: Sprite2D = $LayerMid
@onready var layer_near: Sprite2D = $LayerNear

var _camera_last_pos: Vector2 = Vector2.ZERO
var _parallax_initialized: bool = false


func _ready() -> void:
	_camera_last_pos = Vector2.ZERO
	_fit_layers_to_viewport()


func _fit_layers_to_viewport() -> void:
	var sz: Vector2 = get_viewport_rect().size
	for spr: Sprite2D in [layer_far, layer_mid, layer_near]:
		if spr.texture == null:
			continue
		var tw: float = float(spr.texture.get_width())
		var th: float = float(spr.texture.get_height())
		spr.scale = Vector2(sz.x / tw, sz.y / th)


func update_parallax(camera_pos: Vector2) -> void:
	global_position = camera_pos
	if not _parallax_initialized:
		_parallax_initialized = true
		_camera_last_pos = camera_pos
		return
	var delta_pos: Vector2 = camera_pos - _camera_last_pos
	layer_far.position -= delta_pos * 0.05
	layer_mid.position -= delta_pos * 0.15
	layer_near.position -= delta_pos * 0.30
	_camera_last_pos = camera_pos
