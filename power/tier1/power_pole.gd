# SYSTEM: Power / Tier 1
# AGENT: Electrical Grid Agent
# PURPOSE: Wooden power pole — distributes electricity within radius; connects to nearby poles.

extends Node2D
class_name PowerPole

# GDD §6 wooden pole rated 500 W; distribution spans scale with tile art.
const CAPACITY_WATTS: float = 500.0
const CONNECTION_RANGE: float = 160.0
const DISTRIBUTION_RADIUS: float = 80.0

var is_powered: bool = false

@onready var pole_sprite: Sprite2D = $PoleSprite


func _ready() -> void:
	add_to_group("power_poles")
	PowerGrid.register_pole(self)
	PowerGrid.power_updated.connect(_on_power_updated)
	_refresh_power_visual()


func _exit_tree() -> void:
	var cb := Callable(self, "_on_power_updated")
	if PowerGrid.power_updated.is_connected(cb):
		PowerGrid.power_updated.disconnect(cb)
	PowerGrid.unregister_pole(self)


func _on_power_updated(_generation: float, _demand: float) -> void:
	var nw: float = PowerGrid.get_pole_network_watts(self)
	is_powered = nw > 0.0
	_refresh_power_visual()


func _refresh_power_visual() -> void:
	if pole_sprite:
		pole_sprite.modulate = Color(1.0, 0.85, 0.4) if is_powered else Color(1.0, 1.0, 1.0)


# Draws wire connections to nearby poles with sag.
func _draw() -> void:
	var my_id: int = get_instance_id()
	for pole in get_tree().get_nodes_in_group("power_poles"):
		if pole == self or not pole is Node2D:
			continue
		if (pole as Node2D).get_instance_id() <= my_id:
			continue
		var dist: float = global_position.distance_to((pole as Node2D).global_position)
		if dist > CONNECTION_RANGE:
			continue
		var local_target: Vector2 = to_local((pole as Node2D).global_position)
		var mid: Vector2 = local_target / 2.0 + Vector2(0, dist / 8.0)
		draw_line(Vector2.ZERO, mid, Color(0.2, 0.2, 0.2), 2.0)
		draw_line(mid, local_target, Color(0.2, 0.2, 0.2), 2.0)


func _process(_delta: float) -> void:
	queue_redraw()
