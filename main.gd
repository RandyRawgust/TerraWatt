# SYSTEM: Main
# AGENT: Integration Agent
# PURPOSE: Initializes all systems, wires connections, starts the game.

extends Node2D

const WORLD_SEED: int = 12345

@onready var world_renderer: Node2D = $WorldRenderer
@onready var background_layer: Node2D = $BackgroundLayer
@onready var lighting_manager: Node2D = $LightingManager
@onready var player: CharacterBody2D = $Player
@onready var game_camera: Camera2D = $GameCamera
@onready var hud: CanvasLayer = $HUD
@onready var creature_spawner: Node = $CreatureSpawner
@onready var sim_renderer: Node2D = $SimRenderer
@onready var day_night_cycle: Node = $DayNightCycle


func _ready() -> void:
	print("Terra.Watt: Initializing world (seed %d)..." % WORLD_SEED)
	_ensure_input_actions()

	WorldData.initialize(WORLD_SEED)

	var spawn: Vector2 = SpawnLocator.find_spawn_point(200)
	player.global_position = spawn
	print("Terra.Watt: Player spawned at %s" % spawn)

	if game_camera.has_method("set_target"):
		game_camera.call("set_target", player)
	game_camera.global_position = player.global_position

	if world_renderer.has_method("set_camera"):
		world_renderer.set_camera(game_camera)

	var player_light: PointLight2D = player.get_node_or_null("Headlamp") as PointLight2D
	if player_light:
		lighting_manager.set_player_light(player_light)

	# StatusIconBar connects to PlayerStatus in its _ready (deferred).

	creature_spawner.set_player(player)

	print("Terra.Watt: All systems initialized. Game running.")


func _process(delta: float) -> void:
	background_layer.update_parallax(game_camera.global_position)

	var nb: float = 0.0
	if day_night_cycle != null and day_night_cycle.has_method("get_night_blend"):
		nb = float(day_night_cycle.call("get_night_blend"))
	if lighting_manager.has_method("set_cycle_night_factor"):
		lighting_manager.set_cycle_night_factor(nb)
	if background_layer.has_method("set_cycle_night_factor"):
		background_layer.set_cycle_night_factor(nb)

	game_camera.global_position = game_camera.global_position.lerp(
		player.global_position, delta * 8.0
	)


func _ensure_input_actions() -> void:
	_add_mouse_button_action("mine", MOUSE_BUTTON_LEFT)
	_add_mouse_button_action("place", MOUSE_BUTTON_RIGHT)
	var keycodes: Array[int] = [
		KEY_1, KEY_2, KEY_3, KEY_4, KEY_5, KEY_6, KEY_7, KEY_8, KEY_9, KEY_0
	]
	for i in range(10):
		var action_name: String = "hotbar_%d" % (i + 1 if i < 9 else 0)
		if not InputMap.has_action(action_name):
			InputMap.add_action(action_name)
		if not _action_has_key(action_name, keycodes[i]):
			var ev := InputEventKey.new()
			ev.keycode = keycodes[i]
			InputMap.action_add_event(action_name, ev)


func _add_mouse_button_action(action_name: String, button: int) -> void:
	if not InputMap.has_action(action_name):
		InputMap.add_action(action_name)
	if not _action_has_mouse_button(action_name, button):
		var ev := InputEventMouseButton.new()
		ev.button_index = button
		InputMap.action_add_event(action_name, ev)


func _action_has_mouse_button(action_name: String, button: int) -> bool:
	for ev in InputMap.action_get_events(action_name):
		if ev is InputEventMouseButton and (ev as InputEventMouseButton).button_index == button:
			return true
	return false


func _action_has_key(action_name: String, keycode: int) -> bool:
	for ev in InputMap.action_get_events(action_name):
		if ev is InputEventKey and (ev as InputEventKey).keycode == keycode:
			return true
	return false
