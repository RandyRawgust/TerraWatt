# SYSTEM: Main Game Loop
# AGENT: Integration Agent (stub created by Foundation Agent)
# PURPOSE: Entry point. Initializes all systems and starts the game.

extends Node2D

func _ready() -> void:
	print("Terra.Watt — Initializing...")
	# Systems initialize via their own _ready() calls as autoloads.
	# Demo inventory so the hotbar shows counts (replace when mining loop is wired).
	if Inventory.get_count("coal") == 0:
		Inventory.add_item("coal", 3)
	print("Terra.Watt — Ready. Open main.tscn in Godot to run.")

func _process(delta: float) -> void:
	pass
