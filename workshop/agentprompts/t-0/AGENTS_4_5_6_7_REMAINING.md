━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
TERRAWATT — VISUAL & ART AGENT (AGENT 4)
Single command: Paste this entire block into a Cursor Composer Agent tab and press Enter.
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

## MISSION: Generate all art assets and build the visual systems (backgrounds, lighting, tileset).

You are the VISUAL & ART AGENT. You produce everything the player sees:
tile sprites, parallax backgrounds, lighting, and the TileSet resource.
Use PixelLab MCP for all asset generation.

---

## PHASE 0: READ YOUR DOCTRINE (MANDATORY FIRST STEP)

1. Read `TERRAWATT_DOCTRINE.md`
2. Read `TERRAWATT_GDD.md` — Section 0 (visual identity), Section 17 (PixelLab prompts)
3. Read `AGENT_STATUS.md` — confirm Foundation Agent COMPLETE
4. Poll for World Gen Agent completing — you need the TileSet IDs to match WorldData constants

While waiting: generate all art assets immediately. Art generation does not depend on other agents.

---

## PHASE 1: GENERATE ALL TILE ART (PixelLab MCP)

Generate each tile at 16×16 pixels. Style for ALL tiles:
`"16x16 pixel art tile, painterly texture, detailed, slightly gritty, no hard outlines, natural subsurface lighting, Terra.Watt industrial game style"`

### Terrain Tiles
```
TILE: dirt          — warm brown cracked earth #8B6914, slight moisture variation
TILE: grass_dirt    — dirt base, bright green grass blades on top #4A7C2F, roots visible
TILE: stone         — grey granite-like, cracked lines, subtle blue-grey #6B6B6B
TILE: clay          — smooth ochre clay, slightly reddish #A0785A, layered bands
```

### Ore Tiles (stone base + ore flecks)
```
TILE: coal_ore      — dark stone with glossy near-black coal veins #2A2A2A, slight shine
TILE: copper_ore    — grey stone base with warm copper-orange vein flecks #B87333
TILE: iron_ore      — grey stone with metallic silver-blue streak deposits #8A8A9A
```

### Structure/Build Tiles
```
TILE: wood_plank    — horizontal grain wood planks, warm brown, visible nails
TILE: stone_brick   — cut stone blocks, mortar lines, slightly rough #7A7A7A
```

Save all to: `res://assets/tiles/terrain/` and `res://assets/tiles/ores/`

---

## PHASE 2: CREATE GODOT TILESET RESOURCE

Create `res://assets/tiles/terrawatt_tileset.tres` — a Godot TileSet resource.

Each tile gets:
- Atlas source from the corresponding PNG
- Single 16×16 tile at position (0,0) in the atlas
- Physics layer: full rectangle collision for solid tiles (not air)
- Tile ID matching WorldData constants (dirt=1, stone=2, etc.)

Write a Godot EditorScript or a tool script at `res://scripts/create_tileset.gd` that:
- Creates the TileSet programmatically using GDScript
- Sets correct physics shapes for collidable tiles
- Saves the resource to disk
- Run it once via Godot's "Run Script" feature in the Script editor

---

## PHASE 3: PARALLAX BACKGROUND

Create `res://world/background.tscn` and `res://world/background.gd`:

```gdscript
# SYSTEM: Visual / Background
# AGENT: Visual Art Agent
# PURPOSE: 3-layer parallax deep space background. Starbound aesthetic.

extends Node2D

class_name BackgroundLayer

@onready var layer_far:    Sprite2D = $LayerFar    # speed 0.05
@onready var layer_mid:    Sprite2D = $LayerMid    # speed 0.15
@onready var layer_near:   Sprite2D = $LayerNear   # speed 0.30

var _camera_last_pos: Vector2 = Vector2.ZERO

func update_parallax(camera_pos: Vector2) -> void:
    var delta_pos: Vector2 = camera_pos - _camera_last_pos
    layer_far.position  -= delta_pos * 0.05
    layer_mid.position  -= delta_pos * 0.15
    layer_near.position -= delta_pos * 0.30
    _camera_last_pos = camera_pos
```

Generate background art via PixelLab MCP:
```
3 parallax background images for Terra.Watt, 320×180px each:
  Layer 1 (far): Deep space — dark navy #0A0A1A, scattered white star points,
                 faint purple nebula wisps, 2-3 very distant mountain silhouettes
  Layer 2 (mid): Dark forest horizon silhouette, dark green against deep blue sky,
                 very faint orange glow near horizon (distant fire/industrial)
  Layer 3 (near): Foreground grass/rock silhouette, slightly darker, tree outlines,
                  warm brown-green
```
Save to: `res://assets/backgrounds/bg_layer_far.png`, `bg_layer_mid.png`, `bg_layer_near.png`

---

## PHASE 4: LIGHTING SYSTEM

Create `res://world/lighting.gd`:

```gdscript
# SYSTEM: Lighting
# AGENT: Visual Art Agent
# PURPOSE: Underground darkness, player torch glow, ore glow effects.

extends Node2D

class_name LightingManager

# Darkness overlay — a full-screen dark rect that fades based on depth
@onready var darkness_overlay: ColorRect = $DarknessOverlay

# Player light (PointLight2D on player — controlled here)
var player_light: PointLight2D = null

# Underground darkness ramp
# Surface (Y=0): no darkness. Deep (Y=200+): full darkness.
const DARK_START_Y: int = 10   # tiles — starts getting dark
const DARK_FULL_Y:  int = 80   # tiles — full darkness
const MAX_DARKNESS: float = 0.92  # alpha at full depth

func _process(_delta: float) -> void:
    _update_darkness()
    _update_ore_glow()

func set_player_light(light: PointLight2D) -> void:
    player_light = light

func _update_darkness() -> void:
    var player: Node2D = get_tree().get_first_node_in_group("player")
    if not player: return
    var player_tile_y: float = player.global_position.y / 16.0
    var darkness_t: float = clamp(
        (player_tile_y - DARK_START_Y) / float(DARK_FULL_Y - DARK_START_Y),
        0.0, 1.0
    )
    darkness_overlay.color = Color(0, 0, 0, darkness_t * MAX_DARKNESS)

func _update_ore_glow() -> void:
    # Ore tiles near the player emit a faint colored glow
    # This is handled by adding small PointLight2D nodes near ore tiles
    # when the player is close enough. Implementation: scan 8-tile radius,
    # add/remove light nodes as player moves.
    pass  # TODO: implement ore proximity glow in full version
```

Generate via PixelLab MCP:
```
Soft radial gradient PNG, 128×128px, white center fading to transparent edges.
Used as PointLight2D texture for player headlamp.
Background: transparent. Style: soft painterly glow.
Save to: res://assets/ui/light_radial.png
```

---

## PHASE 5: ASSET MANIFEST

Create `res://assets/ASSET_MANIFEST.md`:
List every asset generated, its path, dimensions, and which system uses it.
Update this as you complete each asset.

---

## FINAL REPORT

```
VISUAL ART AGENT — FINAL REPORT

✅ Generated [N] tile sprites via PixelLab MCP
✅ TileSet resource created with correct IDs and collision shapes
✅ Parallax background (3 layers) generated and scene built
✅ Lighting system: underground darkness overlay + player torch
✅ Light radial texture generated
✅ ASSET_MANIFEST.md complete
✅ All commits pushed: [latest commit hash]
✅ AGENT_STATUS.md updated

Self-Audit Complete. All visual systems verified.
```

━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
TERRAWATT — UI & CREATURES AGENT (AGENT 5)
Single command: Paste this entire block into a Cursor Composer Agent tab and press Enter.
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

## MISSION: Build the HUD, status icons, hotbar, and Scope 1 creatures.

---

## PHASE 0: READ YOUR DOCTRINE (MANDATORY FIRST STEP)

1. Read `TERRAWATT_DOCTRINE.md`
2. Read `TERRAWATT_GDD.md` — Section 7 (Status Icons), Section 11 (Creatures), Section 14 (UI Design)
3. Read `AGENT_STATUS.md`
4. Read `res://player/inventory.gd` — the Inventory autoload you display.
5. Read `res://player/player_status.gd` stub — you receive its signals.

While waiting for Player Agent: build all UI scenes standalone. Wire up signals when Player Agent delivers.

---

## PHASE 1: HUD STRUCTURE

Create `res://ui/hud.tscn`:

```
CanvasLayer (root)
  ├── HBoxContainer (top-right, anchored top-right)
  │     └── PowerMeter (script: power_meter.gd)
  ├── StatusIconBar (top-left, script: status_icons.gd)
  │     — stacks icons vertically above player
  ├── AirBar (top-left below health, script: air_bar.gd)
  │     — only visible when air < 1.0
  ├── HealthBar (top-left, script: health_bar.gd)
  └── Hotbar (bottom-center, anchored bottom, script: hotbar.gd)
```

### res://ui/status_icons.gd

```gdscript
# SYSTEM: UI
# AGENT: UI & Creatures Agent
# PURPOSE: Displays Noita-style status icons above the player.

extends Node2D

class_name StatusIconBar

# Icon scene (TextureRect with label)
@export var icon_scene: PackedScene

var _active_icons: Dictionary = {}   # status_name → icon node

const ICON_SPACING: float = 20.0
const FLOAT_ABOVE:  float = -60.0   # pixels above player

func _ready() -> void:
    # Connect to PlayerStatus signal when player is available
    call_deferred("_connect_to_player")

func _connect_to_player() -> void:
    var player: Node = get_tree().get_first_node_in_group("player")
    if player and player.has_node("PlayerStatus"):
        player.get_node("PlayerStatus").status_changed.connect(_on_status_changed)

func _process(_delta: float) -> void:
    # Follow player position
    var player: Node2D = get_tree().get_first_node_in_group("player")
    if player:
        global_position = player.global_position + Vector2(0, FLOAT_ABOVE)

func _on_status_changed(wet: bool, on_fire: bool, suffocating: bool, air: float, health: float) -> void:
    _set_icon("wet",         wet,         "💧", Color(0.2, 0.5, 0.9))
    _set_icon("on_fire",     on_fire,     "🔥", Color(1.0, 0.4, 0.1))
    _set_icon("suffocating", suffocating, "💨", Color(0.5, 0.5, 0.5))
    _reposition_icons()

func _set_icon(key: String, active: bool, symbol: String, color: Color) -> void:
    if active and not _active_icons.has(key):
        var icon: Node = icon_scene.instantiate()
        icon.get_node("Label").text = symbol
        icon.modulate = color
        add_child(icon)
        _active_icons[key] = icon
    elif not active and _active_icons.has(key):
        _active_icons[key].queue_free()
        _active_icons.erase(key)

func _reposition_icons() -> void:
    var i: int = 0
    for icon in _active_icons.values():
        icon.position = Vector2(0, -i * ICON_SPACING)
        i += 1
```

Generate status icon art via PixelLab MCP:
```
3 status icon sprites for Terra.Watt HUD, 16×16px each:
  wet_icon:        blue water droplet, glossy, simple
  fire_icon:       orange flame, flickering feel, 3 frame animation
  smoke_icon:      grey puff cloud, simple
Style: simple readable pixel icons, bright colors for clarity against dark background
Save to: res://assets/ui/
```

### res://ui/hotbar.gd

```gdscript
# SYSTEM: UI / Inventory
# AGENT: UI & Creatures Agent
# PURPOSE: Bottom hotbar displaying 10 inventory slots.
# Updates when Inventory signals fire.

extends HBoxContainer

class_name Hotbar

const SLOT_COUNT: int = 10

var _slots: Array = []
var _selected_slot: int = 0

func _ready() -> void:
    _build_slots()
    Inventory.item_added.connect(_on_inventory_changed)
    Inventory.item_removed.connect(_on_inventory_changed)

func _build_slots() -> void:
    for i in range(SLOT_COUNT):
        var slot: Control = _make_slot()
        add_child(slot)
        _slots.append(slot)

func _make_slot() -> Control:
    var panel: PanelContainer = PanelContainer.new()
    panel.custom_minimum_size = Vector2(40, 40)
    var vbox: VBoxContainer = VBoxContainer.new()
    var icon: TextureRect = TextureRect.new()
    icon.expand_mode = TextureRect.EXPAND_FIT_WIDTH
    icon.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_CENTERED
    var label: Label = Label.new()
    label.horizontal_alignment = HORIZONTAL_ALIGNMENT_RIGHT
    label.vertical_alignment = VERTICAL_ALIGNMENT_BOTTOM
    label.add_theme_font_size_override("font_size", 9)
    vbox.add_child(icon)
    vbox.add_child(label)
    panel.add_child(vbox)
    return panel

func _on_inventory_changed(_type: String, _amount: int) -> void:
    _refresh_display()

func _refresh_display() -> void:
    var items: Array = Inventory.items.keys()
    for i in range(SLOT_COUNT):
        var slot: Control = _slots[i]
        var icon: TextureRect = slot.get_node("VBoxContainer/TextureRect")
        var label: Label = slot.get_node("VBoxContainer/Label")
        if i < items.size():
            var item_name: String = items[i]
            var count: int = Inventory.get_count(item_name)
            var tex_path: String = "res://assets/tiles/ores/%s_icon.png" % item_name
            if ResourceLoader.exists(tex_path):
                icon.texture = load(tex_path)
            label.text = str(count)
        else:
            icon.texture = null
            label.text = ""

func _input(event: InputEvent) -> void:
    # 1-9, 0 keys select hotbar slots
    for i in range(10):
        var key: int = KEY_1 + i if i < 9 else KEY_0
        if event is InputEventKey and event.keycode == key and event.pressed:
            _selected_slot = i
            _update_selection_highlight()

func _update_selection_highlight() -> void:
    for i in range(_slots.size()):
        # TODO: highlight selected slot with border
        pass
```

Generate hotbar art via PixelLab MCP:
```
Hotbar slot UI panel, 40×40px:
  Dark background #1A1A2E, subtle copper border #B87333,
  riveted corner details, industrial steampunk style
  No fantasy elements. Looks like a worn metal equipment panel.
Save to: res://assets/ui/hotbar_slot.png
```

---

## PHASE 2: CREATURES

### Wolf (hostile, night spawn)

Create `res://creatures/wolf.tscn`:
```
CharacterBody2D (root, script: wolf.gd)
  ├── AnimatedSprite2D (idle: 1 frame, walk: 4 frames, attack: 2 frames)
  ├── CollisionShape2D (capsule)
  ├── NavigationAgent2D (pathfinding to player at night)
  └── Area2D (detection radius 200px)
```

```gdscript
# res://creatures/wolf.gd
extends CharacterBody2D

const MOVE_SPEED: float = 80.0
const DETECT_RANGE: float = 200.0
const ATTACK_RANGE: float = 24.0
const ATTACK_DAMAGE: float = 10.0
const ATTACK_COOLDOWN: float = 1.5

var _target: Node2D = null
var _attack_timer: float = 0.0

func _ready() -> void:
    add_to_group("creatures")
    add_to_group("hostile_creatures")

func _physics_process(delta: float) -> void:
    _seek_target()
    _attack_cooldown_tick(delta)
    if _target:
        _move_toward_target(delta)

func _seek_target() -> void:
    var player: Node2D = get_tree().get_first_node_in_group("player")
    if player and global_position.distance_to(player.global_position) < DETECT_RANGE:
        _target = player
    else:
        _target = null

func _move_toward_target(delta: float) -> void:
    if not _target: return
    var dir: Vector2 = (_target.global_position - global_position).normalized()
    if global_position.distance_to(_target.global_position) > ATTACK_RANGE:
        velocity.x = dir.x * MOVE_SPEED
        velocity.y += 900.0 * delta  # gravity
    else:
        velocity.x = 0
        _try_attack()
    move_and_slide()

func _try_attack() -> void:
    if _attack_timer <= 0.0:
        # Deal damage to player
        if _target.has_method("take_damage"):
            _target.take_damage(ATTACK_DAMAGE)
        _attack_timer = ATTACK_COOLDOWN

func _attack_cooldown_tick(delta: float) -> void:
    if _attack_timer > 0.0:
        _attack_timer -= delta
```

### Rabbit (passive surface critter)

Create `res://creatures/rabbit.tscn` and `rabbit.gd`:
- Hops around surface randomly
- Flees when player gets within 120px
- CharacterBody2D with gravity
- Hop: brief upward velocity, then falls, then waits 2-4 seconds, then hops again
- Uses AnimatedSprite2D (idle: 1 frame, hop: 2 frames)

### Small Bird (passive surface critter)

Create `res://creatures/bird.tscn` and `bird.gd`:
- Flies horizontally between random points on the surface
- No collision with world (flies above)
- Flutters wings (animated sprite)
- Disappears off screen and respawns elsewhere

Generate creature art via PixelLab MCP:
```
Wolf pixel art sprite sheet for Terra.Watt, 24×16px per frame:
  idle: 1 frame (standing, alert), walk: 4 frames, attack: 2 frames (lunging)
  Style: dark grey wolf, slightly menacing, chunky pixel art
  Background: transparent
Save to: res://assets/creatures/wolf_frames.png

Rabbit pixel art, 12×12px per frame, idle + hop 2 frames.
  Style: small, fluffy, light brown, cute. Transparent background.
Save to: res://assets/creatures/rabbit_frames.png

Small bird pixel art, 10×8px, idle + flap 2 frames.
  Style: small brown sparrow. Transparent background.
Save to: res://assets/creatures/bird_frames.png
```

---

## FINAL REPORT

```
UI & CREATURES AGENT — FINAL REPORT

✅ hud.tscn: HUD scene with all panels assembled
✅ status_icons.gd: 3 status icons (wet, fire, suffocating) working
✅ hotbar.gd: 10-slot hotbar displays Inventory contents
✅ wolf.tscn: hostile night creature, chases player, deals damage
✅ rabbit.tscn: passive hopping critter, flees from player
✅ bird.tscn: passive flying surface critter
✅ All creature/UI art generated via PixelLab MCP
✅ All commits pushed: [latest commit hash]
✅ AGENT_STATUS.md updated

Self-Audit Complete. UI and creature systems verified.
```

━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
TERRAWATT — POWER TIER 0 AGENT (AGENT 6)
Single command: Paste this entire block into a Cursor Composer Agent tab and press Enter.
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

## MISSION: Build Tier 0 power structures — Water Wheel, Windmill, Steam Engine.

---

## PHASE 0: READ YOUR DOCTRINE (MANDATORY FIRST STEP)

1. Read `TERRAWATT_DOCTRINE.md`
2. Read `TERRAWATT_GDD.md` — Tier 0 section and the Power Grid system (Section 6).
3. Read `AGENT_STATUS.md`
4. Read `res://power/power_grid.gd` stub — you will replace this.
5. Note: water and steam pixel sim particles come from SimManager.
   Use stubs if Pixel Sim Agent hasn't delivered yet.

---

## PHASE 1: POWER GRID (REPLACE STUB)

Replace `res://power/power_grid.gd`:

```gdscript
# SYSTEM: Power Grid
# AGENT: Power Tier 0 Agent
# PURPOSE: Tracks all registered power sources and consumers.
# Tier 0: mechanical power only. No electrical grid yet.

extends Node

class_name PowerGrid

# All registered sources: node → { watts: float, position: Vector2 }
var sources: Dictionary = {}
# Total power stats
var total_generation: float = 0.0
var total_demand:     float = 0.0

func _process(_delta: float) -> void:
    _recalculate_totals()

func register_source(node: Node, watts: float) -> void:
    sources[node] = {"watts": watts, "position": node.global_position if node is Node2D else Vector2.ZERO}
    _recalculate_totals()

func unregister_source(node: Node) -> void:
    sources.erase(node)
    _recalculate_totals()

func update_source_output(node: Node, new_watts: float) -> void:
    if sources.has(node):
        sources[node]["watts"] = new_watts
        _recalculate_totals()

func get_local_power(pos: Vector2) -> float:
    # Tier 0: local mechanical power — return output of nearest source within 10 tiles
    var nearest_watts: float = 0.0
    var nearest_dist: float = 10.0 * 16.0  # 10 tiles in pixels
    for node in sources:
        if node is Node2D:
            var dist: float = (node as Node2D).global_position.distance_to(pos)
            if dist < nearest_dist:
                nearest_dist = dist
                nearest_watts = sources[node]["watts"]
    return nearest_watts

func _recalculate_totals() -> void:
    total_generation = 0.0
    for node in sources:
        total_generation += sources[node]["watts"]
    power_updated.emit(total_generation, total_demand)

signal power_updated(generation: float, demand: float)
```

---

## PHASE 2: POWER SOURCE BASE CLASS

Create `res://power/power_source_base.gd`:

```gdscript
# Base class for all Tier 0 power structures.
extends StaticBody2D

class_name PowerSourceBase

@export var max_output_watts: float = 100.0
var current_output_watts:     float = 0.0
var is_operating:             bool = false

func _ready() -> void:
    add_to_group("power_sources")
    PowerGrid.register_source(self, 0.0)

func _exit_tree() -> void:
    PowerGrid.unregister_source(self)

func set_output(watts: float) -> void:
    current_output_watts = clamp(watts, 0.0, max_output_watts)
    PowerGrid.update_source_output(self, current_output_watts)
    is_operating = current_output_watts > 0.0

func get_output_fraction() -> float:
    return current_output_watts / max_output_watts if max_output_watts > 0 else 0.0
```

---

## PHASE 3: WATER WHEEL

Create `res://power/sources/water_wheel.gd`:

```gdscript
# Water Wheel — requires flowing water particles adjacent to generate power.
# Output: 0-50W based on water flow rate nearby.

extends PowerSourceBase

const BASE_OUTPUT: float = 50.0
const WATER_CHECK_RADIUS: int = 2  # tiles

@onready var wheel_sprite: AnimatedSprite2D = $WheelSprite

func _physics_process(_delta: float) -> void:
    var flow_rate: float = _measure_water_flow()
    set_output(BASE_OUTPUT * flow_rate)
    if is_operating:
        wheel_sprite.play("spin")
        wheel_sprite.speed_scale = get_output_fraction() * 2.0
    else:
        wheel_sprite.play("idle")

func _measure_water_flow() -> float:
    # Check SimManager for water particles near the wheel
    var my_tile: Vector2i = Vector2i(
        int(global_position.x / 16),
        int(global_position.y / 16)
    )
    var water_cells: int = 0
    for dx in range(-WATER_CHECK_RADIUS, WATER_CHECK_RADIUS + 1):
        for dy in range(-WATER_CHECK_RADIUS, WATER_CHECK_RADIUS + 1):
            var cell: Dictionary = SimManager.get_cell(my_tile.x + dx, my_tile.y + dy)
            if cell.get("material_id", 0) == MaterialRegistry.MAT_WATER:
                water_cells += 1
    return clamp(float(water_cells) / 8.0, 0.0, 1.0)
```

Scene structure: StaticBody2D → AnimatedSprite2D (WheelSprite), CollisionShape2D, PointLight2D (soft ambient)

---

## PHASE 4: WINDMILL

Create `res://power/sources/windmill.gd`:

```gdscript
# Windmill — variable output based on simulated wind.
# Must be placed at surface (Y <= get_surface_y + 5).
# Output: 0-30W average, peaks to 80W in strong wind.

extends PowerSourceBase

const MIN_OUTPUT:    float = 5.0
const MAX_OUTPUT:    float = 80.0
const WIND_CYCLE:    float = 30.0  # seconds for a full wind cycle

var _wind_time: float = 0.0

@onready var blade_sprite: AnimatedSprite2D = $BladeSprite

func _physics_process(delta: float) -> void:
    _wind_time += delta
    var wind_strength: float = _calculate_wind()
    set_output(lerp(MIN_OUTPUT, MAX_OUTPUT, wind_strength))
    blade_sprite.speed_scale = get_output_fraction() * 3.0
    if not blade_sprite.is_playing():
        blade_sprite.play("spin")

func _calculate_wind() -> float:
    # Sinusoidal wind with some noise for natural variation
    var base_wind: float = (sin(_wind_time * TAU / WIND_CYCLE) + 1.0) / 2.0
    var noise_offset: float = sin(_wind_time * 7.3) * 0.1  # slight turbulence
    return clamp(base_wind + noise_offset, 0.0, 1.0)
```

---

## PHASE 5: WOOD-FIRED STEAM ENGINE

Create `res://power/sources/steam_engine.gd`:

```gdscript
# Wood-fired Steam Engine — burns wood logs, requires water, produces steam particles.
# Output: 0-200W when fueled and watered.

extends PowerSourceBase

const FULL_OUTPUT:       float = 200.0
const WOOD_BURN_RATE:    float = 1.0 / 30.0  # 1 wood per 30 seconds
const WATER_CONSUME_RATE:float = 0.5          # water units per second

var wood_fuel:   float = 0.0   # wood log count stored
var water_level: float = 0.0   # 0.0-10.0 units
var _burn_timer: float = 0.0

@onready var smoke_emit_pos: Marker2D = $SmokeEmitPos

func _physics_process(delta: float) -> void:
    _tick_burn(delta)

func _tick_burn(delta: float) -> void:
    if wood_fuel > 0 and water_level > 0:
        # Consume fuel and water
        _burn_timer += delta
        if _burn_timer >= 1.0 / WOOD_BURN_RATE:
            wood_fuel -= 1.0
            _burn_timer = 0.0
        water_level -= WATER_CONSUME_RATE * delta
        water_level = max(water_level, 0.0)
        set_output(FULL_OUTPUT)
        # Emit steam particles above smokestack
        if randf() < 0.1:  # 10% chance per frame
            SimManager.add_particle(
                int(smoke_emit_pos.global_position.x / 16),
                int(smoke_emit_pos.global_position.y / 16),
                MaterialRegistry.MAT_STEAM
            )
            SimManager.add_particle(
                int(smoke_emit_pos.global_position.x / 16),
                int(smoke_emit_pos.global_position.y / 16),
                MaterialRegistry.MAT_SMOKE
            )
    else:
        set_output(0.0)

func add_wood(amount: float) -> void:
    wood_fuel += amount
    print("Steam Engine: Added %.0f wood. Total fuel: %.0f" % [amount, wood_fuel])

func add_water(amount: float) -> void:
    water_level = min(water_level + amount, 10.0)
```

---

## PHASE 6: GENERATE ART VIA PIXELLAB MCP

```
Water Wheel sprite sheet, 48×32px, 4 spinning frames.
  Style: old wooden water wheel with iron banding, mossy, weathered.
  16-era industrial, Starbound warmth. Transparent background.

Windmill sprite sheet, 32×64px, 4 blade rotation frames.
  Style: old stone windmill tower, canvas sails. 1800s frontier look.
  Transparent background.

Steam Engine sprite, 48×40px, 1 idle + 2 operating frames (steam puffing).
  Style: cast iron box boiler, copper pipes, brass fittings, pressure gauge.
  Industrial steampunk aesthetic. Transparent background.
```

---

## FINAL REPORT

```
POWER TIER 0 AGENT — FINAL REPORT

✅ PowerGrid.gd: source registration, output tracking, local power query
✅ PowerSourceBase: shared base class for all generators
✅ WaterWheel: reads SimManager water presence, variable output, spinning sprite
✅ Windmill: sinusoidal wind simulation, variable output, blade animation
✅ SteamEngine: wood fuel consumption, water consumption, steam/smoke particle emission
✅ All power structure art generated via PixelLab MCP
✅ All commits pushed: [latest commit hash]
✅ AGENT_STATUS.md updated

Self-Audit Complete. Tier 0 power systems verified.
```

━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
TERRAWATT — INTEGRATION AGENT (AGENT 7 — RUN LAST)
Single command: Paste this entire block into a Cursor Composer Agent tab and press Enter.
Run this ONLY after all 6 other agents have STATUS: COMPLETE in AGENT_STATUS.md
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

## MISSION: Wire everything together into a working, launchable game.

---

## PHASE 0: READ YOUR DOCTRINE (MANDATORY FIRST STEP)

1. Read `TERRAWATT_DOCTRINE.md`
2. Read `TERRAWATT_GDD.md` — all of Section 16 (folder structure)
3. Read `AGENT_STATUS.md` — EVERY agent must show STATUS: COMPLETE
   If any agent is not COMPLETE, poll every 5 minutes:
   ```bash
   git pull origin main && grep "STATUS:" AGENT_STATUS.md
   ```
   Do NOT proceed until all show COMPLETE.
4. Read ALL agent notes files (res://[system]/AGENT_NOTES.md for each system)
5. Run `git log --oneline -20` to see all recent commits from all agents

---

## PHASE 1: FULL CODEBASE AUDIT

Read every script in the project. Build a map of:
- What each autoload exposes
- What signals fire and from where
- What scenes exist and what they contain
- Any missing connections or broken references

Output a ≤100 line digest of findings. Flag any issues before touching code.

---

## PHASE 2: WIRE UP main.tscn

Replace the stub main.tscn with the full scene:

```
Node2D (root, script: main.gd)
  ├── SimRenderer (scene: res://simulation/sim_renderer.tscn, rendered below tiles)
  ├── WorldRenderer (scene: res://world/world_renderer.tscn)
  ├── BackgroundLayer (scene: res://world/background.tscn)
  ├── LightingManager (script: res://world/lighting.gd)
  │     └── DarknessOverlay (ColorRect, full screen, z_index: 10)
  ├── Player (scene: res://player/player.tscn)
  ├── Camera2D (name: GameCamera, follow player)
  │     smoothing_enabled: true, smoothing_speed: 8.0
  ├── CreatureSpawner (script: creature_spawner.gd)
  └── HUD (scene: res://ui/hud.tscn, CanvasLayer)
```

### res://main.gd (FULL IMPLEMENTATION):

```gdscript
# SYSTEM: Main
# AGENT: Integration Agent
# PURPOSE: Initializes all systems, wires connections, starts the game.

extends Node2D

const WORLD_SEED: int = 12345  # TODO: replace with world selection screen

@onready var world_renderer:   Node2D     = $WorldRenderer
@onready var background_layer: Node2D     = $BackgroundLayer
@onready var lighting_manager: Node2D     = $LightingManager
@onready var player:           CharacterBody2D = $Player
@onready var game_camera:      Camera2D   = $GameCamera
@onready var hud:              CanvasLayer = $HUD
@onready var creature_spawner: Node       = $CreatureSpawner
@onready var sim_renderer:     Node2D     = $SimRenderer

func _ready() -> void:
    print("Terra.Watt: Initializing world (seed %d)..." % WORLD_SEED)

    # 1. Initialize world data
    WorldData.initialize(WORLD_SEED)

    # 2. Find player spawn point and position player
    var spawn: Vector2 = SpawnLocator.find_spawn_point(200)
    player.global_position = spawn
    print("Terra.Watt: Player spawned at %s" % spawn)

    # 3. Wire camera to follow player
    game_camera.set_target(player) if game_camera.has_method("set_target") else null
    game_camera.global_position = player.global_position

    # 4. Wire renderer to camera
    world_renderer.set_camera(game_camera) if world_renderer.has_method("set_camera") else null

    # 5. Wire lighting to player
    var player_light: PointLight2D = player.get_node_or_null("Headlamp")
    if player_light:
        lighting_manager.set_player_light(player_light)

    # 6. Wire HUD status icons to player
    var status_icons: Node = hud.get_node_or_null("StatusIconBar")
    # (StatusIconBar connects itself to player in its _ready)

    # 7. Start creature spawner
    creature_spawner.set_player(player)

    print("Terra.Watt: All systems initialized. Game running.")

func _process(delta: float) -> void:
    # Update parallax background with camera position
    background_layer.update_parallax(game_camera.global_position)

    # Keep camera following player smoothly
    game_camera.global_position = game_camera.global_position.lerp(
        player.global_position, delta * 8.0
    )
```

---

## PHASE 3: CREATURE SPAWNER

Create `res://creatures/creature_spawner.gd`:
- Spawns wolves at night (in-game time darkness check) at surface, 30+ tiles from player
- Spawns rabbits at day at surface within 40-80 tile radius of player
- Spawns birds randomly at surface in 20-60 tile radius
- Max 3 wolves, 5 rabbits, 4 birds at a time
- Despawns creatures > 100 tiles from player

---

## PHASE 4: DAY/NIGHT CYCLE

Create `res://world/day_night_cycle.gd`:
- Day = 10 minutes real time, Night = 5 minutes
- Drives sky color (LightingManager background tint)
- Drives creature spawner (wolves at night)
- Drives BackgroundLayer color modulation (warm day → cold blue night)

---

## PHASE 5: INPUT MAP VERIFICATION

Verify these actions exist in Godot Project > Input Map:
- `ui_left`, `ui_right`, `ui_up`, `ui_down`, `ui_accept` (built-in)
- `mine` — left mouse button
- `place` — right mouse button
- `hotbar_1` through `hotbar_0` — keys 1-9, 0

Add any missing ones programmatically in main.gd _ready() if needed.

---

## PHASE 6: FULL GAME TEST

Run main.tscn and verify all of these work:

```
✅ Game opens without errors
✅ World generates — surface terrain visible with correct tiles
✅ Player spawns on surface
✅ Player moves left/right with WASD/arrows
✅ Player jumps with Space
✅ Camera follows player smoothly
✅ Background parallax scrolls at different speeds
✅ Underground gets darker as player descends
✅ Player headlamp glows in dark areas
✅ Click a tile to mine it — progress ring shows — tile disappears
✅ Collectible item drops and bobs — auto-collects on contact
✅ Hotbar updates with collected item
✅ Water flows if placed — pixel sim working
✅ Fire spreads if placed — pixel sim working
✅ Steam rises from fire — pixel sim working
✅ Rabbit hops around surface
✅ Wolf appears at night and chases player
✅ Wet status icon appears when player touches water
✅ Fire status icon appears when player touches fire
```

If any test fails — use Claude Code:
```bash
claude "Integration bug: [describe]. main.gd: [paste relevant code]. Fix."
```

---

## PHASE 7: FINAL COMMIT

```bash
git add -A
git commit -m "[Integration] feat: Terra.Watt Scope 1 complete — all systems wired, game playable"
git push origin main
```

---

## FINAL REPORT FORMAT

```
INTEGRATION AGENT — FINAL REPORT

Systems integrated:
  ✅ / ⚠️ / 🚧  Pixel Simulation
  ✅ / ⚠️ / 🚧  World Generation
  ✅ / ⚠️ / 🚧  Player / Mining
  ✅ / ⚠️ / 🚧  Visuals / Art
  ✅ / ⚠️ / 🚧  UI / Creatures
  ✅ / ⚠️ / 🚧  Power Tier 0

Game test results: [N/22 tests passing]
Issues found and resolved: [list any ⚠️ items with fix description]
Remaining blockers: [list any 🚧 items]

Final commit: [hash]

[If all 22 tests pass:]
Self-Audit Complete. Terra.Watt Scope 1 is verified and playable.
Mission accomplished.

[If blockers remain:]
Self-Audit Complete. CRITICAL ISSUES FOUND:
[list each blocker with file:line reference and recommended fix]
```
