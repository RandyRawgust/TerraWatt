# SYSTEM: Pixel Simulation
# AGENT: Pixel Sim Agent
# PURPOSE: Renders sim-space cells as a texture using MaterialRegistry colors.

extends Node2D

@export var sim_manager_path: NodePath = NodePath("/root/SimManager")

var _sim: Node = null
var _image: Image
var _tex: ImageTexture

func _ready() -> void:
	_sim = get_node_or_null(sim_manager_path)
	if _sim == null:
		push_error("SimRenderer: SimManager not found.")
		return
	call_deferred("_rebuild_texture")

func _rebuild_texture() -> void:
	if _sim == null:
		return
	var w: int = _sim.get_sim_width()
	var h: int = _sim.get_sim_height()
	if w <= 0 or h <= 0:
		return
	_image = Image.create(w, h, false, Image.FORMAT_RGBA8)
	_tex = ImageTexture.create_from_image(_image)
	queue_redraw()

func _physics_process(_delta: float) -> void:
	if _sim == null:
		return
	var w: int = _sim.get_sim_width()
	var h: int = _sim.get_sim_height()
	if w <= 0 or h <= 0:
		return
	if _image == null or _image.get_width() != w or _image.get_height() != h:
		_rebuild_texture()
		if _image == null:
			return
	for y in h:
		for x in w:
			var mid: int = int(_sim.get_cell(x, y).get("material_id", 0))
			var c: Color = MaterialRegistry.get_color(mid)
			_image.set_pixel(x, y, c)
	_tex.update(_image)
	queue_redraw()

func _draw() -> void:
	if _tex == null:
		return
	draw_texture(_tex, Vector2.ZERO)
