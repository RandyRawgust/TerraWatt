# SYSTEM: Visual / Background
# AGENT: Visual & Art Agent
# PURPOSE: 3-layer parallax deep space background. Starbound aesthetic.

extends Node2D

class_name BackgroundLayer

@onready var layer_far: Sprite2D = $LayerFar
@onready var layer_mid: Sprite2D = $LayerMid
@onready var layer_near: Sprite2D = $LayerNear
@onready var layer_industrial: Sprite2D = $IndustrialLayer

var _camera_last_pos: Vector2 = Vector2.ZERO
var _parallax_initialized: bool = false

const _DAY_MOD: Color = Color(1.0, 0.98, 0.94, 1.0)
const _NIGHT_MOD: Color = Color(0.62, 0.7, 0.92, 1.0)


func set_cycle_night_factor(f: float) -> void:
	var t: float = clamp(f, 0.0, 1.0)
	var c: Color = _DAY_MOD.lerp(_NIGHT_MOD, t)
	for spr: Sprite2D in [layer_far, layer_mid, layer_near, layer_industrial]:
		if spr != null:
			spr.modulate = c


func _ready() -> void:
	_camera_last_pos = Vector2.ZERO
	_fit_layers_to_viewport()
	PollutionTracker.pollution_changed.connect(_on_pollution_for_era)
	_on_pollution_for_era(PollutionTracker.global_pollution_level)


func _on_pollution_for_era(_level: float) -> void:
	_check_era_shift()


# Show industrial era background layer when Tier 1 pollution begins.
func _check_era_shift() -> void:
	if layer_industrial == null:
		return
	if PollutionTracker.global_pollution_level > 0.1:
		layer_industrial.visible = true
	else:
		layer_industrial.visible = false


func _fit_layers_to_viewport() -> void:
	var sz: Vector2 = get_viewport_rect().size
	for spr: Sprite2D in [layer_far, layer_mid, layer_near, layer_industrial]:
		if spr == null or spr.texture == null:
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
	if layer_industrial != null:
		layer_industrial.position -= delta_pos * 0.18
	_camera_last_pos = camera_pos
