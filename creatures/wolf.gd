# res://creatures/wolf.gd
extends CharacterBody2D

const MOVE_SPEED: float = 80.0
const DETECT_RANGE: float = 200.0
const ATTACK_RANGE: float = 24.0
const ATTACK_DAMAGE: float = 10.0
const ATTACK_COOLDOWN: float = 1.5

var _target: Node2D = null
var _attack_timer: float = 0.0


func _ready() -> void:
	add_to_group("creatures")
	add_to_group("hostile_creatures")
	$AnimatedSprite2D.play("idle")


func _physics_process(delta: float) -> void:
	_seek_target()
	_attack_cooldown_tick(delta)
	if _target:
		_move_toward_target(delta)
	else:
		velocity = velocity.move_toward(Vector2.ZERO, 400.0 * delta)
		velocity.y += 900.0 * delta
		move_and_slide()
	var spr: AnimatedSprite2D = $AnimatedSprite2D
	if _target and global_position.distance_to(_target.global_position) > ATTACK_RANGE:
		spr.play("walk")
	elif _target:
		spr.play("attack")
	else:
		spr.play("idle")
	if _target:
		spr.flip_h = _target.global_position.x < global_position.x


func _seek_target() -> void:
	var player: Node2D = get_tree().get_first_node_in_group("player") as Node2D
	if player and global_position.distance_to(player.global_position) < DETECT_RANGE:
		_target = player
	else:
		_target = null


func _move_toward_target(delta: float) -> void:
	if not _target:
		return
	var dir: Vector2 = (_target.global_position - global_position).normalized()
	if global_position.distance_to(_target.global_position) > ATTACK_RANGE:
		velocity.x = dir.x * MOVE_SPEED
		velocity.y += 900.0 * delta # gravity
	else:
		velocity.x = 0.0
		_try_attack()
	move_and_slide()


func _try_attack() -> void:
	if _attack_timer <= 0.0:
		if _target and _target.has_method("take_damage"):
			_target.call("take_damage", ATTACK_DAMAGE)
		_attack_timer = ATTACK_COOLDOWN


func _attack_cooldown_tick(delta: float) -> void:
	if _attack_timer > 0.0:
		_attack_timer -= delta
