# Terra.Watt — Agent Manifest

## Project
2D sandbox power generation game. Godot 4. GDScript + C++ GDExtension.

## Key Files
- TERRAWATT_GDD.md       — Game Design Document (source of truth)
- AGENT_STATUS.md        — Inter-agent status board (update after every commit)
- .cursor/rules/         — Cursor AI doctrine files

## Autoloads (singletons accessible from anywhere)
- SimManager             — Cellular automata simulation layer
- WorldData              — World generation and tile access
- Inventory              — Player item storage
- PowerGrid              — Power generation/demand tracking
- MaterialRegistry       — All material definitions

## Folder Structure
See TERRAWATT_GDD.md Section 16.

## Build Instructions (GDExtension C++ sim layer)
cd simulation/gdextension && scons platform=<your_platform>

## Git Branch Strategy
main — always runnable. Commit stubs, not broken code.
