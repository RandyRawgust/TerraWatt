# TERRAWATT — ULTIMATE AGENT PROMPT KIT
## Complete multi-agent launch guide for Cursor + Claude Code

---

## WHAT IS IN THIS KIT

```
TERRAWATT_GDD.md                 ← Game Design Document (the bible)
TERRAWATT_DOCTRINE.md            ← Agent operating rules (goes in .cursor/rules/)
AGENT_STATUS.md                  ← Shared coordination board (goes in project root)
AGENT_0_FOUNDATION.md            ← Run FIRST, alone. Sets up everything.
AGENT_1_PIXEL_SIM.md             ← Pixel simulation engine (C++ GDExtension)
AGENT_2_WORLD_GEN.md             ← Procedural world generation
AGENT_3_PLAYER.md                ← Player movement, mining, status
AGENTS_4_5_6_7_REMAINING.md      ← Visual/Art, UI/Creatures, Power Tier 0, Integration
README_LAUNCH.md                 ← This file
```

---

## PREREQUISITES (DO THESE BEFORE LAUNCHING AGENTS)

### Step 1 — Create your Godot project folder
1. Open Godot 4
2. Create a new project named "TerraWatt"
3. Choose "Compatibility" renderer (best for 2D pixel games)
4. Note the folder path — you'll open this in Cursor

### Step 2 — Initialize git repo
```bash
cd /path/to/your/TerraWatt/project
git init
git remote add origin https://github.com/YOUR_USERNAME/terrawatt.git
git branch -M main
```

### Step 3 — Copy kit files into your project
Copy these files into the project root:
- `TERRAWATT_GDD.md`
- `TERRAWATT_DOCTRINE.md`
- `AGENT_STATUS.md`

Create `.cursor/rules/` folder and copy `TERRAWATT_DOCTRINE.md` into it.

### Step 4 — Open project in Cursor
- Open Cursor
- File → Open Folder → select your TerraWatt project folder
- Verify Cursor can see the project files in the sidebar

### Step 5 — Verify Claude Code is available
In Cursor terminal (Ctrl+`):
```bash
claude --version
```
If not found: install from cursor.sh/claude-code or reinstall Cursor Pro.

### Step 6 — Make sure PixelLab MCP is active
- In Cursor, check the MCP panel (or Settings → MCP)
- PixelLab should show as "connected"
- If not: follow PixelLab's Cursor setup instructions

---

## LAUNCH ORDER

### ROUND 1 — Foundation (run ALONE, wait for it to finish)

1. Press `Ctrl+Shift+I` to open Composer
2. Make sure it says **"Agent"** mode (not Normal) in the dropdown
3. Copy the ENTIRE content of `AGENT_0_FOUNDATION.md`
4. Paste it into the Composer and press Enter
5. Watch it run. It will:
   - Create project.godot
   - Create all folders
   - Create all autoload stub files
   - Make the first git commit
6. **WAIT** until it reports "Foundation Agent — COMPLETE" before proceeding

---

### ROUND 2 — All 6 agents simultaneously

Once Foundation Agent is COMPLETE:

1. Open **6 more Composer Agent tabs** — press `+` in the Composer panel 6 times
2. Assign one agent per tab:

| Tab # | File | System |
|---|---|---|
| Tab 1 | `AGENT_1_PIXEL_SIM.md` | Pixel Simulation (MOST IMPORTANT) |
| Tab 2 | `AGENT_2_WORLD_GEN.md` | World Generation |
| Tab 3 | `AGENT_3_PLAYER.md` | Player / Mining |
| Tab 4 | First section of `AGENTS_4_5_6_7_REMAINING.md` | Visual & Art |
| Tab 5 | Second section of `AGENTS_4_5_6_7_REMAINING.md` | UI & Creatures |
| Tab 6 | Third section of `AGENTS_4_5_6_7_REMAINING.md` | Power Tier 0 |

3. Start all 6 tabs roughly simultaneously (they'll pull from each other's git commits)
4. Check on them every 10-15 minutes

**How to split AGENTS_4_5_6_7_REMAINING.md for tabs 4, 5, 6:**
- Tab 4: Everything from the start to the first `━━━━━` separator (Visual Agent section)
- Tab 5: Everything between separator 1 and separator 2 (UI & Creatures section)
- Tab 6: Everything between separator 2 and separator 3 (Power Tier 0 section)

---

### ROUND 3 — Integration (run LAST, after all 6 agents complete)

1. Watch `AGENT_STATUS.md` — when all 6 agents show `STATUS: COMPLETE`:
   ```bash
   git pull origin main && grep "STATUS:" AGENT_STATUS.md
   ```
2. Open a **new Composer Agent tab**
3. Copy the Integration Agent section (last section of `AGENTS_4_5_6_7_REMAINING.md`)
4. Paste and press Enter
5. This agent wires everything together and runs all verification tests

---

## MONITORING YOUR AGENTS

### See what all agents are doing
```bash
# In Cursor terminal — check git history across all agents
git log --oneline --all --graph

# See current status board
cat AGENT_STATUS.md

# Check if any agent is stuck (no commits in last 30 min)
git log --since="30 minutes ago" --oneline
```

### If an agent gets stuck
1. Look at what it's blocked on in `AGENT_STATUS.md`
2. If it's waiting for another agent's code: the stuck agent should have built a stub — remind it:
   *"You should have created a stub for this dependency. Build the stub and continue."*
3. If it's a compile/Godot error: paste the error directly into the stuck agent's chat

### Using Claude Code to debug mid-session
In any Cursor terminal tab:
```bash
# Quick code review
claude "Review this GDScript for Godot 4 API correctness: [paste code]"

# Debug an error
claude "Fix this Godot error: [paste full error output]"

# C++ GDExtension help
claude "This SConstruct fails with: [error]. Help me fix the build."
```

---

## RETRO (OPTIONAL — run after Integration completes)

Paste this into any agent that had issues during the session:

```
## Mission Briefing: Retrospective & Doctrine Evolution Protocol

The operational phase is complete. Review the entire session.

Analyze:
- What patterns caused delays or bugs?
- What did other agents depend on that wasn't ready?
- What stubs were used and were they adequate?
- What Godot 4 API mistakes were made?
- What should be added to TERRAWATT_DOCTRINE.md to prevent these next session?

Update TERRAWATT_DOCTRINE.md and .cursor/rules/TERRAWATT_DOCTRINE.md with durable lessons.
Commit the updated doctrine: "[Retro] docs: doctrine updated with session learnings"
```

---

## WHAT SCOPE 1 LOOKS LIKE WHEN DONE

When Integration Agent reports all 22 tests passing, you have:

- A world that generates from a seed (rolling hills, caves, ore veins)
- A player character (hardhat miner) who moves, jumps, and mines tiles
- Pixel simulation: water flows, fire spreads, steam rises
- Mining: click a tile → progress ring → tile disappears → collectible drops → auto-collects
- Hotbar: shows collected items with counts
- Status icons above player head (wet 💧, on fire 🔥, suffocating 💨)
- Underground gets dark → player headlamp illuminates
- Parallax deep space background scrolls
- Rabbits hopping on surface, wolves hunting at night
- Tier 0 power: water wheel, windmill, steam engine generating mechanical watts
- All art generated by PixelLab MCP in Starbound style

**This is your foundation. Every future tier builds on top of this.**

---

## NEXT SESSIONS (TIER 1+)

When ready to add Tier 1:
1. Run `retro.md` protocol to capture session learnings
2. Create a new prompt file based on this kit's pattern
3. Launch agents for: coal boiler system, electrical grid, first power poles, pollution mechanic
4. The GDD already specifies everything they need to build

---

*Terra.Watt Prompt Kit v1.0 — built for Cursor Pro + Claude Code + PixelLab MCP*
