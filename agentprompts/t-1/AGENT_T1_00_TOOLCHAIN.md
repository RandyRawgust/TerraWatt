TERRAWATT — PRE-PREFLIGHT TOOLCHAIN INSTALLER
Single command: Paste this entire block into a Cursor Composer Agent tab and press Enter.
Run this BEFORE the Preflight Agent. Takes ~5-15 minutes depending on download speed.

━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

## MISSION: Install Python and C++ build tools so the GDExtension can compile.

No code changes. No git commits. Pure toolchain setup.
This is a Windows machine. Use PowerShell syntax throughout (`;` not `&&`).

---

## PHASE 1: CHECK WHAT IS ALREADY INSTALLED

Run each check separately and report the result before proceeding:

```powershell
python --version
```
```powershell
pip --version
```
```powershell
cl 2>&1 | Select-Object -First 1
```
```powershell
scons --version
```
```powershell
git --version
```

Report exactly what each command returns. If a command is not found,
that tool needs installing. Continue to the relevant phase below.

---

## PHASE 2: INSTALL PYTHON (if missing)

Python 3.11 is recommended — stable, widely supported, works with SCons.

Download and install silently via winget (built into Windows 10/11):
```powershell
winget install Python.Python.3.11 --silent --accept-package-agreements --accept-source-agreements
```

If winget fails or is not available, download manually:
```powershell
# Download Python 3.11 installer
Invoke-WebRequest -Uri "https://www.python.org/ftp/python/3.11.9/python-3.11.9-amd64.exe" -OutFile "$env:TEMP\python_installer.exe"

# Install silently — adds to PATH automatically
Start-Process -FilePath "$env:TEMP\python_installer.exe" -ArgumentList "/quiet InstallAllUsers=1 PrependPath=1 Include_pip=1" -Wait
```

After install, CLOSE and REOPEN the Cursor terminal, then verify:
```powershell
python --version
pip --version
```
Both must return version numbers before continuing.

---

## PHASE 3: INSTALL SCONS (if missing)

SCons is the build system used by Godot's C++ extensions.
Install via pip once Python is confirmed working:

```powershell
pip install scons
```

Verify:
```powershell
scons --version
```
Must return something like `SCons by Steven Knight et al.: ...`

If `scons` is not found after pip install, try:
```powershell
python -m SCons --version
```
If that works, note it — the Preflight Agent will need to call
`python -m SCons` instead of `scons` directly.

---

## PHASE 4: INSTALL C++ BUILD TOOLS (if `cl` missing)

This is the Microsoft C++ compiler. Required to compile the GDExtension.
The fastest path is the Build Tools package (no full Visual Studio needed).

```powershell
winget install Microsoft.VisualStudio.2022.BuildTools --silent --accept-package-agreements --accept-source-agreements
```

If winget is slow or fails, download directly:
```powershell
Invoke-WebRequest -Uri "https://aka.ms/vs/17/release/vs_BuildTools.exe" -OutFile "$env:TEMP\vs_buildtools.exe"
```

Then run the installer — this part requires manual interaction:
```powershell
Start-Process -FilePath "$env:TEMP\vs_buildtools.exe" -Wait
```

In the installer window that opens:
1. Check: **"Desktop development with C++"**
2. On the right panel, confirm these are checked:
   - MSVC v143 - VS 2022 C++ x64/x86 build tools
   - Windows 11 SDK (or Windows 10 SDK if on Win10)
3. Click **Install**
4. Wait for download and install (~2-4GB, 10-15 minutes)

After install completes, CLOSE Cursor completely and reopen it.
Then verify in a NEW terminal:
```powershell
cl 2>&1 | Select-Object -First 1
```
Must return something like: `Microsoft (R) C/C++ Optimizing Compiler Version...`

If `cl` still not found after install, the compiler needs to be on PATH.
Run this to locate it:
```powershell
Get-ChildItem -Path "C:\Program Files (x86)\Microsoft Visual Studio" -Recurse -Filter "cl.exe" -ErrorAction SilentlyContinue | Select-Object -First 3 FullName
```
Report the path it finds. The Preflight Agent will need it.

---

## PHASE 5: FINAL VERIFICATION

Run all checks one more time and report each result:

```powershell
python --version
```
```powershell
pip --version
```
```powershell
scons --version
```
```powershell
cl 2>&1 | Select-Object -First 1
```
```powershell
git --version
```

---

## FINAL REPORT FORMAT

```
TOOLCHAIN INSTALLER — FINAL REPORT

Python:  ✅ [version] / ⚠️ installed but needs terminal restart / 🚧 failed — [reason]
pip:     ✅ [version] / 🚧 failed — [reason]
SCons:   ✅ [version] / ⚠️ only works as `python -m SCons` / 🚧 failed — [reason]
cl.exe:  ✅ [version] / 🚧 failed — [reason]
git:     ✅ [version] / 🚧 not installed

[If all ✅:]
Toolchain ready. Launch AGENT_T1_0_PREFLIGHT.md now.

[If any 🚧:]
BLOCKED: [describe what failed and what the developer needs to do manually]
Do NOT proceed to Preflight until all tools are confirmed working.

Notes for Preflight Agent:
  [e.g. "SCons must be called as `python -m SCons` not `scons`"]
  [e.g. "cl.exe found at C:\Program Files\... — use Developer Command Prompt"]
```

---

## IF VISUAL STUDIO INSTALLER NEEDS MANUAL STEPS

Tell the developer:

```
ACTION REQUIRED — cannot be automated:

1. The Visual Studio Build Tools installer has opened
2. Check the box for "Desktop development with C++"  
3. Click Install in the bottom right
4. Wait for it to finish (10-15 minutes)
5. Close Cursor completely
6. Reopen Cursor
7. Run this prompt again to verify cl.exe is working
8. Then proceed to AGENT_T1_0_PREFLIGHT.md
```
