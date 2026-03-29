# SYSTEM: UI
# AGENT: UI & Creatures Agent
# PURPOSE: Top-left health bar (0–100).

extends ProgressBar

class_name HealthBar


func _ready() -> void:
	min_value = 0.0
	max_value = 100.0
	show_percentage = false
	call_deferred("_connect_status")


func _connect_status() -> void:
	var player: Node = get_tree().get_first_node_in_group("player")
	if player and player.has_node("PlayerStatus"):
		var ps: Node = player.get_node("PlayerStatus")
		ps.connect("status_changed", Callable(self, "_on_status_changed"))
		_on_status_changed(
			bool(ps.get("is_wet")),
			bool(ps.get("is_on_fire")),
			bool(ps.get("is_suffocating")),
			float(ps.get("air_level")),
			float(ps.get("health"))
		)


func _on_status_changed(_wet: bool, _on_fire: bool, _suff: bool, _air: float, health: float) -> void:
	value = health
