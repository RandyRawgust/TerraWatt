extends Node2D

const FLY_SPEED: float = 52.0
const FLUTTER_SPEED: float = 10.0

var _target_x: float = 0.0
var _flutter_phase: float = 0.0
var _anchor_y: float = 0.0


func _ready() -> void:
	add_to_group("creatures")
	_anchor_y = global_position.y
	_setup_bird_sprite_frames()
	_play_anim_if($AnimatedSprite2D, &"fly")
	_pick_target()


func _process(delta: float) -> void:
	var spr: AnimatedSprite2D = $AnimatedSprite2D
	var v: Rect2 = get_viewport().get_visible_rect()
	_flutter_phase += delta * FLUTTER_SPEED

	global_position.y = _anchor_y + sin(_flutter_phase) * 4.0
	global_position.x = move_toward(global_position.x, _target_x, FLY_SPEED * delta)

	spr.flip_h = global_position.x > _target_x
	if has_node("Silhouette"):
		$Silhouette.scale.x = -1.0 if spr.flip_h else 1.0
	if abs(global_position.x - _target_x) < 6.0:
		_play_anim_if(spr, &"perch")
		_pick_target()
	else:
		_play_anim_if(spr, &"fly")

	var cam: Camera2D = get_viewport().get_camera_2d()
	var world_left: float = v.position.x
	var world_right: float = v.end.x
	if cam:
		world_left = cam.get_screen_center_position().x - v.size.x * 0.55
		world_right = cam.get_screen_center_position().x + v.size.x * 0.55

	var gx: float = global_position.x
	if gx < world_left - 100.0 or gx > world_right + 100.0:
		_respawn_side(v, cam)


func _pick_target() -> void:
	var v: Rect2 = get_viewport().get_visible_rect()
	var cam: Camera2D = get_viewport().get_camera_2d()
	if cam:
		var cx: float = cam.get_screen_center_position().x
		_target_x = cx + randf_range(-v.size.x * 0.35, v.size.x * 0.35)
	else:
		_target_x = randf_range(v.position.x + 80.0, v.end.x - 80.0)


func _respawn_side(v: Rect2, cam: Camera2D) -> void:
	var nx: float
	if cam:
		var cx: float = cam.get_screen_center_position().x
		var spread: float = randf_range(v.size.x * 0.35, v.size.x * 0.48)
		nx = cx + spread if randf() > 0.5 else cx - spread
	else:
		nx = randf_range(v.position.x + 40.0, v.end.x - 40.0)
	global_position = Vector2(nx, _anchor_y + randf_range(-12.0, 12.0))
	_pick_target()


func _setup_bird_sprite_frames() -> void:
	const BIRD_TEX: String = "res://assets/creatures/bird_sheet.png"
	if not ResourceLoader.exists(BIRD_TEX):
		push_warning("bird.gd: sprite sheet missing, skipping setup")
		return
	var texture: Texture2D = load(BIRD_TEX) as Texture2D
	if texture == null:
		push_warning("bird.gd: could not load sprite sheet")
		return

	var fw: int = maxi(1, int(floor(texture.get_width() / 3.0)))
	var fh: int = maxi(1, mini(texture.get_height(), 10))

	var frames: SpriteFrames = SpriteFrames.new()
	var add_frames := func(anim_name: String, start: int, end: int, fps: float, loop: bool) -> void:
		frames.add_animation(anim_name)
		frames.set_animation_loop(anim_name, loop)
		frames.set_animation_speed(anim_name, fps)
		for i in range(start, end + 1):
			var atlas: AtlasTexture = AtlasTexture.new()
			atlas.atlas = texture
			atlas.region = Rect2(i * fw, 0, fw, fh)
			frames.add_frame(anim_name, atlas)

	add_frames.call("perch", 0, 0, 1.0, true)
	add_frames.call("fly", 1, 2, 8.0, true)

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
