Add-Type -AssemblyName System.Drawing
function Save-Radial($path) {
    $s = 128
    $bmp = New-Object Drawing.Bitmap $s, $s
    $cx = $s / 2.0
    $cy = $s / 2.0
    $rmax = [Math]::Min($cx, $cy)
    for ($y = 0; $y -lt $s; $y++) {
        for ($x = 0; $x -lt $s; $x++) {
            $dx = $x - $cx + 0.5
            $dy = $y - $cy + 0.5
            $d = [Math]::Sqrt($dx * $dx + $dy * $dy)
            $t = [Math]::Max(0.0, 1.0 - ($d / $rmax))
            $a = [int](255 * $t * $t)
            $bmp.SetPixel($x, $y, [Drawing.Color]::FromArgb($a, 255, 245, 220))
        }
    }
    $bmp.Save($path, [Drawing.Imaging.ImageFormat]::Png)
    $bmp.Dispose()
}
function Save-OreIcon($path, $r, $g, $b) {
    $bmp = New-Object Drawing.Bitmap 8, 8
    for ($y = 0; $y -lt 8; $y++) {
        for ($x = 0; $x -lt 8; $x++) {
            $edge = ($x -eq 0 -or $y -eq 0 -or $x -eq 7 -or $y -eq 7)
            $a = if ($edge) { 200 } else { 255 }
            $bmp.SetPixel($x, $y, [Drawing.Color]::FromArgb($a, $r, $g, $b))
        }
    }
    $bmp.Save($path, [Drawing.Imaging.ImageFormat]::Png)
    $bmp.Dispose()
}
$root = Split-Path $PSScriptRoot -Parent
Save-Radial (Join-Path $root "assets\ui\light_radial.png")
$ores = Join-Path $root "assets\tiles\ores"
Save-OreIcon (Join-Path $ores "dirt_icon.png") 120 85 55
Save-OreIcon (Join-Path $ores "stone_icon.png") 120 120 120
Save-OreIcon (Join-Path $ores "coal_icon.png") 40 40 40
Save-OreIcon (Join-Path $ores "copper_ore_icon.png") 184 115 51
Save-OreIcon (Join-Path $ores "iron_ore_icon.png") 138 138 150
Save-OreIcon (Join-Path $ores "clay_icon.png") 166 122 89
Write-Host "done"
