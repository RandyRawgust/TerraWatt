# Automatically transfers items from belt to adjacent machine.
extends Area2D


func _ready() -> void:
	body_entered.connect(_on_item_entered)


func _on_item_entered(body: Node) -> void:
	if body == null or not (body is RigidBody2D):
		return
	var item_type: Variant = body.get("item_type")
	if item_type == null:
		return
	var type_str: String = str(item_type)
	if type_str.is_empty():
		return
	var furnace: Node = _find_adjacent_furnace()
	if furnace and furnace.has_method("add_coal") and type_str == "coal":
		furnace.call("add_coal", 1)
		body.queue_free()


func _find_adjacent_furnace() -> Node:
	for machine in get_tree().get_nodes_in_group("coal_furnaces"):
		if machine is Node2D:
			if global_position.distance_to((machine as Node2D).global_position) < 24.0:
				return machine
	for machine in get_tree().get_nodes_in_group("machines"):
		if machine is Node2D:
			if global_position.distance_to((machine as Node2D).global_position) < 24.0:
				return machine
	return null
