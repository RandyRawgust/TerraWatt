TERRAWATT — PIXEL SIMULATION AGENT
Single command: Paste this entire block into a Cursor Composer Agent tab and press Enter.
Run this SIMULTANEOUSLY with World Gen, Player, Visual, UI, and Power agents after Foundation Agent completes.

━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

## MISSION: Build the cellular automata pixel simulation engine — the heart of Terra.Watt.

You are the PIXEL SIM AGENT. This is the HIGHEST PRIORITY system in the entire game.
Everything interesting in Terra.Watt — fire spreading, water flowing, steam rising,
explosions, meltdowns — depends on what you build. Do not rush it. Build it correctly.

Your output: a working C++ GDExtension that simulates pixels using cellular automata,
integrated with Godot 4 via a GDScript manager, rendering correctly over the tile layer.

---

## PHASE 0: READ YOUR DOCTRINE (MANDATORY FIRST STEP)

1. Read `TERRAWATT_DOCTRINE.md` — your operating rules.
2. Read `TERRAWATT_GDD.md` — specifically Section 4 (Pixel Simulation Layer) in full.
3. Read `AGENT_STATUS.md` — check Foundation Agent is COMPLETE before proceeding.
4. Read existing stub at `res://simulation/sim_manager.gd` — you are replacing this stub.

If Foundation Agent is NOT COMPLETE, poll every 3 minutes:
```bash
git pull origin main && cat AGENT_STATUS.md
```
Do NOT wait idly. While waiting, write and test your C++ simulation code locally.

---

## PHASE 1: RECONNAISSANCE — UNDERSTAND THE ARCHITECTURE

Study these before writing a single line:
- Godot 4 GDExtension documentation approach (you will use GDExtension, NOT GDNative)
- SCons build system for Godot 4 C++ extensions
- Cellular automata fundamentals: each cell checks neighbors each tick and updates state
- Noita's "falling sand" simulation approach (this is your reference)
- The Powder Toy material interaction model

Output a ≤100 line digest confirming you understand:
- How GDExtension registers a C++ class with Godot
- How cellular automata update order works (why you must use double buffering)
- How the simulation grid relates to the Godot TileMap

---

## PHASE 2: C++ GDEXTENSION — SIMULATION CORE

### Build System Setup

Create `res://simulation/gdextension/SConstruct`:
```python
#!/usr/bin/env python
import os, sys
env = SConscript("godot-cpp/SConstruct")
env.Append(CPPPATH=["src/"])
sources = Glob("src/*.cpp")
library = env.SharedLibrary("../../../bin/libterrawatt_sim{}{}".format(
    env["suffix"], env["SHLIBSUFFIX"]))
Default(library)
```

Create `res://simulation/gdextension/terrawatt_sim.gdextension`:
```ini
[configuration]
entry_symbol = "terrawatt_sim_init"
compatibility_minimum = "4.1"

[libraries]
macos.debug   = "res://bin/libterrawatt_sim.macos.template_debug.framework"
windows.debug.x86_64 = "res://bin/libterrawatt_sim.windows.template_debug.x86_64.dll"
linux.debug.x86_64   = "res://bin/libterrawatt_sim.linux.template_debug.x86_64.so"
```

### Core C++ Files

Create `res://simulation/gdextension/src/sim_cell.h`:
```cpp
#pragma once
#include <cstdint>

// Bitmask flags for cell state
namespace CellFlags {
    constexpr uint8_t UPDATED  = 0x01; // Already processed this tick
    constexpr uint8_t WET      = 0x02; // Cell is wet (affects player status)
    constexpr uint8_t BURNING  = 0x04; // Cell is on fire
    constexpr uint8_t FALLING  = 0x08; // Solid falling due to gravity
}

struct SimCell {
    uint16_t material_id;  // 0 = air
    float    temperature;  // Celsius, affects phase changes
    uint8_t  flags;
    uint8_t  lifetime;     // For particles that expire (smoke, steam)

    SimCell() : material_id(0), temperature(20.0f), flags(0), lifetime(255) {}
    SimCell(uint16_t mat, float temp = 20.0f)
        : material_id(mat), temperature(temp), flags(0), lifetime(255) {}

    bool is_air()    const { return material_id == 0; }
    bool is_updated()const { return flags & CellFlags::UPDATED; }
    bool is_wet()    const { return flags & CellFlags::WET; }
    bool is_burning()const { return flags & CellFlags::BURNING; }
};
```

Create `res://simulation/gdextension/src/material_defs.h`:
```cpp
#pragma once
#include <cstdint>

// Material IDs — must match MaterialRegistry.gd constants exactly
namespace MatID {
    constexpr uint16_t AIR        = 0;
    constexpr uint16_t DIRT       = 1;
    constexpr uint16_t STONE      = 2;
    constexpr uint16_t GRASS_DIRT = 3;
    constexpr uint16_t COAL       = 4;
    constexpr uint16_t COPPER_ORE = 5;
    constexpr uint16_t IRON_ORE   = 6;
    constexpr uint16_t CLAY       = 7;
    // Simulation particles (100+)
    constexpr uint16_t WATER      = 100;
    constexpr uint16_t STEAM      = 101;
    constexpr uint16_t FIRE       = 102;
    constexpr uint16_t SMOKE      = 103;
    constexpr uint16_t ASH        = 104;
    constexpr uint16_t MUD        = 105;
    constexpr uint16_t COAL_DUST  = 106;
    constexpr uint16_t EMBERS     = 107;
}

// Material categories
enum class MatCategory { SOLID, LIQUID, GAS, ENERGY };

struct MaterialDef {
    uint16_t    id;
    MatCategory category;
    float       density;         // for liquid layering
    bool        flammable;
    float       ignition_temp;   // Celsius threshold for ignition
    float       burn_rate;       // fuel consumed per tick when burning
    bool        conducts_elec;
    bool        radioactive;
    bool        falls_gravity;   // sand, gravel, coal dust
    float       viscosity;       // 0=flows free, 1=solid-like (mud)
};

// Static table of all material definitions
// Indexed by MatID value
static const MaterialDef MATERIAL_TABLE[] = {
    //id                  cat             dens  flamm  ign   burn   elec   rad    fall   visc
    {MatID::AIR,          MatCategory::GAS,    0.0f, false, 0,    0,     false, false, false, 0.0f},
    {MatID::DIRT,         MatCategory::SOLID,  2.0f, false, 0,    0,     false, false, false, 0.0f},
    {MatID::STONE,        MatCategory::SOLID,  3.0f, false, 0,    0,     false, false, false, 0.0f},
    {MatID::GRASS_DIRT,   MatCategory::SOLID,  2.0f, false, 0,    0,     false, false, false, 0.0f},
    {MatID::COAL,         MatCategory::SOLID,  1.8f, true,  300,  0.02f, false, false, false, 0.0f},
    {MatID::WATER,        MatCategory::LIQUID, 1.0f, false, 0,    0,     true,  false, false, 0.1f},
    {MatID::STEAM,        MatCategory::GAS,    0.1f, false, 0,    0,     false, false, false, 0.0f},
    {MatID::FIRE,         MatCategory::ENERGY, 0.1f, false, 0,    0,     false, false, false, 0.0f},
    {MatID::SMOKE,        MatCategory::GAS,    0.2f, false, 0,    0,     false, false, false, 0.0f},
    {MatID::ASH,          MatCategory::SOLID,  0.5f, false, 0,    0,     false, false, true,  0.0f},
    {MatID::MUD,          MatCategory::LIQUID, 1.8f, false, 0,    0,     false, false, false, 0.8f},
    {MatID::COAL_DUST,    MatCategory::SOLID,  0.8f, true,  200,  0.05f, false, false, true,  0.0f},
    {MatID::EMBERS,       MatCategory::ENERGY, 0.3f, false, 0,    0,     false, false, true,  0.0f},
};

inline const MaterialDef& get_mat(uint16_t id) {
    if (id < sizeof(MATERIAL_TABLE)/sizeof(MATERIAL_TABLE[0]))
        return MATERIAL_TABLE[id];
    return MATERIAL_TABLE[MatID::AIR];
}
```

Create `res://simulation/gdextension/src/sim_core.h`:
```cpp
#pragma once
#include "sim_cell.h"
#include "material_defs.h"
#include <vector>
#include <random>

class SimCore {
public:
    // Grid dimensions in simulation pixels (not world tiles)
    // 1 world tile = SIM_SCALE × SIM_SCALE simulation cells
    static constexpr int SIM_SCALE  = 4;   // 4x4 sim cells per tile
    static constexpr int CHUNK_SIZE = 32;  // tiles per chunk

    SimCore(int width_tiles, int height_tiles);
    ~SimCore() = default;

    // Advance simulation by one tick. Call once per physics frame.
    void step();

    // Cell access (in SIMULATION pixel coordinates, not tile coords)
    SimCell& get_cell(int x, int y);
    const SimCell& get_cell(int x, int y) const;
    void set_cell(int x, int y, const SimCell& cell);

    // Tile-space convenience access (converts tile→sim coords)
    void set_tile(int tile_x, int tile_y, uint16_t material_id);
    uint16_t get_tile_material(int tile_x, int tile_y) const;

    // Spawn a simulation particle at sim-space coords
    void add_particle(int x, int y, uint16_t material_id, float temperature = 20.0f);

    // Returns true if the grid has any active (non-sleeping) cells
    bool has_active_cells() const;

    int get_sim_width()  const { return sim_width; }
    int get_sim_height() const { return sim_height; }

private:
    int sim_width, sim_height;
    std::vector<SimCell> grid_a, grid_b;   // double buffer
    std::vector<SimCell>* current;
    std::vector<SimCell>* next;
    std::mt19937 rng;
    int tick_count;

    // Per-material update rules
    void update_water(int x, int y);
    void update_steam(int x, int y);
    void update_fire(int x, int y);
    void update_smoke(int x, int y);
    void update_falling_solid(int x, int y);   // ash, coal dust, embers
    void update_liquid(int x, int y, float viscosity);

    // Interaction checks
    void check_fire_spread(int x, int y);
    void check_water_extinguish(int x, int y);
    void check_phase_change(int x, int y);     // water→steam at >100°C

    // Utilities
    bool in_bounds(int x, int y) const;
    bool is_empty(int x, int y) const;
    bool can_displace(int x, int y, uint16_t by_material) const;
    void swap_cells(int x1, int y1, int x2, int y2);
    SimCell& cell(int x, int y);
    const SimCell& cell(int x, int y) const;
};
```

Create `res://simulation/gdextension/src/sim_core.cpp`:
Implement all methods from sim_core.h. Key rules:
- Double buffering: read from `current`, write to `next`, swap at end of step()
- Process grid bottom-to-top for falling materials, top-to-bottom for rising gases
- Alternate left-to-right / right-to-left each tick to prevent directional bias
- Use rng for randomized spread (fire, liquid sideways flow)
- Clear UPDATED flags at start of each tick
- Water rule: fall if below is empty, else spread sideways randomly
- Steam rule: rise if above is empty/gas, condense to water if temp < 80°C
- Fire rule: spread to adjacent flammable cells with probability, consume fuel, produce smoke above
- Smoke rule: rise, dissipate with lifetime counter
- Falling solid (ash, coal dust): fall if below empty, pile up

Create `res://simulation/gdextension/src/register_types.cpp`:
```cpp
#include "register_types.h"
#include "terrawatt_sim_node.h"
#include <gdextension_interface.h>
#include <godot_cpp/core/defs.hpp>
#include <godot_cpp/godot.hpp>

using namespace godot;

void initialize_terrawatt_sim(ModuleInitializationLevel p_level) {
    if (p_level != MODULE_INITIALIZATION_LEVEL_SCENE) return;
    ClassDB::register_class<TerrawattSimNode>();
}

void uninitialize_terrawatt_sim(ModuleInitializationLevel p_level) {
    if (p_level != MODULE_INITIALIZATION_LEVEL_SCENE) return;
}

extern "C" {
GDExtensionBool GDE_EXPORT terrawatt_sim_init(
        GDExtensionInterfaceGetProcAddress p_get_proc_address,
        const GDExtensionClassLibraryPtr p_library,
        GDExtensionInitialization *r_initialization) {
    godot::GDExtensionBinding::InitObject init_obj(p_get_proc_address, p_library, r_initialization);
    init_obj.register_initializer(initialize_terrawatt_sim);
    init_obj.register_terminator(uninitialize_terrawatt_sim);
    init_obj.set_minimum_initialization_level(MODULE_INITIALIZATION_LEVEL_SCENE);
    return init_obj.init();
}
}
```

Create `res://simulation/gdextension/src/terrawatt_sim_node.h` and `.cpp`:
A Godot Node class that wraps SimCore, exposing:
- `step(delta: float)` — advance sim by one tick
- `get_cell_material(x: int, y: int) -> int`
- `set_cell_material(x: int, y: int, material_id: int)`
- `add_particle(x: int, y: int, material_id: int)`
- Signal: `cells_updated(region: Rect2i)` — emitted after each step for dirty regions

---

## PHASE 3: UPDATE sim_manager.gd (REPLACE STUB)

Once the GDExtension builds successfully, replace the stub:

```gdscript
# SYSTEM: Pixel Simulation
# AGENT: Pixel Sim Agent
# PURPOSE: GDScript wrapper that integrates C++ SimCore with Godot scene tree.
# Manages the simulation node, coordinates rendering updates.

extends Node

class_name SimManager

var _sim_node: Node = null  # TerrawattSimNode (C++ GDExtension)
var _is_loaded: bool = false

func _ready() -> void:
    _try_load_extension()

func _try_load_extension() -> void:
    # Attempt to load the C++ extension
    if ClassDB.class_exists("TerrawattSimNode"):
        _sim_node = ClassDB.instantiate("TerrawattSimNode")
        add_child(_sim_node)
        _sim_node.cells_updated.connect(_on_cells_updated)
        _is_loaded = true
        print("SimManager: C++ extension loaded successfully.")
    else:
        push_warning("SimManager: TerrawattSimNode not found. Using GDScript fallback.")
        _is_loaded = false

func _physics_process(delta: float) -> void:
    if _is_loaded and _sim_node:
        _sim_node.step(delta)

func get_cell(x: int, y: int) -> Dictionary:
    if _is_loaded:
        var mat_id: int = _sim_node.get_cell_material(x, y)
        return {"material_id": mat_id, "temperature": 20.0, "flags": 0}
    return {"material_id": 0, "temperature": 0.0, "flags": 0}

func set_cell(x: int, y: int, material_id: int) -> void:
    if _is_loaded:
        _sim_node.set_cell_material(x, y, material_id)

func add_particle(x: int, y: int, material_id: int) -> void:
    if _is_loaded:
        _sim_node.add_particle(x, y, material_id)

func _on_cells_updated(region: Rect2i) -> void:
    cell_changed.emit(region.position.x, region.position.y, 0)

signal cell_changed(x: int, y: int, material_id: int)
```

---

## PHASE 4: SIM RENDERER

Create `res://simulation/sim_renderer.gd`:
A Node2D that:
- Uses `_draw()` to render simulation cells as colored pixels
- Reads dirty regions from SimManager after each step
- Renders using a Texture2D that gets updated via Image.set_pixel()
- Uses color values from MaterialRegistry.get_color(id)
- Renders at sim-space resolution, scaled to screen via texture filtering
- Performance: only redraws dirty regions, not the full grid every frame

---

## PHASE 5: COMPILE AND VERIFY

```bash
# From project root
cd simulation/gdextension

# If godot-cpp not present, clone it:
git clone -b 4.3-stable https://github.com/godotengine/godot-cpp.git

# Build
scons platform=linux target=template_debug
# or: scons platform=windows target=template_debug
# or: scons platform=macos target=template_debug

# If build fails — USE CLAUDE CODE:
claude "GDExtension build failed. Error: [paste error].
        SConstruct: [paste file]. Fix the build error."
```

---

## PHASE 6: INTEGRATION TEST

Write a minimal test scene `res://simulation/test_sim.tscn` that:
1. Spawns 100 water particles at y=50
2. Spawns fire at x=50, y=30
3. Runs for 5 seconds and logs whether water flowed and fire spread
4. Checks that steam appears above fire
5. Verifies no Godot errors in output

Run it. Fix any issues. Use Claude Code for compile errors.

---

## PHASE 7: POLLING AND GIT

After each significant working component, commit:
```bash
git add -A
git commit -m "[PixelSim] feat: [describe what works now]"
git push origin main
```

If waiting for Foundation Agent: poll every 3 minutes:
```bash
git pull origin main && grep -A5 "Foundation Agent" AGENT_STATUS.md
```

---

## FINAL REPORT FORMAT

```
PIXEL SIM AGENT — FINAL REPORT

✅ C++ GDExtension compiles on [platform]
✅ TerrawattSimNode registered with Godot ClassDB
✅ sim_manager.gd stub replaced with real implementation
✅ Materials implemented: [list: water, steam, fire, smoke, ash, mud, coal_dust]
✅ Interactions working: [list: water flow, fire spread, water extinguishes fire, steam rise, etc.]
✅ sim_renderer.gd renders simulation cells correctly
✅ Integration test passed: water flows, fire spreads, steam rises
✅ All commits pushed: [latest commit hash]
✅ AGENT_STATUS.md updated

Self-Audit Complete. Pixel simulation engine verified and functional.
```
