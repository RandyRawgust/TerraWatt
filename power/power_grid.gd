# SYSTEM: Power Grid
# AGENT: Electrical Grid Agent (Tier 1)
# PURPOSE: Tracks power sources, pole distribution networks, and local delivery.
# Tier 0: mechanical radius. Tier 1: pole-connected zones + distribution radius.

extends Node

signal power_updated(generation: float, demand: float)
signal pole_registered(pole: Node2D)

# All registered sources: node → { watts: float, position: Vector2 }
var sources: Dictionary = {}
var total_generation: float = 0.0
var total_demand: float = 0.0
var total_load_watts: float = 0.0

# Pole registry: connectivity refreshed when poles register/unregister; watts refresh each tick.
var pole_networks: Dictionary = {}
var registered_poles: Array[Node2D] = []

var _pole_network_watts: Dictionary = {}
var _pole_components: Array[Array] = []


func _process(_delta: float) -> void:
	_recalculate_totals()


func register_pole(pole: Node2D) -> void:
	if not is_instance_valid(pole):
		return
	if pole not in registered_poles:
		registered_poles.append(pole)
	pole_networks[pole] = {"watts": 0.0, "loads": []}
	_rebuild_pole_components()
	_update_pole_network_watts()
	pole_registered.emit(pole)
	power_updated.emit(total_generation, total_demand)


func unregister_pole(pole: Node2D) -> void:
	pole_networks.erase(pole)
	registered_poles.erase(pole)
	_rebuild_pole_components()
	_update_pole_network_watts()
	power_updated.emit(total_generation, total_demand)


func has_power_at(world_pos: Vector2) -> bool:
	for pole in registered_poles:
		if not is_instance_valid(pole):
			continue
		if pole.global_position.distance_to(world_pos) <= PowerPole.DISTRIBUTION_RADIUS:
			if float(_pole_network_watts.get(pole, 0.0)) > 0.0:
				return true
	return false


func get_pole_network_watts(pole: Node2D) -> float:
	return float(_pole_network_watts.get(pole, 0.0))


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
	var mechanical: float = _get_nearest_source_watts(pos)
	var electrical: float = 0.0
	for pole in registered_poles:
		if not is_instance_valid(pole):
			continue
		if pole.global_position.distance_to(pos) <= PowerPole.DISTRIBUTION_RADIUS:
			electrical = maxf(electrical, float(_pole_network_watts.get(pole, 0.0)))
	return maxf(mechanical, electrical)


func _get_nearest_source_watts(pos: Vector2) -> float:
	var nearest_watts: float = 0.0
	var nearest_dist: float = 10.0 * 16.0
	for node in sources:
		if not is_instance_valid(node):
			continue
		if node is Node2D:
			var dist: float = (node as Node2D).global_position.distance_to(pos)
			if dist < nearest_dist:
				nearest_dist = dist
				nearest_watts = float(sources[node]["watts"])
	return nearest_watts


func _rebuild_pole_components() -> void:
	_pole_components.clear()
	var poles: Array[Node2D] = []
	for pole in registered_poles:
		if is_instance_valid(pole):
			poles.append(pole)
	registered_poles.clear()
	registered_poles.append_array(poles)
	if poles.is_empty():
		return

	var parent: Dictionary = {}
	for p in poles:
		parent[p] = p

	for i in range(poles.size()):
		for j in range(i + 1, poles.size()):
			var a: Node2D = poles[i]
			var b: Node2D = poles[j]
			if a.global_position.distance_to(b.global_position) <= PowerPole.CONNECTION_RANGE:
				_union_poles(parent, a, b)

	var buckets: Dictionary = {}
	for p in poles:
		var r: Node2D = _pole_find_parent(parent, p)
		if not buckets.has(r):
			buckets[r] = [] as Array
		(buckets[r] as Array).append(p)

	for k in buckets:
		_pole_components.append(buckets[k])


func _update_pole_network_watts() -> void:
	_pole_network_watts.clear()
	for pole in pole_networks.keys():
		if not is_instance_valid(pole):
			continue
		if pole_networks[pole] is Dictionary:
			pole_networks[pole]["watts"] = 0.0

	for group in _pole_components:
		var feed_sum: float = 0.0
		for node in sources:
			if not is_instance_valid(node):
				continue
			var spos: Vector2 = Vector2(sources[node]["position"])
			var w: float = float(sources[node]["watts"])
			if w <= 0.0:
				continue
			for pole in group:
				if spos.distance_to((pole as Node2D).global_position) <= PowerPole.CONNECTION_RANGE:
					feed_sum += w
					break
		var cap: float = float(group.size()) * PowerPole.CAPACITY_WATTS
		var net_w: float = minf(feed_sum, cap)
		for pole in group:
			_pole_network_watts[pole] = net_w
			if pole_networks.has(pole):
				pole_networks[pole]["watts"] = net_w


func _pole_find_parent(parent: Dictionary, p: Node2D) -> Node2D:
	var cur: Node2D = p
	while parent[cur] != cur:
		parent[cur] = parent[parent[cur]]
		cur = parent[cur]
	return cur


func _union_poles(parent: Dictionary, a: Node2D, b: Node2D) -> void:
	var ra: Node2D = _pole_find_parent(parent, a)
	var rb: Node2D = _pole_find_parent(parent, b)
	if ra != rb:
		parent[rb] = ra


func _recalculate_totals() -> void:
	total_generation = 0.0
	var stale: Array[Node] = []
	for node in sources:
		if not is_instance_valid(node):
			stale.append(node)
			continue
		if node is Node2D:
			sources[node]["position"] = (node as Node2D).global_position
		total_generation += float(sources[node]["watts"])
	for n in stale:
		sources.erase(n)

	_update_pole_network_watts()
	power_updated.emit(total_generation, total_demand)
