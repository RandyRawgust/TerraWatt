# Windmill — variable output based on simulated wind.
# Must be placed at surface (tile Y <= surface + 5). Output ~5-80W.

extends PowerSourceBase

const MIN_OUTPUT: float = 5.0
const MAX_OUTPUT: float = 80.0
const WIND_CYCLE: float = 30.0  # seconds for a full wind cycle

var _wind_time: float = 0.0

@onready var blade_sprite: AnimatedSprite2D = $BladeSprite

const PLACEHOLDER_TEX: Texture2D = preload("res://icon.svg")


func _ready() -> void:
	max_output_watts = MAX_OUTPUT
	if blade_sprite and blade_sprite.sprite_frames == null:
		var sf := SpriteFrames.new()
		sf.add_animation("spin")
		sf.add_frame("spin", PLACEHOLDER_TEX)
		sf.add_frame("spin", PLACEHOLDER_TEX)
		blade_sprite.sprite_frames = sf
	super._ready()


func _physics_process(delta: float) -> void:
	_wind_time += delta
	if not _is_surface_placement_valid():
		set_output(0.0)
		if blade_sprite:
			blade_sprite.speed_scale = 0.0
		return

	var wind_strength: float = _calculate_wind()
	set_output(lerp(MIN_OUTPUT, MAX_OUTPUT, wind_strength))
	if blade_sprite and blade_sprite.sprite_frames:
		blade_sprite.speed_scale = get_output_fraction() * 3.0
		if blade_sprite.sprite_frames.has_animation("spin") and not blade_sprite.is_playing():
			blade_sprite.play("spin")


func _is_surface_placement_valid() -> bool:
	var tile_x := int(floor(global_position.x / 16.0))
	var tile_y := int(floor(global_position.y / 16.0))
	var surface_y: int = WorldData.get_surface_y(tile_x)
	return tile_y <= surface_y + 5


func _calculate_wind() -> float:
	var base_wind: float = (sin(_wind_time * TAU / WIND_CYCLE) + 1.0) / 2.0
	var noise_offset: float = sin(_wind_time * 7.3) * 0.1
	return clamp(base_wind + noise_offset, 0.0, 1.0)
