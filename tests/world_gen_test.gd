# Headless verification for World Gen Agent (run: godot --headless -s res://tests/world_gen_test.gd)
extends SceneTree


func _init() -> void:
	WorldData.initialize(12345)

	var sy: int = WorldData.get_surface_y(200)
	if sy < 8 or sy > 18:
		push_error("world_gen_test: surface Y at x=200 expected 8–18, got %d" % sy)
		quit(1)
		return

	if WorldData.get_tile(200, 5) != WorldData.TILE_AIR:
		push_error("world_gen_test: sky tile at (200,5) should be AIR")
		quit(1)
		return

	var found_stone: bool = false
	for y in range(60, 150):
		if WorldData.get_tile(200, y) == WorldData.TILE_STONE:
			found_stone = true
			break
	if not found_stone:
		push_error("world_gen_test: expected at least one STONE in mid band for x=200")
		quit(1)
		return

	var found_cave_air: bool = false
	for wx in range(180, 221):
		var surf: int = WorldData.get_surface_y(wx)
		for y in range(20, 61):
			if y <= surf:
				continue
			if WorldData.get_tile(wx, y) == WorldData.TILE_AIR:
				found_cave_air = true
				break
		if found_cave_air:
			break
	if not found_cave_air:
		push_error("world_gen_test: expected underground cave AIR (y>surface) in shallow band")
		quit(1)
		return

	print("world_gen_test: OK")
	quit(0)
