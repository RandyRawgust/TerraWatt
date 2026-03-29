# SYSTEM: Mining
# AGENT: Player Agent
# PURPOSE: Dropped resource pickup; adds to Inventory when player touches Area2D.

extends Area2D

class_name CollectibleItem

signal item_collected(item_type: String)

@export var item_type: String = "dirt"
var source_tile_id: int = -1

var _base_y: float = 0.0
var _time: float = 0.0

@onready var _sprite: Sprite2D = $Sprite2D


func _ready() -> void:
	_base_y = global_position.y
	body_entered.connect(_on_body_entered)
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


func _process(delta: float) -> void:
	_time += delta
	global_position.y = _base_y + sin(_time * 3.0) * 3.0


func _on_body_entered(body: Node2D) -> void:
	if body is CharacterBody2D and body.is_in_group("player"):
		Inventory.add_item(item_type, 1)
		item_collected.emit(item_type)
		queue_free()
