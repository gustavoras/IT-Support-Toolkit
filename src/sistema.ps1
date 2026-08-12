$codigo = @'
# IT Support Toolkit
# Windows System Diagnostic
# Author: Gustavo

Clear-Host

Write-Host ""
Write-Host "==================================================" -ForegroundColor Cyan
Write-Host "          IT SUPPORT TOOLKIT - SYSTEM            " -ForegroundColor Cyan
Write-Host "==================================================" -ForegroundColor Cyan
Write-Host ""

Write-Host "SYSTEM INFORMATION" -ForegroundColor Yellow
Write-Host "------------------"

$OS = Get-CimInstance Win32_OperatingSystem
$Computer = Get-CimInstance Win32_ComputerSystem

Write-Host "Computer     : $($Computer.Name)"
Write-Host "User         : $($Computer.UserName)"
Write-Host "Operating OS : $($OS.Caption)"
Write-Host "Version      : $($OS.Version)"
Write-Host "Build        : $($OS.BuildNumber)"
Write-Host "Architecture : $($OS.OSArchitecture)"
Write-Host ""

Write-Host "PROCESSOR INFORMATION" -ForegroundColor Yellow
Write-Host "----------------------"

$CPU = Get-CimInstance Win32_Processor

foreach ($Processor in $CPU) {
    Write-Host "CPU          : $($Processor.Name)"
    Write-Host "Cores        : $($Processor.NumberOfCores)"
    Write-Host "Logical CPUs : $($Processor.NumberOfLogicalProcessors)"
    Write-Host "Max Clock    : $($Processor.MaxClockSpeed) MHz"
}

Write-Host ""

Write-Host "MEMORY STATUS" -ForegroundColor Yellow
Write-Host "-------------"

$TotalRAMGB = [math]::Round($Computer.TotalPhysicalMemory / 1GB, 2)
$FreeRAMGB = [math]::Round(($OS.FreePhysicalMemory * 1KB) / 1GB, 2)
$UsedRAMGB = [math]::Round($TotalRAMGB - $FreeRAMGB, 2)

if ($TotalRAMGB -gt 0) {
    $RAMPercent = [math]::Round(($UsedRAMGB / $TotalRAMGB) * 100, 2)
}
else {
    $RAMPercent = 0
}

Write-Host "Total RAM : $TotalRAMGB GB"
Write-Host "Used RAM  : $UsedRAMGB GB"
Write-Host "Free RAM  : $FreeRAMGB GB"
Write-Host "Usage     : $RAMPercent %"

if ($RAMPercent -lt 70) {
    Write-Host "[OK] Memory usage normal." -ForegroundColor Green
}
elseif ($RAMPercent -lt 90) {
    Write-Host "[WARNING] Memory usage elevated." -ForegroundColor Yellow
}
else {
    Write-Host "[CRITICAL] Memory usage high." -ForegroundColor Red
}

Write-Host ""

Write-Host "DISK STATUS" -ForegroundColor Yellow
Write-Host "-----------"

$Disks = Get-CimInstance Win32_LogicalDisk | Where-Object {$_.DriveType -eq 3}

foreach ($Disk in $Disks) {

    if ($Disk.Size -gt 0) {

        $SizeGB = [math]::Round($Disk.Size / 1GB, 2)
        $FreeGB = [math]::Round($Disk.FreeSpace / 1GB, 2)
        $UsedGB = [math]::Round($SizeGB - $FreeGB, 2)
        $UsedPercent = [math]::Round(($UsedGB / $SizeGB) * 100, 2)

        Write-Host "Drive : $($Disk.DeviceID)"
        Write-Host "Total : $SizeGB GB"
        Write-Host "Used  : $UsedGB GB"
        Write-Host "Free  : $FreeGB GB"
        Write-Host "Usage : $UsedPercent %"

        if ($FreeGB -lt 10) {
            Write-Host "[CRITICAL] Very low disk space." -ForegroundColor Red
        }
        elseif ($UsedPercent -ge 80) {
            Write-Host "[WARNING] Disk usage is high." -ForegroundColor Yellow
        }
        else {
            Write-Host "[OK] Disk space normal." -ForegroundColor Green
        }

        Write-Host ""
    }
}

Write-Host "TOP PROCESSES" -ForegroundColor Yellow
Write-Host "-------------"

$Processes = Get-Process |
    Sort-Object WorkingSet64 -Descending |
    Select-Object -First 10

foreach ($Process in $Processes) {

    $MemoryMB = [math]::Round($Process.WorkingSet64 / 1MB, 2)

    Write-Host "$($Process.ProcessName) - PID $($Process.Id) - $MemoryMB MB"
}

Write-Host ""

Write-Host "IMPORTANT WINDOWS SERVICES" -ForegroundColor Yellow
Write-Host "---------------------------"

$Services = @(
    "wuauserv",
    "BITS",
    "Dnscache",
    "Dhcp",
    "Spooler"
)

foreach ($ServiceName in $Services) {

    $Service = Get-Service -Name $ServiceName -ErrorAction SilentlyContinue

    if ($null -eq $Service) {
        Write-Host "[NOT FOUND] $ServiceName"
    }
    elseif ($Service.Status -eq "Running") {
        Write-Host "[RUNNING] $($Service.DisplayName)" -ForegroundColor Green
    }
    else {
        Write-Host "[STOPPED] $($Service.DisplayName)" -ForegroundColor Yellow
    }
}

Write-Host ""

Write-Host "SYSTEM UPTIME" -ForegroundColor Yellow
Write-Host "-------------"

$LastBoot = $OS.LastBootUpTime

if ($LastBoot -is [datetime]) {

    $Uptime = (Get-Date) - $LastBoot

    Write-Host "Last Boot : $LastBoot"
    Write-Host "Uptime    : $($Uptime.Days) days, $($Uptime.Hours) hours, $($Uptime.Minutes) minutes"
}
else {
    Write-Host "[WARNING] Unable to determine system uptime." -ForegroundColor Yellow
}

Write-Host ""

Write-Host "NETWORK ADAPTERS" -ForegroundColor Yellow
Write-Host "----------------"

try {
    Get-NetAdapter |
        Select-Object Name, Status, MacAddress, LinkSpeed |
        Format-Table -AutoSize
}
catch {
    Write-Host "[WARNING] Network adapter information unavailable." -ForegroundColor Yellow
}

Write-Host ""

Write-Host "==================================================" -ForegroundColor Cyan
Write-Host "          SYSTEM CHECK COMPLETED                  " -ForegroundColor Green
Write-Host "==================================================" -ForegroundColor Cyan
Write-Host ""

Write-Host "IT Support Toolkit - Windows System Diagnostic"
Write-Host "Author: Gustavo"
Write-Host ""
'@

Set-Content -Path "C:\Users\GustavoEstudo\Downloads\sistema.ps1" -Value $codigo -Encoding UTF8
