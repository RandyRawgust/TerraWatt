# SYSTEM: Power / Tier 1
# AGENT: Coal Power Agent
# PURPOSE: Burns coal to produce heat. Feeds boiler via pipe connection.

extends StaticBody2D

class_name CoalFurnace

const MAX_COAL_STORED: int = 20
const BURN_RATE: float = 1.0 / 30.0
const HEAT_OUTPUT: float = 150.0

var coal_stored: int = 0
var is_burning: bool = false
var heat_output: float = 0.0
var _burn_timer: float = 0.0

@onready var flame_sprite: AnimatedSprite2D = $FlameSprite
@onready var smoke_emitter: Marker2D = $SmokeEmitter


func _ready() -> void:
	add_to_group("machines")
	add_to_group("coal_furnaces")
	_setup_flame_frames()


func _physics_process(delta: float) -> void:
	_tick_burn(delta)
	_emit_smoke_if_burning()


func add_coal(amount: int) -> int:
	var space: int = MAX_COAL_STORED - coal_stored
	var added: int = mini(amount, space)
	coal_stored += added
	return added


func get_heat_output() -> float:
	return heat_output


func _setup_flame_frames() -> void:
	if flame_sprite.sprite_frames and flame_sprite.sprite_frames.has_animation("idle"):
		flame_sprite.play("idle")
		return
	var sf := SpriteFrames.new()
	var tex: Texture2D = load("res://assets/tiles/ores/coal_icon.png") as Texture2D
	sf.add_animation("idle")
	sf.set_animation_speed("idle", 1.0)
	sf.add_frame("idle", tex, 0.0)
	sf.add_animation("burn")
	sf.set_animation_speed("burn", 10.0)
	for _i in 3:
		sf.add_frame("burn", tex, 0.0)
	flame_sprite.sprite_frames = sf
	flame_sprite.play("idle")


func _tick_burn(delta: float) -> void:
	if coal_stored > 0:
		_burn_timer += delta
		if _burn_timer >= 1.0 / BURN_RATE:
			coal_stored -= 1
			_burn_timer = 0.0
			PollutionTracker.report_coal_burned()
		is_burning = true
		heat_output = HEAT_OUTPUT
		if flame_sprite.sprite_frames:
			flame_sprite.play("burn")
	else:
		is_burning = false
		heat_output = 0.0
		if flame_sprite.sprite_frames:
			flame_sprite.play("idle")


func _emit_smoke_if_burning() -> void:
	if not is_burning or randf() >= 0.15:
		return
	var pos := Vector2i(
		int(smoke_emitter.global_position.x / 16.0),
		int(smoke_emitter.global_position.y / 16.0)
	)
	SimManager.add_particle(pos.x, pos.y, MaterialRegistry.MAT_SMOKE)
