# SYSTEM: Pollution Visual
# AGENT: Pollution Agent
# PURPOSE: Renders atmospheric haze that intensifies with pollution level.

extends CanvasLayer


@onready var haze_rect: ColorRect = $HazeRect


func _ready() -> void:
	layer = 5
	PollutionTracker.pollution_changed.connect(_on_pollution_changed)
	var vp := get_viewport()
	if vp != null:
		_on_viewport_resized()
		if not vp.size_changed.is_connected(_on_viewport_resized):
			vp.size_changed.connect(_on_viewport_resized)
	_on_pollution_changed(PollutionTracker.global_pollution_level)


func _on_viewport_resized() -> void:
	if haze_rect != null:
		haze_rect.size = get_viewport().get_visible_rect().size


func _on_pollution_changed(level: float) -> void:
	var haze_color := Color(
		0.4 + level * 0.3,
		0.35 + level * 0.1,
		0.1,
		level * 0.35
	)
	haze_rect.color = haze_color
