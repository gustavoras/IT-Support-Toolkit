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
# COMPUTER INFORMATION
# ------------------------------------------------------------

Write-Host "--------------------------------------------------"
Write-Host "COMPUTER INFORMATION" -ForegroundColor Yellow
Write-Host "--------------------------------------------------"
Write-Host ""

try {

    $ComputerSystem = Get-CimInstance Win32_ComputerSystem

    Write-Host "Computer Name : $($ComputerSystem.Name)"
    Write-Host "Manufacturer  : $($ComputerSystem.Manufacturer)"
    Write-Host "Model         : $($ComputerSystem.Model)"
    Write-Host "User          : $($ComputerSystem.UserName)"

}
catch {

    Write-Host "[ERROR] Unable to retrieve computer information." -ForegroundColor Red
}

Write-Host ""

# ------------------------------------------------------------
# OPERATING SYSTEM
# ------------------------------------------------------------

Write-Host "--------------------------------------------------"
Write-Host "OPERATING SYSTEM" -ForegroundColor Yellow
Write-Host "--------------------------------------------------"
Write-Host ""

try {

    $OperatingSystem = Get-CimInstance Win32_OperatingSystem

    Write-Host "OS            : $($OperatingSystem.Caption)"
    Write-Host "Version       : $($OperatingSystem.Version)"
    Write-Host "Build         : $($OperatingSystem.BuildNumber)"
    Write-Host "Architecture  : $($OperatingSystem.OSArchitecture)"

}
catch {

    Write-Host "[ERROR] Unable to retrieve operating system information." -ForegroundColor Red
}

Write-Host ""

# ------------------------------------------------------------
# CPU
# ------------------------------------------------------------

Write-Host "--------------------------------------------------"
Write-Host "PROCESSOR" -ForegroundColor Yellow
Write-Host "--------------------------------------------------"
Write-Host ""

try {

    $CPU = Get-CimInstance Win32_Processor

    foreach ($Processor in $CPU) {

        Write-Host "CPU           : $($Processor.Name)"
        Write-Host "Cores         : $($Processor.NumberOfCores)"
        Write-Host "Logical CPUs  : $($Processor.NumberOfLogicalProcessors)"
        Write-Host "Max Clock     : $($Processor.MaxClockSpeed) MHz"
        Write-Host ""
    }

}
catch {

    Write-Host "[ERROR] Unable to retrieve CPU information." -ForegroundColor Red
}

# ------------------------------------------------------------
# MEMORY
# ------------------------------------------------------------

Write-Host "--------------------------------------------------"
Write-Host "MEMORY" -ForegroundColor Yellow
Write-Host "--------------------------------------------------"
Write-Host ""

try {

    $Memory = Get-CimInstance Win32_ComputerSystem

    $TotalMemoryGB = [math]::Round(
        $Memory.TotalPhysicalMemory / 1GB,
        2
    )

    Write-Host "Total RAM     : $TotalMemoryGB GB"

}
catch {

    Write-Host "[ERROR] Unable to retrieve memory information." -ForegroundColor Red
}

Write-Host ""

# ------------------------------------------------------------
# DISKS
# ------------------------------------------------------------

Write-Host "--------------------------------------------------"
Write-Host "DISK INFORMATION" -ForegroundColor Yellow
Write-Host "--------------------------------------------------"
Write-Host ""

try {

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

}
catch {

    Write-Host "[ERROR] Unable to retrieve disk information." -ForegroundColor Red
}

# ------------------------------------------------------------
# NETWORK ADAPTERS
# ------------------------------------------------------------

Write-Host "--------------------------------------------------"
Write-Host "NETWORK ADAPTERS" -ForegroundColor Yellow
Write-Host "--------------------------------------------------"
Write-Host ""

try {

    Get-NetAdapter |
        Select-Object `
            Name,
            InterfaceDescription,
            Status,
            MacAddress,
            LinkSpeed |
        Format-Table -AutoSize

}
catch {

    Write-Host "[ERROR] Unable to retrieve network adapter information." -ForegroundColor Red
}

# ------------------------------------------------------------
# IP INFORMATION
# ------------------------------------------------------------

Write-Host "--------------------------------------------------"
Write-Host "IP INFORMATION" -ForegroundColor Yellow
Write-Host "--------------------------------------------------"
Write-Host ""

try {

    Get-NetIPAddress -AddressFamily IPv4 |
        Where-Object {
            $_.IPAddress -notlike "127.*" -and
            $_.IPAddress -notlike "169.254.*"
        } |
        Select-Object InterfaceAlias, IPAddress, PrefixLength |
        Format-Table -AutoSize

}
catch {

    Write-Host "[ERROR] Unable to retrieve IP information." -ForegroundColor Red
}

# ------------------------------------------------------------
# SYSTEM IDENTIFICATION
# ------------------------------------------------------------

Write-Host "--------------------------------------------------"
Write-Host "SYSTEM IDENTIFICATION" -ForegroundColor Yellow
Write-Host "--------------------------------------------------"
Write-Host ""

try {

    $BIOS = Get-CimInstance Win32_BIOS

    Write-Host "Serial Number : $($BIOS.SerialNumber)"

}
catch {

    Write-Host "[ERROR] Unable to retrieve serial number." -ForegroundColor Red
}

Write-Host ""

# ------------------------------------------------------------
# SYSTEM UPTIME
# ------------------------------------------------------------

Write-Host "--------------------------------------------------"
Write-Host "SYSTEM UPTIME" -ForegroundColor Yellow
Write-Host "--------------------------------------------------"
Write-Host ""

try {

    # Get-CimInstance already returns LastBootUpTime
    # as a DateTime object on modern PowerShell versions.

    $OperatingSystem = Get-CimInstance Win32_OperatingSystem

    $LastBootDate = $OperatingSystem.LastBootUpTime

    if ($LastBootDate -is [datetime]) {

        $Uptime = (Get-Date) - $LastBootDate

        Write-Host "Last Boot     : $LastBootDate"
        Write-Host "Uptime        : $($Uptime.Days) days, $($Uptime.Hours) hours, $($Uptime.Minutes) minutes"

    }
    else {

        Write-Host "[!] Could not determine system uptime." -ForegroundColor Yellow

    }

}
catch {

    Write-Host "[ERROR] Unable to calculate system uptime." -ForegroundColor Red
}

Write-Host ""

# ------------------------------------------------------------
# COMPLETED
# ------------------------------------------------------------

Write-Host "==================================================" -ForegroundColor Cyan
Write-Host "             INVENTORY COMPLETED                  " -ForegroundColor Green
Write-Host "==================================================" -ForegroundColor Cyan
Write-Host ""

Write-Host "IT Support Toolkit - System Inventory"
Write-Host "Author: Gustavo" -ForegroundColor Gray

Write-Host ""
```
