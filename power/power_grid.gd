# SYSTEM: Power Grid
# AGENT: Power Tier 0 Agent
# PURPOSE: Tracks all registered power sources and consumers.
# Tier 0: mechanical power only. No electrical grid yet.

extends Node

class_name PowerGrid

signal power_updated(generation: float, demand: float)

# All registered sources: node → { watts: float, position: Vector2 }
var sources: Dictionary = {}
var total_generation: float = 0.0
var total_demand: float = 0.0

func _process(_delta: float) -> void:
	_recalculate_totals()

func register_source(node: Node, watts: float) -> void:
	if not is_instance_valid(node):
		return
	sources[node] = {
		"watts": watts,
		"position": node.global_position if node is Node2D else Vector2.ZERO
	}
	_recalculate_totals()

func unregister_source(node: Node) -> void:
	sources.erase(node)
	_recalculate_totals()

func update_source_output(node: Node, new_watts: float) -> void:
	if sources.has(node) and is_instance_valid(node):
		sources[node]["watts"] = new_watts
		if node is Node2D:
			sources[node]["position"] = (node as Node2D).global_position
		_recalculate_totals()

func get_local_power(pos: Vector2) -> float:
	# Tier 0: local mechanical power — output of nearest source within 10 tiles
	var nearest_watts: float = 0.0
	var nearest_dist: float = 10.0 * 16.0
	for node in sources:
		if not is_instance_valid(node):
			continue
		if node is Node2D:
			var dist: float = (node as Node2D).global_position.distance_to(pos)
			if dist < nearest_dist:
				nearest_dist = dist
				nearest_watts = sources[node]["watts"]
	return nearest_watts

func _recalculate_totals() -> void:
	total_generation = 0.0
	var stale: Array[Node] = []
	for node in sources:
		if not is_instance_valid(node):
			stale.append(node)
			continue
		total_generation += float(sources[node]["watts"])
	for n in stale:
		sources.erase(n)
	power_updated.emit(total_generation, total_demand)
