# TERRAWATT — COWORK INSTRUCTIONS
## Plain English instructions for Claude Cowork desktop agent
## Run simultaneously with AGENT_ALIGNMENT.md in Cursor

---

## YOUR ROLE

You are the visual verifier. The Cursor alignment agent is fixing code.
Your job is to open Godot, force-import all assets, run the game,
and report back what you actually see on screen.

You have access to the desktop. Use it.

---

## STEP 1 — WAIT FOR ALIGNMENT AGENT TO COMMIT

First check if the Cursor agent has finished its initial fixes:

Open a terminal and run:
```
cd [path to TerraWatt project folder]
git log --oneline -3
```

If the latest commit contains "[Alignment]" — proceed to Step 2.
If not — wait 2 minutes and check again. The Cursor agent runs first.

---

## STEP 2 — OPEN GODOT AND FORCE REIMPORT

1. Open **Godot 4** from the desktop or Start menu
2. If the TerraWatt project is in the list — click it to open
   If not — click **Import**, navigate to the TerraWatt folder, select `project.godot`
3. Wait for Godot to finish its initial scan (progress bar at top)
4. Look at the **FileSystem panel** (bottom-left)
5. Click on the `res://assets/` folder to expand it
6. You should see all subfolders: `creatures/`, `player/`, `backgrounds/`, `tiles/`, `power/`

**Force reimport everything:**
- In the top menu: **Project → Tools → Reimport All**
- OR right-click the `assets` folder in FileSystem → **Reimport**
- Wait for the spinner/progress to finish completely

If any PNG shows a red error icon in the FileSystem panel — note its path.

---

## STEP 3 — READ THE ALIGNMENT REPORT

Open `ALIGNMENT_REPORT.md` from the project root in any text editor.
Find the section "NEEDS GODOT REIMPORT" and note which files are listed.
After the reimport in Step 2, these should now be resolved.

---

## STEP 4 — RUN THE GAME

Press **F5** in Godot (or click the ▶ Play button).

Wait for the game window to open. Then check:

**In the Output panel (bottom of Godot editor):**
- Look for red ERROR lines — screenshot the output panel
- Note any errors that mention missing textures, failed animations, or missing nodes

**In the game window:**
- Can you see the player character? Does it have a real sprite or is it a taco/blob?
- Is the game running smoothly or stuttering/lagging?
- Can you see the world terrain (brown dirt, green grass surface)?
- Is the hotbar visible at the bottom?
- Is the power meter visible top-right?

---

## STEP 5 — TEST MOVEMENT AND BASIC GAMEPLAY

With the game running, test these and note pass/fail for each:

```
Movement:
  [ ] WASD moves the player left and right
  [ ] W or Space makes the player jump
  [ ] Player walks animation plays when moving
  [ ] Player idle animation plays when still

World:
  [ ] Terrain is visible (not all black or all grey)
  [ ] Can dig underground (click on ground tiles)
  [ ] Mined tile disappears
  [ ] Collectible item drops and bobs
  [ ] Walking over item collects it
  [ ] Hotbar shows collected item with count

Creatures:
  [ ] Rabbit visible on surface (real sprite, not white square)
  [ ] Bird visible flying (real sprite, not white square)
  [ ] Wait for nighttime — wolf appears (real sprite)

Visual:
  [ ] No obvious lag or stuttering
  [ ] Screen resolution looks correct (not oversized)
```

---

## STEP 6 — SCREENSHOT AND REPORT

Take a screenshot of:
1. The running game window
2. The Godot Output panel showing current errors

Then write your findings to `ALIGNMENT_REPORT.md` — append a new section:

```markdown
## COWORK VISUAL REPORT
Date: [date/time]

### Import Status
[Did reimport complete successfully? Any red icons remaining?]

### Game Launch
[Did F5 work? Any launch errors?]

### Visual Checklist
Movement:    [results]
World:       [results]
Creatures:   [results — real sprites or placeholders?]
Performance: [smooth / laggy / stuttering]

### Output Panel Errors
[paste any red error lines]

### Screenshots taken
[describe what is visible in the game window]

### Recommended Next Actions
[what still needs fixing based on what you saw]
```

---

## STEP 7 — IF SPRITES STILL NOT SHOWING

If creature sprites are still white squares or missing after reimport:

1. In Godot FileSystem, navigate to `res://assets/creatures/`
2. Click on `wolf_sheet.png`
3. In the **Import panel** (right side, next to Inspector) — verify it shows:
   - Preset: `2D Pixel` (important for pixel art — no filtering/mipmaps)
   - If it says something else, change it to `2D Pixel` and click **Reimport**
4. Do the same for `rabbit_sheet.png` and `bird_sheet.png`
5. Do the same for `player_sheet.png` in `res://assets/player/`

**The 2D Pixel preset is critical** — without it sprites will be blurry
even if the code sets TEXTURE_FILTER_NEAREST.

After changing import presets, press F5 again and check.

---

## STEP 8 — REPORT BACK

Once you have visual confirmation of what works and what doesn't,
the Cursor alignment agent can be given a targeted follow-up prompt
with exactly what still needs fixing.

Your visual report is the ground truth. Trust what you see on screen
over what the code claims to do.
