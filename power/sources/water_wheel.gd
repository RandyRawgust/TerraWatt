# Water Wheel — requires flowing water particles adjacent to generate power.
# Output: 0-50W based on water presence nearby (Pixel Sim reports water cells).

extends PowerSourceBase

const BASE_OUTPUT: float = 50.0
const WATER_CHECK_RADIUS: int = 2  # tiles

@onready var wheel_sprite: AnimatedSprite2D = $WheelSprite

const PLACEHOLDER_TEX: Texture2D = preload("res://assets/power/placeholder_8x8.png")


func _ready() -> void:
	max_output_watts = BASE_OUTPUT
	if wheel_sprite and wheel_sprite.sprite_frames == null:
		var sf := SpriteFrames.new()
		sf.add_animation("idle")
		sf.add_animation("spin")
		sf.add_frame("idle", PLACEHOLDER_TEX)
		sf.add_frame("spin", PLACEHOLDER_TEX)
		sf.add_frame("spin", PLACEHOLDER_TEX)
		wheel_sprite.sprite_frames = sf
	super._ready()


func _physics_process(_delta: float) -> void:
	var flow_rate: float = _measure_water_flow()
	set_output(BASE_OUTPUT * flow_rate)
	if wheel_sprite:
		if is_operating:
			wheel_sprite.play("spin")
			wheel_sprite.speed_scale = get_output_fraction() * 2.0
		else:
			wheel_sprite.play("idle")


func _measure_water_flow() -> float:
	var my_tile := Vector2i(
		int(floor(global_position.x / 16.0)),
		int(floor(global_position.y / 16.0))
	)
	var water_cells: int = 0
	for dx in range(-WATER_CHECK_RADIUS, WATER_CHECK_RADIUS + 1):
		for dy in range(-WATER_CHECK_RADIUS, WATER_CHECK_RADIUS + 1):
			var cell: Dictionary = SimManager.get_cell(my_tile.x + dx, my_tile.y + dy)
			if int(cell.get("material_id", 0)) == MaterialRegistry.MAT_WATER:
				water_cells += 1
	return clampf(float(water_cells) / 8.0, 0.0, 1.0)
