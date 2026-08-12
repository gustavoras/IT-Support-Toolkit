```powershell
# ============================================================
# IT Support Toolkit
# Windows System Diagnostic
# Author: Gustavo
# ============================================================

Clear-Host

Write-Host ""
Write-Host "==================================================" -ForegroundColor Cyan
Write-Host "           IT SUPPORT TOOLKIT - SYSTEM            " -ForegroundColor Cyan
Write-Host "==================================================" -ForegroundColor Cyan
Write-Host ""

# ------------------------------------------------------------
# BASIC INFORMATION
# ------------------------------------------------------------

Write-Host "--------------------------------------------------"
Write-Host "SYSTEM INFORMATION" -ForegroundColor Yellow
Write-Host "--------------------------------------------------"
Write-Host ""

$OS = Get-CimInstance Win32_OperatingSystem
$Computer = Get-CimInstance Win32_ComputerSystem

Write-Host "Computer     : $($Computer.Name)"
Write-Host "User         : $($Computer.UserName)"
Write-Host "Operating OS : $($OS.Caption)"
Write-Host "Version      : $($OS.Version)"
Write-Host "Build        : $($OS.BuildNumber)"
Write-Host "Architecture : $($OS.OSArchitecture)"

Write-Host ""

# ------------------------------------------------------------
# CPU USAGE
# ------------------------------------------------------------

Write-Host "--------------------------------------------------"
Write-Host "CPU USAGE" -ForegroundColor Yellow
Write-Host "--------------------------------------------------"
Write-Host ""

try {

    $CPU = Get-Counter '\Processor(_Total)\% Processor Time'

    $CPUUsage = [math]::Round(
        $CPU.CounterSamples[0].CookedValue,
        2
    )

    Write-Host "CPU Usage    : $CPUUsage %"

    if ($CPUUsage -lt 50) {

        Write-Host "[OK] CPU usage normal." -ForegroundColor Green

    }
    elseif ($CPUUsage -lt 80) {

        Write-Host "[WARNING] CPU usage elevated." -ForegroundColor Yellow

    }
    else {

        Write-Host "[CRITICAL] CPU usage high." -ForegroundColor Red
    }

}
catch {

    Write-Host "[ERROR] Unable to read CPU usage." -ForegroundColor Red
}

Write-Host ""

# ------------------------------------------------------------
# MEMORY USAGE
# ------------------------------------------------------------

Write-Host "--------------------------------------------------"
Write-Host "MEMORY USAGE" -ForegroundColor Yellow
Write-Host "--------------------------------------------------"
Write-Host ""

try {

    $TotalRAM = [math]::Round(
        $Computer.TotalPhysicalMemory / 1GB,
        2
    )

    $FreeRAM = [math]::Round(
        $OS.FreePhysicalMemory / 1MB,
        2
    )

    $UsedRAM = [math]::Round(
        $TotalRAM - $FreeRAM,
        2
    )

    $RAMPercent = [math]::Round(
        ($UsedRAM / $TotalRAM) * 100,
        2
    )

    Write-Host "Total RAM    : $TotalRAM GB"
    Write-Host "Used RAM     : $UsedRAM GB"
    Write-Host "Free RAM     : $FreeRAM GB"
    Write-Host "Usage        : $RAMPercent %"

    if ($RAMPercent -lt 70) {

        Write-Host "[OK] Memory usage normal." -ForegroundColor Green

    }
    elseif ($RAMPercent -lt 90) {

        Write-Host "[WARNING] Memory usage elevated." -ForegroundColor Yellow

    }
    else {

        Write-Host "[CRITICAL] Memory usage high." -ForegroundColor Red
    }

}
catch {

    Write-Host "[ERROR] Unable to read memory usage." -ForegroundColor Red
}

Write-Host ""

# ------------------------------------------------------------
# DISK SPACE
# ------------------------------------------------------------

Write-Host "--------------------------------------------------"
Write-Host "DISK SPACE" -ForegroundColor Yellow
Write-Host "--------------------------------------------------"
Write-Host ""

try {

    $Disks = Get-CimInstance Win32_LogicalDisk |
        Where-Object {
            $_.DriveType -eq 3
        }

    foreach ($Disk in $Disks) {

        $SizeGB = [math]::Round(
            $Disk.Size / 1GB,
            2
        )

        $FreeGB = [math]::Round(
            $Disk.FreeSpace / 1GB,
            2
        )

        $UsedPercent = [math]::Round(
            (($SizeGB - $FreeGB) / $SizeGB) * 100,
            2
        )

        Write-Host "$($Disk.DeviceID)"
        Write-Host "  Total : $SizeGB GB"
        Write-Host "  Free  : $FreeGB GB"
        Write-Host "  Used  : $UsedPercent %"
        Write-Host ""

        if ($FreeGB -lt 10) {

            Write-Host "[CRITICAL] Low disk space." -ForegroundColor Red

        }
        elseif ($UsedPercent -gt 80) {

            Write-Host "[WARNING] Disk usage high." -ForegroundColor Yellow

        }
        else {

            Write-Host "[OK] Disk space normal." -ForegroundColor Green
        }

        Write-Host ""
    }

}
catch {

    Write-Host "[ERROR] Unable to check disk space." -ForegroundColor Red
}

# ------------------------------------------------------------
# TOP PROCESSES
# ------------------------------------------------------------

Write-Host "--------------------------------------------------"
Write-Host "TOP PROCESSES BY CPU" -ForegroundColor Yellow
Write-Host "--------------------------------------------------"
Write-Host ""

try {

    Get-Process |
        Sort-Object CPU -Descending |
        Select-Object -First 10 `
            ProcessName,
            Id,
            CPU |
        Format-Table -AutoSize

}
catch {

    Write-Host "[ERROR] Unable to retrieve processes." -ForegroundColor Red
}

# ------------------------------------------------------------
# IMPORTANT SERVICES
# ------------------------------------------------------------

Write-Host "--------------------------------------------------"
Write-Host "IMPORTANT WINDOWS SERVICES" -ForegroundColor Yellow
Write-Host "--------------------------------------------------"
Write-Host ""

$Services = @(
    "wuauserv",
    "BITS",
    "Dnscache",
    "Dhcp",
    "Spooler"
)

foreach ($ServiceName in $Services) {

    try {

        $Service = Get-Service `
            -Name $ServiceName `
            -ErrorAction Stop

        if ($Service.Status -eq "Running") {

            Write-Host "[RUNNING] $($Service.DisplayName)" `
                -ForegroundColor Green

        }
        else {

            Write-Host "[STOPPED] $($Service.DisplayName)" `
                -ForegroundColor Yellow
        }

    }
    catch {

        Write-Host "[NOT FOUND] $ServiceName" `
            -ForegroundColor Gray
    }
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

    $LastBoot = $OS.LastBootUpTime

    if ($LastBoot -is [datetime]) {

        $Uptime = (Get-Date) - $LastBoot

        Write-Host "Last Boot : $LastBoot"
        Write-Host "Uptime    : $($Uptime.Days) days, $($Uptime.Hours) hours, $($Uptime.Minutes) minutes"

    }

}
catch {

    Write-Host "[ERROR] Unable to calculate uptime." -ForegroundColor Red
}

Write-Host ""

# ------------------------------------------------------------
# FINAL STATUS
# ------------------------------------------------------------

Write-Host "==================================================" -ForegroundColor Cyan
Write-Host "             SYSTEM CHECK COMPLETED               " -ForegroundColor Green
Write-Host "==================================================" -ForegroundColor Cyan
Write-Host ""

Write-Host "IT Support Toolkit"
Write-Host "Author: Gustavo" -ForegroundColor Gray
Write-Host ""
```
