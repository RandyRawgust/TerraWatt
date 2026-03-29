# SYSTEM: Player
# AGENT: Coal Power Agent
# PURPOSE: Handles player pressing E to interact with nearby machines.

extends Node

const INTERACT_RANGE: float = 48.0
const CHAIN_CONNECT_RANGE: float = 128.0

@onready var player: Node2D = get_parent() as Node2D


func _input(event: InputEvent) -> void:
	if event.is_action_pressed("interact"):
		_try_interact()


func _try_interact() -> void:
	if not player:
		return
	var nearest: Node2D = null
	var nearest_dist: float = INTERACT_RANGE
	for machine in get_tree().get_nodes_in_group("machines"):
		if machine is Node2D:
			var dist: float = player.global_position.distance_to(machine.global_position)
			if dist < nearest_dist:
				nearest_dist = dist
				nearest = machine
	if nearest:
		_interact_with(nearest)


func _interact_with(machine: Node2D) -> void:
	if machine.has_method("add_coal") and Inventory.has_item("coal", 1):
		var coal_in_inventory: int = Inventory.get_count("coal")
		var accepted: int = machine.add_coal(coal_in_inventory)
		if accepted > 0:
			Inventory.remove_item("coal", accepted)
		print("Loaded %d coal into furnace." % accepted)

	elif machine is WaterBoiler:
		var wb: WaterBoiler = machine as WaterBoiler
		var furnace: CoalFurnace = _find_nearest_coal_furnace(wb.global_position)
		if furnace:
			wb.connect_heat_source(furnace)
			print("Boiler linked to nearest coal furnace.")
		if Inventory.has_item("water_bucket", 1):
			var accepted_water: float = wb.add_water(5.0)
			if accepted_water > 0.0:
				Inventory.remove_item("water_bucket", 1)
				print("Added water to boiler.")

	elif machine.has_method("connect_steam_source"):
		var boiler: WaterBoiler = _find_nearest_water_boiler(machine.global_position)
		if boiler:
			machine.connect_steam_source(boiler)
			print("Turbine connected to boiler.")


func _find_nearest_coal_furnace(from_pos: Vector2) -> CoalFurnace:
	var best: CoalFurnace = null
	var best_d: float = CHAIN_CONNECT_RANGE
	for m in get_tree().get_nodes_in_group("machines"):
		if m is CoalFurnace:
			var cf: CoalFurnace = m as CoalFurnace
			var d: float = from_pos.distance_to(cf.global_position)
			if d < best_d:
				best_d = d
				best = cf
	return best


func _find_nearest_water_boiler(from_pos: Vector2) -> WaterBoiler:
	var best: WaterBoiler = null
	var best_d: float = CHAIN_CONNECT_RANGE
	for m in get_tree().get_nodes_in_group("machines"):
		if m is WaterBoiler:
			var wb: WaterBoiler = m as WaterBoiler
			var d: float = from_pos.distance_to(wb.global_position)
			if d < best_d:
				best_d = d
				best = wb
	return best
