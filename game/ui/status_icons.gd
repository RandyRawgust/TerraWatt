# SYSTEM: UI
# AGENT: UI & Creatures Agent
# PURPOSE: Displays Noita-style status icons above the player.

extends Node2D

class_name StatusIconBar

# Icon scene (TextureRect with label)
@export var icon_scene: PackedScene

var _active_icons: Dictionary = {} # status_name → icon node

const ICON_SPACING: float = 20.0
const FLOAT_ABOVE: float = -60.0 # pixels above player (screen space)


func _ready() -> void:
	call_deferred("_connect_to_player")


func _connect_to_player() -> void:
	var player: Node = get_tree().get_first_node_in_group("player")
	if player and player.has_node("PlayerStatus"):
		var ps: Node = player.get_node("PlayerStatus")
		ps.connect("status_changed", Callable(self, "_on_status_changed"))


func _process(_delta: float) -> void:
	var player: Node2D = get_tree().get_first_node_in_group("player") as Node2D
	if not player:
		return
	var xf: Transform2D = get_viewport().get_canvas_transform()
	global_position = xf * player.global_position + Vector2(0, FLOAT_ABOVE)


func _on_status_changed(wet: bool, on_fire: bool, suffocating: bool, _air: float, _health: float) -> void:
	_set_icon("wet", wet, "💧", Color(0.2, 0.5, 0.9))
	_set_icon("on_fire", on_fire, "🔥", Color(1.0, 0.4, 0.1))
	_set_icon("suffocating", suffocating, "💨", Color(0.5, 0.5, 0.5))
	_reposition_icons()


func _set_icon(key: String, active: bool, symbol: String, color: Color) -> void:
	if not icon_scene:
		return
	if active and not _active_icons.has(key):
		var icon: Node = icon_scene.instantiate()
		var label: Label = icon.get_node("Label") as Label
		if label:
			label.text = symbol
		icon.modulate = color
		add_child(icon)
		_active_icons[key] = icon
	elif not active and _active_icons.has(key):
		_active_icons[key].queue_free()
		_active_icons.erase(key)


func _reposition_icons() -> void:
	var i: int = 0
	for icon in _active_icons.values():
		icon.position = Vector2(0, -i * ICON_SPACING)
		i += 1
