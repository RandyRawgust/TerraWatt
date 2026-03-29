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

const ConveyorBeltScene: PackedScene = preload("res://structures/conveyor_belt.tscn")
# Matches ConveyorBelt.Direction: LEFT=0, RIGHT=1, UP=2, DOWN=3
var _pending_belt_direction: int = 1

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
	const PLAYER_TEX: String = "res://assets/player/player_sheet.png"
	if not ResourceLoader.exists(PLAYER_TEX):
		var placeholder := PlaceholderTexture2D.new()
		placeholder.size = Vector2(24, 40)
		var sf_p := SpriteFrames.new()
		for anim_name in ["idle", "jump", "walk"]:
			sf_p.add_animation(anim_name)
			sf_p.set_animation_loop(anim_name, true)
			sf_p.add_frame(anim_name, placeholder, 1.0)
		sprite.sprite_frames = sf_p
		return
	var texture: Texture2D = load(PLAYER_TEX) as Texture2D
	if texture == null:
		push_error("Player: could not load %s" % PLAYER_TEX)
		return

	var frames: SpriteFrames = SpriteFrames.new()
	var _add: Callable = func(anim_name: String, start: int, end: int, fps: float, loop: bool) -> void:
		frames.add_animation(anim_name)
		frames.set_animation_loop(anim_name, loop)
		frames.set_animation_speed(anim_name, fps)
		for i in range(start, end + 1):
			var atlas: AtlasTexture = AtlasTexture.new()
			atlas.atlas = texture
			atlas.region = Rect2(i * 24, 0, 24, 40)
			frames.add_frame(anim_name, atlas)

	_add.call("idle", 0, 0, 1.0, true)
	_add.call("walk", 1, 4, 8.0, true)
	_add.call("jump", 5, 5, 1.0, false)

	sprite.sprite_frames = frames
	sprite.texture_filter = CanvasItem.TEXTURE_FILTER_NEAREST
	if sprite.sprite_frames.has_animation("idle"):
		sprite.play("idle")


func _physics_process(delta: float) -> void:
	_apply_gravity(delta)
	_handle_belt_placement_input()
	_handle_movement(delta)
	_apply_conveyor_push(delta)
	_handle_jump()
	move_and_slide()
	is_on_ground = is_on_floor()
	_update_animation()
	_update_headlamp()


func _unhandled_input(event: InputEvent) -> void:
	if _get_selected_hotbar_item() != "conveyor_belt":
		return
	if event is InputEventMouseButton and event.pressed:
		var mb := event as InputEventMouseButton
		if mb.button_index == MOUSE_BUTTON_WHEEL_UP:
			_pending_belt_direction = (_pending_belt_direction + 3) % 4
		elif mb.button_index == MOUSE_BUTTON_WHEEL_DOWN:
			_pending_belt_direction = (_pending_belt_direction + 1) % 4


func _get_selected_hotbar_item() -> String:
	var hb: Node = get_tree().get_first_node_in_group("hotbar")
	if hb and hb.has_method("get_selected_item_name"):
		return hb.call("get_selected_item_name") as String
	return ""


func _handle_belt_placement_input() -> void:
	if Input.is_action_just_pressed("rotate_structure"):
		_pending_belt_direction = (_pending_belt_direction + 1) % 4
	if not Input.is_action_just_pressed("place"):
		return
	var selected: String = _get_selected_hotbar_item()
	if selected == "power_pole" and Inventory.has_item("power_pole", 1):
		var ppos: Vector2 = get_global_mouse_position()
		var tile_pos: Vector2i = Vector2i(
			int(floor(ppos.x / float(WorldData.TILE_SIZE))),
			int(floor(ppos.y / float(WorldData.TILE_SIZE)))
		)
		if WorldData.get_tile(tile_pos.x, tile_pos.y + 1) == WorldData.TILE_AIR:
			return
		var pole: Node2D = _place_structure_at(
			"res://power/tier1/power_pole.tscn",
			ppos.snapped(Vector2(16, 16))
		)
		if pole != null:
			Inventory.remove_item("power_pole", 1)
		return
	if selected != "conveyor_belt" or not Inventory.has_item("conveyor_belt", 1):
		return
	var place_pos: Vector2 = get_global_mouse_position().snapped(Vector2(16, 16))
	for belt in get_tree().get_nodes_in_group("conveyors"):
		if belt is Node2D and (belt as Node2D).global_position.distance_to(place_pos) < 8.0:
			print("Cannot place: conveyors cannot cross until Tier 2.")
			return
	var placed: Node2D = _place_structure_at(ConveyorBeltScene.resource_path, place_pos)
	if placed == null:
		return
	placed.set("direction", _pending_belt_direction)
	if Inventory.remove_item("conveyor_belt", 1):
		pass


func _place_structure_at(scene_path: String, world_pos: Vector2) -> Node2D:
	if not ResourceLoader.exists(scene_path):
		push_warning("Player: missing scene %s" % scene_path)
		return null
	var scene: PackedScene = load(scene_path) as PackedScene
	var node: Node2D = scene.instantiate() as Node2D
	if node == null:
		return null
	node.global_position = world_pos
	get_tree().current_scene.add_child(node)
	return node


func _apply_conveyor_push(delta: float) -> void:
	for belt in get_tree().get_nodes_in_group("conveyors"):
		if not belt.has_method("get_push_vector"):
			continue
		var belt2d: Node2D = belt as Node2D
		if belt2d == null:
			continue
		if global_position.distance_to(belt2d.global_position) < 14.0:
			var push: Vector2 = belt.call("get_push_vector") as Vector2
			velocity += push * delta
			return


func _handle_movement(delta: float) -> void:
	var direction: float = Input.get_axis("ui_left", "ui_right")
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
	if Input.is_action_just_pressed("ui_accept") and is_on_floor():
		velocity.y = JUMP_VELOCITY


func _apply_gravity(delta: float) -> void:
	if not is_on_floor():
		velocity.y += GRAVITY * delta
	elif velocity.y > 0:
		velocity.y = 0.0


func _update_animation() -> void:
	if sprite.sprite_frames == null:
		return
	if not is_on_ground:
		if sprite.sprite_frames.has_animation("jump"):
			sprite.play("jump")
	elif abs(velocity.x) > 10.0:
		if sprite.sprite_frames.has_animation("walk"):
			sprite.play("walk")
	else:
		if sprite.sprite_frames.has_animation("idle"):
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
