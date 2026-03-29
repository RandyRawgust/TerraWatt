# SYSTEM: UI / Power
# AGENT: Electrical Grid Agent
# PURPOSE: Top-right HUD showing generation vs demand in watts (Tier 1+).

extends Control

class_name PowerMeter

@onready var gen_label: Label = $PanelContainer/VBox/GenRow/GenLabel
@onready var dem_label: Label = $PanelContainer/VBox/DemLabel
@onready var gen_bar: ProgressBar = $PanelContainer/VBox/GenBar
@onready var dem_bar: ProgressBar = $PanelContainer/VBox/DemBar
@onready var status_light: ColorRect = $PanelContainer/VBox/GenRow/StatusLight

const MAX_DISPLAY_WATTS: float = 50000.0


func _ready() -> void:
	PowerGrid.power_updated.connect(_on_power_updated)
	_on_power_updated(PowerGrid.total_generation, PowerGrid.total_demand)


func _on_power_updated(generation: float, demand: float) -> void:
	gen_label.text = "Gen: %s" % _format_watts(generation)
	dem_label.text = "Dem: %s" % _format_watts(demand)

	gen_bar.value = minf(generation / MAX_DISPLAY_WATTS, 1.0) * 100.0
	dem_bar.value = minf(demand / MAX_DISPLAY_WATTS, 1.0) * 100.0

	var ratio: float = demand / maxf(generation, 1.0)
	if ratio < 0.7:
		status_light.color = Color(0.0, 0.8, 0.2)
	elif ratio < 0.9:
		status_light.color = Color(1.0, 0.7, 0.0)
	else:
		status_light.color = Color(0.9, 0.1, 0.1)


static func _format_watts(watts: float) -> String:
	if watts >= 1000.0:
		return "%.1f kW" % (watts / 1000.0)
	return "%.0f W" % watts
