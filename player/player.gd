# SYSTEM: Player
# AGENT: Player Agent
# PURPOSE: Player movement, physics, collision, input, status tracking.

extends CharacterBody2D

class_name Player

signal tile_mined(tile_pos: Vector2i, tile_id: int)
signal item_collected(item_type: String, amount: int)

const WALK_SPEED: float = 160.0
const JUMP_VELOCITY: float = -380.0
const GRAVITY: float = 900.0
const ACCELERATION: float = 800.0
const FRICTION: float = 700.0
const AIR_RESISTANCE: float = 200.0

var is_on_ground: bool = false
var facing_right: bool = true
var current_tool: String = "hammer"

@onready var sprite: AnimatedSprite2D = $AnimatedSprite2D
@onready var collision: CollisionShape2D = $CollisionShape2D
@onready var headlamp: PointLight2D = $Headlamp
@onready var mining_system: Node2D = $MiningSystem
@onready var status_node: Node = $PlayerStatus


func _ready() -> void:
	add_to_group("player")
	_setup_sprite_frames()
	mining_system.connect("tile_mined", Callable(self, "_on_mining_tile_mined"))


func _on_mining_tile_mined(tile_pos: Vector2i, tile_id: int) -> void:
	tile_mined.emit(tile_pos, tile_id)


func _on_collectible_item_collected(item_type: String) -> void:
	item_collected.emit(item_type, 1)


func _setup_sprite_frames() -> void:
	const PLAYER_TEX: String = "res://assets/player/player_frames.png"
	if not ResourceLoader.exists(PLAYER_TEX):
		# Temporary placeholder until PixelLab sprites are generated
		var placeholder := PlaceholderTexture2D.new()
		placeholder.size = Vector2(24, 40)
		var sf_p := SpriteFrames.new()
		for anim_name in ["idle", "jump", "walk"]:
			sf_p.add_animation(anim_name)
			sf_p.set_animation_loop(anim_name, true)
			sf_p.add_frame(anim_name, placeholder, 1.0)
		sprite.sprite_frames = sf_p
		return
	var tex: Texture2D = load(PLAYER_TEX) as Texture2D
	if tex == null:
		push_error("Player: could not load %s" % PLAYER_TEX)
		return
	var sf := SpriteFrames.new()
	sf.add_animation("idle")
	sf.set_animation_loop("idle", true)
	var at_idle := AtlasTexture.new()
	at_idle.atlas = tex
	at_idle.region = Rect2(0, 0, 24, 40)
	sf.add_frame("idle", at_idle, 1.0)
	sf.add_animation("jump")
	sf.set_animation_loop("jump", true)
	var at_jump := AtlasTexture.new()
	at_jump.atlas = tex
	at_jump.region = Rect2(24, 0, 24, 40)
	sf.add_frame("jump", at_jump, 1.0)
	sf.add_animation("walk")
	sf.set_animation_loop("walk", true)
	for i in 4:
		var at := AtlasTexture.new()
		at.atlas = tex
		at.region = Rect2(i * 24, 0, 24, 40)
		sf.add_frame("walk", at, 1.0)
	sprite.sprite_frames = sf


func _physics_process(delta: float) -> void:
	_apply_gravity(delta)
	_handle_movement(delta)
	_handle_jump()
	move_and_slide()
	is_on_ground = is_on_floor()
	_update_animation()
	_update_headlamp()


func _handle_movement(delta: float) -> void:
	var direction: float = 0.0
	if Input.is_action_pressed("ui_left") or Input.is_key_pressed(KEY_A):
		direction = -1.0
	if Input.is_action_pressed("ui_right") or Input.is_key_pressed(KEY_D):
		direction = 1.0
	if direction != 0:
		facing_right = direction > 0
		sprite.flip_h = !facing_right
		if abs(velocity.x) < WALK_SPEED:
			velocity.x += direction * ACCELERATION * delta
			velocity.x = clamp(velocity.x, -WALK_SPEED, WALK_SPEED)
	else:
		var friction_amount: float = (FRICTION if is_on_ground else AIR_RESISTANCE) * delta
		velocity.x = move_toward(velocity.x, 0.0, friction_amount)


func _handle_jump() -> void:
	var jump: bool = Input.is_action_just_pressed("ui_accept") \
			or Input.is_key_just_pressed(KEY_W) \
			or Input.is_key_just_pressed(KEY_SPACE)
	if jump and is_on_ground:
		velocity.y = JUMP_VELOCITY


func _apply_gravity(delta: float) -> void:
	if not is_on_floor():
		velocity.y += GRAVITY * delta
	elif velocity.y > 0:
		velocity.y = 0.0


func _update_animation() -> void:
	if not is_on_ground:
		sprite.play("jump")
	elif abs(velocity.x) > 10.0:
		sprite.play("walk")
	else:
		sprite.play("idle")


func _update_headlamp() -> void:
	headlamp.position.x = 8.0 if facing_right else -8.0


func get_world_tile_pos() -> Vector2i:
	return Vector2i(
		int(floor(global_position.x / float(WorldData.TILE_SIZE))),
		int(floor(global_position.y / float(WorldData.TILE_SIZE)))
	)


func set_tool(tool_name: String) -> void:
	current_tool = tool_name
	mining_system.call("set_active_tool", tool_name)
