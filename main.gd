# SYSTEM: Main Game Loop
# AGENT: Integration Agent (stub created by Foundation Agent)
# PURPOSE: Entry point. Initializes all systems and starts the game.

extends Node2D


func _ready() -> void:
	print("Terra.Watt — Initializing...")
	WorldData.initialize(12345)
	var cam := $Camera2D as Camera2D
	var spawn: Vector2 = SpawnLocator.find_spawn_point(200)
	cam.global_position = spawn
	var wr := $WorldRenderer as WorldRenderer
	if wr:
		wr.set_camera(cam)
	print("Terra.Watt — Ready. Spawn at ", spawn)


func _process(_delta: float) -> void:
	pass
