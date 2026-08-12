```powershell
# ============================================================
# IT Support Toolkit
# System Inventory
# Author: Gustavo
# ============================================================

Clear-Host

Write-Host ""
Write-Host "==================================================" -ForegroundColor Cyan
Write-Host "            IT SUPPORT TOOLKIT - INVENTORY         " -ForegroundColor Cyan
Write-Host "==================================================" -ForegroundColor Cyan
Write-Host ""

# ------------------------------------------------------------
# BASIC INFORMATION
# ------------------------------------------------------------

Write-Host "--------------------------------------------------"
Write-Host "COMPUTER INFORMATION" -ForegroundColor Yellow
Write-Host "--------------------------------------------------"
Write-Host ""

$ComputerSystem = Get-CimInstance Win32_ComputerSystem
$OperatingSystem = Get-CimInstance Win32_OperatingSystem

Write-Host "Computer Name : $($ComputerSystem.Name)"
Write-Host "Manufacturer  : $($ComputerSystem.Manufacturer)"
Write-Host "Model         : $($ComputerSystem.Model)"
Write-Host "User          : $($ComputerSystem.UserName)"
Write-Host ""

# ------------------------------------------------------------
# OPERATING SYSTEM
# ------------------------------------------------------------

Write-Host "--------------------------------------------------"
Write-Host "OPERATING SYSTEM" -ForegroundColor Yellow
Write-Host "--------------------------------------------------"
Write-Host ""

Write-Host "OS            : $($OperatingSystem.Caption)"
Write-Host "Version       : $($OperatingSystem.Version)"
Write-Host "Build         : $($OperatingSystem.BuildNumber)"
Write-Host "Architecture  : $($OperatingSystem.OSArchitecture)"
Write-Host ""

# ------------------------------------------------------------
# CPU
# ------------------------------------------------------------

Write-Host "--------------------------------------------------"
Write-Host "PROCESSOR" -ForegroundColor Yellow
Write-Host "--------------------------------------------------"
Write-Host ""

$CPU = Get-CimInstance Win32_Processor

Write-Host "CPU           : $($CPU.Name)"
Write-Host "Cores         : $($CPU.NumberOfCores)"
Write-Host "Logical CPUs  : $($CPU.NumberOfLogicalProcessors)"
Write-Host "Max Clock     : $($CPU.MaxClockSpeed) MHz"
Write-Host ""

# ------------------------------------------------------------
# MEMORY
# ------------------------------------------------------------

Write-Host "--------------------------------------------------"
Write-Host "MEMORY" -ForegroundColor Yellow
Write-Host "--------------------------------------------------"
Write-Host ""

$Memory = Get-CimInstance Win32_ComputerSystem

$TotalMemoryGB = [math]::Round(
    $Memory.TotalPhysicalMemory / 1GB,
    2
)

Write-Host "Total RAM     : $TotalMemoryGB GB"
Write-Host ""

# ------------------------------------------------------------
# DISKS
# ------------------------------------------------------------

Write-Host "--------------------------------------------------"
Write-Host "DISK INFORMATION" -ForegroundColor Yellow
Write-Host "--------------------------------------------------"
Write-Host ""

Get-CimInstance Win32_LogicalDisk |
    Where-Object {
        $_.DriveType -eq 3
    } |
    Select-Object `
        DeviceID,
        @{Name="SizeGB";Expression={
            [math]::Round($_.Size / 1GB, 2)
        }},
        @{Name="FreeGB";Expression={
            [math]::Round($_.FreeSpace / 1GB, 2)
        }} |
    Format-Table -AutoSize

# ------------------------------------------------------------
# NETWORK
# ------------------------------------------------------------

Write-Host "--------------------------------------------------"
Write-Host "NETWORK ADAPTERS" -ForegroundColor Yellow
Write-Host "--------------------------------------------------"
Write-Host ""

Get-NetAdapter |
    Select-Object `
        Name,
        InterfaceDescription,
        Status,
        MacAddress,
        LinkSpeed |
    Format-Table -AutoSize

# ------------------------------------------------------------
# IP INFORMATION
# ------------------------------------------------------------

Write-Host "--------------------------------------------------"
Write-Host "IP INFORMATION" -ForegroundColor Yellow
Write-Host "--------------------------------------------------"
Write-Host ""

Get-NetIPAddress -AddressFamily IPv4 |
    Where-Object {
        $_.IPAddress -notlike "127.*" -and
        $_.IPAddress -notlike "169.254.*"
    } |
    Select-Object InterfaceAlias, IPAddress, PrefixLength |
    Format-Table -AutoSize

# ------------------------------------------------------------
# WINDOWS SERIAL
# ------------------------------------------------------------

Write-Host "--------------------------------------------------"
Write-Host "SYSTEM IDENTIFICATION" -ForegroundColor Yellow
Write-Host "--------------------------------------------------"
Write-Host ""

$BIOS = Get-CimInstance Win32_BIOS

Write-Host "Serial Number : $($BIOS.SerialNumber)"
Write-Host ""

# ------------------------------------------------------------
# UPTIME
# ------------------------------------------------------------

Write-Host "--------------------------------------------------"
Write-Host "SYSTEM UPTIME" -ForegroundColor Yellow
Write-Host "--------------------------------------------------"
Write-Host ""

$LastBoot = $OperatingSystem.LastBootUpTime
$LastBootDate = [Management.ManagementDateTimeConverter]::ToDateTime(
    $LastBoot
)

$Uptime = (Get-Date) - $LastBootDate

Write-Host "Last Boot     : $LastBootDate"
Write-Host "Uptime        : $($Uptime.Days) days, $($Uptime.Hours) hours, $($Uptime.Minutes) minutes"

Write-Host ""

# ------------------------------------------------------------
# END
# ------------------------------------------------------------

Write-Host "=================================================="
Write-Host "             INVENTORY COMPLETED                  " -ForegroundColor Green
Write-Host "==================================================" -ForegroundColor Cyan
Write-Host ""

Write-Host "IT Support Toolkit - System Inventory"
Write-Host "Author: Gustavo" -ForegroundColor Gray

Write-Host ""
```
