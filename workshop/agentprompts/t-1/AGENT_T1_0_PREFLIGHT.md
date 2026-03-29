TERRAWATT — TIER 1 PREFLIGHT AGENT
Single command: Paste this entire block into a Cursor Composer Agent tab and press Enter.
Run this FIRST and ALONE before any other Tier 1 agent.

━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

## MISSION: Fix all known Scope 1 debt. Compile the C++ pixel simulation. Leave the project clean.

You are the PREFLIGHT AGENT. Nothing else starts until you finish.
Your job is surgical fixes and one major build task. No new gameplay.

---

## PHASE 0: DOCTRINE + RECON (MANDATORY)

1. Read `TERRAWATT_DOCTRINE.md` — full read, every section.
   Pay specific attention to:
   - RETROSPECTIVE section (all of it — these are real failure modes)
   - ENGINE VERSION: project is Godot 4.4.1 — use 4.4.x APIs only
   - GIT WORKFLOW: use path-scoped `git add`, NOT `git add -A`
   - Windows PowerShell: use `;` not `&&` between commands

2. Read `AGENT_STATUS.md` — confirm all Scope 1 agents show COMPLETE.

3. Run these read-only checks and report findings before touching anything:
```bash
git log --oneline -10
git status
```
Read these files:
- `res://simulation/sim_manager.gd` — current state of stub vs real
- `res://mining/collectible_item.gd` — confirm sleeping=false is missing
- `res://creatures/wolf.gd` — confirm sleeping=false is missing
- `project.godot` — find the gdextension reference
- `res://simulation/gdextension/SConstruct` — does it exist?
- `res://simulation/gdextension/src/` — what C++ files exist?

Output a ≤60 line digest of what you find before proceeding.

---

## PHASE 1: SCOPE 1 BUG FIXES

Fix all of these in sequence. After EACH fix: open the affected file,
verify the change is correct, then move to the next.
Do NOT batch-commit — commit each fix individually.

### FIX A — RigidBody2D sleeping (collectibles stay floating after ground removed)

In `res://mining/collectible_item.gd`:
Find the `_ready()` function or the node setup and add:
```gdscript
# Prevents physics body from sleeping — ensures it falls when ground removed
func _ready() -> void:
    sleeping = false
    can_sleep = false
    apply_central_impulse(Vector2(randf_range(-30.0, 30.0), -80.0))
```
Also add to `_physics_process` or `_integrate_forces` if the node has one:
```gdscript
    sleeping = false  # keep awake every frame
```

```bash
git add res/mining/collectible_item.gd
git commit -m "[Preflight] fix: collectibles never sleep, fall into dug holes correctly"
git push origin main
```

### FIX B — Creature physics sleeping (creatures don't fall into holes)

In `res://creatures/wolf.gd`, `rabbit.gd`, and `bird.gd`:
These use CharacterBody2D (not RigidBody2D) so the fix is different.
CharacterBody2D must call `move_and_slide()` every physics frame even
when idle, otherwise Godot skips collision resolution.

In each creature's `_physics_process`, ensure `move_and_slide()` is
called unconditionally at the end — not only when moving:
```gdscript
func _physics_process(delta: float) -> void:
    # Always apply gravity
    if not is_on_floor():
        velocity.y += 900.0 * delta
    # ... existing movement logic ...
    move_and_slide()  # MUST be called every frame, not inside an if block
```

```bash
git add res/creatures/wolf.gd res/creatures/rabbit.gd res/creatures/bird.gd
git commit -m "[Preflight] fix: creatures apply gravity every frame, fall into holes"
git push origin main
```

### FIX C — Suppress GDExtension not-found error on launch

In `project.godot`, find the gdextension entry and remove or comment it.
The file likely has something like:
```ini
[gdextension]
...terrawatt_sim.gdextension...
```
Remove the entire `[gdextension]` section. We will add it back correctly
after compilation in Phase 2.

```bash
git add project.godot
git commit -m "[Preflight] fix: remove broken gdextension reference pre-compile"
git push origin main
```

### FIX D — Static function call warning (tile_id_to_source_id)

In `res://world/world_renderer.gd` (or wherever the warning fires):
Find any call like `world_data_instance.tile_id_to_source_id(id)` where
`world_data_instance` is a variable holding the WorldData node.
Replace with the direct class call since WorldData is an autoload:
```gdscript
# Wrong: calling static via instance variable
var source: int = some_variable.tile_id_to_source_id(tile_id)

# Correct: call on the autoload directly
var source: int = WorldData.tile_id_to_source_id(tile_id)
```

If `tile_id_to_source_id` does not exist as a function, add it to
`res://world/world_data.gd` as a static function:
```gdscript
# Maps WorldData tile ID to TileSet source ID.
# Single-atlas layout: source_id = tile_id, atlas coord = Vector2i(0,0)
static func tile_id_to_source_id(tile_id: int) -> int:
    return tile_id
```

```bash
git add res/world/world_data.gd res/world/world_renderer.gd
git commit -m "[Preflight] fix: tile_id_to_source_id called correctly as static"
git push origin main
```

### FIX E — TileMap set_cell enum warning

Find all `tile_map.set_cell()` calls in world_renderer.gd.
The atlas_coords argument must be `Vector2i`, not a raw int:
```gdscript
# Wrong — passes tile_id as atlas coords
tile_map.set_cell(0, Vector2i(wx, wy), source_id, Vector2i(tile_id, 0))

# Correct — atlas coords are always Vector2i(0, 0) for single-tile sources
tile_map.set_cell(0, Vector2i(wx, wy), source_id, Vector2i(0, 0))
```

```bash
git add res/world/world_renderer.gd
git commit -m "[Preflight] fix: TileMap set_cell atlas coords use Vector2i(0,0)"
git push origin main
```

---

## PHASE 2: COMPILE THE C++ GDEXTENSION

This is the most complex part. Read every step before executing.

### Step 1 — Verify toolchain
```bash
python --version        # needs 3.8+
# Windows:
cl 2>&1 | head -1       # Visual Studio compiler
# Mac/Linux:
gcc --version
```
If Python is missing: STOP and report to the developer — they must install it.
If compiler is missing: STOP and report.

### Step 2 — Install SCons
```bash
pip install scons
scons --version
```

### Step 3 — Check godot-cpp
```bash
# From project root:
dir res\simulation\gdextension\godot-cpp    # Windows
ls res/simulation/gdextension/godot-cpp     # Mac/Linux
```

If godot-cpp folder is empty or missing:
```bash
cd res/simulation/gdextension

# IMPORTANT: pin to 4.4 to match Godot 4.4.1 editor
# First check what tags exist:
git ls-remote --tags https://github.com/godotengine/godot-cpp.git | grep "4.4"
# Clone the matching tag (use 4.4 stable or closest available):
git clone --depth 1 -b godot-4.4-stable https://github.com/godotengine/godot-cpp.git
# If that tag doesn't exist, try:
git clone --depth 1 -b 4.4 https://github.com/godotengine/godot-cpp.git
```

CRITICAL: Do NOT assume the branch name. Verify it exists from the tag list above
before cloning. If 4.4-stable is not available, use the closest 4.x tag.

### Step 4 — Verify C++ source files exist
```bash
dir res\simulation\gdextension\src    # Windows
ls res/simulation/gdextension/src     # Mac/Linux
```
Expected files: `sim_core.cpp`, `sim_core.h`, `sim_cell.h`, `material_defs.h`,
`register_types.cpp`, `terrawatt_sim_node.h`, `terrawatt_sim_node.cpp`

If any are missing, check git history:
```bash
git log --all --oneline -- "res/simulation/gdextension/src/*.cpp"
```
If they were never created: STOP and report — the Pixel Sim Agent never
completed its task. Do not attempt to rewrite C++ from scratch.
Report which files are missing in AGENT_STATUS.md and mark Preflight as BLOCKED.

### Step 5 — Compile
```bash
cd res/simulation/gdextension

# Windows:
scons platform=windows target=template_debug arch=x86_64
# Mac:
scons platform=macos target=template_debug
# Linux:
scons platform=linux target=template_debug arch=x86_64
```

Expected output: a `.dll` (Windows), `.dylib` (Mac), or `.so` (Linux) in
`res://bin/` or `res://simulation/gdextension/bin/`.

If compile fails — use Claude Code immediately:
```bash
claude "GDExtension compile failed. Godot version: 4.4.1. Error output: [paste ALL error lines].
SConstruct contents: [paste file]. src/ files present: [list them].
godot-cpp version: [paste git log -1 in godot-cpp folder].
Fix the compilation error."
```
Do not attempt to fix C++ compile errors manually without Claude Code diagnosis.
Do not loop more than twice — escalate to cloud agent after 2 failed attempts.

### Step 6 — Add .gdextension back to project.godot

After successful compile, add the correct entry to project.godot:
```ini
[gdextension]

singletons=["res://simulation/gdextension/terrawatt_sim.gdextension"]
```

Verify `res://simulation/gdextension/terrawatt_sim.gdextension` file exists
and has the correct library path pointing to your compiled binary.
Update the library path if it doesn't match:
```ini
[configuration]
entry_symbol = "terrawatt_sim_init"
compatibility_minimum = "4.1"

[libraries]
windows.debug.x86_64 = "res://bin/libterrawatt_sim.windows.template_debug.x86_64.dll"
macos.debug = "res://bin/libterrawatt_sim.macos.template_debug.framework"
linux.debug.x86_64 = "res://bin/libterrawatt_sim.linux.template_debug.x86_64.so"
```

### Step 7 — Verify in Godot
Open the project in Godot 4.4. Check output panel:
- Should see: "SimManager: C++ extension loaded successfully."
- Should NOT see: "TerrawattSimNode not found"

If you see the not-found error still: the binary path in .gdextension is wrong.
Check the actual filename in res://bin/ and update the path.

```bash
git add res/simulation/gdextension/terrawatt_sim.gdextension project.godot
git commit -m "[Preflight] feat: GDExtension compiled and registered, pixel sim active"
git push origin main
```

---

## PHASE 3: VERIFY GAME STILL BOOTS

After all fixes and the compile:
1. Open Godot 4.4
2. Press F5
3. Confirm:
   - No red errors in output (yellow warnings acceptable)
   - "SimManager: C++ extension loaded successfully." appears
   - "Terra.Watt: All systems initialized." appears
   - Player can move, jump, mine
   - Dig a hole, drop an item into it — confirm it falls further when ground removed

---

## PHASE 4: UPDATE AGENT_STATUS.md

```
## Preflight Agent (Tier 1) — [TODAY'S DATE]
STATUS: COMPLETE
COMPLETED:
  - RigidBody2D sleeping bug fixed (collectibles fall into holes)
  - Creature CharacterBody2D gravity fixed (creatures fall into holes)
  - GDExtension compiled for [platform] — TerrawattSimNode active
  - Static function call warnings resolved
  - TileMap set_cell enum warnings resolved
  - project.godot gdextension entry correct and loading
EXPORTS:
  - SimManager is now REAL — get_cell() returns actual simulation state
  - SimManager.add_particle(x, y, material_id) spawns real particles
  - Water flows. Fire spreads. Steam rises.
  NOTE: Tier 1 agents that read SimManager can now get meaningful sim data.
```

---

## FINAL REPORT FORMAT

```
PREFLIGHT AGENT — FINAL REPORT

✅ Fix A: collectible_item.gd — sleeping disabled, falls correctly
✅ Fix B: wolf/rabbit/bird.gd — gravity every frame, falls into holes
✅ Fix C: project.godot — gdextension entry removed pre-compile
✅ Fix D: tile_id_to_source_id — called as static, no warning
✅ Fix E: set_cell atlas coords — Vector2i(0,0) throughout
✅ C++ compiled: [platform] binary at [path]
✅ SimManager: TerrawattSimNode loaded — "C++ extension loaded successfully."
✅ Game boots: F5 confirmed, no red errors
✅ AGENT_STATUS.md updated
✅ All commits pushed (path-scoped git add used throughout)

Self-Audit Complete. Scope 1 debt cleared. Pixel sim active.
Tier 1 parallel agents may now launch.
```

If compile blocked:
```
🚧 BLOCKED: C++ compile failed / source files missing
Fixes A-E: [✅ or ⚠️ each]
Compile status: [exact error or missing files]
Recommended next step: [what developer needs to do manually]
Tier 1 agents that DON'T need real sim (Coal Power, Grid, Conveyors):
  may proceed — SimManager stub is still present as fallback.
Tier 1 agents that DO need real sim (Pollution):
  should wait or build with explicit stub dependency.
```
