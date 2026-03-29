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
	_setup_wolf_sprite_frames()
	_play_anim_if($AnimatedSprite2D, &"idle")


func _physics_process(delta: float) -> void:
	_seek_target()
	_attack_cooldown_tick(delta)
	if not is_on_floor():
		velocity.y += 900.0 * delta
	if _target:
		_move_toward_target(delta)
	else:
		velocity.x = move_toward(velocity.x, 0.0, 400.0 * delta)
	move_and_slide()
	var spr: AnimatedSprite2D = $AnimatedSprite2D
	if _target and global_position.distance_to(_target.global_position) > ATTACK_RANGE:
		_play_anim_if(spr, &"walk")
	elif _target:
		_play_anim_if(spr, &"attack")
	else:
		_play_anim_if(spr, &"idle")
	if _target:
		spr.flip_h = _target.global_position.x < global_position.x
	if has_node("Silhouette"):
		$Silhouette.scale.x = -1.0 if spr.flip_h else 1.0


func _seek_target() -> void:
	var player: Node2D = get_tree().get_first_node_in_group("player") as Node2D
	if player and global_position.distance_to(player.global_position) < DETECT_RANGE:
		_target = player
	else:
		_target = null


func _move_toward_target(_delta: float) -> void:
	if not _target:
		return
	var dir: Vector2 = (_target.global_position - global_position).normalized()
	if global_position.distance_to(_target.global_position) > ATTACK_RANGE:
		velocity.x = dir.x * MOVE_SPEED
	else:
		velocity.x = 0.0
		_try_attack()


func _try_attack() -> void:
	if _attack_timer <= 0.0:
		if _target and _target.has_method("take_damage"):
			_target.call("take_damage", ATTACK_DAMAGE)
		_attack_timer = ATTACK_COOLDOWN


func _attack_cooldown_tick(delta: float) -> void:
	if _attack_timer > 0.0:
		_attack_timer -= delta


func _setup_wolf_sprite_frames() -> void:
	const WOLF_TEX: String = "res://assets/creatures/wolf_sheet.png"
	if not ResourceLoader.exists(WOLF_TEX):
		push_warning("wolf.gd: sprite sheet missing, skipping setup")
		return
	var texture: Texture2D = load(WOLF_TEX) as Texture2D
	if texture == null:
		push_warning("wolf.gd: could not load sprite sheet")
		return

	var frames: SpriteFrames = SpriteFrames.new()
	var _add: Callable = func(anim_name: String, start: int, end: int, fps: float, loop: bool) -> void:
		frames.add_animation(anim_name)
		frames.set_animation_loop(anim_name, loop)
		frames.set_animation_speed(anim_name, fps)
		for i in range(start, end + 1):
			var atlas: AtlasTexture = AtlasTexture.new()
			atlas.atlas = texture
			atlas.region = Rect2(i * 32, 0, 32, 20)
			frames.add_frame(anim_name, atlas)

	_add.call("idle", 0, 0, 1.0, true)
	_add.call("walk", 1, 4, 8.0, true)
	_add.call("attack", 5, 5, 4.0, true)

	var spr: AnimatedSprite2D = $AnimatedSprite2D
	spr.sprite_frames = frames
	spr.texture_filter = CanvasItem.TEXTURE_FILTER_NEAREST
	spr.visible = true
	var silhouette: CanvasItem = get_node_or_null("Silhouette") as CanvasItem
	if silhouette:
		silhouette.visible = false


func _play_anim_if(spr: AnimatedSprite2D, anim_name: StringName) -> void:
	if spr != null and spr.sprite_frames != null and spr.sprite_frames.has_animation(anim_name):
		spr.play(anim_name)
