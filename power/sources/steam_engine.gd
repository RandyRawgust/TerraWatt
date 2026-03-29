# Wood-fired Steam Engine — burns wood logs, requires water, emits steam/smoke particles.

extends PowerSourceBase

const FULL_OUTPUT: float = 200.0
const WOOD_BURN_RATE: float = 1.0 / 30.0  # 1 wood per 30 seconds at full burn
const WATER_CONSUME_RATE: float = 0.5  # units per second

var wood_fuel: float = 0.0
var water_level: float = 0.0
var _burn_timer: float = 0.0

@onready var smoke_emit_pos: Marker2D = $SmokeEmitPos
@onready var engine_sprite: AnimatedSprite2D = $EngineSprite

const PLACEHOLDER_TEX: Texture2D = preload("res://icon.svg")


func _ready() -> void:
	max_output_watts = FULL_OUTPUT
	if engine_sprite and engine_sprite.sprite_frames == null:
		var sf := SpriteFrames.new()
		sf.add_animation("idle")
		sf.add_animation("operate")
		sf.add_frame("idle", PLACEHOLDER_TEX)
		sf.add_frame("operate", PLACEHOLDER_TEX)
		sf.add_frame("operate", PLACEHOLDER_TEX)
		engine_sprite.sprite_frames = sf
	super._ready()


func _physics_process(delta: float) -> void:
	_tick_burn(delta)


func _tick_burn(delta: float) -> void:
	if wood_fuel > 0.0 and water_level > 0.0:
		_burn_timer += delta
		if _burn_timer >= 1.0 / WOOD_BURN_RATE:
			wood_fuel -= 1.0
			_burn_timer = 0.0
		water_level -= WATER_CONSUME_RATE * delta
		water_level = max(water_level, 0.0)
		set_output(FULL_OUTPUT)
		var ex: int = int(smoke_emit_pos.global_position.x / 16.0)
		var ey: int = int(smoke_emit_pos.global_position.y / 16.0)
		if randf() < 0.1:
			SimManager.add_particle(ex, ey, MaterialRegistry.MAT_STEAM)
			SimManager.add_particle(ex, ey, MaterialRegistry.MAT_SMOKE)
		if engine_sprite and engine_sprite.sprite_frames and engine_sprite.sprite_frames.has_animation("operate"):
			engine_sprite.play("operate")
	else:
		set_output(0.0)
		if engine_sprite and engine_sprite.sprite_frames and engine_sprite.sprite_frames.has_animation("idle"):
			engine_sprite.play("idle")


func add_wood(amount: float) -> void:
	wood_fuel += amount


func add_water(amount: float) -> void:
	water_level = min(water_level + amount, 10.0)
