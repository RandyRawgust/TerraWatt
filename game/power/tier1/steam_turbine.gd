# SYSTEM: Power / Tier 1
# AGENT: Coal Power Agent
# PURPOSE: Converts steam pressure to electrical output via generator.

extends PowerSourceBase

class_name SteamTurbine

const EFFICIENCY: float = 0.75
const MAX_OUTPUT: float = 10000.0

var _steam_source: Node = null

@onready var turbine_sprite: AnimatedSprite2D = $TurbineSprite


func _ready() -> void:
	super._ready()
	max_output_watts = MAX_OUTPUT
	add_to_group("machines")
	_setup_turbine_frames()


func _physics_process(_delta: float) -> void:
	_calculate_output()
	_update_animation()


func connect_steam_source(boiler: Node) -> void:
	_steam_source = boiler


func _setup_turbine_frames() -> void:
	if turbine_sprite.sprite_frames and turbine_sprite.sprite_frames.has_animation("idle"):
		turbine_sprite.play("idle")
		return
	var sf := SpriteFrames.new()
	const _idle_path: String = "res://assets/power/tier1/steam_turbine.png"
	const _spin_path: String = "res://assets/power/tier1/turbine_active.png"
	if not ResourceLoader.exists(_idle_path):
		return
	var tex_idle: Texture2D = load(_idle_path) as Texture2D
	var tex_spin: Texture2D = load(_spin_path) as Texture2D if ResourceLoader.exists(_spin_path) else tex_idle
	if tex_idle == null:
		return
	sf.add_animation("idle")
	sf.set_animation_speed("idle", 1.0)
	sf.add_frame("idle", tex_idle, 1.0)
	sf.add_animation("spin")
	sf.set_animation_speed("spin", 12.0)
	for _i in 4:
		sf.add_frame("spin", tex_spin, 0.2)
	turbine_sprite.sprite_frames = sf
	turbine_sprite.play("idle")


func _calculate_output() -> void:
	var steam_in: float = 0.0
	if _steam_source and _steam_source.has_method("get_steam_output"):
		steam_in = _steam_source.get_steam_output()
	set_output(steam_in * EFFICIENCY)


func _update_animation() -> void:
	if not turbine_sprite.sprite_frames:
		return
	var spin_speed: float = get_output_fraction() * 5.0
	turbine_sprite.speed_scale = spin_speed
	if spin_speed > 0.1:
		if turbine_sprite.sprite_frames.has_animation("spin"):
			turbine_sprite.play("spin")
	else:
		if turbine_sprite.sprite_frames.has_animation("idle"):
			turbine_sprite.play("idle")
