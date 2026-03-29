# SYSTEM: Power Grid
# AGENT: Power Tier 0 Agent (stub created by Foundation Agent)
# PURPOSE: Global power management. Tracks generation vs demand.
# STUB VERSION.

extends Node

class_name PowerGrid

var total_generation_watts: float = 0.0
var total_demand_watts: float = 0.0

# Register a power source at world position `pos` generating `watts`.
func register_source(node: Node, watts: float) -> void:
	pass  # STUB

# Unregister a power source.
func unregister_source(node: Node) -> void:
	pass  # STUB

# Get available local power at a world position.
func get_local_power(pos: Vector2) -> float:
	return total_generation_watts  # STUB: no local zones yet

signal power_updated(generation: float, demand: float)
