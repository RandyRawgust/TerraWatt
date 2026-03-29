# SYSTEM: Structures / Conveyors
# AGENT: Conveyors Agent
# PURPOSE: Moves items in one direction. Player can walk on top.
# Tier 1: no crossing — single direction per placed segment.

extends StaticBody2D

class_name ConveyorBelt

enum Direction { LEFT, RIGHT, UP, DOWN }

@export var direction: Direction = Direction.RIGHT
@export var belt_speed: float = 64.0

var _riding_items: Array[Node2D] = []

@onready var belt_sprite: AnimatedSprite2D = $BeltSprite


func _ready() -> void:
	add_to_group("conveyors")
	_setup_belt_sprite_frames()


func _physics_process(delta: float) -> void:
	_move_riding_items(delta)
	_animate_belt()


func register_item(item: Node2D) -> void:
	if not _riding_items.has(item):
		_riding_items.append(item)


func unregister_item(item: Node2D) -> void:
	_riding_items.erase(item)


func _move_riding_items(delta: float) -> void:
	var move_vec: Vector2 = _direction_to_vector() * belt_speed * delta
	var stale: Array[Node2D] = []
	for item in _riding_items:
		if is_instance_valid(item):
			item.global_position += move_vec
		else:
			stale.append(item)
	for s in stale:
		_riding_items.erase(s)


func _direction_to_vector() -> Vector2:
	match direction:
		Direction.RIGHT:
			return Vector2.RIGHT
		Direction.LEFT:
			return Vector2.LEFT
		Direction.UP:
			return Vector2.UP
		Direction.DOWN:
			return Vector2.DOWN
	return Vector2.RIGHT


func _animate_belt() -> void:
	belt_sprite.speed_scale = belt_speed / 64.0
	if belt_sprite.sprite_frames and belt_sprite.sprite_frames.has_animation("move"):
		if not belt_sprite.is_playing():
			belt_sprite.play("move")


func get_push_vector() -> Vector2:
	return _direction_to_vector() * 20.0


func _setup_belt_sprite_frames() -> void:
	const SHEET: String = "res://assets/structures/conveyor_belt_sheet.png"
	if ResourceLoader.exists(SHEET):
		_build_frames_from_sheet(load(SHEET) as Texture2D)
	else:
		_build_procedural_frames()


func _build_frames_from_sheet(tex: Texture2D) -> void:
	var sf := SpriteFrames.new()
	sf.add_animation("move")
	sf.set_animation_loop("move", true)
	sf.set_animation_speed("move", 8.0)
	for i in 4:
		var at := AtlasTexture.new()
		at.atlas = tex
		at.region = Rect2(i * 16, 0, 16, 8)
		sf.add_frame("move", at, 1.0)
	belt_sprite.sprite_frames = sf
	if belt_sprite.sprite_frames.has_animation("move"):
		belt_sprite.play("move")


func _build_procedural_frames() -> void:
	var rubber := Color(0.165, 0.165, 0.165)
	var chev := Color(0.29, 0.29, 0.29)
	var rail := Color(0.533, 0.6, 0.667, 1.0)
	var sf := SpriteFrames.new()
	sf.add_animation("move")
	sf.set_animation_loop("move", true)
	sf.set_animation_speed("move", 8.0)
	for f in 4:
		var img := Image.create(16, 8, false, Image.FORMAT_RGBA8)
		img.fill(Color(0, 0, 0, 0))
		for y in 8:
			for x in 16:
				var c: Color = rubber
				if y <= 0 or y >= 7:
					c = rail
				else:
					var cx: int = (x + f * 4) % 8
					if cx in [2, 3, 4]:
						c = chev
				img.set_pixel(x, y, c)
		var itex := ImageTexture.create_from_image(img)
		sf.add_frame("move", itex, 1.0)
	belt_sprite.sprite_frames = sf
	if belt_sprite.sprite_frames.has_animation("move"):
		belt_sprite.play("move")
