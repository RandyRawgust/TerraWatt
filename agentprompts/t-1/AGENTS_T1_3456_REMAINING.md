━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
TERRAWATT — TIER 1 ELECTRICAL GRID AGENT (T1-3)
Single command: Paste this entire block into a Cursor Composer Agent tab and press Enter.
Run simultaneously with Sprites, Coal Power, Conveyors, and Pollution agents.
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

## MISSION: Build the first electrical grid — power poles, copper wire, power meter HUD.

---

## PHASE 0: DOCTRINE + RECON (MANDATORY)

1. Read `TERRAWATT_DOCTRINE.md` — full read.
2. Read `TERRAWATT_GDD.md` — Section 6 (Power Grid System) fully.
3. Read `res://power/power_grid.gd` — you are expanding this, not replacing it.
4. Read `res://ui/hud.tscn` and `res://ui/power_meter.gd` — you are replacing the stub meter.

```bash
git pull origin main ; cat AGENT_STATUS.md
```

While waiting for Coal Power Agent (if needed), use PowerGrid stub —
your grid infrastructure is fully buildable independently.

---

## PHASE 1: EXPAND POWER GRID FOR ELECTRICAL DISTRIBUTION

Tier 1 introduces the concept of electrical distribution zones.
A SteamTurbine/Generator feeds into a power pole network.
Machines within range of a powered pole receive electricity.

Expand `res://power/power_grid.gd` — add electrical zone tracking:

```gdscript
# NEW: Electrical distribution zones
# A zone is a connected network of poles.
# Key: pole Node → value: { watts_available, connected_poles, connected_loads }
var pole_networks: Dictionary = {}
var total_load_watts: float = 0.0

# Register a power pole. Called by PowerPole._ready().
func register_pole(pole: Node2D) -> void:
    # Find nearby poles and merge networks
    pole_networks[pole] = {"watts": 0.0, "loads": []}
    _rebuild_pole_network()
    pole_registered.emit(pole)

func unregister_pole(pole: Node2D) -> void:
    pole_networks.erase(pole)
    _rebuild_pole_network()

# Returns true if a world position has electrical power available.
func has_power_at(world_pos: Vector2) -> bool:
    for pole in pole_networks:
        if pole is Node2D:
            if pole.global_position.distance_to(world_pos) <= PowerPole.DISTRIBUTION_RADIUS:
                return get_local_power(world_pos) > 0.0
    return false

# Recalculate network connectivity (called when poles added/removed).
func _rebuild_pole_network() -> void:
    _recalculate_totals()
    power_updated.emit(total_generation, total_demand)

signal pole_registered(pole: Node2D)
```

---

## PHASE 2: POWER POLE

Create `res://power/tier1/power_pole.gd` and `power_pole.tscn`:

```gdscript
# SYSTEM: Power / Tier 1
# AGENT: Electrical Grid Agent
# PURPOSE: Wooden power pole. Distributes electricity within radius.
# Poles within CONNECTION_RANGE of each other share the same network.

extends Node2D

const CAPACITY_WATTS:      float = 5000.0  # 5kW per wooden pole
const CONNECTION_RANGE:    float = 160.0   # pixels — connect to nearby poles
const DISTRIBUTION_RADIUS: float = 80.0    # pixels — powers machines nearby

var is_powered: bool = false

@onready var pole_sprite:  Sprite2D = $PoleSprite
@onready var wire_drawer:  Node2D   = $WireDrawer

func _ready() -> void:
    add_to_group("power_poles")
    PowerGrid.register_pole(self)
    PowerGrid.power_updated.connect(_on_power_updated)

func _exit_tree() -> void:
    PowerGrid.unregister_pole(self)

func _on_power_updated(generation: float, _demand: float) -> void:
    is_powered = generation > 0.0
    # Visual: pole top glows amber when powered
    pole_sprite.modulate = Color(1.0, 0.85, 0.4) if is_powered else Color(1.0, 1.0, 1.0)

# Draw wire connections to nearby poles.
func _draw() -> void:
    for pole in get_tree().get_nodes_in_group("power_poles"):
        if pole == self or not pole is Node2D:
            continue
        var dist: float = global_position.distance_to(pole.global_position)
        if dist <= CONNECTION_RANGE:
            var local_target: Vector2 = to_local(pole.global_position)
            # Wire sag: midpoint drops by distance/8 for visual realism
            var mid: Vector2 = local_target / 2.0 + Vector2(0, dist / 8.0)
            draw_line(Vector2.ZERO, mid, Color(0.2, 0.2, 0.2), 2.0)
            draw_line(mid, local_target, Color(0.2, 0.2, 0.2), 2.0)

func _process(_delta: float) -> void:
    queue_redraw()  # redraw wire each frame (poles may move during placement)
```

Scene structure for power_pole.tscn:
```
Node2D (root, script: power_pole.gd)
  ├── Sprite2D (name: PoleSprite, texture: res://assets/power/tier1/power_pole.png)
  ├── Node2D (name: WireDrawer)
  └── Area2D (name: DistributionArea, shows radius visually when selected)
        └── CollisionShape2D (CircleShape2D radius=DISTRIBUTION_RADIUS)
```

---

## PHASE 3: POLE PLACEMENT SYSTEM

Players place poles by selecting them in inventory and right-clicking.

In `res://player/player.gd`, add placement mode:

```gdscript
# Handles right-click placement of power poles from inventory.
func _handle_placement_input() -> void:
    if not Input.is_mouse_button_pressed(MOUSE_BUTTON_RIGHT):
        return
    # Check hotbar selected item is a placeable structure
    var selected_item: String = _get_selected_hotbar_item()
    if selected_item == "power_pole" and Inventory.has_item("power_pole", 1):
        var place_pos: Vector2 = get_global_mouse_position()
        var tile_pos: Vector2i = Vector2i(
            int(place_pos.x / 16),
            int(place_pos.y / 16)
        )
        # Only place on solid ground (tile below must be solid)
        var tile_below: int = WorldData.get_tile(tile_pos.x, tile_pos.y + 1)
        if tile_below != WorldData.TILE_AIR:
            _place_structure("power_pole", place_pos)
            Inventory.remove_item("power_pole", 1)

func _place_structure(structure_name: String, world_pos: Vector2) -> void:
    var scene_path: String = "res://power/tier1/%s.tscn" % structure_name
    if not ResourceLoader.exists(scene_path):
        push_warning("No scene for structure: " + structure_name)
        return
    var scene: PackedScene = load(scene_path)
    var node: Node2D = scene.instantiate()
    node.global_position = world_pos.snapped(Vector2(16, 16))
    get_tree().current_scene.add_child(node)
```

---

## PHASE 4: POWER METER HUD (REPLACE STUB)

Replace `res://ui/power_meter.gd` with full Tier 1 implementation:

```gdscript
# SYSTEM: UI / Power
# AGENT: Electrical Grid Agent
# PURPOSE: Top-right HUD showing generation vs demand in watts.
# Tier 1: simple bar + numeric readout. Tier 3+ adds live chart.

extends Control

@onready var gen_label:    Label    = $GenLabel
@onready var dem_label:    Label    = $DemLabel
@onready var gen_bar:      ProgressBar = $GenBar
@onready var dem_bar:      ProgressBar = $DemBar
@onready var status_light: ColorRect   = $StatusLight

const MAX_DISPLAY_WATTS: float = 50000.0  # 50kW full scale for Tier 1

func _ready() -> void:
    PowerGrid.power_updated.connect(_on_power_updated)

func _on_power_updated(generation: float, demand: float) -> void:
    # Labels — format as W or kW depending on scale
    gen_label.text = "Gen: %s" % _format_watts(generation)
    dem_label.text = "Dem: %s" % _format_watts(demand)

    # Bars
    gen_bar.value = minf(generation / MAX_DISPLAY_WATTS, 1.0) * 100.0
    dem_bar.value = minf(demand    / MAX_DISPLAY_WATTS, 1.0) * 100.0

    # Status light: green=surplus, yellow=near limit, red=overload
    var ratio: float = demand / maxf(generation, 1.0)
    if ratio < 0.7:
        status_light.color = Color(0.0, 0.8, 0.2)   # green
    elif ratio < 0.9:
        status_light.color = Color(1.0, 0.7, 0.0)   # yellow
    else:
        status_light.color = Color(0.9, 0.1, 0.1)   # red

# Format watts as human-readable string.
static func _format_watts(watts: float) -> String:
    if watts >= 1000.0:
        return "%.1f kW" % (watts / 1000.0)
    return "%.0f W" % watts
```

Scene structure for power_meter.tscn (anchored top-right of HUD):
```
Control (root, script: power_meter.gd, anchor: top-right)
  ├── PanelContainer (dark industrial panel background)
  │     └── VBoxContainer
  │           ├── HBoxContainer
  │           │     ├── ColorRect (name: StatusLight, 12×12px)
  │           │     └── Label (name: GenLabel, "Gen: 0 W")
  │           ├── ProgressBar (name: GenBar, green tint)
  │           ├── Label (name: DemLabel, "Dem: 0 W")
  │           └── ProgressBar (name: DemBar, red tint)
```

---

## PHASE 5: GENERATE ART VIA PIXELLAB MCP

```
Power pole pixel art for Terra.Watt Tier 1, 16×64px:
  Wooden utility pole, creosote-stained dark brown.
  Cross-arm near top with ceramic insulators.
  Small amber bulb at top (glows when powered).
  1880s-1920s style. Slightly weathered.
  Palette: #3D1F0A dark brown pole, #C8B89A ceramic insulators
Save to: res://assets/power/tier1/power_pole.png

Copper wire segment, 16×4px, tileable horizontal:
  Dark copper wire with slight sag curve.
  #B87333 copper colour, 2px thick line, transparent background.
Save to: res://assets/power/tier1/wire_segment.png
```

---

## FINAL REPORT

```
ELECTRICAL GRID AGENT — FINAL REPORT

✅ PowerGrid expanded: pole network tracking, has_power_at()
✅ PowerPole: places in world, connects to nearby poles, draws wire sag
✅ Placement system: right-click to place pole from inventory
✅ Power meter HUD: Gen/Dem bars, status light, kW formatting
✅ Art: power_pole.png and wire_segment.png generated
✅ Committed (path-scoped git add)
✅ AGENT_STATUS.md updated

Self-Audit Complete. Electrical grid functional.
Place turbine → connect to pole → power meter shows watts.
```

━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
TERRAWATT — TIER 1 CONVEYORS AGENT (T1-4)
Single command: Paste this entire block into a Cursor Composer Agent tab and press Enter.
Run simultaneously with Sprites, Coal Power, Grid, and Pollution agents.
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

## MISSION: Build conveyor belts that automate coal transport from mine to furnace.

---

## PHASE 0: DOCTRINE + RECON

1. Read `TERRAWATT_DOCTRINE.md`.
2. Read GDD Section 10 (Conveyors & Pipes) fully.
   KEY RULE: Conveyors cannot cross other conveyors until Tier 2.
   Players CAN walk on and stand on conveyors.
3. Read existing WorldData and Inventory code.

```bash
git pull origin main ; cat AGENT_STATUS.md
```

Stub dependency: `CoalFurnace.add_coal()` — from Coal Power Agent.
Build a stub if not yet delivered:
```gdscript
# STUB: CoalFurnace not yet built. Replace when Coal Power Agent delivers.
func _try_deliver_to_furnace(amount: int) -> void:
    var furnace = get_tree().get_first_node_in_group("coal_furnaces")
    if furnace and furnace.has_method("add_coal"):
        furnace.add_coal(amount)
    else:
        # STUB fallback: print delivery attempt
        print("Conveyor: would deliver %d coal to furnace" % amount)
```

---

## PHASE 1: CONVEYOR BELT SEGMENT

Create `res://structures/conveyor_belt.gd` and `conveyor_belt.tscn`:

```gdscript
# SYSTEM: Structures / Conveyors
# AGENT: Conveyors Agent
# PURPOSE: Moves items in one direction. Player can walk on top.
# Tier 1: no crossing — single direction per placed segment.

extends StaticBody2D

enum Direction { LEFT, RIGHT, UP, DOWN }

@export var direction: Direction = Direction.RIGHT
@export var belt_speed: float    = 64.0  # pixels per second

# Items currently riding this belt segment
var _riding_items: Array[Node2D] = []

@onready var belt_sprite: AnimatedSprite2D = $BeltSprite

func _ready() -> void:
    add_to_group("conveyors")

func _physics_process(delta: float) -> void:
    _move_riding_items(delta)
    _animate_belt()

# Called by items that overlap this belt via their Area2D.
func register_item(item: Node2D) -> void:
    if not _riding_items.has(item):
        _riding_items.append(item)

func unregister_item(item: Node2D) -> void:
    _riding_items.erase(item)

func _move_riding_items(delta: float) -> void:
    var move_vec: Vector2 = _direction_to_vector() * belt_speed * delta
    for item in _riding_items:
        if is_instance_valid(item):
            item.global_position += move_vec
        else:
            _riding_items.erase(item)

func _direction_to_vector() -> Vector2:
    match direction:
        Direction.RIGHT: return Vector2.RIGHT
        Direction.LEFT:  return Vector2.LEFT
        Direction.UP:    return Vector2.UP
        Direction.DOWN:  return Vector2.DOWN
    return Vector2.RIGHT

func _animate_belt() -> void:
    # Belt animation plays faster at higher speed
    belt_sprite.speed_scale = belt_speed / 64.0
    if not belt_sprite.is_playing():
        belt_sprite.play("move")

# Returns direction vector for player movement assist.
# Player gently pushed in belt direction when standing on it.
func get_push_vector() -> Vector2:
    return _direction_to_vector() * 20.0  # gentle nudge
```

Scene:
```
StaticBody2D (root, script: conveyor_belt.gd, collision layer 1)
  ├── AnimatedSprite2D (name: BeltSprite — move: 4 frames, 8fps)
  ├── CollisionShape2D (rectangle 16×8, player can stand on top)
  └── Area2D (name: ItemDetector — detects collectible items on belt)
        └── CollisionShape2D (rectangle 14×6, slightly smaller than belt)
```

---

## PHASE 2: BELT PLACEMENT + DIRECTION CYCLING

In `res://player/player.gd`, add belt placement:
- Right-click with "conveyor_belt" selected in hotbar → places a belt segment
- Scroll wheel or R key → cycles direction (LEFT/RIGHT/UP/DOWN)
- Belt snaps to 16px grid
- Cannot cross another belt at Tier 1 (check for existing belt at position before placing)

```gdscript
var _pending_direction: int = 0  # ConveyorBelt.Direction

func _handle_belt_placement() -> void:
    if Input.is_action_just_pressed("rotate_structure"):  # R key
        _pending_direction = (_pending_direction + 1) % 4

    if Input.is_mouse_button_pressed(MOUSE_BUTTON_RIGHT):
        var selected: String = _get_selected_hotbar_item()
        if selected != "conveyor_belt" or not Inventory.has_item("conveyor_belt", 1):
            return
        var place_pos: Vector2 = get_global_mouse_position().snapped(Vector2(16, 16))
        # Tier 1: no crossing — check for existing belt
        for belt in get_tree().get_nodes_in_group("conveyors"):
            if belt is Node2D and belt.global_position.distance_to(place_pos) < 8.0:
                print("Cannot place: conveyors cannot cross until Tier 2.")
                return
        _place_structure("conveyor_belt", place_pos)
        # Set direction after placement
        var placed: Node = get_tree().current_scene.get_child(-1)
        if placed.has_method("set") :
            placed.direction = _pending_direction
        Inventory.remove_item("conveyor_belt", 1)
```

Add `rotate_structure` to Input Map in project.godot: key R (keycode 82).

---

## PHASE 3: ITEM RIDING BEHAVIOUR

Collectible items need to register with belts they overlap.
In `res://mining/collectible_item.gd`, add:

```gdscript
func _physics_process(delta: float) -> void:
    sleeping = false
    # Check if on a conveyor belt
    for belt in get_tree().get_nodes_in_group("conveyors"):
        if belt is Node2D:
            var dist: float = global_position.distance_to(belt.global_position)
            if dist < 12.0:
                belt.register_item(self)
                return
    # Not on any belt — unregister from all
    for belt in get_tree().get_nodes_in_group("conveyors"):
        belt.unregister_item(self)
```

---

## PHASE 4: BELT → FURNACE DELIVERY

When a coal item reaches the end of a belt chain and overlaps a furnace,
it should auto-load into the furnace.

Create `res://structures/belt_inserter.gd` — a small inserter node placed
at the output end of a belt, adjacent to a furnace:

```gdscript
# Automatically transfers items from belt to adjacent machine.
extends Area2D

func _ready() -> void:
    body_entered.connect(_on_item_entered)

func _on_item_entered(body: Node) -> void:
    if not body.has_method("item_type"):
        return
    var item_type: String = body.get("item_type")
    if item_type == "" or item_type == null:
        return
    # Find adjacent furnace
    var furnace: Node = _find_adjacent_furnace()
    if furnace and furnace.has_method("add_coal") and item_type == "coal":
        furnace.add_coal(1)
        body.queue_free()

func _find_adjacent_furnace() -> Node:
    for machine in get_tree().get_nodes_in_group("machines"):
        if machine is Node2D:
            if global_position.distance_to(machine.global_position) < 24.0:
                return machine
    return null
```

---

## PHASE 5: GENERATE ART VIA PIXELLAB MCP

```
Conveyor belt sprite sheet, 16×8px per frame, 4 frames horizontal:
  Top-down view of a moving rubber belt with directional chevron arrows.
  Belt moves right in frames 0→3 (animation implies rightward motion).
  Dark rubber #2A2A2A with lighter #4A4A4A chevrons.
  Metal side rails #8899AA.
  Transparent background. Total: 64×8px.
Save to: res://assets/structures/conveyor_belt_sheet.png
```

---

## FINAL REPORT

```
CONVEYORS AGENT — FINAL REPORT

✅ ConveyorBelt: places in world, moves items in direction
✅ Belt direction cycling: R key rotates LEFT/RIGHT/UP/DOWN
✅ Tier 1 no-crossing rule enforced on placement
✅ Collectible items register with overlapping belts and ride them
✅ BeltInserter: auto-delivers coal items to adjacent furnace
✅ Player gently nudged when standing on belt
✅ Art: conveyor_belt_sheet.png generated
✅ Committed (path-scoped git add)
✅ AGENT_STATUS.md updated

Self-Audit Complete. Coal flows from mine → belt → inserter → furnace automatically.
```

━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
TERRAWATT — TIER 1 POLLUTION AGENT (T1-5)
Single command: Paste this entire block into a Cursor Composer Agent tab and press Enter.
Run simultaneously with Sprites, Coal Power, Grid, and Conveyors agents.
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

## MISSION: Build the Tier 1 pollution system — smoke accumulation, soot, background haze.

IMPORTANT: This agent depends on Preflight having compiled the C++ sim.
If SimManager is still in stub mode (Preflight not complete), use the
ANTI-STUCK PROTOCOL — implement everything except live particle reads,
document the stub clearly, and commit. Replace when Preflight completes.

---

## PHASE 0: DOCTRINE + RECON

1. Read `TERRAWATT_DOCTRINE.md`.
2. Read GDD Tier 1 section — pollution mechanic description.
3. Read `res://simulation/material_registry.gd` — MAT_SMOKE is id 103.
4. Read `res://world/lighting.gd` — you will coordinate with this for visual haze.

```bash
git pull origin main ; cat AGENT_STATUS.md
# Check if Preflight shows SimManager as real:
grep -A5 "Preflight" AGENT_STATUS.md
```

---

## PHASE 1: POLLUTION TRACKER (AUTOLOAD)

Create `res://world/pollution_tracker.gd` and register it as an autoload
named `PollutionTracker` in project.godot.

```gdscript
# SYSTEM: Pollution
# AGENT: Pollution Agent
# PURPOSE: Tracks accumulated pollution level. Drives visual haze and acid rain.
# NOTE: No class_name — this is an autoload singleton.

extends Node

# 0.0 = clean air, 1.0 = maximum pollution
var global_pollution_level: float = 0.0

# Pollution rises when coal burns, falls slowly over time (natural dissipation)
const POLLUTION_PER_COAL_BURN: float = 0.0005   # per coal burned
const NATURAL_DISSIPATION:     float = 0.00002  # per second passively
const ACID_RAIN_THRESHOLD:     float = 0.6      # triggers acid rain event

var acid_rain_active:   bool  = false
var _acid_rain_timer:   float = 0.0

func _process(delta: float) -> void:
    # Natural dissipation
    global_pollution_level = maxf(
        global_pollution_level - NATURAL_DISSIPATION * delta,
        0.0
    )
    # Check acid rain trigger
    if global_pollution_level >= ACID_RAIN_THRESHOLD and not acid_rain_active:
        _start_acid_rain()
    elif global_pollution_level < ACID_RAIN_THRESHOLD * 0.8 and acid_rain_active:
        _stop_acid_rain()
    # Tick acid rain
    if acid_rain_active:
        _tick_acid_rain(delta)

# Called by CoalFurnace each time a coal unit is burned.
func report_coal_burned() -> void:
    global_pollution_level = minf(
        global_pollution_level + POLLUTION_PER_COAL_BURN,
        1.0
    )
    pollution_changed.emit(global_pollution_level)

func _start_acid_rain() -> void:
    acid_rain_active = true
    acid_rain_started.emit()
    print("PollutionTracker: Acid rain begins — pollution at %.0f%%" % (global_pollution_level * 100))

func _stop_acid_rain() -> void:
    acid_rain_active = false
    acid_rain_stopped.emit()

func _tick_acid_rain(delta: float) -> void:
    # Acid rain slowly damages exposed wooden structures
    # Spawn acid particles near surface level every few seconds
    _acid_rain_timer += delta
    if _acid_rain_timer >= 3.0:
        _acid_rain_timer = 0.0
        acid_rain_tick.emit()

signal pollution_changed(level: float)
signal acid_rain_started
signal acid_rain_stopped
signal acid_rain_tick
```

Register in project.godot `[autoload]` section:
```ini
PollutionTracker="*res://world/pollution_tracker.gd"
```

---

## PHASE 2: WIRE FURNACE TO POLLUTION

In `res://power/tier1/coal_furnace.gd`, add one line to `_tick_burn()`:
```gdscript
# Report to pollution system each coal burn
if _burn_timer >= 1.0 / BURN_RATE:
    coal_stored -= 1
    _burn_timer = 0.0
    PollutionTracker.report_coal_burned()   # ← add this
```

If CoalFurnace not yet delivered, add this as a comment stub with a
`# STUB: wire to PollutionTracker.report_coal_burned() when Coal Agent delivers`
note in pollution_tracker.gd.

---

## PHASE 3: VISUAL POLLUTION LAYER

Create `res://world/pollution_overlay.gd`:

```gdscript
# SYSTEM: Pollution Visual
# AGENT: Pollution Agent
# PURPOSE: Renders atmospheric haze that intensifies with pollution level.

extends CanvasLayer

@onready var haze_rect: ColorRect = $HazeRect

func _ready() -> void:
    PollutionTracker.pollution_changed.connect(_on_pollution_changed)
    haze_rect.size = get_viewport().get_visible_rect().size

# Update haze colour and opacity based on pollution level.
func _on_pollution_changed(level: float) -> void:
    # Low pollution: slight yellow tinge. High: thick brown-grey smog.
    var haze_color: Color = Color(
        0.4 + level * 0.3,   # R: shifts from dull to brown
        0.35 + level * 0.1,  # G: slight green-brown
        0.1,                 # B: flat low
        level * 0.35         # A: 0 when clean, 0.35 at max pollution
    )
    haze_rect.color = haze_color
```

Add `PollutionOverlay` scene to `main.tscn` as a CanvasLayer child
(z_index = 5, below darkness overlay but above world).

---

## PHASE 4: BACKGROUND ERA SHIFT (TIER 1)

The background should show a distant smokestack silhouette once pollution > 0.1.

In `res://world/background.gd`, add:
```gdscript
# Show industrial era background layer when Tier 1 pollution begins.
func _check_era_shift() -> void:
    if PollutionTracker.global_pollution_level > 0.1:
        $IndustrialLayer.visible = true  # smokestack silhouette layer
    else:
        $IndustrialLayer.visible = false
```

Generate via PixelLab MCP:
```
Background silhouette layer for Terra.Watt Tier 1, 320×180px:
  Dark silhouette of a distant industrial scene against a hazy sky.
  One large brick chimney with smoke trail. Two smaller structures.
  Colour: very dark #1A1005 silhouette, hazy amber sky behind #3D2A0A.
  Painterly, distant, slightly ominous.
  Background: transparent (PNG) — composited over the sky background.
Save to: res://assets/backgrounds/bg_industrial_tier1.png
```

---

## PHASE 5: SOOT BUILDUP

Soot accumulates on structures near active furnaces.
This is a visual effect only — modulate nearby Sprite2D nodes toward grey.

Create `res://world/soot_system.gd`:
```gdscript
# Applies soot darkening to structures near active furnaces.
extends Node

const SOOT_RANGE:     float = 80.0   # pixels
const SOOT_RATE:      float = 0.01   # per second when furnace burning
const SOOT_DECAY:     float = 0.002  # per second natural cleaning

var _soot_levels: Dictionary = {}   # Node → float (0.0-1.0)

func _process(delta: float) -> void:
    var furnaces: Array = get_tree().get_nodes_in_group("coal_furnaces")
    var active_furnaces: Array = furnaces.filter(
        func(f): return f.has_method("get_heat_output") and f.get_heat_output() > 0
    )

    for structure in get_tree().get_nodes_in_group("structures"):
        if not structure is Node2D:
            continue
        var max_soot: float = 0.0
        for furnace in active_furnaces:
            if furnace is Node2D:
                var dist: float = structure.global_position.distance_to(furnace.global_position)
                if dist < SOOT_RANGE:
                    max_soot = maxf(max_soot, 1.0 - dist / SOOT_RANGE)

        var current: float = _soot_levels.get(structure, 0.0)
        if max_soot > 0:
            current = minf(current + SOOT_RATE * delta, max_soot)
        else:
            current = maxf(current - SOOT_DECAY * delta, 0.0)

        _soot_levels[structure] = current
        # Apply as a dark grey modulate
        var soot_color: Color = Color(
            1.0 - current * 0.4,
            1.0 - current * 0.4,
            1.0 - current * 0.45
        )
        if structure.has_method("set_modulate"):
            structure.modulate = soot_color
```

---

## FINAL REPORT

```
POLLUTION AGENT — FINAL REPORT

✅ PollutionTracker autoload: tracks 0.0-1.0 level, acid rain threshold
✅ CoalFurnace wired (or stubbed with clear comment if not yet delivered)
✅ PollutionOverlay: visual haze scales with pollution level
✅ Background industrial layer appears at pollution > 10%
✅ SootSystem: structures near furnaces darken over time
✅ bg_industrial_tier1.png generated via PixelLab
✅ Committed (path-scoped git add)
✅ AGENT_STATUS.md updated

Self-Audit Complete. Pollution system functional.
Burn coal → smoke rises → haze builds → background shifts → acid rain begins.
```

━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
TERRAWATT — TIER 1 INTEGRATION AGENT (T1-6)
Single command: Paste this entire block into a Cursor Composer Agent tab and press Enter.
Run ONLY after all T1-0 through T1-5 agents show STATUS: COMPLETE in AGENT_STATUS.md
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

## MISSION: Wire all Tier 1 systems together. Run the 30-point verification checklist.

---

## PHASE 0: DOCTRINE + RECON (MANDATORY)

1. Read `TERRAWATT_DOCTRINE.md` in full.
2. Read `AGENT_STATUS.md` — EVERY agent T1-0 through T1-5 must be COMPLETE.
   If any are not, poll every 5 minutes:
   ```bash
   git pull origin main ; grep "STATUS:" AGENT_STATUS.md
   ```
3. Read ALL `AGENT_NOTES.md` files and EXPORTS sections in AGENT_STATUS.md.
4. Run `git log --oneline -20` — review every Tier 1 commit.
5. Open every new script and read it. Build a map of what connects to what.

---

## PHASE 1: MAIN SCENE WIRING

In `res://main.gd` and `res://main.tscn`:

Add these new nodes/scenes to main.tscn:
```
main.tscn
  ├── [existing Scope 1 nodes...]
  ├── PollutionOverlay (scene: res://world/pollution_overlay.tscn)
  ├── SootSystem (script: res://world/soot_system.gd)
  └── [Tier 1 structures are spawned dynamically, not hardcoded here]
```

In `main.gd _ready()`, add after existing initialization:
```gdscript
# Wire Tier 1 systems
PollutionTracker.acid_rain_started.connect(_on_acid_rain_started)
PollutionTracker.acid_rain_stopped.connect(_on_acid_rain_stopped)

func _on_acid_rain_started() -> void:
    # Visual: tint sky slightly green-grey during acid rain
    $BackgroundLayer.modulate = Color(0.85, 0.9, 0.8)
    print("Acid rain has begun.")

func _on_acid_rain_stopped() -> void:
    $BackgroundLayer.modulate = Color(1.0, 1.0, 1.0)
```

Add `PollutionTracker` to project.godot autoloads if not already present.

---

## PHASE 2: INPUT MAP COMPLETENESS

Verify project.godot [input] section contains ALL of these:
```
ui_left:    Left arrow + A (keycode 4194319, 65)
ui_right:   Right arrow + D (keycode 4194321, 68)
ui_accept:  Space + W (keycode 32, 87)
mine:       Left mouse button
place:      Right mouse button
interact:   E key (keycode 69)
rotate_structure: R key (keycode 82)
hotbar_1 through hotbar_0: keys 1-9,0
```
Add any that are missing.

---

## PHASE 3: 30-POINT TIER 1 VERIFICATION CHECKLIST

Run main.tscn. Verify each item. Mark ✅ pass, ⚠️ issue found+fixed, 🚧 blocked.

**SCOPE 1 REGRESSION (should still work):**
```
[ ] Game opens without red errors in output panel
[ ] "SimManager: C++ extension loaded successfully." appears (or stub warning)
[ ] Player spawns on surface
[ ] WASD and arrow keys both move player
[ ] Space and W both jump
[ ] Camera follows player smoothly
[ ] Click tile → mining ring → tile disappears
[ ] Collectible drops from mined tile
[ ] Dig a hole, drop item into it → item falls further when ground removed
[ ] Walk into item → auto-collects into hotbar
[ ] Wolf appears at night, chases player
[ ] Rabbit hops, flees when player approaches
[ ] Player gets darker as they go underground
```

**TIER 1 — SPRITES:**
```
[ ] Player sprite shows real industrial miner (not taco/placeholder)
[ ] Wolf sprite shows real grey wolf (not white square)
[ ] Rabbit sprite shows real brown rabbit (not white square)
[ ] All sprites are crisp/pixelated (TEXTURE_FILTER_NEAREST applied)
```

**TIER 1 — COAL POWER:**
```
[ ] Coal exists underground, mineable, adds "coal" to inventory
[ ] E key near furnace with coal → coal loads into furnace
[ ] Furnace burns coal (flame animation plays)
[ ] Smoke particles rise from furnace chimney
[ ] E key near boiler with water bucket → water loads
[ ] Boiler produces steam (steam particles visible)
[ ] Steam turbine spins when connected to active boiler
[ ] Power meter top-right shows Gen > 0W when chain is running
```

**TIER 1 — ELECTRICAL GRID:**
```
[ ] Place power pole from inventory → pole appears in world
[ ] Two nearby poles → wire drawn between them (with sag)
[ ] Power meter status light turns green when generation > demand
```

**TIER 1 — CONVEYORS:**
```
[ ] Place conveyor belt → belt appears, animates
[ ] R key cycles belt direction before placement
[ ] Mined coal placed on belt → coal rides belt toward furnace
[ ] Cannot cross conveyors (second belt at same position refused)
```

**TIER 1 — POLLUTION:**
```
[ ] Running furnace raises pollution_level (check via Remote Inspector)
[ ] Atmospheric haze visually increases as pollution rises
[ ] Background industrial layer appears once pollution > 10%
[ ] Structures near furnace gradually darken with soot
```

For every ⚠️ or 🚧: diagnose root cause, fix, re-verify, commit fix.
Use Claude Code for anything that takes more than 10 minutes:
```bash
claude "Tier 1 integration bug: [describe]. File: [path]. Code: [paste]. Fix."
```

---

## PHASE 4: FINAL COMMIT

```bash
git add main.gd main.tscn project.godot
git status  # confirm only integration files staged
git commit -m "[T1-Integration] feat: Tier 1 complete — coal power chain, grid, conveyors, pollution verified"
git push origin main
```

Update AGENT_STATUS.md with full Tier 1 summary.

---

## FINAL REPORT FORMAT

```
TIER 1 INTEGRATION AGENT — FINAL REPORT

Scope 1 regression:    [N]/13 passing
Sprites:               [N]/4  passing
Coal power chain:      [N]/8  passing
Electrical grid:       [N]/3  passing
Conveyors:             [N]/4  passing
Pollution:             [N]/4  passing

TOTAL: [N]/30 verification points passing

Issues found and resolved:
  [list any ⚠️ items with file:line and fix applied]

Remaining blocked items:
  [list any 🚧 with recommended next steps]

Final commit: [hash]

[If 28+/30 passing:]
Self-Audit Complete. Terra.Watt Tier 1 verified and playable.
Coal → boiler → turbine → grid → watts. Mission accomplished.

[If < 28/30:]
Self-Audit Complete. CRITICAL ISSUES REMAIN:
[list each with severity and recommended fix approach]
```
