# SYSTEM: UI
# AGENT: UI & Creatures Agent
# PURPOSE: Top-right readout for grid generation vs demand (Tier 0+).

extends HBoxContainer

class_name PowerMeter

@onready var _gen_label: Label = $GenLabel
@onready var _dem_label: Label = $DemLabel


func _ready() -> void:
	PowerGrid.power_updated.connect(_on_power_updated)
	_on_power_updated(PowerGrid.total_generation, PowerGrid.total_demand)


func _on_power_updated(generation: float, demand: float) -> void:
	_gen_label.text = "Gen: %.0f W" % generation
	_dem_label.text = "Dem: %.0f W" % demand
