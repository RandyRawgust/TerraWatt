TERRAWATT — TIER 1 COAL POWER AGENT
Single command: Paste this entire block into a Cursor Composer Agent tab and press Enter.
Run simultaneously with Sprites, Grid, Conveyors, and Pollution agents after Preflight completes.

━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

## MISSION: Build the complete coal → boiler → steam turbine → generator chain.
## This is the spine of Tier 1. Everything else in this tier connects to what you build.

---

## PHASE 0: DOCTRINE + RECON (MANDATORY)

1. Read `TERRAWATT_DOCTRINE.md` — full read.
   Key sections: DATA CONTRACTS, STUBS ADEQUACY CHECKLIST, RETROSPECTIVE.

2. Read `TERRAWATT_GDD.md` — Tier 1 section in full.

3. Read and understand these existing files before writing anything:
   - `res://power/power_source_base.gd` — you extend this
   - `res://power/power_grid.gd` — you register sources here
   - `res://simulation/material_registry.gd` — coal ID, smoke ID
   - `res://world/world_data.gd` — TILE_COAL constant
   - `res://player/inventory.gd` — players collect coal here

4. Run recon:
```bash
git pull origin main
cat AGENT_STATUS.md
git log --oneline -8
```

While waiting for Preflight (if needed), poll every 3 minutes:
```bash
git pull origin main ; grep -A3 "Preflight" AGENT_STATUS.md
```
Build all GDScript code while waiting. Only the SimManager-dependent parts
(steam particle emission) need Preflight complete.

---

## PHASE 1: COAL AS A PROPER MINEABLE RESOURCE

Coal already exists as TILE_COAL in WorldData. Verify it generates underground.
If coal mining drops generically as "coal" in inventory — that is correct.
What we need to add: coal is now a FUEL ITEM that machines recognize.

In `res://simulation/material_registry.gd`, confirm MAT_COAL = 4 and that
the material definition includes:
```gdscript
{"name": "Coal", "category": "SOLID", "color": Color(0.16, 0.16, 0.16),
 "flammable": true, "mine_time": 1.0, "ignition_temp": 300.0,
 "fuel_value": 30.0}   # ← add this: seconds of burn time per unit
```

Add `fuel_value` to any material definitions that are burnable fuels.
Wood gets `"fuel_value": 15.0` (burns faster, less heat).

---

## PHASE 2: COAL FURNACE

The coal furnace is the first machine the player places.
It burns coal to produce heat — feeds into the boiler.

Create `res://power/tier1/coal_furnace.gd` and `coal_furnace.tscn`:

```gdscript
# SYSTEM: Power / Tier 1
# AGENT: Coal Power Agent
# PURPOSE: Burns coal to produce heat. Feeds boiler via pipe connection.

extends StaticBody2D

class_name CoalFurnace

const MAX_COAL_STORED: int   = 20         # coal units
const BURN_RATE: float       = 1.0 / 30.0 # 1 coal per 30 sec
const HEAT_OUTPUT: float     = 150.0       # degrees C when burning

var coal_stored:   int   = 0
var is_burning:    bool  = false
var heat_output:   float = 0.0
var _burn_timer:   float = 0.0

@onready var flame_sprite: AnimatedSprite2D = $FlameSprite
@onready var smoke_emitter: Marker2D        = $SmokeEmitter

func _physics_process(delta: float) -> void:
    _tick_burn(delta)
    _emit_smoke_if_burning()

# Add coal from player inventory. Called by player interaction.
func add_coal(amount: int) -> int:
    var space: int = MAX_COAL_STORED - coal_stored
    var added: int = min(amount, space)
    coal_stored += added
    return added  # return how much was actually accepted

# Returns current heat output in degrees C.
func get_heat_output() -> float:
    return heat_output

func _tick_burn(delta: float) -> void:
    if coal_stored > 0:
        _burn_timer += delta
        if _burn_timer >= 1.0 / BURN_RATE:
            coal_stored -= 1
            _burn_timer = 0.0
        is_burning = true
        heat_output = HEAT_OUTPUT
        flame_sprite.play("burn")
    else:
        is_burning = false
        heat_output = 0.0
        flame_sprite.play("idle")

func _emit_smoke_if_burning() -> void:
    if is_burning and randf() < 0.15:
        var pos: Vector2i = Vector2i(
            int(smoke_emitter.global_position.x / 16),
            int(smoke_emitter.global_position.y / 16)
        )
        SimManager.add_particle(pos.x, pos.y, MaterialRegistry.MAT_SMOKE)
```

Scene structure for coal_furnace.tscn:
```
StaticBody2D (root, script: coal_furnace.gd)
  ├── Sprite2D (name: BodySprite, texture: res://assets/power/tier1/furnace.png)
  ├── AnimatedSprite2D (name: FlameSprite — idle + burn 3-frame animation)
  ├── CollisionShape2D (rectangle matching furnace body)
  ├── Marker2D (name: SmokeEmitter, positioned above chimney)
  ├── Marker2D (name: HeatOutputPort, positioned on right side — boiler connects here)
  └── Area2D (name: InteractArea, radius 32px — player can interact when inside)
        └── CollisionShape2D (CircleShape2D radius 32)
```

---

## PHASE 3: WATER BOILER

The boiler takes heat from the furnace and water from a pipe/bucket.
It converts them to steam → feeds turbine.

Create `res://power/tier1/water_boiler.gd` and `water_boiler.tscn`:

```gdscript
# SYSTEM: Power / Tier 1
# AGENT: Coal Power Agent
# PURPOSE: Converts furnace heat + water into high-pressure steam.

extends StaticBody2D

class_name WaterBoiler

const MAX_WATER:       float = 20.0   # litres
const WATER_PER_STEAM: float = 0.5    # litres per second when at temp
const MIN_HEAT_TO_BOIL:float = 100.0  # degrees C minimum
const STEAM_OUTPUT_MAX:float = 500.0  # watts equivalent steam power

var water_level:     float = 0.0
var steam_pressure:  float = 0.0
var _heat_source:    Node  = null     # connected CoalFurnace

@onready var pressure_gauge: Node2D = $PressureGauge
@onready var steam_emitter:  Marker2D = $SteamEmitter

func _physics_process(delta: float) -> void:
    _update_boiling(delta)
    _update_pressure_gauge()

# Connect a furnace as the heat source.
func connect_heat_source(furnace: Node) -> void:
    _heat_source = furnace

# Add water (from player bucket or pipe). Returns amount accepted.
func add_water(amount: float) -> float:
    var space: float = MAX_WATER - water_level
    var added: float = min(amount, space)
    water_level += added
    return added

# Returns current steam output (0.0 to STEAM_OUTPUT_MAX watts equivalent).
func get_steam_output() -> float:
    return steam_pressure

func _update_boiling(delta: float) -> void:
    var current_heat: float = 0.0
    if _heat_source and _heat_source.has_method("get_heat_output"):
        current_heat = _heat_source.get_heat_output()

    if current_heat >= MIN_HEAT_TO_BOIL and water_level > 0.0:
        water_level -= WATER_PER_STEAM * delta
        water_level = maxf(water_level, 0.0)
        steam_pressure = STEAM_OUTPUT_MAX * (current_heat / 150.0)
        # Emit visible steam particles
        if randf() < 0.25:
            var pos: Vector2i = Vector2i(
                int(steam_emitter.global_position.x / 16),
                int(steam_emitter.global_position.y / 16)
            )
            SimManager.add_particle(pos.x, pos.y, MaterialRegistry.MAT_STEAM)
    else:
        steam_pressure = maxf(steam_pressure - 50.0 * delta, 0.0)

func _update_pressure_gauge() -> void:
    # Rotate gauge needle based on pressure fraction
    var fraction: float = steam_pressure / STEAM_OUTPUT_MAX
    pressure_gauge.rotation = lerp(-1.2, 1.2, fraction)
```

---

## PHASE 4: STEAM TURBINE + GENERATOR

The turbine converts steam pressure into mechanical rotation → generator outputs watts.

Create `res://power/tier1/steam_turbine.gd` and `steam_turbine.tscn`:

```gdscript
# SYSTEM: Power / Tier 1
# AGENT: Coal Power Agent
# PURPOSE: Converts steam pressure to electrical output via generator.

extends PowerSourceBase

class_name SteamTurbine

const EFFICIENCY:     float = 0.75    # 75% of steam energy becomes watts
const MAX_OUTPUT:     float = 10000.0 # 10kW peak for Tier 1 turbine

var _steam_source: Node = null

@onready var turbine_sprite: AnimatedSprite2D = $TurbineSprite

func _ready() -> void:
    super._ready()  # registers with PowerGrid
    max_output_watts = MAX_OUTPUT

func _physics_process(_delta: float) -> void:
    _calculate_output()
    _update_animation()

# Connect a boiler as the steam source.
func connect_steam_source(boiler: Node) -> void:
    _steam_source = boiler

func _calculate_output() -> void:
    var steam_in: float = 0.0
    if _steam_source and _steam_source.has_method("get_steam_output"):
        steam_in = _steam_source.get_steam_output()
    set_output(steam_in * EFFICIENCY)

func _update_animation() -> void:
    var spin_speed: float = get_output_fraction() * 5.0
    turbine_sprite.speed_scale = spin_speed
    if spin_speed > 0.1:
        turbine_sprite.play("spin")
    else:
        turbine_sprite.play("idle")
```

---

## PHASE 5: PLAYER INTERACTION SYSTEM

Players need to interact with machines to load coal, add water, connect pipes.

Create `res://player/machine_interactor.gd`:

```gdscript
# SYSTEM: Player
# AGENT: Coal Power Agent
# PURPOSE: Handles player pressing E to interact with nearby machines.

extends Node

const INTERACT_RANGE: float = 48.0   # pixels
const INTERACT_KEY:   int   = KEY_E

@onready var player: Node2D = get_parent()

func _input(event: InputEvent) -> void:
    if event is InputEventKey and event.keycode == INTERACT_KEY and event.pressed:
        _try_interact()

func _try_interact() -> void:
    # Find nearest interactable machine within range
    var nearest: Node2D = null
    var nearest_dist: float = INTERACT_RANGE

    for machine in get_tree().get_nodes_in_group("machines"):
        if machine is Node2D:
            var dist: float = player.global_position.distance_to(machine.global_position)
            if dist < nearest_dist:
                nearest_dist = dist
                nearest = machine

    if nearest:
        _interact_with(nearest)

func _interact_with(machine: Node2D) -> void:
    # Coal furnace: load coal from inventory
    if machine.has_method("add_coal") and Inventory.has_item("coal", 1):
        var coal_in_inventory: int = Inventory.get_count("coal")
        var accepted: int = machine.add_coal(coal_in_inventory)
        Inventory.remove_item("coal", accepted)
        print("Loaded %d coal into furnace." % accepted)

    # Boiler: add water from inventory (water bucket item)
    elif machine.has_method("add_water") and Inventory.has_item("water_bucket", 1):
        var accepted: float = machine.add_water(5.0)
        if accepted > 0:
            Inventory.remove_item("water_bucket", 1)
            print("Added water to boiler.")

    # Turbine: connect to nearest boiler automatically
    elif machine.has_method("connect_steam_source"):
        var boiler: Node = _find_nearest_of_type("WaterBoiler", machine.global_position)
        if boiler:
            machine.connect_steam_source(boiler)
            print("Turbine connected to boiler.")
```

Add MachineInteractor as a child of the player in `player.tscn`.
Add all placed machines to the `"machines"` group in their `_ready()` functions.

---

## PHASE 6: GENERATE ART VIA PIXELLAB MCP

```
Generate pixel art sprites for Terra.Watt Tier 1 power machines.
Style: 1880s industrial era, cast iron, copper fittings, painted metal.
Painterly pixel art, 16px base unit, warm earthy industrial palette.

coal_furnace.png — 32×48px
  Brick-lined iron firebox with a small iron door showing orange glow.
  Short brick chimney on top. Copper pipe fittings on side.
  Dark iron body #2A2A2A, brick #8B4513, copper #B87333

furnace_flame_sheet.png — 3 frames × 16×16px (idle + 2 burn frames)
  Orange-yellow flame inside furnace door.

water_boiler.png — 32×48px
  Round iron pressure vessel, riveted seams, pressure gauge on front.
  Water inlet pipe on top. Steam outlet pipe on side.
  Iron body #3A3A3A, gauge face #F5F5DC, copper pipes #B87333

steam_turbine.png — 48×32px
  Industrial turbine housing with visible spinning blades through vent slots.
  Generator attached on right side with output terminals.
  Dark iron body, copper terminals, amber warning light when running.

turbine_spin_sheet.png — 4 frames × 16×16px (blade rotation)
  Spinning turbine blades, motion blur on fast frames.

Save all to: res://assets/power/tier1/
```

Validate each file is > 200 bytes. Regenerate any that fail.

---

## PHASE 7: CRAFT RECIPES

Add Tier 1 machine recipes to `res://crafting/recipe_registry.gd`
(create this file if it doesn't exist):

```gdscript
# SYSTEM: Crafting
# AGENT: Coal Power Agent
# PURPOSE: Defines all crafting recipes. Tier 1 machines require a Workbench.

extends Node

const RECIPES: Array[Dictionary] = [
    {
        "name": "Coal Furnace",
        "station": "workbench",
        "inputs": [{"item": "stone", "amount": 20}, {"item": "iron_ore", "amount": 5}],
        "output": {"item": "coal_furnace", "amount": 1},
        "tier": 1
    },
    {
        "name": "Water Boiler",
        "station": "workbench",
        "inputs": [{"item": "iron_ore", "amount": 15}, {"item": "copper_ore", "amount": 8}],
        "output": {"item": "water_boiler", "amount": 1},
        "tier": 1
    },
    {
        "name": "Steam Turbine",
        "station": "workbench",
        "inputs": [{"item": "iron_ore", "amount": 25}, {"item": "copper_ore", "amount": 12}],
        "output": {"item": "steam_turbine", "amount": 1},
        "tier": 1
    },
]
```

---

## FINAL REPORT

```
COAL POWER AGENT — FINAL REPORT

✅ MaterialRegistry: fuel_value added to Coal and Wood
✅ CoalFurnace: burns coal, outputs heat, emits smoke particles
✅ WaterBoiler: heat + water → steam pressure, emits steam particles
✅ SteamTurbine: steam → watts via PowerGrid.register_source
✅ MachineInteractor: E key loads coal into furnace, water into boiler
✅ All machines added to "machines" group
✅ PixelLab art generated for all 3 machines + animations
✅ Craft recipes registered in recipe_registry.gd
✅ Chain verified: mine coal → load furnace → add water to boiler
                   → turbine spins → PowerGrid shows watts
✅ Committed (path-scoped git add)
✅ AGENT_STATUS.md updated

Self-Audit Complete. Coal power chain functional end to end.
```
