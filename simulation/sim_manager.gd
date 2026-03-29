# SYSTEM: Pixel Simulation
# AGENT: Pixel Sim Agent (stub created by Foundation Agent)
# PURPOSE: Manages the cellular automata simulation layer.
# The real implementation uses a C++ GDExtension for performance.
# STUB VERSION — replace when Pixel Sim Agent delivers the extension.

extends Node

class_name SimManager

# Called every physics tick to step the simulation forward.
# STUB: does nothing until GDExtension is loaded.
func step_simulation(delta: float) -> void:
	pass

# Returns the simulation cell data at world tile position (x, y).
# Returns material_id=0 (air) until simulation is running.
func get_cell(x: int, y: int) -> Dictionary:
	return {"material_id": 0, "temperature": 0.0, "flags": 0}

# Sets a simulation cell to a specific material.
func set_cell(x: int, y: int, material_id: int) -> void:
	pass

# Spawns a particle of material_id at world position (x, y).
func add_particle(x: int, y: int, material_id: int) -> void:
	pass

# Emitted when a cell's material changes.
signal cell_changed(x: int, y: int, material_id: int)
