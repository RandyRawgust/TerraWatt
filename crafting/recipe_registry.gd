# SYSTEM: Crafting
# AGENT: Coal Power Agent
# PURPOSE: Defines crafting recipes. Tier 1 machines require a Workbench.

extends Node

class_name RecipeRegistry

const RECIPES: Array[Dictionary] = [
	{
		"name": "Coal Furnace",
		"station": "workbench",
		"inputs": [{"item": "stone", "amount": 20}, {"item": "iron_ore", "amount": 5}],
		"output": {"item": "coal_furnace", "amount": 1},
		"tier": 1
	},
	{
		"name": "Water Boiler",
		"station": "workbench",
		"inputs": [{"item": "iron_ore", "amount": 15}, {"item": "copper_ore", "amount": 8}],
		"output": {"item": "water_boiler", "amount": 1},
		"tier": 1
	},
	{
		"name": "Steam Turbine",
		"station": "workbench",
		"inputs": [{"item": "iron_ore", "amount": 25}, {"item": "copper_ore", "amount": 12}],
		"output": {"item": "steam_turbine", "amount": 1},
		"tier": 1
	},
]
