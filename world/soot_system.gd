# SYSTEM: Soot
# AGENT: Pollution Agent
# PURPOSE: Darkens structures near active coal furnaces (visual only).

extends Node

const SOOT_RANGE: float = 80.0
const SOOT_RATE: float = 0.01
const SOOT_DECAY: float = 0.002

var _soot_levels: Dictionary = {}


func _process(delta: float) -> void:
	var furnaces: Array = get_tree().get_nodes_in_group("coal_furnaces")
	var active_furnaces: Array = furnaces.filter(
		func(f: Node) -> bool: return f.has_method("get_heat_output") and f.get_heat_output() > 0.0
	)

	for structure: Node in get_tree().get_nodes_in_group("structures"):
		if not structure is Node2D:
			continue
		var node2d := structure as Node2D
		var max_soot: float = 0.0
		for furnace: Node in active_furnaces:
			if furnace is Node2D:
				var dist: float = node2d.global_position.distance_to((furnace as Node2D).global_position)
				if dist < SOOT_RANGE:
					max_soot = maxf(max_soot, 1.0 - dist / SOOT_RANGE)

		var current: float = float(_soot_levels.get(structure, 0.0))
		if max_soot > 0.0:
			current = minf(current + SOOT_RATE * delta, max_soot)
		else:
			current = maxf(current - SOOT_DECAY * delta, 0.0)

		_soot_levels[structure] = current
		var soot_color := Color(
			1.0 - current * 0.4,
			1.0 - current * 0.4,
			1.0 - current * 0.45
		)
		node2d.modulate = soot_color
