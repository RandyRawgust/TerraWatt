TERRAWATT — PLAYER AGENT
Single command: Paste this entire block into a Cursor Composer Agent tab and press Enter.
Run SIMULTANEOUSLY with Pixel Sim, World Gen, Visual, UI, and Power agents after Foundation Agent completes.

━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

## MISSION: Build the player character — movement, mining, status tracking, and tool system.

You are the PLAYER AGENT. The player is an industrial miner in the 1800s.
They should feel weighty but responsive — think Starbound movement, not Mario.
You own: player.tscn, player.gd, mining_system.gd, collectible_item, player_status.gd, tools.

---

## PHASE 0: READ YOUR DOCTRINE (MANDATORY FIRST STEP)

1. Read `TERRAWATT_DOCTRINE.md` — your operating rules.
2. Read `TERRAWATT_GDD.md` — Section 9 (Tools), and the player character description in Section 0.
3. Read `AGENT_STATUS.md` — confirm Foundation Agent is COMPLETE.
4. Read `res://simulation/material_registry.gd` — for tile IDs and mining times.
5. Read `res://world/world_data.gd` stub — you'll call WorldData.set_tile() when mining.

If WorldData is still a stub (Foundation Agent's version), that is fine.
Use the stub. It will be replaced by World Gen Agent and your calls will still work.

While waiting for Foundation Agent (if needed): write all player code, test with placeholder world.

---

## PHASE 1: PLAYER MOVEMENT (player.gd + player.tscn)

### res://player/player.gd

```gdscript
# SYSTEM: Player
# AGENT: Player Agent
# PURPOSE: Player movement, physics, collision, input, status tracking.

extends CharacterBody2D

class_name Player

# Movement constants — tuned for Starbound feel (slightly floaty, responsive)
const WALK_SPEED:      float = 160.0   # pixels per second
const JUMP_VELOCITY:   float = -380.0  # negative = upward in Godot
const GRAVITY:         float = 900.0   # pixels per second squared
const ACCELERATION:    float = 800.0   # how fast we reach walk speed
const FRICTION:        float = 700.0   # how fast we slow down on ground
const AIR_RESISTANCE:  float = 200.0   # slower deceleration in air

# State
var is_on_ground: bool = false
var facing_right: bool = true
var current_tool: String = "hammer"    # equip name from hotbar

# References
@onready var sprite:        AnimatedSprite2D = $AnimatedSprite2D
@onready var collision:     CollisionShape2D = $CollisionShape2D
@onready var headlamp:      PointLight2D     = $Headlamp
@onready var mining_system: Node2D           = $MiningSystem
@onready var status_node:   Node             = $PlayerStatus

func _ready() -> void:
    add_to_group("player")

func _physics_process(delta: float) -> void:
    _apply_gravity(delta)
    _handle_movement(delta)
    _handle_jump()
    move_and_slide()
    is_on_ground = is_on_floor()
    _update_animation()
    _update_headlamp()

func _handle_movement(delta: float) -> void:
    var direction: float = Input.get_axis("ui_left", "ui_right")
    if direction != 0:
        facing_right = direction > 0
        sprite.flip_h = !facing_right
        if abs(velocity.x) < WALK_SPEED:
            velocity.x += direction * ACCELERATION * delta
            velocity.x = clamp(velocity.x, -WALK_SPEED, WALK_SPEED)
    else:
        # Apply friction
        var friction_amount: float = (FRICTION if is_on_ground else AIR_RESISTANCE) * delta
        velocity.x = move_toward(velocity.x, 0.0, friction_amount)

func _handle_jump() -> void:
    if Input.is_action_just_pressed("ui_accept") and is_on_ground:
        velocity.y = JUMP_VELOCITY

func _apply_gravity(delta: float) -> void:
    if not is_on_floor():
        velocity.y += GRAVITY * delta
    elif velocity.y > 0:
        velocity.y = 0.0

func _update_animation() -> void:
    if not is_on_ground:
        sprite.play("jump")
    elif abs(velocity.x) > 10:
        sprite.play("walk")
    else:
        sprite.play("idle")

func _update_headlamp() -> void:
    # Headlamp follows facing direction
    headlamp.position.x = 8.0 if facing_right else -8.0

func get_world_tile_pos() -> Vector2i:
    return Vector2i(
        int(global_position.x / 16),
        int(global_position.y / 16)
    )

func set_tool(tool_name: String) -> void:
    current_tool = tool_name
    mining_system.set_active_tool(tool_name)
```

### player.tscn scene structure:
```
CharacterBody2D (root, script: player.gd, collision layer 1, mask 1)
  ├── AnimatedSprite2D (name: AnimatedSprite2D)
  │     Animations: idle (1 frame), walk (4 frames), jump (1 frame)
  │     Sprite frames: res://assets/player/player_spriteframes.tres
  ├── CollisionShape2D (name: collision)
  │     Shape: CapsuleShape2D, 10px wide × 30px tall
  ├── PointLight2D (name: Headlamp)
  │     Energy: 1.0, Range: 120px, soft glow yellow-white color
  │     Texture: res://assets/ui/light_radial.png
  ├── Node2D (name: MiningSystem, script: mining_system.gd)
  └── Node (name: PlayerStatus, script: player_status.gd)
```

---

## PHASE 2: MINING SYSTEM

### res://mining/mining_system.gd

```gdscript
# SYSTEM: Mining
# AGENT: Player Agent
# PURPOSE: Handles tile mining on click, progress tracking, item spawning.

extends Node2D

class_name MiningSystem

const MAX_MINE_DISTANCE: int = 4    # tiles from player center
const MINE_TIME_DEFAULT: float = 1.0

var _active_tool: String = "hammer"
var _mining_tile: Vector2i = Vector2i(-9999, -9999)
var _mine_progress: float = 0.0
var _mine_duration: float = 0.0
var _is_mining: bool = false

@onready var _player: CharacterBody2D = get_parent()
@onready var _progress_indicator: Node2D = $MineProgressIndicator

func _ready() -> void:
    pass

func set_active_tool(tool_name: String) -> void:
    _active_tool = tool_name

func _process(delta: float) -> void:
    _handle_mining_input(delta)

func _handle_mining_input(delta: float) -> void:
    if Input.is_mouse_button_pressed(MOUSE_BUTTON_LEFT):
        var mouse_tile: Vector2i = _get_mouse_tile_pos()
        if _is_tile_in_range(mouse_tile) and _is_solid_tile(mouse_tile):
            if mouse_tile != _mining_tile:
                _start_mining(mouse_tile)
            else:
                _continue_mining(delta)
        else:
            _cancel_mining()
    else:
        _cancel_mining()

func _get_mouse_tile_pos() -> Vector2i:
    var mouse_world_pos: Vector2 = get_viewport().get_canvas_transform().affine_inverse() * get_viewport().get_mouse_position()
    return Vector2i(int(mouse_world_pos.x / 16), int(mouse_world_pos.y / 16))

func _is_tile_in_range(tile_pos: Vector2i) -> bool:
    var player_tile: Vector2i = _player.get_world_tile_pos()
    var dist: float = Vector2(tile_pos - player_tile).length()
    return dist <= MAX_MINE_DISTANCE

func _is_solid_tile(tile_pos: Vector2i) -> bool:
    var tile_id: int = WorldData.get_tile(tile_pos.x, tile_pos.y)
    return tile_id != WorldData.TILE_AIR

func _start_mining(tile_pos: Vector2i) -> void:
    _mining_tile = tile_pos
    _mine_progress = 0.0
    var tile_id: int = WorldData.get_tile(tile_pos.x, tile_pos.y)
    var mat: Dictionary = MaterialRegistry.get_material(tile_id)
    _mine_duration = mat.get("mine_time", MINE_TIME_DEFAULT)
    _mine_duration = _apply_tool_bonus(_mine_duration)
    _is_mining = true
    _progress_indicator.visible = true
    _progress_indicator.global_position = Vector2(tile_pos) * 16 + Vector2(8, 8)

func _continue_mining(delta: float) -> void:
    _mine_progress += delta
    _progress_indicator.set_progress(_mine_progress / _mine_duration)
    if _mine_progress >= _mine_duration:
        _complete_mining()

func _complete_mining() -> void:
    var tile_id: int = WorldData.get_tile(_mining_tile.x, _mining_tile.y)
    var item_type: String = MaterialRegistry.get_display_name(tile_id).to_lower().replace(" ", "_")
    WorldData.set_tile(_mining_tile.x, _mining_tile.y, WorldData.TILE_AIR)
    # Spawn collectible item at mined position
    _spawn_collectible(_mining_tile, item_type)
    tile_mined.emit(_mining_tile, tile_id)
    _cancel_mining()

func _apply_tool_bonus(base_time: float) -> float:
    match _active_tool:
        "stone_pickaxe": return base_time * 0.75
        "iron_pickaxe":  return base_time * 0.5
        _:               return base_time  # hammer = no bonus

func _spawn_collectible(tile_pos: Vector2i, item_type: String) -> void:
    var collectible_scene: PackedScene = preload("res://mining/collectible_item.tscn")
    var item: Node2D = collectible_scene.instantiate()
    item.item_type = item_type
    item.global_position = Vector2(tile_pos) * 16 + Vector2(8, 8)
    get_tree().current_scene.add_child(item)

func _cancel_mining() -> void:
    _is_mining = false
    _mine_progress = 0.0
    _mining_tile = Vector2i(-9999, -9999)
    _progress_indicator.visible = false

signal tile_mined(tile_pos: Vector2i, tile_id: int)
```

Create `res://mining/collectible_item.gd` and `.tscn`:
- Small sprite (same art as the tile, scaled to 10×10)
- Bobs up and down with a sine wave animation
- Area2D with collision circle (radius 20px) for player pickup
- When player enters area: calls `Inventory.add_item(item_type, 1)`, emits `collected`, queues_free()
- item_type: String property set when spawned
- Signal: `item_collected(item_type: String)`

Create `res://mining/mine_progress_indicator.gd`:
- Node2D that draws a circular arc progress bar around the tile being mined
- Uses `_draw()` with `draw_arc()`
- Arc goes from 0 to TAU based on progress (0.0-1.0)
- Green color, 2px thick, 12px radius
- set_progress(value: float) function

---

## PHASE 3: PLAYER STATUS SYSTEM

### res://player/player_status.gd

```gdscript
# SYSTEM: Player Status
# AGENT: Player Agent
# PURPOSE: Tracks player status conditions (wet, on fire, suffocating).
# Emits signals for the UI to display status icons above the player.

extends Node

class_name PlayerStatus

# Status flags
var is_wet:         bool = false
var is_on_fire:     bool = false
var is_suffocating: bool = false

# Air meter (1.0 = full air, 0.0 = no air → death)
var air_level: float = 1.0
const AIR_DRAIN_RATE:   float = 0.1   # per second when suffocating
const AIR_REFILL_RATE:  float = 0.3   # per second when in fresh air

# Health
var health: float = 100.0
const MAX_HEALTH: float = 100.0
const FIRE_DAMAGE_RATE:  float = 10.0  # HP per second on fire
const SUFFOC_THRESHOLD:  float = 0.0   # air level that triggers damage

@onready var player: CharacterBody2D = get_parent()

func _physics_process(delta: float) -> void:
    _check_environment()
    _apply_status_effects(delta)
    _update_air(delta)

func _check_environment() -> void:
    var player_tile: Vector2i = player.get_world_tile_pos()
    # Check the simulation cell at player position for status conditions
    var cell: Dictionary = SimManager.get_cell(player_tile.x, player_tile.y)
    var mat_id: int = cell.get("material_id", 0)
    # Water check
    is_wet = (mat_id == MaterialRegistry.MAT_WATER)
    # Fire check
    is_on_fire = (mat_id == MaterialRegistry.MAT_FIRE)
    # Suffocating: in smoke or enclosed gas pocket (no air nearby)
    is_suffocating = (mat_id == MaterialRegistry.MAT_SMOKE)
    # Emit current status for UI
    status_changed.emit(is_wet, is_on_fire, is_suffocating, air_level, health)

func _apply_status_effects(delta: float) -> void:
    if is_on_fire:
        health -= FIRE_DAMAGE_RATE * delta
        health = max(health, 0.0)
    if air_level <= 0.0:
        health -= 5.0 * delta  # suffocation damage

func _update_air(delta: float) -> void:
    if is_suffocating:
        air_level -= AIR_DRAIN_RATE * delta
        air_level = max(air_level, 0.0)
    else:
        air_level = min(air_level + AIR_REFILL_RATE * delta, 1.0)

signal status_changed(wet: bool, on_fire: bool, suffocating: bool, air: float, health: float)
```

---

## PHASE 4: USE PIXELLAB MCP FOR PLAYER ART

Generate these assets using PixelLab MCP in Cursor:

```
Generate pixel art sprite sheet for Terra.Watt player character:
  - Size: 24×40 pixels per frame
  - Character: industrial miner, brown hardhat with headlamp gem,
    yellow safety vest over grey armored chest, brown leather work pants,
    heavy brown boots, backpack visible on back
  - Animations needed:
      idle:  1 frame — standing neutral
      walk:  4 frames — walking cycle (left foot, both feet, right foot, both feet)
      jump:  1 frame — legs bent, arms out
  - Style: chunky pixel art, Starbound-inspired, warm earthy palette
  - Background: transparent
Save to: res://assets/player/player_frames.png
Also create: res://assets/player/player_spriteframes.tres (Godot SpriteFrames resource)
```

```
Generate pixel art for collectible item drop:
  - Sizes: 8×8 pixel icons for each: dirt, stone, coal, copper ore, iron ore, clay
  - Style: small glowing gem-like versions of each material
  - Background: transparent
Save each to: res://assets/tiles/ores/[name]_icon.png
```

---

## PHASE 5: TEST AND VERIFY

Test scenario:
1. Place player in world at spawn point
2. Walk left/right — verify smooth movement with Starbound feel
3. Jump — verify arc feels slightly floaty
4. Click a dirt tile nearby — verify mining progress shows, tile disappears
5. Collectible appears and bobs — verify it auto-collects when player walks near it
6. Check Inventory.items has the collected dirt
7. Walk into a water simulation cell — verify is_wet becomes true
8. Verify no errors in Godot output

Use Claude Code for any errors:
```bash
claude "Player physics bug: [describe]. player.gd line [N]: [paste code]. Fix."
```

---

## FINAL REPORT FORMAT

```
PLAYER AGENT — FINAL REPORT

✅ player.gd: movement, jump, gravity — Starbound feel achieved
✅ player.tscn: scene with sprite, collision, headlamp, subsystems
✅ mining_system.gd: click to mine, progress indicator, tile removal
✅ collectible_item.tscn: bobbing drop, auto-collect, Inventory.add_item()
✅ player_status.gd: wet/fire/suffocating tracking, air meter, health drain
✅ Player art generated via PixelLab MCP
✅ All commits pushed: [latest commit hash]
✅ AGENT_STATUS.md updated

Self-Audit Complete. Player system verified and functional.
```
