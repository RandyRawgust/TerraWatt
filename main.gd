# SYSTEM: Main Game Loop
# AGENT: Integration Agent (stub created by Foundation Agent)
# PURPOSE: Entry point. Initializes all systems and starts the game.

extends Node2D

func _ready() -> void:
	print("Terra.Watt — Initializing...")
	# Systems initialize via their own _ready() calls as autoloads.
	# Main scene wires them together here once all agents deliver.
	print("Terra.Watt — Ready. Open main.tscn in Godot to run.")

func _process(delta: float) -> void:
	pass
