# SYSTEM: Player
# AGENT: UI & Creatures Agent (minimal stub until Player Agent delivers full player)
# PURPOSE: Registers in "player" group; forwards damage to PlayerStatus.

extends Node2D


func _ready() -> void:
	add_to_group("player")


func take_damage(amount: float) -> void:
	if has_node("PlayerStatus"):
		($PlayerStatus as PlayerStatus).apply_damage(amount)
