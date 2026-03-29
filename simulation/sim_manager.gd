# SYSTEM: Pixel Simulation
# AGENT: Pixel Sim Agent
# PURPOSE: GDScript wrapper integrating C++ SimCore (TerrawattSimNode) with the scene tree.

extends Node

class_name SimManager

var _sim_node: Node = null
var _is_loaded: bool = false

func _ready() -> void:
	_try_load_extension()

func _try_load_extension() -> void:
	if ClassDB.class_exists("TerrawattSimNode"):
		_sim_node = ClassDB.instantiate("TerrawattSimNode")
		add_child(_sim_node)
		_sim_node.cells_updated.connect(_on_cells_updated)
		_is_loaded = true
		print("SimManager: C++ extension loaded successfully.")
	else:
		push_warning("SimManager: TerrawattSimNode not found. Using GDScript fallback.")
		_is_loaded = false

func _physics_process(_delta: float) -> void:
	if _is_loaded and _sim_node:
		_sim_node.step(_delta)

## Legacy API (Foundation stub); forwards to the simulation step (driven by _physics_process).
func step_simulation(delta: float) -> void:
	if _is_loaded and _sim_node:
		_sim_node.step(delta)

func get_sim_node() -> Node:
	return _sim_node

func get_sim_width() -> int:
	if _is_loaded and _sim_node:
		return _sim_node.get_sim_width()
	return 0

func get_sim_height() -> int:
	if _is_loaded and _sim_node:
		return _sim_node.get_sim_height()
	return 0

func get_cell(x: int, y: int) -> Dictionary:
	if _is_loaded and _sim_node:
		return {
			"material_id": _sim_node.get_cell_material(x, y),
			"temperature": _sim_node.get_cell_temperature(x, y),
			"flags": _sim_node.get_cell_flags(x, y),
		}
	return {"material_id": 0, "temperature": 0.0, "flags": 0}

func set_cell(x: int, y: int, material_id: int) -> void:
	if _is_loaded and _sim_node:
		_sim_node.set_cell_material(x, y, material_id)

func add_particle(x: int, y: int, material_id: int) -> void:
	if _is_loaded and _sim_node:
		_sim_node.add_particle(x, y, material_id)

func _on_cells_updated(region: Rect2i) -> void:
	cell_changed.emit(region.position.x, region.position.y, 0)

signal cell_changed(x: int, y: int, material_id: int)
