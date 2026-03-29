TERRAWATT — GRAPHICS OVERHAUL AGENT V1: SETUP
Single command: Paste into Cursor Composer Agent. Run FIRST and ALONE.

━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

## MISSION: Clean structure, install Style Bible, copy logo references, build pipeline foundation.

---

## PHASE 0: RECON

```powershell
git pull origin main
Get-ChildItem -Path "." | Select-Object Name, Attributes
Get-ChildItem -Path "." -Recurse -Filter "project.godot" | Select-Object FullName
Get-ChildItem -Path "." -Recurse -Filter "*.png" | Select-Object FullName, Length | Sort-Object FullName
```

Report the full structure. Note where project.godot lives.
Note every PNG found and its size.
Do NOT move anything until recon is reported.

---

## PHASE 1: ENSURE CORRECT FOLDER STRUCTURE

The project must have exactly this layout at the root:

```
TerraWattv2/
├── game/              ← Godot project lives here
│   ├── project.godot
│   ├── assets/
│   │   ├── backgrounds/
│   │   ├── creatures/
│   │   ├── player/
│   │   ├── power/
│   │   │   └── tier1/
│   │   ├── structures/
│   │   ├── tiles/
│   │   │   ├── ores/
│   │   │   └── terrain/
│   │   └── ui/
│   ├── creatures/
│   ├── mining/
│   ├── player/
│   ├── power/
│   ├── simulation/
│   ├── structures/
│   ├── ui/
│   └── world/
│
└── workshop/          ← everything else lives here
    ├── agentprompts/
    ├── pipeline/
    └── raw_assets/
        ├── backgrounds/
        ├── characters/
        ├── logo/
        ├── power/
        ├── tiles/
        └── ui/
```

Create any missing folders:
```powershell
$folders = @(
    "game\assets\backgrounds", "game\assets\creatures",
    "game\assets\player", "game\assets\power\tier1",
    "game\assets\structures", "game\assets\tiles\ores",
    "game\assets\tiles\terrain", "game\assets\ui",
    "workshop\agentprompts", "workshop\pipeline",
    "workshop\raw_assets\backgrounds", "workshop\raw_assets\characters",
    "workshop\raw_assets\logo", "workshop\raw_assets\power",
    "workshop\raw_assets\tiles", "workshop\raw_assets\ui"
)
foreach ($f in $folders) {
    New-Item -ItemType Directory -Force -Path $f | Out-Null
    Write-Host "Ensured: $f"
}
```

---

## PHASE 2: COPY LOGO FILES TO workshop/raw_assets/logo/

The two logo PNGs are the visual reference for the entire game.
Find them and copy to the logo folder:

```powershell
# Search for logo files
Get-ChildItem -Path "." -Recurse -Filter "logo*.png" -ErrorAction SilentlyContinue |
    Select-Object FullName, Length

# Copy the pixel art logo (smaller file) as logo_pixel.png
# Copy the full illustrated logo (larger file) as logo_full.png
# Adjust source paths based on what the search above finds
```

After copying, confirm both are in workshop/raw_assets/logo/:
```powershell
Get-ChildItem "workshop\raw_assets\logo" | Select-Object Name, Length
```

---

## PHASE 3: REMOVE ALL .gdignore FROM ASSET FOLDERS

These block Godot from seeing the files:
```powershell
Get-ChildItem -Path "game\assets" -Recurse -Filter ".gdignore" |
    ForEach-Object { Remove-Item $_.FullName -Force ; Write-Host "Removed: $($_.FullName)" }
Get-ChildItem -Path "workshop\raw_assets" -Recurse -Filter ".gdignore" |
    ForEach-Object { Remove-Item $_.FullName -Force ; Write-Host "Removed: $($_.FullName)" }
```

---

## PHASE 4: INSTALL STYLE BIBLE

Copy `TERRAWATT_STYLE_BIBLE_V2.md` into:
- `workshop/TERRAWATT_STYLE_BIBLE.md`
- `.cursor/rules/TERRAWATT_STYLE_BIBLE.md`

Both copies must be identical. Cursor loads from `.cursor/rules/` automatically.

```powershell
Copy-Item "TERRAWATT_STYLE_BIBLE_V2.md" "workshop\TERRAWATT_STYLE_BIBLE.md" -Force
Copy-Item "TERRAWATT_STYLE_BIBLE_V2.md" ".cursor\rules\TERRAWATT_STYLE_BIBLE.md" -Force
Write-Host "Style Bible installed in both locations."
```

---

## PHASE 5: MOVE ANY EXISTING VALID PNGs TO CORRECT LOCATIONS

Any PNG over 500 bytes found outside game/ or workshop/ is a misplaced asset.
Move it to the correct raw_assets subfolder:

```powershell
Get-ChildItem -Path "." -Recurse -Filter "*.png" -ErrorAction SilentlyContinue |
    Where-Object {
        $_.FullName -notlike "*\game\*" -and
        $_.FullName -notlike "*\workshop\*" -and
        $_.FullName -notlike "*\.godot\*" -and
        $_.Length -gt 500
    } | ForEach-Object {
        $dest = "workshop\raw_assets\" + $_.Name
        Copy-Item $_.FullName $dest -Force
        Write-Host "Archived: $($_.Name) ($($_.Length) bytes)"
    }
```

---

## PHASE 6: INSTALL PIPELINE DEPENDENCIES

```powershell
pip install Pillow
python -c "from PIL import Image; print('Pillow OK')"
& "C:\Program Files\Aseprite\Aseprite.exe" --version
```

Report version numbers. If either fails — stop and report.

---

## PHASE 7: CREATE FRESH manifest.json

Create `workshop/pipeline/manifest.json`:

```json
{
  "version": "2.0",
  "style_bible": "workshop/TERRAWATT_STYLE_BIBLE.md",
  "aseprite": "C:\\Program Files\\Aseprite\\Aseprite.exe",
  "logo_pixel": "workshop/raw_assets/logo/logo_pixel.png",
  "logo_full": "workshop/raw_assets/logo/logo_full.png",
  "paths": {
    "raw_characters": "workshop/raw_assets/characters",
    "raw_tiles": "workshop/raw_assets/tiles",
    "raw_backgrounds": "workshop/raw_assets/backgrounds",
    "raw_power": "workshop/raw_assets/power",
    "raw_ui": "workshop/raw_assets/ui",
    "game_assets": "game/assets"
  },
  "characters": {
    "player":  {"master": "player_master.png",  "status": "needed", "frame_w": 24, "frame_h": 40, "frames": ["idle","walk1","walk2","walk3","walk4","jump"]},
    "wolf":    {"master": "wolf_master.png",    "status": "needed", "frame_w": 32, "frame_h": 20, "frames": ["idle","walk1","walk2","walk3","walk4","attack"]},
    "rabbit":  {"master": "rabbit_master.png",  "status": "needed", "frame_w": 16, "frame_h": 16, "frames": ["idle","hop1","hop2"]},
    "bird":    {"master": "bird_master.png",    "status": "needed", "frame_w": 12, "frame_h": 10, "frames": ["perched","flap1","flap2"]}
  },
  "tiles": {
    "dirt":        {"file": "tile_dirt.png",       "status": "needed", "dest": "game/assets/tiles/terrain/dirt.png"},
    "grass_dirt":  {"file": "tile_grass_dirt.png", "status": "needed", "dest": "game/assets/tiles/terrain/grass_dirt.png"},
    "stone":       {"file": "tile_stone.png",      "status": "needed", "dest": "game/assets/tiles/terrain/stone.png"},
    "clay":        {"file": "tile_clay.png",       "status": "needed", "dest": "game/assets/tiles/terrain/clay.png"},
    "coal_ore":    {"file": "tile_coal_ore.png",   "status": "needed", "dest": "game/assets/tiles/ores/coal_ore.png"},
    "copper_ore":  {"file": "tile_copper_ore.png", "status": "needed", "dest": "game/assets/tiles/ores/copper_ore.png"},
    "iron_ore":    {"file": "tile_iron_ore.png",   "status": "needed", "dest": "game/assets/tiles/ores/iron_ore.png"},
    "wood_plank":  {"file": "tile_wood_plank.png", "status": "needed", "dest": "game/assets/tiles/structures/wood_plank.png"}
  },
  "backgrounds": {
    "bg_sky":        {"file": "bg_sky.png",        "status": "needed", "dest": "game/assets/backgrounds/bg_sky.png"},
    "bg_industrial": {"file": "bg_industrial.png", "status": "needed", "dest": "game/assets/backgrounds/bg_industrial_tier1.png"}
  },
  "power": {
    "furnace":  {"file": "power_furnace.png",  "status": "needed", "dest": "game/assets/power/tier1/furnace.png"},
    "boiler":   {"file": "power_boiler.png",   "status": "needed", "dest": "game/assets/power/tier1/water_boiler.png"},
    "turbine":  {"file": "power_turbine.png",  "status": "needed", "dest": "game/assets/power/tier1/steam_turbine.png"},
    "pole":     {"file": "power_pole.png",     "status": "needed", "dest": "game/assets/power/tier1/power_pole.png"}
  },
  "ui": {
    "hotbar_slot":  {"file": "ui_hotbar_slot.png",  "status": "needed", "dest": "game/assets/ui/hotbar_slot.png"},
    "status_icon":  {"file": "ui_status_icon.png",  "status": "needed", "dest": "game/assets/ui/status_icon_base.png"},
    "light_radial": {"file": "ui_light_radial.png", "status": "needed", "dest": "game/assets/ui/light_radial.png"}
  }
}
```

---

## PHASE 8: COMMIT

```powershell
git add workshop/
git add game/assets/
git add .cursor/rules/TERRAWATT_STYLE_BIBLE.md
git add .gitignore
git status
git commit -m "[Overhaul-V1] setup: structure clean, Style Bible installed, manifest created"
git push origin main
```

---

## FINAL REPORT

```
OVERHAUL V1 SETUP — FINAL REPORT

Structure:        ✅ game/ and workshop/ confirmed
Logo files:       ✅ logo_pixel.png + logo_full.png in workshop/raw_assets/logo/
Style Bible:      ✅ installed in workshop/ and .cursor/rules/
.gdignore files:  ✅ [N] removed from asset folders
Pillow:           ✅ [version]
Aseprite:         ✅ [version]
manifest.json:    ✅ created, 35 assets tracked
Committed:        ✅ [hash]

Proceed to V2 Master Sprites agent.
```
