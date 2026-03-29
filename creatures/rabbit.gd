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
	$AnimatedSprite2D.play("idle")
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
	if abs(velocity.x) > 8.0:
		spr.flip_h = velocity.x < 0
	if has_node("Silhouette"):
		$Silhouette.scale.x = -1.0 if spr.flip_h else 1.0

	move_and_slide()
