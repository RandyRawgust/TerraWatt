# Base class for all Tier 0 power structures.
extends StaticBody2D

class_name PowerSourceBase

@export var max_output_watts: float = 100.0
var current_output_watts: float = 0.0
var is_operating: bool = false

func _ready() -> void:
	add_to_group("power_sources")
	PowerGrid.register_source(self, 0.0)

func _exit_tree() -> void:
	PowerGrid.unregister_source(self)

func set_output(watts: float) -> void:
	current_output_watts = clamp(watts, 0.0, max_output_watts)
	PowerGrid.update_source_output(self, current_output_watts)
	is_operating = current_output_watts > 0.0

func get_output_fraction() -> float:
	return current_output_watts / max_output_watts if max_output_watts > 0.0 else 0.0
