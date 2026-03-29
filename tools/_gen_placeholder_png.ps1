Add-Type -AssemblyName System.Drawing
$bmp = New-Object Drawing.Bitmap 96, 40
for ($y = 0; $y -lt 40; $y++) {
    for ($x = 0; $x -lt 96; $x++) {
        $c = [Drawing.Color]::FromArgb(255, [Math]::Min(255, 60 + ($x % 24) * 6), 90, 55)
        $bmp.SetPixel($x, $y, $c)
    }
}
$out = Join-Path $PSScriptRoot "..\assets\player\player_frames.png"
$bmp.Save($out, [Drawing.Imaging.ImageFormat]::Png)
$bmp.Dispose()
Write-Host "saved $out"
