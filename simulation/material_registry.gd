# SYSTEM: Material Registry
# AGENT: Pixel Sim Agent (stub created by Foundation Agent)
# PURPOSE: Defines all materials and their properties.
# Maps tile IDs (int) to material definitions (Dictionary).

extends Node

class_name MaterialRegistry

# Material IDs — match WorldData tile constants
const MAT_AIR: int = 0
const MAT_DIRT: int = 1
const MAT_STONE: int = 2
const MAT_GRASS_DIRT: int = 3
const MAT_COAL: int = 4
const MAT_COPPER_ORE: int = 5
const MAT_IRON_ORE: int = 6
const MAT_CLAY: int = 7
# Simulation particle materials (100+)
const MAT_WATER: int = 100
const MAT_STEAM: int = 101
const MAT_FIRE: int = 102
const MAT_SMOKE: int = 103
const MAT_ASH: int = 104
const MAT_MUD: int = 105

# Full material definitions loaded from res://simulation/materials/
var materials: Dictionary = {}

func _ready() -> void:
	_register_defaults()

func get_material(id: int) -> Dictionary:
	return materials.get(id, {})

func get_display_name(id: int) -> String:
	return materials.get(id, {}).get("name", "Unknown")

func get_color(id: int) -> Color:
	return materials.get(id, {}).get("color", Color.MAGENTA)

func _register_defaults() -> void:
	materials[MAT_AIR]        = {"name": "Air",       "category": "GAS",    "color": Color(0,0,0,0),       "flammable": false}
	materials[MAT_DIRT]       = {"name": "Dirt",      "category": "SOLID",  "color": Color(0.55,0.42,0.24), "flammable": false, "mine_time": 0.5}
	materials[MAT_STONE]      = {"name": "Stone",     "category": "SOLID",  "color": Color(0.42,0.42,0.42), "flammable": false, "mine_time": 1.5}
	materials[MAT_GRASS_DIRT] = {"name": "Grass",     "category": "SOLID",  "color": Color(0.29,0.49,0.18), "flammable": false, "mine_time": 0.5}
	materials[MAT_COAL]       = {"name": "Coal",      "category": "SOLID",  "color": Color(0.16,0.16,0.16), "flammable": true,  "mine_time": 1.0, "ignition_temp": 300.0}
	materials[MAT_COPPER_ORE] = {"name": "Copper Ore","category": "SOLID",  "color": Color(0.72,0.45,0.20), "flammable": false, "mine_time": 2.0}
	materials[MAT_IRON_ORE]   = {"name": "Iron Ore",  "category": "SOLID",  "color": Color(0.54,0.54,0.60), "flammable": false, "mine_time": 2.5}
	materials[MAT_CLAY]       = {"name": "Clay",      "category": "SOLID",  "color": Color(0.65,0.48,0.35), "flammable": false, "mine_time": 0.7}
	materials[MAT_WATER]      = {"name": "Water",     "category": "LIQUID", "color": Color(0.20,0.50,0.80,0.8), "flammable": false, "density": 1.0}
	materials[MAT_STEAM]      = {"name": "Steam",     "category": "GAS",    "color": Color(0.85,0.85,0.90,0.5), "flammable": false}
	materials[MAT_FIRE]       = {"name": "Fire",      "category": "ENERGY", "color": Color(1.0,0.45,0.10),  "flammable": false}
	materials[MAT_SMOKE]      = {"name": "Smoke",     "category": "GAS",    "color": Color(0.25,0.25,0.25,0.7), "flammable": false}
	materials[MAT_ASH]        = {"name": "Ash",       "category": "SOLID",  "color": Color(0.50,0.48,0.45), "flammable": false}
	materials[MAT_MUD]        = {"name": "Mud",       "category": "LIQUID", "color": Color(0.40,0.30,0.18,0.9), "flammable": false, "density": 1.8}
