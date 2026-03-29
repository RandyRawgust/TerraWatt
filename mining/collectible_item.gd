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
	apply_central_impulse(Vector2(randf_range(-30.0, 30.0), -80.0))
	$PickupArea.body_entered.connect(_on_pickup_area_body_entered)
	_apply_icon()


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
