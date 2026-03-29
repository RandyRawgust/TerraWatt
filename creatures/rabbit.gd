extends CharacterBody2D

const FLEE_DISTANCE: float = 120.0
const FLEE_SPEED: float = 140.0
const HOP_VELOCITY: float = -260.0
const GRAVITY: float = 900.0
const IDLE_WAIT_MIN: float = 2.0
const IDLE_WAIT_MAX: float = 4.0

var _idle_timer: float = 0.0


func _ready() -> void:
	add_to_group("creatures")
	var sprite: AnimatedSprite2D = $AnimatedSprite2D
	var sf: SpriteFrames = SpriteFrames.new()
	CreatureSpriteUtil.add_animation_frames(sf, "idle", 1, 12, 12, Color(0.62, 0.48, 0.36))
	CreatureSpriteUtil.add_animation_frames(sf, "hop", 2, 12, 12, Color(0.58, 0.44, 0.32), 0.06)
	sprite.sprite_frames = sf
	sprite.play("idle")
	_idle_timer = randf_range(IDLE_WAIT_MIN, IDLE_WAIT_MAX)


func _physics_process(delta: float) -> void:
	var player: Node2D = get_tree().get_first_node_in_group("player") as Node2D
	var flee: bool = player != null and global_position.distance_to(player.global_position) < FLEE_DISTANCE

	velocity.y += GRAVITY * delta

	if flee and player:
		var away: Vector2 = (global_position - player.global_position).normalized()
		velocity.x = away.x * FLEE_SPEED
	elif is_on_floor():
		velocity.x = move_toward(velocity.x, 0.0, 320.0 * delta)
		if _idle_timer > 0.0:
			_idle_timer -= delta
		else:
			velocity.y = HOP_VELOCITY
			_idle_timer = randf_range(IDLE_WAIT_MIN, IDLE_WAIT_MAX)

	var spr: AnimatedSprite2D = $AnimatedSprite2D
	if not is_on_floor():
		spr.play("hop")
	else:
		spr.play("idle")

	move_and_slide()
