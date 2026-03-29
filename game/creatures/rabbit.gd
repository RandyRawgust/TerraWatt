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
	_setup_rabbit_sprite_frames()
	_play_anim_if($AnimatedSprite2D, &"idle")
	_idle_timer = randf_range(IDLE_WAIT_MIN, IDLE_WAIT_MAX)


func _physics_process(delta: float) -> void:
	var player: Node2D = get_tree().get_first_node_in_group("player") as Node2D
	var flee: bool = player != null and global_position.distance_to(player.global_position) < FLEE_DISTANCE

	if not is_on_floor():
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
		_play_anim_if(spr, &"hop")
	elif flee and abs(velocity.x) > 8.0:
		_play_anim_if(spr, &"flee")
	else:
		_play_anim_if(spr, &"idle")
	if abs(velocity.x) > 8.0:
		spr.flip_h = velocity.x < 0
	if has_node("Silhouette"):
		$Silhouette.scale.x = -1.0 if spr.flip_h else 1.0

	move_and_slide()


func _setup_rabbit_sprite_frames() -> void:
	const RABBIT_TEX: String = "res://assets/creatures/rabbit_sheet.png"
	if not ResourceLoader.exists(RABBIT_TEX):
		push_warning("rabbit.gd: sprite sheet missing, skipping setup")
		return
	var texture: Texture2D = load(RABBIT_TEX) as Texture2D
	if texture == null:
		push_warning("rabbit.gd: could not load sprite sheet")
		return

	var frames: SpriteFrames = SpriteFrames.new()
	var add_rects := func(anim_name: String, rects: Array[Rect2], fps: float, loop: bool) -> void:
		frames.add_animation(anim_name)
		frames.set_animation_loop(anim_name, loop)
		frames.set_animation_speed(anim_name, fps)
		for r in rects:
			var atlas: AtlasTexture = AtlasTexture.new()
			atlas.atlas = texture
			atlas.region = r
			frames.add_frame(anim_name, atlas)

	# Contract: 36×12 strip, 12×12 frames — idle(1), hop(2) @ 6fps
	add_rects.call("idle", [Rect2(0, 0, 12, 12)], 1.0, true)
	add_rects.call("hop", [Rect2(12, 0, 12, 12), Rect2(24, 0, 12, 12)], 6.0, true)
	add_rects.call("flee", [Rect2(12, 0, 12, 12), Rect2(24, 0, 12, 12)], 12.0, true)

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
