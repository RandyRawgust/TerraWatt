# SYSTEM: Mining
# AGENT: Player Agent
# PURPOSE: Dropped resource pickup; physics body + Area2D trigger for collection.

extends RigidBody2D

class_name CollectibleItem

signal item_collected(item_type: String)

@export var item_type: String = "dirt"
var source_tile_id: int = -1

@onready var _sprite: Sprite2D = $Sprite2D


func _ready() -> void:
	sleeping = false
	can_sleep = false
	apply_central_impulse(Vector2(randf_range(-30.0, 30.0), -80.0))
	$PickupArea.body_entered.connect(_on_pickup_area_body_entered)
	_apply_icon()


func _physics_process(_delta: float) -> void:
	sleeping = false
	var on_belt: Node2D = null
	for belt in get_tree().get_nodes_in_group("conveyors"):
		if belt is Node2D:
			var dist: float = global_position.distance_to((belt as Node2D).global_position)
			if dist < 12.0:
				on_belt = belt as Node2D
				break
	for belt in get_tree().get_nodes_in_group("conveyors"):
		if belt.has_method("register_item") and belt.has_method("unregister_item"):
			if on_belt != null and belt == on_belt:
				belt.register_item(self)
			else:
				belt.unregister_item(self)


func _apply_icon() -> void:
	var path: String = "res://assets/tiles/ores/%s_icon.png" % item_type
	if ResourceLoader.exists(path):
		_sprite.texture = load(path) as Texture2D
	else:
		var fb: String = "res://assets/tiles/ores/dirt_icon.png"
		if ResourceLoader.exists(fb):
			_sprite.texture = load(fb) as Texture2D
	if source_tile_id >= 0:
		_sprite.self_modulate = MaterialRegistry.get_color(source_tile_id)


func _on_pickup_area_body_entered(body: Node2D) -> void:
	if body.is_in_group("player"):
		Inventory.add_item(item_type, 1)
		item_collected.emit(item_type)
		queue_free()
