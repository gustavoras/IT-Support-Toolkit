$codigo = @'
# IT Support Toolkit
# Windows Maintenance Toolkit
# Author: Gustavo

Clear-Host

Write-Host ""
Write-Host "==================================================" -ForegroundColor Cyan
Write-Host "       IT SUPPORT TOOLKIT - MAINTENANCE           " -ForegroundColor Cyan
Write-Host "==================================================" -ForegroundColor Cyan
Write-Host ""

Write-Host "SYSTEM INFORMATION" -ForegroundColor Yellow
Write-Host "------------------"

$Computer = Get-CimInstance Win32_ComputerSystem
$OS = Get-CimInstance Win32_OperatingSystem

Write-Host "Computer : $($Computer.Name)"
Write-Host "User     : $($Computer.UserName)"
Write-Host "Windows  : $($OS.Caption)"
Write-Host "Version  : $($OS.Version)"
Write-Host ""

Write-Host "DISK STATUS BEFORE MAINTENANCE" -ForegroundColor Yellow
Write-Host "------------------------------"

$DiskBefore = Get-CimInstance Win32_LogicalDisk -Filter "DeviceID='C:'"

$FreeBefore = [math]::Round($DiskBefore.FreeSpace / 1GB, 2)
$SizeBefore = [math]::Round($DiskBefore.Size / 1GB, 2)
$UsedBefore = [math]::Round($SizeBefore - $FreeBefore, 2)

Write-Host "Total : $SizeBefore GB"
Write-Host "Used  : $UsedBefore GB"
Write-Host "Free  : $FreeBefore GB"
Write-Host ""

Write-Host "TEMP FILE CLEANUP" -ForegroundColor Yellow
Write-Host "-----------------"

$TempFolders = @(
    $env:TEMP,
    "$env:WINDIR\Temp"
)

foreach ($Folder in $TempFolders) {

    if (Test-Path $Folder) {

        Write-Host "Cleaning: $Folder"

        try {

            Get-ChildItem -Path $Folder -Force -ErrorAction SilentlyContinue |
                Remove-Item -Force -Recurse -ErrorAction SilentlyContinue

            Write-Host "[OK] Cleanup completed." -ForegroundColor Green

        }
        catch {

            Write-Host "[WARNING] Some files could not be removed." -ForegroundColor Yellow
        }
    }
}

Write-Host ""

Write-Host "RECYCLE BIN" -ForegroundColor Yellow
Write-Host "-----------"

try {

    Clear-RecycleBin -Force -ErrorAction SilentlyContinue

    Write-Host "[OK] Recycle Bin processed." -ForegroundColor Green

}
catch {

    Write-Host "[WARNING] Recycle Bin could not be completely cleared." -ForegroundColor Yellow
}

Write-Host ""

Write-Host "WINDOWS IMAGE HEALTH" -ForegroundColor Yellow
Write-Host "--------------------"

Write-Host "Running DISM /RestoreHealth..."
Write-Host "This operation may take several minutes."
Write-Host ""

DISM.exe /Online /Cleanup-Image /RestoreHealth

Write-Host ""

Write-Host "SYSTEM FILE CHECKER" -ForegroundColor Yellow
Write-Host "-------------------"

Write-Host "Running SFC /scannow..."
Write-Host "This operation may take several minutes."
Write-Host ""

sfc.exe /scannow

Write-Host ""

Write-Host "DISK STATUS AFTER MAINTENANCE" -ForegroundColor Yellow
Write-Host "-----------------------------"

$DiskAfter = Get-CimInstance Win32_LogicalDisk -Filter "DeviceID='C:'"

$FreeAfter = [math]::Round($DiskAfter.FreeSpace / 1GB, 2)
$SizeAfter = [math]::Round($DiskAfter.Size / 1GB, 2)
$UsedAfter = [math]::Round($SizeAfter - $FreeAfter, 2)

$Recovered = [math]::Round($FreeAfter - $FreeBefore, 2)

Write-Host "Total : $SizeAfter GB"
Write-Host "Used  : $UsedAfter GB"
Write-Host "Free  : $FreeAfter GB"

if ($Recovered -gt 0) {

    Write-Host "Recovered space : $Recovered GB" -ForegroundColor Green

}
elseif ($Recovered -eq 0) {

    Write-Host "Recovered space : 0 GB"

}
else {

    Write-Host "Recovered space : $Recovered GB"

}

Write-Host ""

Write-Host "MAINTENANCE SUMMARY" -ForegroundColor Yellow
Write-Host "-------------------"

Write-Host "[OK] Temporary files processed." -ForegroundColor Green
Write-Host "[OK] Recycle Bin processed." -ForegroundColor Green
Write-Host "[OK] DISM health check executed." -ForegroundColor Green
Write-Host "[OK] SFC system file check executed." -ForegroundColor Green
Write-Host ""

Write-Host "==================================================" -ForegroundColor Cyan
Write-Host "          MAINTENANCE COMPLETED                   " -ForegroundColor Green
Write-Host "==================================================" -ForegroundColor Cyan
Write-Host ""

Write-Host "IT Support Toolkit - Windows Maintenance"
Write-Host "Author: Gustavo"
Write-Host ""
'@

Set-Content -Path "C:\Users\GustavoEstudo\Downloads\manutencao.ps1" -Value $codigo -Encoding UTF8
