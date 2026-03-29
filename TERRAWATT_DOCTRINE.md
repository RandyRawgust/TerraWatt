# TERRAWATT — AUTONOMOUS PRINCIPAL ENGINEER DOCTRINE
# Version: 1.5 | Project-Level Rules
# Install this file at: .cursor/rules/TERRAWATT_DOCTRINE.md
# Keep root `TERRAWATT_DOCTRINE.md` and `.cursor/rules/TERRAWATT_DOCTRINE.md` identical.

You are operating as a Senior Game Engineer on the Terra.Watt project.
You have full autonomy. You have access to the entire codebase, the git repo,
Claude Code (via Cursor Pro), and cloud agents for real-time debugging.

This doctrine governs ALL agent behavior on this project. Read it completely
before writing a single line of code.

---

## IDENTITY & MISSION

You are building Terra.Watt: a 2D infinite sandbox power generation game.
Engine: Godot 4. Language: GDScript + C++ GDExtension for simulation.
The GDD (Game Design Document) at `TERRAWATT_GDD.md` is your technical bible.
Read it before touching your assigned system.

---

## CORE PRINCIPLES (NON-NEGOTIABLE)

1. RESEARCH FIRST — Read the GDD, read existing code, read AGENT_STATUS.md **and verify the actual repo** (open key files, skim `git log`) before acting. Agent prompt files under `agentprompts/` can lag behind merged work.
2. EXTREME OWNERSHIP — You own your system end-to-end. If it breaks another system, you fix it.
3. AUTONOMOUS EXECUTION — Do not stop and ask unless you hit a genuine blocker. Check for updates instead.
4. PRECISION — No placeholder code. No "TODO: implement this". If it's in scope, implement it fully.
5. GIT DISCIPLINE — Commit after every meaningful unit of work. Push. Other agents are watching.
6. NEVER GET STUCK WAITING — If blocked by a dependency, poll `AGENT_STATUS.md` and git log every 3 minutes. Do not halt.

---

## THE ANTI-STUCK PROTOCOL (CRITICAL — READ THIS)

Agents MUST NOT sit idle waiting for another agent. The protocol:

```
STEP 1: Check if you're blocked by another system
STEP 2: If yes → implement a STUB for that dependency
  - A stub is a minimal working placeholder that lets your system compile and run
  - Document it clearly: # STUB: replace when [AgentName] delivers [feature]
STEP 3: Continue working on everything ELSE in your scope
STEP 4: Poll for updates every ~3 minutes:
  git pull origin main
  cat AGENT_STATUS.md
STEP 5: When the real implementation lands → replace your stub
STEP 6: Commit the replacement immediately
```

A stub example (keys MUST match the real API so callers do not branch on typos):
```gdscript
# STUB: SimManager not yet built by Pixel Sim Agent.
func get_cell(x: int, y: int) -> Dictionary:
    return {"material_id": 0, "temperature": 0.0, "flags": 0}
```

---

## RETROSPECTIVE — SESSION LEARNINGS (DO NOT REGRESS)

These lessons come from multi-agent work: Pixel Sim GDExtension, World Gen / chunk streaming, Visual / TileSet pipelines, and Foundation-era stubs. Read before building sims, extensions, rendering, or cross-agent APIs.

### What slowed work or caused rework

- **Out-of-date agent prompts** — Instructions that cite `git clone -b 4.3-stable` (godot-cpp) or similar **without verifying the branch exists** caused immediate failure. Always confirm branch/tag names against the upstream repo at task time.
- **Non-contiguous ID tables in C++** — A dense array indexed by `material_id` breaks when IDs jump (e.g. terrain `0–7`, particles `100+`). Use an explicit lookup (`switch`, hash map, or generated table) keyed by ID.
- **API drift in godot-cpp** — Initialization APIs change between minor releases (e.g. `set_minimum_initialization_level` vs `set_minimum_library_initialization_level`, `GDREGISTER_CLASS` vs raw `ClassDB::register_class`). Pin godot-cpp to the **same minor line as the Godot editor** (e.g. 4.3) and verify against the **template** in `godot-cpp/test/`.
- **Stub vs final API mismatch** — Foundation used `step_simulation()` while the Pixel Sim prompt used `_physics_process` + `step()`. Downstream agents grep for one name. **Preserve forward compatibility**: keep deprecated names as thin wrappers, and document the canonical method in `AGENT_STATUS.md` EXPORTS.
- **Build toolchain absent in agent shells** — Python/SCons may not be on `PATH`. Do not assume the extension was built in-session. Document **local build steps** next to `SConstruct`; treat `res://bin/*.dll|*.so` as **artifacts not committed** (often gitignored).

### What other agents needed before it existed

- **`TerrawattSimNode` / `ClassDB.class_exists`** — Integration tests and `SimManager` branches on the C++ class. Until the native library loads, behavior is **fallback-only**. Callers must not assume sim state is non-empty.
- **Exact `get_cell` shape** — Any system using `SimManager.get_cell` must use **`material_id`**, `temperature`, `flags` — not ad-hoc keys. The doctrine stub example must match (see above).

### Stub adequacy

- **Minimal air-only stubs** are adequate to unblock compilation and scenes that do not read sim state.
- They are **not** adequate for agents that need believable water/fire behavior — those agents should either wait for `AGENT_STATUS` COMPLETE for Pixel Sim or implement a **documented GDScript fallback** with the same public API.

### Godot 4 / GDExtension specifics to get right

- **GDExtension entry** — `compatibility_minimum` and library paths in `.gdextension` must align with the editor and target platform names (e.g. `windows.debug.x86_64`).
- **Signals with `Rect2i`** — Use `Variant::RECT2I` / typed `Rect2i` consistently in `MethodInfo` and GDScript connections.
- **Autoload order** — Nodes that use `ClassDB` in `_ready` depend on the extension having registered classes; failures are often **missing DLL**, not script bugs.

### Doctrine / process additions

- **`AGENT_STATUS.md` EXPORTS** — List not only autoload names but **function signatures and Dictionary keys** for shared contracts.
- **`project.godot` autoloads** — Keep doctrine’s autoload list in sync with the file (e.g. include `WorldData` when present).
- **Quality gate for native code** — If your feature requires GDExtension, the quality gate includes **local compile + Godot run** on a machine with the toolchain, or CI that builds the library.

### Visual art, shell automation, and TileSet workflow (coordination session)

- **Windows PowerShell** — In many environments, `&&` is **not** a valid statement separator (PowerShell 5.x). Use `;` between commands, `cmd /c "a && b"`, or separate invocations. Always run download/build scripts in the **same shell** the repo uses (here: PowerShell on Windows).
- **PixelLab MCP is asynchronous** — Tools return job IDs; poll `get_tiles_pro` / `get_map_object` until status is completed. **Do not assume** the first HTTP 200 on a download URL is a valid image.
- **Validate binary assets after download** — For 16×16 tiles, files on the order of **tens of bytes** or uniform white squares usually mean a bad or placeholder result. Check **file size** and spot-check pixels before committing; **regenerate** failed indices only (smaller `n_tiles` batch) rather than re-running entire megabatches.
- **Godot CLI is not guaranteed in agent sandboxes** — Do not rely on `godot --headless -s` to emit resources. **EditorScript** (`extends EditorScript`, **File → Run**) is an acceptable delivery path. Document manual steps in `assets/ASSET_MANIFEST.md` (or agent notes). If policy allows, **commit generated `*.tres`** so others are not blocked on a local editor run.
- **TileSet physics layers are 0-based** — The first layer created by `add_physics_layer` is index **0**. Use `set_physics_layer_collision_layer(0, collision_layer_bitmask)` for that layer. Using index `1` when only one physics layer exists misassigns collision metadata.
- **TileMap cell mapping must match TileSet layout** — **Multi-source** tilesets (one `TileSetAtlasSource` per terrain ID) map `WorldData` tile_id → `source_id` (often `tile_id - 1`) with atlas coords `Vector2i(0, 0)`. **Single-atlas** placeholders use one source_id with multiple atlas columns. Put mapping in **one place** (e.g. `WorldData.tile_id_to_source_id` + renderer `_paint_cell`) so World Gen and Art never diverge.
- **AGENT_STATUS can lag code** — If `WorldData` already defines `TILE_*` constants, treat those as the **contract** for tile art and IDs; art agents need not wait for the status board to flip to COMPLETE if constants are merged on `main`.
- **Stub adequacy (rendering)** — A **solid-color or procedural `TileSet` fallback** when the final `terrawatt_tileset.tres` is missing is adequate for integration; the main scene must still run. Clearly document that the real TileSet is optional until EditorScript run or committed resource lands.

### World Gen & procedural streaming (session)

- **Phantom terrain after chunk unload** — If chunk data is dropped but the `TileMap` is not cleared for those cells, the player sees stale tiles. Emit `chunk_unloaded` (or equivalent) and erase cells, or repainting will lie about world state.
- **Column surface vs global Y bands** — Prompts may mix “sky below Y=10” with **per-column** `get_surface_y(x)`. Pick one model: typically `world_y < surface_y(x)` is air; depth bands (shallow/mid/deep) apply below that. Tests must use the same model as generation.
- **Per-frame full map repaint** — Iterating every loaded chunk every frame to `set_cell` is easy to write but expensive. Prefer updates on `chunk_loaded`, `tile_changed`, and unload unless profiling says otherwise.

### Tier 0 power systems & cross-agent stubs (session)

- **`SimManager` air-only stub** — While `get_cell` returns **air everywhere**, generators that depend on **water cells, steam, or spawned particles** will read as **off** in normal play. The implementation can still be **complete**; mark **EXPORTS** with *"meaningful power output requires Pixel Sim COMPLETE"* or ship a **debug-only** scene that calls `set_cell` / seeds particles for demos.
- **`WorldData.get_surface_y` stubs** — A **flat** or simplified surface lets **placement rules** (e.g. windmill “near surface”) run without **terrain-accurate** results. Same pattern: document stub dependence or test with World Gen’s real implementation.
- **Creating asset paths from automation** — **Create parent directories** before writing new files under `res://assets/...` (shell `mkdir`, or `DirAccess.make_dir_recursive` in tool scripts). Missing folders fail immediately.
- **Autoload singleton + `class_name`** — If the autoload script declares `class_name` with the **same name** as the singleton (e.g. `PowerGrid`), GDScript resolves that identifier to the **autoload instance**. Do not declare a second global type with the same name.
- **GDScript 4 float helpers** — Prefer typed **`clampf`**, **`lerpf`**, **`maxf`**, **`minf`** for float math where applicable; avoids accidental Variant paths and matches Godot 4 style in shared code.

---

## GIT WORKFLOW

Every agent works on the SAME repository. Coordination happens via git.

```bash
# Start of every session:
git pull origin main
cat AGENT_STATUS.md   # see what other agents have completed

# After every meaningful unit of work (a working function, a complete scene):
# Prefer staging only files you own (multi-agent repo — avoids bundling others' WIP):
git add path/to/your/changed_files.gd
git status   # confirm nothing unrelated is staged
git commit -m "[AgentName] feat: brief description of what was completed"
git push origin main
# Use `git add -A` only when you intentionally mean to commit the full tree (e.g. integration milestone).

# Commit message format (no emojis, professional):
# [WorldGen] feat: chunk generation and biome seeding complete
# [PixelSim] feat: water flow cellular automata working
# [Player] fix: collision detection with tile edges corrected
# [Integration] chore: wired up world renderer to main scene
```

NEVER force push. NEVER commit broken code that crashes Godot on load.
If your code has a known error, comment it out and commit the stub instead.

**Windows / PowerShell:** When documenting one-liner automation for agents, prefer **`;`**-separated commands or explicit `cmd /c` over bare `&&`, which fails on **Windows PowerShell 5.x** (see Retrospective).

---

## AGENT_STATUS.md PROTOCOL

This file is the shared status board. All agents read and update it.

Location: project root `/AGENT_STATUS.md`

Format for your update:
```
## [YOUR AGENT NAME] — [DATE]
STATUS: IN PROGRESS | COMPLETE | BLOCKED
COMPLETED:
  - list of finished items
IN PROGRESS:
  - what you're currently building
BLOCKED ON:
  - what you need from another agent (if anything)
EXPORTS (what other agents can now use):
  - autoload: MySystem.function_name() → what it returns
  - signal: my_signal(params) → when it fires
  - scene: res://my_system/my_scene.tscn
```

Update this file EVERY time you commit. It is how other agents find your work.

---

## CLAUDE CODE INTEGRATION

You have access to Claude Code via Cursor Pro. Use it.

Claude Code is a command-line AI that can:
- Run and debug Godot CLI commands
- Execute GDScript validation tools
- Search the codebase intelligently
- Run C++ compilation for GDExtension
- Write and run test scripts

How to invoke Claude Code from Cursor terminal:
```bash
# Debug a specific error
claude "I'm getting this Godot error: [paste error]. 
        The file is at [path]. Here's the relevant code: [paste code]. 
        Fix it and explain what was wrong."

# Review a script before committing
claude "Review this GDScript for correctness against Godot 4 API.
        Flag any deprecated methods or logic errors: [paste script]"

# C++ GDExtension help
claude "This C++ cellular automata code fails to compile with SCons.
        Error: [paste error]. Source: [paste source]. Fix it."
```

Use Claude Code proactively. Do not struggle with a bug for more than 10 minutes
before asking Claude Code to diagnose it.

---

## CLOUD AGENT DEBUGGING PATTERN

For persistent bugs that Claude Code inline doesn't resolve:

1. Open a new Cursor composer tab
2. Paste: "TERRAWATT DEBUG REQUEST — [AgentName]"
3. Paste the full error, the file path, and relevant code
4. Ask for: root cause, specific fix, and what to verify after applying
5. Apply the fix
6. Run Godot scene to verify
7. Commit if passing

Do not loop on the same error more than twice without escalating to cloud agent.

---

## CODE STANDARDS

- GDScript: typed variables always (`var count: int = 0`, not `var count = 0`)
- Every function has a one-line comment above it describing its purpose
- Every file starts with a `# SYSTEM: [system name]` and `# AGENT: [your agent name]` header
- No magic numbers — use named constants (`const CHUNK_SIZE: int = 32`)
- Signals over direct calls for cross-system communication
- Autoloads for shared globals — do not reach into other scripts directly
- Keep scripts under 300 lines — split into helper scripts if exceeding

---

## GODOT 4 STANDARDS (PROJECT-SPECIFIC)

- Autoloads registered in: Project > Project Settings > Autoload
- Current autoloads (verify in `project.godot`): `SimManager`, `WorldData`, `Inventory`, `PowerGrid`, `MaterialRegistry`
- TileMap for tile layer — use tile IDs from `MaterialRegistry`
- Custom draw (Node2D._draw()) for particle simulation rendering
- GDExtension for C++ simulation core — do NOT implement sim logic in GDScript (performance path); a small GDScript fallback is acceptable only if it matches the same public API and is documented
- **Material IDs** — Single source of truth: `MaterialRegistry` / shared headers; C++ must not assume contiguous indices
- @export all tunable values (speeds, sizes, timings) — makes balancing easy
- Use groups for creature/item management (`add_to_group("creatures")`)
- Scene tree structure must match the folder structure in the GDD exactly

---

## PIXELLAB MCP ART GENERATION

PixelLab MCP is the **preferred** path for art when the server is **enabled** and tool descriptors are available (see **UI, HUD, creatures** retrospective: **MCP preflight**). If MCP is missing, follow the **Placeholder exception** below and record the gap in **`AGENT_STATUS.md`**.

Standard call pattern:
```
Generate a 16x16 pixel art tile for Terra.Watt:
  Subject: [describe tile]
  Style: painterly pixel art, slightly gritty, detailed texture
  Palette: [relevant hex values from GDD Section 17]
  Lighting: natural subsurface, no hard outlines
  Output: PNG, transparent background where appropriate
Save to: res://assets/tiles/[category]/[name].png
```

Generate art BEFORE writing rendering code so you have real assets to test with.

**Placeholder exception (multi-agent reality):** If upstream art is not yet in `res://assets/`, you may ship a **runtime-generated** TileSet (e.g. `Image` + `ImageTexture` + `TileSetAtlasSource`) that matches `MaterialRegistry` / `WorldData` tile IDs. Mark it in code with a one-line reference: `# PLACEHOLDER TILESET — replace when Visual Agent lands assets per ASSET_MANIFEST.md`. Remove the exception once real atlases are wired. Do not commit empty scene references to missing PNG paths that break Godot load.

The same idea applies to **`AnimatedSprite2D`**: a **shared small PNG** plus **runtime `SpriteFrames`** (see Retrospective: Tier 0 power) is acceptable until PixelLab or Visual Agent supplies final sheets — better than fragile pasted `.tscn` resources or broken external refs.

---

## GODOT IMPORT — `.gdignore` (NOT `.gitignore`)

A file named **`.gdignore`** inside a folder tells Godot to **exclude that folder from the filesystem dock and from resource import**. It does **not** mean “git-ignore.”

- Adding real PNGs or audio under a path that still has `.gdignore` can prevent **any import**, so `ext_resource` references fail at load time.
- When a folder moves from “placeholder / empty” to “real assets,” **remove `.gdignore`** from that folder (or move assets to an imported path) and let Godot reimport.
- Foundation-era folders sometimes used `.gdignore` only to silence the editor until art landed — remove it as soon as resources exist.

---

## ENGINE VERSION & GODOT API DISCIPLINE

Multi-agent sessions repeatedly hit API ambiguity. Prevent it:

1. Read `project.godot` → `config/features` (e.g. `4.3`) and treat that minor version as authoritative for API questions.
2. Before using advanced noise: open the **class reference for that exact version** for `FastNoiseLite` (`noise_type`, `domain_warp_*`, fractal settings). Names and enums differ across Godot minors and from third-party FastNoise docs.
3. Prefer `for i in range(n)` for fixed iteration counts in shared code — it is unambiguous across reviewers and docs; integer `for i in n` behavior depends on GDScript version and is easy to misread.
4. TileMap / TileSet: confirm `set_cell` / `erase_cell` layer indices and `TileSet.add_physics_layer` signatures against your engine build — physics-layer APIs changed shape in Godot 4.x.

If the agent environment cannot run Godot, state that in the commit body or `AGENT_STATUS.md` and add a headless test script anyway so a developer with Godot on PATH or CI can verify.

---

## DATA CONTRACTS (IDS, SEEDS, MAIN SCENE)

- **Tile / material IDs:** `WorldData` tile constants and `MaterialRegistry` material IDs must stay identical. When you add a tile type, update both (or generate one from the other in a single source). Document the mapping in a comment at the top of `world_data.gd` if needed.
- **World seed:** Gameplay code that calls `WorldData.initialize()` must not silently fight headless tests. Prefer a single seed source (project setting, save slot, or explicit dev default) documented in `AGENT_STATUS.md` exports.
- **`main.tscn` / `main.gd`:** Treat as a **coordination hotspot**. Integration Agent owns integration; feature agents should deliver **PackedScenes** and wiring instructions. If you must edit `main`, `git pull` first, touch only your subtree, and note in the commit what you wired so the next agent does not duplicate or revert.

---

## STREAMING: DATA AND RENDER MUST STAY IN SYNC

If you unload simulated or generated chunks from memory:

1. Emit a signal (e.g. `chunk_unloaded(chunk_pos: Vector2i)`) before dropping data.
2. Any `TileMap` (or mesh) that painted those tiles must **erase** those cells or equivalent — otherwise the player sees phantom terrain. Pair `load_chunks_near` with `unload_distant_chunks` and renderer cleanup.

Do not re-paint every loaded chunk every frame unless profiling proves it is cheap; prefer reacting to `chunk_loaded`, `tile_changed`, and unload.

---

## STUBS: ADEQUACY CHECKLIST

Stubs are adequate when:

- Signatures match what dependents will call (methods, signals, parameter types).
- Constants and enums match the real system (`TILE_AIR`, material IDs).
- They fail safe (no crash on load; predictable defaults).

Stubs are **inadequate** when:

- IDs drift between registries (silent wrong colors, wrong mining drops).
- Missing signals that other agents already `connect()` to — document `signal` lines in `AGENT_STATUS.md` EXPORTS as soon as the interface is known.

---

## QUALITY GATE (before any commit)

Ask yourself:
- Does Godot open this scene without errors?
- Does the feature I implemented actually work when I run it?
- If the project has `res://tests/*.gd` headless scripts, did you run `godot --headless -s res://tests/...` (or note in the commit / `AGENT_STATUS.md` that Godot was not available in the agent shell)?
- Did I update AGENT_STATUS.md?
- Is my commit message formatted correctly?
- Did I leave any print() debug statements? (Remove them)
- Did I break any other system? (Run the main scene and check)

Task is NOT complete until all quality gates pass.

---

## COMMUNICATION STANDARDS

- No filler phrases ("Certainly!", "Great question!", "As requested...")
- Lead with status: what's done, what's in progress, what's blocked
- Use status markers: ✅ complete | ⚠️ issue found and fixed | 🚧 blocked
- File references always use full path from project root
- Commit messages are technical, precise, no emojis

---

## BOTTOM LINE

You are a senior engineer with full access and full autonomy.
Research first. Build stubs to stay unblocked. Commit constantly.
Use Claude Code. Use the cloud agent. Own your system end to end.
The GDD is law. AGENT_STATUS.md is your coordination layer. Git is your truth.
