TERRAWATT — VISUAL OVERHAUL AGENT V1: RESTRUCTURE
Single command: Paste into Cursor Composer Agent. Run FIRST and ALONE.

━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

## MISSION: Split TerraWattv2 into game/ and workshop/. Update all paths. Verify Godot still opens.

This is a structural surgery operation. Read everything before moving anything.
One wrong move can break Godot's resource paths. Follow each step exactly.

---

## PHASE 0: FULL RECON BEFORE TOUCHING ANYTHING

```powershell
# Map the entire current structure
Get-ChildItem -Path "." -Recurse -Directory | Select-Object FullName
Get-ChildItem -Path "." -Recurse -Filter "project.godot" | Select-Object FullName
Get-ChildItem -Path "." -Recurse -Filter "*.gd" | Measure-Object | Select-Object Count
Get-ChildItem -Path "." -Recurse -Filter "*.tscn" | Measure-Object | Select-Object Count
```

Report the full structure. Confirm exactly where project.godot currently lives.
Do NOT move anything until this recon is complete and reported.

---

## PHASE 1: CREATE THE NEW STRUCTURE

Create both top-level folders:
```powershell
New-Item -ItemType Directory -Force -Path "game"
New-Item -ItemType Directory -Force -Path "workshop"
New-Item -ItemType Directory -Force -Path "workshop\agentprompts"
New-Item -ItemType Directory -Force -Path "workshop\raw_assets\characters"
New-Item -ItemType Directory -Force -Path "workshop\raw_assets\tiles"
New-Item -ItemType Directory -Force -Path "workshop\raw_assets\backgrounds"
New-Item -ItemType Directory -Force -Path "workshop\raw_assets\ui"
New-Item -ItemType Directory -Force -Path "workshop\raw_assets\power"
New-Item -ItemType Directory -Force -Path "workshop\pipeline"
```

---

## PHASE 2: MOVE WORKSHOP FILES

Move all agent/documentation files to workshop/:

```powershell
# Agent prompts folder
if (Test-Path "agentprompts") {
    Move-Item "agentprompts\*" "workshop\agentprompts\" -Force
    Remove-Item "agentprompts" -Recurse -Force
}

# Root documentation files
$docs = @("TERRAWATT_GDD.md", "TERRAWATT_DOCTRINE.md", "AGENT_STATUS.md",
          "ALIGNMENT_REPORT.md", "README_LAUNCH.md", "README_TIER1.md",
          "AGENT_ALIGNMENT.md", "COWORK_INSTRUCTIONS.md")
foreach ($doc in $docs) {
    if (Test-Path $doc) {
        Move-Item $doc "workshop\" -Force
        Write-Host "Moved: $doc"
    }
}

# Move any existing raw PNGs to workshop/raw_assets
# (these are PixelLab outputs that ended up in wrong places)
Get-ChildItem -Path "." -Recurse -Filter "*_raw.png" -ErrorAction SilentlyContinue |
    ForEach-Object {
        Copy-Item $_.FullName "workshop\raw_assets\" -Force
        Write-Host "Copied raw: $($_.Name)"
    }
```

---

## PHASE 3: MOVE GODOT PROJECT TO game/

This is the critical step. Godot's res:// system is relative to project.godot.
Moving project.godot to game/ means all res:// paths still work — they
just now resolve relative to game/ instead of the root.

```powershell
# These are the Godot project folders/files to move into game/
$godotItems = @(
    "assets", "bin", "crafting", "creatures", "mining",
    "player", "power", "scripts", "simulation", "structures",
    "ui", "world", "main.tscn", "main.gd", "project.godot",
    "icon.svg", "icon.svg.import"
)

foreach ($item in $godotItems) {
    if (Test-Path $item) {
        Move-Item $item "game\" -Force
        Write-Host "Moved to game/: $item"
    }
}

# Move .godot cache folder (Godot needs this with the project)
if (Test-Path ".godot") {
    Move-Item ".godot" "game\.godot" -Force
    Write-Host "Moved .godot cache to game/"
}

# Move .cursor rules (Cursor loads these relative to workspace root)
# Keep .cursor at root — Cursor looks for it there
# But copy doctrine into workshop too for reference
if (Test-Path ".cursor\rules\TERRAWATT_DOCTRINE.md") {
    Copy-Item ".cursor\rules\TERRAWATT_DOCTRINE.md" "workshop\TERRAWATT_DOCTRINE.md" -Force
}
```

---

## PHASE 4: MOVE REMAINING ASSET FILES TO workshop/raw_assets

Any PNG files that exist outside game/assets/ are raw PixelLab outputs.
Move them to workshop/raw_assets/ for safekeeping:

```powershell
# Find any PNGs not inside game/ 
Get-ChildItem -Path "." -Recurse -Filter "*.png" |
    Where-Object { $_.FullName -notlike "*\game\*" -and $_.FullName -notlike "*\workshop\*" } |
    ForEach-Object {
        $dest = "workshop\raw_assets\" + $_.Name
        Copy-Item $_.FullName $dest -Force
        Write-Host "Archived raw: $($_.Name) → workshop/raw_assets/"
    }
```

---

## PHASE 5: UPDATE .cursor/rules PATH

The doctrine file needs to stay accessible to Cursor agents.
Create/update `.cursor/rules/TERRAWATT_DOCTRINE.md` at the root:

```powershell
# .cursor stays at root — Cursor reads it from there
# Ensure the doctrine is current
Copy-Item "workshop\TERRAWATT_DOCTRINE.md" ".cursor\rules\TERRAWATT_DOCTRINE.md" -Force
```

---

## PHASE 6: CLEAN UP LEFTOVER EMPTY FOLDERS

```powershell
# Remove any empty directories left at root (not game/, workshop/, .cursor/)
Get-ChildItem -Path "." -Directory |
    Where-Object { $_.Name -notin @("game", "workshop", ".cursor") } |
    ForEach-Object {
        $contents = Get-ChildItem $_.FullName -Recurse
        if ($contents.Count -eq 0) {
            Remove-Item $_.FullName -Recurse -Force
            Write-Host "Removed empty: $($_.Name)"
        } else {
            Write-Host "WARNING: Non-empty folder at root: $($_.Name) — investigate"
        }
    }
```

---

## PHASE 7: VERIFY FINAL STRUCTURE

```powershell
Write-Host "=== ROOT CONTENTS ==="
Get-ChildItem -Path "." -Directory | Select-Object Name

Write-Host "=== game/ CONTENTS ==="
Get-ChildItem -Path "game" | Select-Object Name

Write-Host "=== workshop/ CONTENTS ==="
Get-ChildItem -Path "workshop" -Recurse -Directory | Select-Object FullName

Write-Host "=== project.godot location ==="
Get-ChildItem -Path "." -Recurse -Filter "project.godot" | Select-Object FullName

Write-Host "=== GD file count in game/ ==="
Get-ChildItem -Path "game" -Recurse -Filter "*.gd" | Measure-Object | Select-Object Count
```

Expected result:
```
ROOT: game/  workshop/  .cursor/  .git/  .gitignore
game/: project.godot  assets/  player/  world/  creatures/  etc.
workshop/: agentprompts/  raw_assets/  pipeline/  TERRAWATT_GDD.md  etc.
```

---

## PHASE 8: OPEN GODOT AND VERIFY

IMPORTANT MANUAL STEP — tell the developer:
```
ACTION REQUIRED:
1. Open Godot 4
2. Click "Import" or "Scan"
3. Navigate to TerraWattv2/game/
4. Select project.godot
5. Confirm the project opens without errors
6. Check that res://assets/ and all script folders are visible in FileSystem
7. Press F5 — game should still run
```

Do not commit until developer confirms Godot opens correctly from game/.

---

## PHASE 9: UPDATE GIT AND .gitignore

```powershell
# Update .gitignore for new structure
$gitignore = @"
# Godot
game/.godot/
game/**/*.import
game/**/export_presets.cfg

# C++ build artifacts  
game/bin/*.dll
game/bin/*.so
game/bin/*.dylib

# Workshop pipeline cache
workshop/pipeline/__pycache__/
workshop/pipeline/*.pyc

# OS
.DS_Store
Thumbs.db
"@
Set-Content -Path ".gitignore" -Value $gitignore

git add -A
git status
git commit -m "[Restructure] refactor: split into game/ and workshop/, clean folder structure"
git push origin main
```

---

## FINAL REPORT

```
RESTRUCTURE AGENT — FINAL REPORT

Root structure:
  ✅ game/ created with all Godot files
  ✅ workshop/ created with all agent files
  ✅ workshop/raw_assets/ ready for PixelLab outputs
  ✅ workshop/pipeline/ ready for automation scripts
  ✅ .cursor/rules/ doctrine still at root

File counts:
  GD scripts in game/:    [N]
  TSCN scenes in game/:   [N]
  PNGs in game/assets/:   [N]
  PNGs in workshop/raw/:  [N]

Godot verification:
  ✅ project.godot found at game/project.godot
  ⏳ AWAITING DEVELOPER CONFIRMATION that Godot opens game/

Committed: [hash]

Self-Audit Complete. Structure is clean. Proceed to V2 Pipeline after Godot confirmed.
```
