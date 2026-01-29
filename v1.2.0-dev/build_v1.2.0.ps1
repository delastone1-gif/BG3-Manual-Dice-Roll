# Build PhysicalDiceMod.pak (v1.2.0-dev)
# NOTE: Edit DivinePath if needed
$DivinePath = "C:\Users\boris\Downloads\LSLib\Packed\Tools\Divine.exe"
$ProjectRoot = $PSScriptRoot
$TempPath = "$env:TEMP\pak_temp_v120"
$OutputPath = "$env:LOCALAPPDATA\Larian Studios\Baldur`'s Gate 3\Mods\PhysicalDiceMod_v1.2.0-dev.pak"

Write-Host "Building PhysicalDiceMod v1.2.0-dev..." -ForegroundColor Cyan
Write-Host "Source: $ProjectRoot\Mods\PhysicalDiceMod" -ForegroundColor Gray

# Check if Divine.exe exists
if (-not (Test-Path $DivinePath)) {
    Write-Host "`nERROR: Divine.exe not found at: $DivinePath" -ForegroundColor Red
    Write-Host "Please download LSLib from: https://github.com/Norbyte/lslib/releases" -ForegroundColor Yellow
    Write-Host "Then edit this script to set the correct DivinePath." -ForegroundColor Yellow
    exit 1
}

# Create temp folder with correct Mods/PhysicalDiceMod structure
Write-Host "Creating temp folder with correct structure..." -ForegroundColor Gray
if (Test-Path $TempPath) {
    Remove-Item -Recurse -Force $TempPath
}
New-Item -ItemType Directory -Path "$TempPath\Mods" -Force | Out-Null
Copy-Item -Recurse "$ProjectRoot\Mods\PhysicalDiceMod" "$TempPath\Mods\"

# Pack from temp folder (must contain Mods/PhysicalDiceMod/ structure)
Write-Host "Packing with Divine.exe..." -ForegroundColor Gray
& $DivinePath -g bg3 -a create-package -s $TempPath -d $OutputPath -c lz4

# Clean up temp folder
Remove-Item -Recurse -Force $TempPath

if ($LASTEXITCODE -eq 0) {
    Write-Host "`nBuild successful!" -ForegroundColor Green
    Write-Host "Output: $OutputPath" -ForegroundColor Gray

    # Show file info
    $fileInfo = Get-Item $OutputPath
    Write-Host "Size: $([math]::Round($fileInfo.Length / 1KB, 2)) KB" -ForegroundColor Gray
    Write-Host "Modified: $($fileInfo.LastWriteTime)" -ForegroundColor Gray
    Write-Host "`nCopy to Mods folder if testing:" -ForegroundColor Yellow
    $modsFolder = "$env:LOCALAPPDATA\Larian Studios\Baldur`'s Gate 3\Mods\PhysicalDiceMod.pak"
    Write-Host "   Copy-Item `"$OutputPath`" `"$modsFolder`"" -ForegroundColor Gray
    Write-Host "`nRestart BG3 to load the new version." -ForegroundColor Yellow
} else {
    Write-Host "`nBuild failed!" -ForegroundColor Red
    exit 1
}
