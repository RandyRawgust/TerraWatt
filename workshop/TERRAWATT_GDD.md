# TERRAWATT — GAME DESIGN DOCUMENT
## Version 1.0 | Pre-Production Bible
## Status: ACTIVE — All agents must read this entire document before writing any code or generating any assets.

---

> **FOR AI AGENTS:** This document is your single source of truth. Every script, scene, asset, and system you build must conform to what is written here. If you encounter a conflict between this document and a task prompt, this document wins. When in doubt, ask — do not invent.

---

## 0. PROJECT IDENTITY

**Game Title:** Terra.Watt
**Tagline:** *"The world needs power. You're the only one who can give it."*
**Genre:** 2D Side-Scrolling Sandbox / Industrial Simulation
**Engine:** Godot 4 (GDScript primary, GDExtension C++ for pixel simulation layer)
**Target Platform:** PC (Windows/Mac/Linux)
**Development Approach:** Vibe coding with Cursor AI multi-agent workflow

### Visual Identity
- **Logo Style:** "Terra" in earthy stone lettering with grass and roots growing from it, transitioning to "Watt" in glowing electric-blue industrial lettering with pipes, gears, and smokestacks. A lightning bolt separates the two halves. A diamond crystal and wrench cross beneath the logo text.
- **Color Language:**
  - Earth side: warm browns (#8B6914), moss greens (#4A7C2F), stone greys (#6B6B6B)
  - Industry side: electric blue (#00AAFF), steel grey (#8899AA), warning amber (#FFB300)
  - UI / HUD: dark industrial panel (#1A1A2E), copper accent (#B87333), muted gold (#C9A84C)
- **Tile Size:** 16×16 pixels. Tiles have a slightly painterly, detailed texture — not flat pixel art. Think Starbound's warmth with a more grounded, earthier palette.
- **Player Sprite Size:** 24×40 pixels (Terraria proportions, chunky and readable)
- **Font:** Industrial stencil/slab style for UI. Clean sans for numbers/meters.

### Player Character Reference
The default player character is an industrial miner:
- Brown hardhat with mounted headlamp
- Yellow safety vest over grey armored chest plate
- Brown leather work pants
- Heavy work boots
- Backpack (visible on back, upgradeable)
- Holds drill/hammer depending on equipped tool
- The character should read as rugged, working-class, practical

---

## 1. CONCEPT SUMMARY

Terra.Watt is a **2D infinite sandbox power generation game**. The player is dropped into a procedurally generated world at the dawn of the industrial age. Beneath their feet are the raw materials needed to power a civilization. Above ground, demand for electricity is growing — and it will never stop.

The player mines, refines, builds, and manages an ever-growing power grid across 8 technology tiers spanning from water wheels to fusion reactors. The world is made of **simulated materials** (cellular automata) — water flows, oil burns, gas explodes, radioactive particles drift. No two playthroughs are the same.

**There is no win condition.** The game is endless. The demand always grows.

### Inspirations
| Game | What We Borrow |
|---|---|
| Terraria | Core mining loop, building, world structure, wiring, UI feel |
| Starbound | Visual warmth, pixel art style, exploration feel |
| Satisfactory | Tech tier progression, factory logic, power grid, no tutorial needed |
| Noita | Cellular automata physics, status icons, emergent danger, meltdown events |
| The Powder Toy | Material interactions, simulation depth, fire/liquid/gas behavior |
| Sandustry | Conveyor and pipe systems for material transport |
| Valheim | Structural stability, building integrity |

---

## 2. CORE GAME LOOP

```
MINE raw materials from the world
        ↓
REFINE / PROCESS them (smelt, crush, purify)
        ↓
BUILD power generation structures
        ↓
CONNECT to the grid → generate watts
        ↓
DEMAND grows → current setup is insufficient
        ↓
UNLOCK next tier technology
        ↓
Mine BETTER materials (new layer of world opens up)
        ↓
Repeat — but the systems are deeper each time
```

The player should never need a tutorial. Each tier naturally teaches the next. The game rewards curiosity and punishes carelessness — especially with dangerous materials.

---

## 3. WORLD GENERATION

### Seed System
- Every world has a numeric seed (shown at world creation)
- Same seed = same world layout, always
- Player can name their world and record the seed
- World size selected at creation: Small / Medium / Large / Vast
- **World size directly affects how fast demand scales** — larger worlds are harder endgames

### Vertical World Layers
```
Y POSITION     LAYER NAME          CONTENTS
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
0 to -20       SKY                 Air, clouds, weather, wind
0 to +10       SURFACE             Dirt, grass, trees, critters, spawn point
+10 to +60     SHALLOW GROUND      Soft dirt, clay, coal seams, groundwater
+60 to +150    MID UNDERGROUND     Stone, iron, copper, oil pockets, quartz
+150 to +280   DEEP UNDERGROUND    Granite, gold, gas pockets, rare minerals
+280 to +400   ABYSS               Obsidian, uranium, extreme heat, pressure
+400+          BEDROCK             Near-indestructible. Geothermal heat. Extreme danger.
```
*(Y increases downward. Surface is Y=0)*

### Terrain Features (Procedural)
- Rolling hills on the surface with trees, rocks, rivers
- Underground cave systems (open caverns, narrow tunnels)
- Underground rivers and water pockets
- Oil reservoirs (mid-underground, visible as dark liquid pockets)
- Gas pockets (invisible until drilled — air meter drops)
- Ore veins — visible as flecks in surrounding stone
- **River locations** matter for Tier 2 hydroelectric dams (terrain strategy begins)

### World Finiteness
- Resources are finite — a world can be exhausted
- This adds real stakes to resource decisions in late game
- Players may establish new mines or reach deeper layers when surface resources deplete

---

## 4. THE PIXEL SIMULATION LAYER

### Architecture Overview
This is the most critical and performance-sensitive system in the game. It MUST be built correctly from Scope 1 and never bolted on later.

**Two-layer world architecture:**
```
TILE LAYER (Godot TileMap)
  — Solid placed blocks
  — Stored as a 2D integer array (chunked, 32×32 chunk size)
  — Handles structure, stability, placement/removal
  — Rendered via TileMap node

PARTICLE SIMULATION LAYER (Cellular Automata — GDExtension C++)
  — Simulated pixels that flow, burn, react, drift
  — Runs at a fixed sim tick rate (independent of render framerate)
  — Each cell is a struct: { material_id, temperature, pressure, flags }
  — Sits on top of / underneath the tile layer
  — When a tile is broken → may release particles into sim layer
  — When particles accumulate → may solidify back into tiles
```

**Performance Strategy:**
- Sim layer only processes ACTIVE CHUNKS (chunks with non-static particles)
- Sleeping chunks (all particles settled/static) skip simulation
- Use spatial hash to track active cells
- C++ GDExtension handles the inner simulation loop — NOT GDScript (too slow)
- GDScript handles: game logic, UI, Godot scene tree
- GDExtension handles: cellular automata update loop, material interactions

### Material Definitions

Every material has a struct with these fields:
```
material_id      : int     — unique identifier
name             : string  — display name
category         : enum    — SOLID, LIQUID, GAS, ENERGY
density          : float   — affects sinking/floating in liquids
temperature      : float   — current heat level
flammable        : bool    — can catch fire?
ignition_temp    : float   — temperature that triggers ignition
burn_rate        : float   — how fast it burns once ignited
conductive       : bool    — carries electricity?
corrosive        : bool    — eats other materials?
radioactive      : bool    — emits contamination radius?
radiation_str    : float   — strength of radiation emission
toxic            : bool    — harms player on proximity?
soluble          : bool    — dissolves in liquids?
pressure_rating  : float   — explosion pressure threshold
color_base       : Color   — primary render color
color_variance   : Color   — secondary (for natural variation)
```

### Core Material Behaviors (Scope 1 — must be implemented)

```
MATERIAL        BEHAVIOR
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
Water           Flows downhill. Spreads sideways. Evaporates at >100°C into Steam.
                Conducts electricity (bad for player). Extinguishes fire (not oil fire).
                Falls through Air. Settles. Displaces lighter fluids upward.

Steam           Rises upward. Passes through air. Condenses back to Water on
                cool surfaces. Scalding to touch (player takes damage).
                Dissipates slowly into air at low concentrations.

Fire            Spreads to adjacent Flammable materials. Has temperature value.
                Different burn colors by material. Produces Smoke above it.
                Extinguished by Water (except oil fires). Spreads through Air to
                nearby flammables. Goes out if starved of fuel.

Smoke           Rises. Drifts slightly with "wind" (random offset upward).
                Reduces visibility (opacity layer). Causes player Choking status.
                Dissipates over time. Different colors per source material.

Wood            Solid. Flammable. Burns slowly producing Smoke + Ash + Embers.
                Structural material (low stability rating).

Dirt            Solid. Falls if unsupported (small gravity settle).
                Not flammable. Can become Mud when wet.

Stone           Solid. Stable. Not flammable.

Coal            Solid. Highly flammable. Burns long and hot.
                Produces Smoke (dark) + Ash when burned.
                As particles: Coal Dust — extremely flammable, explosion risk.

Ash             Particle. Falls slowly (lighter than sand). Piles up.
                Not flammable. Inert. Must be cleared manually.

Mud             Liquid-like (viscous). Formed from Dirt + Water.
                Slows player movement significantly.
```

### Material Interactions (Scope 1)
```
MATERIAL A      + MATERIAL B      = RESULT
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
Water           + Electricity     = Player death zone, equipment damage
Water           + Fire            = Fire extinguished, Steam produced
Water           + extreme heat    = Steam
Coal Dust       + Spark/Fire      = Explosion (scale with dust volume)
Wood            + Fire            = Burns, structural collapse risk
Dirt            + Water           = Mud (viscous, slow)
Steam           + Cold surface    = Condenses to Water droplets
Smoke           + Air (enclosed)  = Player Suffocating status
Fire            + Air (enclosed)  = Fire grows (oxygen feeds it)
```

### Future Materials (Tier 1+ — designed for but not in Scope 1)
Oil, Acid, Natural Gas, Coolant, Lava, Radioactive particles, Nuclear Waste, Toxic Gas, Radioactive Gas — all follow the same material struct, added as the game expands.

---

## 5. TECHNOLOGY TIER PROGRESSION

Each tier is an "era." Unlocking a tier changes the world visually in the background.

### TIER 0 — PRIMITIVE / MECHANICAL POWER
**Era Feel:** 1800s frontier. Wood, rope, muddy rivers, canvas sails.
**No electrical grid yet — direct mechanical power only (shafts, gears).**

**Power Sources:**
- Water Wheel — requires flowing water, terrain dependent. Output: ~50W mechanical
- Windmill — surface only, wind-variable. Output: ~30W average, 80W peak
- Wood-Fired Steam Engine — burns wood logs. Output: ~200W, requires water feed

**What the player learns here:**
- Basic mining loop (hammer tool, hand collection)
- Resource flow: chop wood → fuel boiler → spin wheel → local power
- Pixel sim introduction: water flows, wood burns, steam rises
- Building basics: placement, simple structure
- Day/night cycle, first creature encounters

**Materials available in Tier 0:**
Dirt, Stone, Clay, Wood, Leaves, Coal (discoverable, can't use yet), Water, Mud, Grass, Sand, Gravel

**Unlocks for Tier 1:**
- Discover coal underground → coal boiler recipe unlocks
- Craft first copper wire from surface copper nuggets
- First generator blueprint (mechanical → electrical conversion)

---

### TIER 1 — COAL & INDUSTRIAL STEAM
**Era Feel:** 1880-1910. Brick smokestacks, coal dust, iron machinery.
**First true electrical grid.**

**Power Sources:**
- Coal-fired Boiler → Steam Turbine → Generator chain
- Upgrade path: Basic Boiler (500W) → High-Pressure Boiler (2kW) → Superheated Steam Plant (10kW)

**New Systems Unlocked:**
- Electrical grid: power poles, copper wire, power meter
- Conveyor belts (coal mine → furnace automation)
- Basic pipes (water feed to boilers)
- Pollution mechanic: coal smoke fills air, soot builds on nearby objects
- Acid rain event (coal pollution + humidity = acid rain, damages wood structures)

**New Hazards:**
- Boiler overpressure explosion (no pressure release valve = catastrophe)
- Coal dust ignition (particle sim — accumulated coal dust + spark = explosion)
- Steam burn (scalding gas contact)

**Background Change:** Distant tree line now has one smokestack silhouette.

---

### TIER 2 — HYDRO & OIL / EARLY ELECTRICAL EXPANSION
**Era Feel:** 1910-1940. Concrete dams, oil derricks, rubber-insulated wire.

**Power Sources:**
- Hydroelectric Dam (requires river/canyon terrain — LOCATION STRATEGY begins)
- Oil/Diesel Generator (flexible, portable, expensive per watt)
- Full oil pipeline: Oil Pump → Refinery → Fuel Tank → Generator

**What the player learns:**
- Terrain reconnaissance — you scout your world for dam sites
- Liquids in pipes: oil behaves differently than water
- Hydro = stable baseload. Oil = peak demand filler
- Grid expansion: transmission poles, longer distance power
- Oil spill: flammable, spreads on water surface, ecological damage

**New Hazards:**
- Oil fire (spreads fast, water makes it WORSE — foam extinguisher needed)
- Dam structural failure (Valheim stability under water pressure)
- Pipeline leak (oil pools, ignites)

---

### TIER 3 — NATURAL GAS & GRID OPTIMIZATION
**Era Feel:** 1950s-1970s. Turbines, control rooms, the modern grid.

**Power Sources:**
- Natural Gas Turbine (fast ramp, flexible)
- Combined Cycle Plant (gas turbine + steam heat recovery = best efficiency yet)

**What the player learns:**
- Gas is invisible — AIR METER becomes critical
- Efficiency ratings per power source
- Supply vs demand balancing: live demand chart appears
- Time-of-day peaks (7-9am, 5-9pm demand spikes)
- Gas turbines ramp fast — essential for spike management

**New Hazards:**
- Gas pocket explosion (drill into pressurized pocket without venting first)
- Pipeline overpressure
- Grid cascade: overload one breaker → nearby stations trip → blackout cascade

---

### TIER 4 — NUCLEAR FISSION
**Era Feel:** 1970s-1990s. Containment domes, hazmat suits, geiger counters.

**Power Sources:**
- Fission Reactor (massive output, massive risk)

**The Reactor Build Sequence (Terraria-style step-by-step construction):**
1. Excavate reactor vault (must be concrete, minimum 20×20 tiles)
2. Place reactor vessel (core component)
3. Insert empty fuel rod assemblies
4. Flood cooling pool with water (pipes required)
5. Connect steam loop to turbine generator
6. Load enriched uranium fuel pellets
7. Start reaction — water boils → steam → turbine → enormous power output

**THE CHINA SYNDROME (Full Meltdown Event):**
```
STAGE 1 — WARNING (T-90 seconds)
  Coolant drops below safe threshold
  ⚠ icon appears above player, pulsing yellow
  Reactor hum increases in pitch
  Steam begins venting visibly from structure

STAGE 2 — CRITICAL (T-60 seconds)  
  Temperature gauge enters red zone
  ☢ icon joins warning icons
  Screen vignette turns orange at edges
  Nearby water begins boiling (pixel sim visible)
  Industrial klaxon sounds (muffled)
  Player takes 1 HP/sec radiation damage

STAGE 3 — POINT OF NO RETURN (T-30 seconds)
  Emergency shutdown button — last chance
  If ignored: core temperature maxes out

STAGE 4 — MELTDOWN
  Explosion blows reactor structure outward
  Pixel sim takes full control:
    Molten core material burns downward through floor tiles
    Radioactive particles spray outward in burst
    Water in pipes flashes instantly to steam
    Ground collapses in ~10 tile radius
    Contamination zone established

STAGE 5 — AFTERMATH
  Contamination zone marked on map (permanent red haze)
  200 gameplay hours of active contamination
  Player entry without full hazmat = radiation sickness
  Nearby structures degrade over time
  Creatures entering zone become irradiated variants
  Cannot be cleaned until Tier 6 Superfund tech
```

**New Materials (Tier 4):**
Uranium Ore (radioactive even raw), Enriched Uranium, Spent Fuel Rods, Nuclear Waste, Coolant Fluid, Lead Shielding, Concrete (required for containment)

---

### TIER 5 — RENEWABLE ENERGY EXPANSION
**Era Feel:** 2000s-2010s. Wind farms, solar arrays, green energy transition.

**Power Sources:**
- Wind Turbines (variable — actual wind simulation)
- Solar Panels (day/night cycle + weather dependent)
- Geothermal Plant (deep drilling, stable, locked to specific deep-hot-rock locations)

**New Mechanic:** Intermittency
- Sun sets → solar drops to zero
- Wind stops → turbines idle
- Player MUST have backup sources or storage
- Weather system now affects power strategy

**Environmental Recovery:**
- Renewable expansion slowly reduces pollution levels from Tiers 1-2
- Background gradually clears as renewable %, atmospheric change

---

### TIER 6 — ENERGY STORAGE & SMART GRID
**Era Feel:** 2020s. Battery walls, grid computers, remediation crews.

**New Systems:**
- Battery Banks (store surplus, release on demand)
- Pumped Hydro Storage (pump water uphill during surplus, release when needed)
- Smart Grid Controller (automates source switching)
- **SUPERFUND CLEANUP TECH** — remediation equipment to clean Tier 4 contamination zones

**What the player masters:**
- Peak shaving: store during low demand, release during peaks
- Time-of-day strategy becomes deep meta-game
- The grid is now a puzzle to optimize, not just build
- Price-per-kWh fluctuates — sell surplus at peak pricing

---

### TIER 7 — ADVANCED / ENDGAME (INFINITE LOOP)
**Era Feel:** 2040s+. Fusion, orbital arrays, hydrogen economy.

**Power Sources:**
- Fusion Reactor (near-limitless, extraordinarily complex to build)
- Small Modular Reactors (SMRs — compact, safer, faster fission)
- Space-Based Solar Array (requires launching components — new mechanic)
- Hydrogen Economy (electrolysis → hydrogen fuel → stored energy vector)

**No ceiling.** Demand always grows. The world is now a living industrial civilization you built from scratch.

---

## 6. THE POWER GRID SYSTEM

### Three-Layer Grid Architecture

**Layer 1: Local Power (Terraria wiring style)**
- Short copper wire connections
- Powers: lights, machines, crafting stations, small appliances
- Max distance: ~20 tiles
- No load management at this scale

**Layer 2: Distribution Grid (Satisfactory style)**
- Power poles with hanging wire (visual sag effect between poles)
- Rated capacity by pole type:
  - Wooden Pole: 500W
  - Iron Pole: 5kW
  - Steel Tower: 50kW
  - Transmission Tower: 500kW
- Overload = breaker trips, area goes dark
- Upgrade poles to increase capacity
- Visual: sparks and flicker when near overload

**Layer 3: Transmission Grid (Late Tier 2+)**
- High-voltage transmission towers
- Long distance, high capacity
- Requires transformer stations at endpoints
- Eventually connects to city grid at world edge (Tier 3+)
- Connecting to the world-edge grid pole is a major milestone per tier

### The Demand Meter (HUD Element — always visible from Tier 1)
```
TIER 0:   No meter (no electrical power yet)
TIER 1:   Simple bar — current generation vs current load
TIER 2:   Numerical watts display + color indicator
TIER 3:   Rolling 24-hour demand chart. Day/night peaks visible.
          Time-of-day strategy begins.
TIER 4+:  Live city demand forecast.
          Peak demand windows highlighted (7-9am, 5-9pm)
          Weather events affect demand (+10% on cold nights)
          Price-per-kWh shown — sell surplus at peak price
          Trip events: cascade warnings, blackout risk indicators
```

### Grid Stability Rules
- GREEN zone: 0-70% capacity = stable
- YELLOW zone: 70-90% = warning, minor flicker
- RED zone: 90-100% = imminent trip, everything flickers
- OVERLOAD: breaker trips, sector loses power, must reset manually
- CASCADE: multiple breakers trip in sequence if grid is poorly balanced — city districts go dark

---

## 7. PLAYER STATUS ICON SYSTEM (NOITA STYLE)

Icons float above the player's head. Stack vertically. Pulse when severe. Visible to player at all times.

```
ICON          COLOR         TRIGGER                        EFFECT ON PLAYER
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
Wet           Blue drop     Touching water                 Electricity = lethal. Slower movement.
Oily          Brown drop    Touching oil                   Fire spreads to player. Slippery.
On Fire       Orange flame  Player is burning              Fast health drain. Spreads to nearby.
Irradiated    Green atom    In radiation zone              Slow health drain. Worsens over time.
Suffocating   Grey cloud    In enclosed gas pocket         Air bar drains. Pass out when empty.
Toxic         Purple skull  Near toxic material            Vision blur. Nausea. Health drain.
Shocked       Yellow bolt   Touched live wire              Stun. Brief loss of input control.
Overheated    Red thermo.   Near extreme heat              Slow drain. Thirst increases.
Pressurized   White arrows  Near explosive decompression   Screen distortion. Ear-ringing sound.
Acid Exposed  Lime green    Acid contact                   Armor/PPE degrades. Then skin.
Cold          Blue crystal  Deep cold zones underground    Slowed movement. Hand tremor effect.
```

---

## 8. STRUCTURAL STABILITY (VALHEIM SYSTEM)

### Core Rules
- Every block requires a continuous support path to the ground
- Stability decreases with height AND horizontal distance from support
- Color feedback overlay (toggle with a key) shows stability of each block

### Stability Color Scale
```
GREEN  — Fully supported. Safe to build on.
YELLOW — Some stress. Monitor it.
ORANGE — Warning. Add support soon.
RED    — Imminent collapse. Fix immediately.
BLACK  — Will collapse on next physics tick.
```

### Material Stability Ratings
```
MATERIAL      STABILITY SPREAD    NOTES
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
Wood          4 tiles             Cheap, weak. Early game only.
Stone         6 tiles             Good general purpose.
Iron          10 tiles            First real engineering material.
Steel         14 tiles            Required for tall industrial structures.
Concrete      20 tiles            Required for reactor containment. Best available.
```

### Gameplay Implications
- A tall coal plant needs iron support columns
- A dam wall must be reinforced concrete or fails under water pressure
- Nuclear containment structure: concrete MINIMUM — no exceptions
- Overloaded floors (too many machines per tile) will collapse
- Fire damage weakens wooden structure stability over time
- Structural collapse is simulated — connected blocks fall in chain

### Special Rule: Metallic Structures
Metal blocks and components require a **Welder** tool to place. The welder is a mid-Tier-1 crafted tool. Without a welder, metal objects cannot be built or repaired.

---

## 9. TOOLS & CRAFTING

### Tool Progression
```
TIER 0 TOOLS:
  Bare Hands     — interact with world, very slow mining
  Hammer         — basic construction, places/removes blocks
  Stone Pickaxe  — mines soft materials (dirt, clay, soft stone)

TIER 1 TOOLS:
  Iron Pickaxe   — mines stone, coal
  Axe            — chops wood faster
  Welder         — required to place/build metallic objects and furniture
  Wrench         — connects pipes, installs mechanical components
  Wire Cutter    — connects/cuts electrical wire

TIER 2 TOOLS:
  Steel Pickaxe  — mines deep stone, iron ore
  Pump Wrench    — installs pumps and large pipe joints
  Survey Tool    — shows terrain scan (reveals ore veins, water, oil pockets)

TIER 3 TOOLS:
  Drill (basic)  — replaces pickaxe. Faster, area mine, requires power
  Gas Detector   — detects gas pockets before drilling into them
  Voltmeter      — diagnoses grid problems

TIER 4 TOOLS:
  Hazmat Suit    — required to mine/handle uranium and radioactive materials
  Geiger Counter — detects radiation zones and levels
  Lead Gloves    — handle nuclear materials without full suit (partial protection)
  Rad Dosimeter  — tracks cumulative radiation exposure (permanent damage threshold)

TIER 5+ TOOLS:
  Advanced Drill  — powered, fast, can be mounted on automated mining rigs
  Excavator Arm   — automated block mining via machine placement
```

### Crafting Station Requirements
Some recipes require proximity to specific stations:
```
ITEM CATEGORY            REQUIRED STATION
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
Basic items              Workbench (crafted from wood)
Metal objects/furniture  Forge + Welder tool
Electrical components    Electronics Bench
Pipe/pump systems        Plumbing Bench
Chemical processing      Chemistry Lab (Tier 2+)
PPE / Hazmat gear        Safety Workshop (Tier 3+)
Nuclear components       Specialized Reactor Workshop (Tier 4)
```

---

## 10. CONVEYORS & PIPES (SANDUSTRY STYLE)

### Conveyor Belts
- Transport solid materials: stone, coal, ore, refined metals, components
- Player can walk on and stand on conveyors (they'll move the player slightly)
- Can be run underground ("spaghetti routing" is possible but inefficient)
- **Cannot cross other conveyors until Tier 2** (junction component unlocks)
- Visual: rubber belt, animated sprite, directional arrows painted on

### Pipes
- Transport liquids and gases: water, oil, coolant, steam, natural gas
- Player can pass through pipes (they're passable objects)
- Gravity matters for liquid pipes — uphill pumping requires pump components
- **Cannot cross other pipes until Tier 2** (T-junction and cross-junction components)
- Pipe material matters: copper pipe (Tier 1), steel pipe (Tier 2+, required for steam), lead pipe (Tier 4 — nuclear coolant loops)
- Pipe leaks possible — damaged pipes need repair with Wrench

### Pump Mechanics
- Pumps push liquids in a specific direction
- Pump power rating determines flow rate (L/min)
- Powered pumps require electricity from the grid
- Water pump (Tier 0 hand-crank), Electric pump (Tier 1+)

---

## 11. CREATURES

### Hostile Creatures (primarily night spawns, some location-based)
```
CREATURE        SPAWN CONDITION              BEHAVIOR
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
Wolf/Coyote     Surface, nighttime           Chases player, pack behavior
Crocodile       Near rivers/water, anytime   Slow on land, fast in water, ambushes
Bear            Forest/cave entrance, dawn   Territorial, charges if approached
Cave Bat        Underground darkness         Swarms, disrupts mining
Giant Bird      Open surface, daytime        Swoops, rare, high HP
Irradiated Wolf Contamination zone (T4+)     Faster, more damage, glows faintly
```

### Passive Critters (environmental life, make the world feel alive)
```
CRITTER     LOCATION               BEHAVIOR
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
Small Bird  Surface, daytime       Flutters between trees, flees on approach
Rabbit      Surface, grassland     Hops around, flees fast
Deer        Forest, morning        Grazes, graceful, runs from player
Squirrel    Trees, surface         Climbs, scurries, chatters
Frog        Near water             Jumps, croaks, sits on rocks at water edge
Cave Fish   Underground water      Swims in underground rivers, passive
Butterfly   Surface, daytime       Decorative. Follows flowers.
```

### Irradiated Creature Variants (Tier 4+)
Any creature that wanders into a contamination zone can become an irradiated variant:
- Glowing green tint
- Increased HP and damage
- Emits small radiation aura (player takes damage nearby without PPE)
- Drops radioactive material on death (handle with care)

---

## 12. ENVIRONMENTAL & BACKGROUND PROGRESSION

The background world changes visually as the player advances through tiers.

```
TIER 0   Background: Lush green hills, clear sky, birds, distant mountains.
         World feels pristine and untouched.

TIER 1   Background: One smokestack visible in the distance. Sky is slightly
         hazier. Distant sound of machinery at dawn.

TIER 2   Background: Oil derrick silhouettes on the horizon. A distant
         dam visible if terrain is right. River has a dock structure.

TIER 3   Background: City lights visible at night on the horizon.
         Multiple smokestacks. Power lines visible crossing the horizon.
         Sky is noticeably amber-tinted during sunsets (pollution).

TIER 4   Background: Cooling tower silhouettes. Distant red warning lights.
         If meltdown occurred: permanent dark red haze in that direction.

TIER 5   Background: Wind turbine silhouettes. Solar farm glint.
         Sky gradually clears if renewables % is high enough.

TIER 6   Background: Smart grid towers visible. City horizon brighter.
         If Superfund cleanup completed: contamination haze fades.

TIER 7   Background: Orbital infrastructure visible at night (faint lights
         on high orbit trajectory). Hydrogen fuel depots. Clean horizon.
```

---

## 13. THE DEV EDITOR

A separate tool launched alongside the main game. This is the "game engine within the game" — how Terra.Watt expands over time.

### Tabs and Features

**World Editor**
- Paint any block/tile anywhere in the world
- Spawn any material (particles or solid blocks)
- Set world seed and size after the fact (for testing)
- Adjust terrain generation parameters
- Toggle time of day and weather state
- Spawn/remove creatures
- Flood fill regions with any material

**Material Editor**
- Create new materials from scratch using a GUI form
- Set all material properties (dropdowns and toggles — no code needed)
- Define interaction rules with other materials (matrix interface)
- Set pixel sim behavior (falls, flows, rises, etc.)
- Draw 16×16 tile sprite inline OR import from PixelLab
- Test material in a sandbox sim window before saving
- Save as `.twmat` file (Terra.Watt Material)

**Recipe Editor**
- Create new crafting recipes with a drag-and-drop interface
- Set required crafting station
- Define input materials and quantities
- Define output item and quantity
- Set required tool
- Set tier unlock requirement
- Preview recipe card as it will appear in-game

**Creature Editor**
- Create or edit creature definitions
- Set spawn conditions (biome, time, tier, contamination zone)
- Set behaviors (hostile, passive, territorial radius)
- Import sprite sheet
- Define loot table
- Set health, speed, damage values

**Mod Pack Export**
- Bundle materials + recipes + creatures into a `.twmod` file
- Load mods in main game from settings menu
- Versioning and dependency tracking

---

## 14. USER INTERFACE DESIGN

### HUD Layout (always visible)
```
TOP LEFT:     Health bar, Air bar (when underground), Radiation dosimeter (Tier 4+)
TOP CENTER:   Clock (day/night), Current weather icon
TOP RIGHT:    Power meter (Tier 1+) — generation vs demand bar, watt values
BOTTOM:       Hotbar (10 slots), currently equipped tool shown large
ABOVE PLAYER: Status icons (stack vertically, pulse on severity)
```

### Menu Design Philosophy
- Industrial aesthetic — dark panels, copper/amber accents, riveted borders
- No fantasy elements — everything should feel like a real industrial era tool
- Minimal text — use iconography where possible
- Terraria-style inventory grid, but with a more mechanical/technical look
- Crafting stations show recipes in a scrollable list with material requirements highlighted (green = have it, red = missing)

### The Power Dashboard (Tier 3+ separate screen)
- Full-screen overlay accessible via key press
- Shows: live wattage chart (last 24 hours), all power sources and their output, all connected loads, grid stability by sector, demand forecast, price per kWh over time
- Think: a real power company control room on a screen

---

## 15. SCOPE 1 — FIRST PLAYABLE BUILD

### What to Build First
This is the deliverable for the initial multi-agent development sprint. Everything else in this document is designed for — but built later.

```
✅ MUST BE IN SCOPE 1

WORLD SYSTEM
  ├── Seed-based world generation
  ├── Terrain: surface, shallow underground, mid underground
  ├── Cave systems (procedural)
  ├── Biome: surface (grassland)
  ├── Tile types: Sky, Dirt, Grass-Dirt, Stone, Clay, Coal (visible vein)
  ├── Day/night cycle (visual only, affects creature spawning)
  └── Chunked world storage (32×32 chunks, infinite horizontal scroll)

PIXEL SIMULATION LAYER ← HIGHEST PRIORITY
  ├── C++ GDExtension cellular automata engine
  ├── Materials: Water, Steam, Fire, Smoke, Wood (burning), Dirt (falling), Ash
  ├── All core interactions from Section 4
  └── Performance: sleeping chunks, active cell tracking

PLAYER
  ├── Character: hardhat miner sprite (see Section 0 for design reference)
  ├── Movement: WASD, jump, gravity, tile collision
  ├── Starbound-feel movement (slightly floaty, responsive)
  └── Interaction radius (can interact with tiles within 4 tiles)

MINING
  ├── Equip hammer/pickaxe from hotbar
  ├── Click tile to begin mining (hold to mine)
  ├── Progress indicator on tile being mined
  ├── Tile type determines mining time
  ├── Mined tile drops collectible item particle
  └── Walk near item to auto-collect

INVENTORY
  ├── Hotbar (10 slots at bottom)
  ├── Item icon + count per slot
  ├── Auto-collect on proximity
  └── Basic inventory screen (press I to open)

TIER 0 CONTENT
  ├── Water Wheel (places at water edge, outputs mechanical power locally)
  ├── Windmill (surface, outputs mechanical power, variable)
  └── Wood-fired Steam Engine (burns wood, outputs steam → local power)

STATUS ICONS
  ├── Wet (blue drop)
  ├── On Fire (orange flame)
  └── Suffocating (grey cloud + air bar)

STRUCTURAL STABILITY
  └── Color overlay feedback (Green/Yellow/Orange/Red)

CREATURES
  ├── Rabbit (passive surface critter)
  ├── Small Bird (passive surface critter)
  └── Wolf (hostile, night spawn)

VISUALS
  ├── Parallax background: 3 layers (deep sky, distant hills, foreground trees)
  ├── Player headlamp: soft glow circle in dark areas
  ├── Underground darkness gradient (deeper = darker)
  ├── Ore glow (faint color-appropriate glow on ore tiles)
  └── PixelLab MCP integration for all art asset generation

❌ NOT IN SCOPE 1 (but all systems must be architected to support these)
  Electrical grid, Power poles, Demand meter
  Tier 1-7 content
  Conveyors and pipes
  Crafting stations
  Dev Editor
  The China Syndrome
  All Tier 1+ materials (oil, acid, gas, uranium, etc.)
  All remaining status icons
  Contamination system
  Smart grid / demand chart
```

---

## 16. FOLDER STRUCTURE (GODOT 4)

```
res://
├── main.tscn                    ← Master scene, launch point
├── main.gd                      ← Game loop, initialization
├── project.godot
│
├── world/
│   ├── world_data.gd            ← World generation, chunk management
│   ├── world_renderer.gd        ← TileMap rendering
│   ├── chunk.gd                 ← Chunk data structure
│   ├── background.tscn/.gd      ← Parallax background layers
│   └── lighting.gd              ← Player torch, underground darkness
│
├── simulation/
│   ├── sim_manager.gd           ← Coordinates C++ sim layer with Godot
│   ├── material_registry.gd     ← All material definitions (autoload)
│   ├── materials/
│   │   ├── material_base.gd     ← Base material struct
│   │   ├── water.gd
│   │   ├── steam.gd
│   │   ├── fire.gd
│   │   ├── smoke.gd
│   │   └── ... (one file per material)
│   └── gdextension/
│       ├── terrawatt_sim.gdextension
│       └── src/                 ← C++ source for cellular automata
│           ├── sim_core.cpp
│           ├── sim_core.h
│           └── materials.h
│
├── player/
│   ├── player.tscn
│   ├── player.gd                ← Movement, input, collision
│   ├── player_status.gd         ← Status icon system
│   ├── inventory.gd             ← Player inventory (autoload)
│   └── tools/
│       ├── tool_base.gd
│       ├── hammer.gd
│       └── pickaxe.gd
│
├── mining/
│   ├── mining_system.gd         ← Mining logic, tile removal
│   └── collectible_item.tscn/.gd
│
├── power/
│   ├── power_grid.gd            ← Grid manager (autoload)
│   ├── power_source_base.gd     ← Base class for all generators
│   ├── mechanical_power.gd      ← Tier 0 mechanical power system
│   └── sources/
│       ├── water_wheel.tscn/.gd
│       ├── windmill.tscn/.gd
│       └── steam_engine.tscn/.gd
│
├── structures/
│   ├── stability_system.gd      ← Valheim-style structural integrity
│   └── structure_base.gd
│
├── creatures/
│   ├── creature_base.gd
│   ├── wolf.tscn/.gd
│   ├── rabbit.tscn/.gd
│   └── bird.tscn/.gd
│
├── ui/
│   ├── hud.tscn/.gd             ← Main HUD overlay
│   ├── hotbar.tscn/.gd
│   ├── inventory_screen.tscn/.gd
│   ├── status_icons.tscn/.gd    ← Above-player status icon display
│   └── power_meter.tscn/.gd
│
└── assets/
    ├── tiles/                   ← All 16×16 tile sprites
    │   ├── terrain/
    │   ├── ores/
    │   └── structures/
    ├── player/                  ← Player sprite sheets
    ├── creatures/               ← Creature sprite sheets
    ├── ui/                      ← UI elements, icons
    ├── particles/               ← Particle textures for sim layer
    └── backgrounds/             ← Parallax layer images
```

---

## 17. ART DIRECTION FOR PIXELLAB MCP

When using PixelLab MCP to generate assets, always use these prompt parameters:

### Tile Prompts
```
Style keywords: "16x16 pixel art tile, painterly texture, detailed,
                 slightly gritty, industrial era, warm earthen palette,
                 Starbound-inspired, no outlines, natural lighting,
                 subtle subsurface texture"

Color palette guidance:
  Surface/Dirt tiles:  warm browns #8B6914, #6B4A10, #9C7A3C
  Stone tiles:         cool greys #6B6B6B, #555566, #7A7A8A
  Coal tiles:          near-black #2A2A2A with dark grey flecks
  Copper ore:          stone base with #B87333 vein flecks
  Iron ore:            stone base with #8A8A9A metalite streaks
  Grass top:           #4A7C2F bright green top, brown underside
```

### Player Sprite Prompts
```
Style keywords: "pixel art character, 24x40 pixels, industrial miner,
                 brown hardhat with headlamp, yellow safety vest,
                 grey armored chest, brown work pants, heavy boots,
                 backpack, chunky readable silhouette, Terraria proportions,
                 warm palette, Starbound character style"
```

### UI Element Prompts
```
Style keywords: "pixel art UI element, industrial steampunk aesthetic,
                 dark background #1A1A2E, copper accent #B87333,
                 riveted metal panel, no fantasy elements,
                 clean readable iconography, technical/mechanical feel"
```

---

## 18. CLOUD AGENT & CURSOR WORKFLOW NOTES

### For Cursor AI Agents — Important
- You have access to **Claude cloud agents** for real-time debugging and review
- When you write a script and it fails in Godot, paste the error into a cloud agent chat for diagnosis before rewriting from scratch
- Cloud agents can review your code for logic errors BEFORE running it in Godot
- Use cloud agents to: debug GDExtension compilation errors, review algorithm correctness, generate test data for world gen
- Always write your scripts with **detailed inline comments** — other agents (and the human developer) need to read your work

### Multi-Agent Development Rules
1. Each agent works on ONE system only — do not reach into another agent's folder
2. All cross-system communication goes through **autoload singletons** (see folder structure)
3. The autoloads are: `inventory.gd`, `power_grid.gd`, `material_registry.gd` — these are shared globals
4. If you need functionality from another system, call a function on the autoload — do not copy code
5. After completing your task, write a brief `AGENT_NOTES.md` in your system's folder describing: what you built, what's complete, what's a TODO, and what the next agent working on this system needs to know

### Godot 4 Specifics (for agents unfamiliar)
- GDScript is Python-like — use `var`, `func`, `class_name`
- Autoloads: registered in Project > Project Settings > Autoload
- Signals are the Godot event system — prefer signals over direct calls across systems
- Use `@export` to expose variables in the Godot Inspector
- TileMap for the tile layer, plain `Node2D` with custom draw for the sim layer
- GDExtension for C++ — requires building with SCons, see Godot docs

---

## 19. REVISION HISTORY

```
v1.0  — Initial GDD. Scope 1 defined. All 8 tiers documented.
        Pixel sim architecture defined. Folder structure established.
        Art direction locked. China Syndrome fully scripted.
        Tier progression blended from both design sources.
```

---

*Terra.Watt Game Design Document — maintained by development team*
*All agents: when this document is updated, re-read it before continuing work.*
