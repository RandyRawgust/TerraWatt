# TERRAWATT — TIER 1 PROMPT KIT
## Coal & Industrial Steam | Real Sprites | Pixel Sim Compiled
## Version: 1.0 | Builds on top of Scope 1 (must be complete first)

---

## WHAT IS IN THIS KIT

```
README_TIER1.md                    ← This file — launch guide
AGENT_T1_0_PREFLIGHT.md           ← Run FIRST alone — fixes Scope 1 debt + compiles C++
AGENT_T1_1_SPRITES.md             ← Real player + creature sprites (PixelLab)
AGENT_T1_2_COAL_POWER.md          ← Coal mine → boiler → turbine → generator chain
AGENT_T1_3_ELECTRICAL_GRID.md     ← Power poles, copper wire, power meter HUD
AGENT_T1_4_CONVEYORS.md           ← Conveyor belts for coal automation
AGENT_T1_5_POLLUTION.md           ← Smoke fills air, soot, acid rain
AGENT_T1_6_INTEGRATION.md        ← Wire everything together, verify 30-point checklist
```

---

## KEY CHANGES FROM SCOPE 1 WORKFLOW

- **No Foundation Agent** — project is already bootstrapped
- **Preflight Agent runs first** — fixes known Scope 1 debt and compiles GDExtension
  before any Tier 1 agent touches game logic
- **Sprites Agent runs in parallel** with Preflight (art is independent)
- **Coal/Grid/Conveyors/Pollution run simultaneously** after Preflight completes
- **Integration runs last** as before

---

## PREREQUISITES

Before launching any agent:

```bash
# Confirm you are on main with clean Scope 1
git pull origin main
git log --oneline -5
cat AGENT_STATUS.md   # all Scope 1 agents should show COMPLETE

# Confirm Godot version (agents need to know)
# Check title bar in Godot editor — should be 4.4.x
```

Also confirm you have a C++ build toolchain installed:
- **Windows:** Visual Studio 2022 Build Tools (with C++ workload) + Python 3.8+
- **Mac:** Xcode Command Line Tools + Python 3.8+
- **Linux:** `build-essential` + Python 3.8+

Verify with: `python --version` and `cl` (Windows) or `gcc --version` (Mac/Linux)

If toolchain is missing, install it before running the Preflight Agent.
The Preflight Agent will guide you through the SCons install if needed.

---

## LAUNCH ORDER

### ROUND 1 — Preflight (alone, ~20 min)

Open one Composer Agent tab, paste `AGENT_T1_0_PREFLIGHT.md`, press Enter.

It will:
1. Fix the RigidBody2D sleeping bug (collectibles + creatures fall into holes)
2. Fix static function call warnings
3. Fix enum warnings in TileMap
4. Suppress GDExtension not-found by removing the `.gdextension` reference
5. Compile the C++ pixel simulation (the big one)
6. Verify the game still boots after all fixes
7. Commit everything to main

Wait for it to report COMPLETE before proceeding.

---

### ROUND 2 — Parallel (run simultaneously)

Open **5 Composer Agent tabs** after Preflight completes:

| Tab | File | Notes |
|---|---|---|
| 1 | `AGENT_T1_1_SPRITES.md` | Can start immediately, art is independent |
| 2 | `AGENT_T1_2_COAL_POWER.md` | Core Tier 1 gameplay |
| 3 | `AGENT_T1_3_ELECTRICAL_GRID.md` | Depends on PowerGrid autoload (already exists) |
| 4 | `AGENT_T1_4_CONVEYORS.md` | Depends on WorldData tile placement |
| 5 | `AGENT_T1_5_POLLUTION.md` | Depends on SimManager being real (Preflight delivers) |

---

### ROUND 3 — Integration (after all 5 complete)

Paste `AGENT_T1_6_INTEGRATION.md` into a new tab.
It wires everything together and runs the 30-point verification checklist.

---

## WHAT TIER 1 LOOKS LIKE WHEN DONE

- Real pixel art player sprite (no more taco)
- Real creature sprites (no more white squares)
- Collectibles and creatures fall into dug holes correctly
- Water flows, fire spreads, steam rises (real C++ simulation)
- Coal veins mineable underground
- Coal furnace + water boiler + steam turbine chain you build and connect
- First electrical grid: place power poles, run copper wire, connect generator
- Power meter top-right shows real watts generated vs demand
- Conveyor belt drops coal from mine into furnace automatically
- Smoke rises from burning coal, fills enclosed spaces
- Soot accumulates on nearby surfaces over time
- Background shows distant smokestack silhouette (Tier 1 era shift)

---

*Terra.Watt Tier 1 Prompt Kit — built for Cursor Pro + Claude Code + PixelLab MCP*
*Doctrine version: 1.7 | Engine: Godot 4.4.x*
