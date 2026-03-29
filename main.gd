# SYSTEM: Main Game Loop
# AGENT: Integration Agent (stub created by Foundation Agent)
# PURPOSE: Entry point. Initializes all systems and starts the game.

extends Node2D


func _ready() -> void:
	print("Terra.Watt — Initializing...")
	WorldData.initialize(randi())
	var wr: WorldRenderer = $WorldRenderer
	var player: Player = $Player
	var cam: Camera2D = player.get_node("Camera2D") as Camera2D
	wr.set_camera(cam)
	if has_node("LightingManager"):
		var lm: LightingManager = $LightingManager as LightingManager
		lm.set_player_light(player.get_node("Headlamp") as PointLight2D)
	var sx: int = int(floor(player.global_position.x / float(WorldData.TILE_SIZE)))
	var sy: int = WorldData.get_surface_y(sx)
	player.global_position = Vector2(
		float(sx) * float(WorldData.TILE_SIZE) + float(WorldData.TILE_SIZE) * 0.5,
		float(sy - 4) * float(WorldData.TILE_SIZE)
	)
	print("Terra.Watt — Ready. Surface Y at x=%d: %d" % [sx, sy])


func _process(_delta: float) -> void:
	var player: Player = $Player as Player
	var cam: Camera2D = player.get_node("Camera2D") as Camera2D
	var bg: BackgroundLayer = $BackgroundLayer as BackgroundLayer
	if bg != null:
		bg.update_parallax(cam.global_position)
