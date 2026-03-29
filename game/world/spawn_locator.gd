# Finds a safe spawn position for the player at world start.
# Returns a Vector2 in world pixel coordinates.

extends Object

class_name SpawnLocator


static func find_spawn_point(world_x: int = 200) -> Vector2:
	var surface_y: int = WorldData.get_surface_y(world_x)
	return Vector2(
		world_x * WorldData.TILE_SIZE,
		(surface_y - 2) * WorldData.TILE_SIZE
	)
