# Minimal integration test for pixel sim (run scene simulation/test_sim.tscn).
extends Node2D

var _elapsed: float = 0.0
var _reported: bool = false

func _ready() -> void:
	if not ClassDB.class_exists("TerrawattSimNode"):
		push_warning("test_sim: TerrawattSimNode not loaded — build simulation/gdextension and place DLL in res://bin/")
		return
	for i in 100:
		SimManager.add_particle(i, 50, MaterialRegistry.MAT_WATER)
	SimManager.set_cell(49, 30, MaterialRegistry.MAT_COAL)
	SimManager.add_particle(50, 30, MaterialRegistry.MAT_FIRE)

func _physics_process(delta: float) -> void:
	if _reported:
		return
	if not ClassDB.class_exists("TerrawattSimNode"):
		return
	_elapsed += delta
	if _elapsed < 5.0:
		return
	_reported = true
	_run_checks()

func _run_checks() -> void:
	var water_flowed := false
	for x in 100:
		var c: Dictionary = SimManager.get_cell(x, 51)
		if int(c.get("material_id", 0)) == MaterialRegistry.MAT_WATER:
			water_flowed = true
			break
	var coal_burning := int(SimManager.get_cell(49, 30).get("material_id", 0)) == MaterialRegistry.MAT_FIRE
	var exhaust_up := false
	for dy in range(-8, 0):
		var c2: Dictionary = SimManager.get_cell(50, 30 + dy)
		var mid: int = int(c2.get("material_id", 0))
		if mid == MaterialRegistry.MAT_STEAM or mid == MaterialRegistry.MAT_SMOKE:
			exhaust_up = true
			break
	print("test_sim: water_flowed=", water_flowed, " coal_caught_fire=", coal_burning, " smoke_or_steam_above_fire=", exhaust_up)
	if water_flowed and coal_burning and exhaust_up:
		print("test_sim: PASS (flow + fire spread + exhaust above fire)")
	else:
		push_warning("test_sim: partial — tune sim or re-run")
