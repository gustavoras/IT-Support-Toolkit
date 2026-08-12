```powershell
# ============================================================
# IT Support Toolkit
# Network Diagnostic Tool
# Author: Gustavo
# ============================================================

Clear-Host

Write-Host ""
Write-Host "==================================================" -ForegroundColor Cyan
Write-Host "          IT SUPPORT TOOLKIT - NETWORK            " -ForegroundColor Cyan
Write-Host "==================================================" -ForegroundColor Cyan
Write-Host ""

# ------------------------------------------------------------
# COMPUTER INFORMATION
# ------------------------------------------------------------

$ComputerName = $env:COMPUTERNAME
$UserName = $env:USERNAME

Write-Host "[+] Computer : $ComputerName" -ForegroundColor White
Write-Host "[+] User     : $UserName" -ForegroundColor White
Write-Host ""

# ------------------------------------------------------------
# NETWORK CONFIGURATION
# ------------------------------------------------------------

Write-Host "--------------------------------------------------"
Write-Host "NETWORK CONFIGURATION" -ForegroundColor Yellow
Write-Host "--------------------------------------------------"
Write-Host ""

try {

    $NetworkAdapters = Get-NetIPConfiguration -ErrorAction Stop

    $ValidAdapters = $NetworkAdapters | Where-Object {
        $_.IPv4Address -ne $null
    }

    if ($ValidAdapters.Count -eq 0) {

        Write-Host "[!] No active network adapter found." -ForegroundColor Red

    }
    else {

        foreach ($Adapter in $ValidAdapters) {

            $IPv4 = $Adapter.IPv4Address |
                Where-Object {
                    $_.IPAddress -notlike "169.254.*"
                } |
                Select-Object -First 1

            $Gateway = $Adapter.IPv4DefaultGateway |
                Select-Object -First 1

            $DNS = $Adapter.DnsServer.ServerAddresses -join ", "

            Write-Host "Interface : $($Adapter.InterfaceAlias)"
            Write-Host "IPv4      : $($IPv4.IPAddress)"
            Write-Host "Gateway   : $($Gateway.NextHop)"
            Write-Host "DNS       : $DNS"
            Write-Host ""
        }
    }
}
catch {

    Write-Host "[ERROR] Unable to obtain network information." -ForegroundColor Red
    Write-Host $_.Exception.Message -ForegroundColor Red
}

# ------------------------------------------------------------
# IP CONFIGURATION
# ------------------------------------------------------------

Write-Host "--------------------------------------------------"
Write-Host "IP CONFIGURATION" -ForegroundColor Yellow
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
# GATEWAY TEST
# ------------------------------------------------------------

Write-Host "--------------------------------------------------"
Write-Host "GATEWAY TEST" -ForegroundColor Yellow
Write-Host "--------------------------------------------------"
Write-Host ""

try {

    $GatewayObject = Get-NetIPConfiguration |
        Where-Object {
            $_.IPv4DefaultGateway -ne $null
        } |
        Select-Object -First 1

    if ($GatewayObject) {

        $GatewayIP = $GatewayObject.IPv4DefaultGateway.NextHop

        Write-Host "[+] Testing gateway: $GatewayIP"

        $GatewayTest = Test-Connection `
            -ComputerName $GatewayIP `
            -Count 2 `
            -Quiet `
            -ErrorAction SilentlyContinue

        if ($GatewayTest) {

            Write-Host "[OK] Gateway reachable." -ForegroundColor Green

        }
        else {

            Write-Host "[ERROR] Gateway unreachable." -ForegroundColor Red
        }

    }
    else {

        Write-Host "[!] Default gateway not found." -ForegroundColor Red
    }

}
catch {

    Write-Host "[ERROR] Gateway test failed." -ForegroundColor Red
}

Write-Host ""

# ------------------------------------------------------------
# INTERNET CONNECTIVITY
# ------------------------------------------------------------

Write-Host "--------------------------------------------------"
Write-Host "INTERNET CONNECTIVITY TEST" -ForegroundColor Yellow
Write-Host "--------------------------------------------------"
Write-Host ""

Write-Host "[+] Testing 8.8.8.8..."

$InternetTest = Test-Connection `
    -ComputerName "8.8.8.8" `
    -Count 2 `
    -Quiet `
    -ErrorAction SilentlyContinue

if ($InternetTest) {

    Write-Host "[ONLINE] Internet connectivity OK." -ForegroundColor Green

}
else {

    Write-Host "[OFFLINE] Internet connectivity failed." -ForegroundColor Red
}

Write-Host ""

# ------------------------------------------------------------
# DNS TEST
# ------------------------------------------------------------

Write-Host "--------------------------------------------------"
Write-Host "DNS RESOLUTION TEST" -ForegroundColor Yellow
Write-Host "--------------------------------------------------"
Write-Host ""

Write-Host "[+] Resolving google.com..."

try {

    $DNSResult = Resolve-DnsName `
        -Name "google.com" `
        -ErrorAction Stop

    if ($DNSResult) {

        Write-Host "[OK] DNS resolution working." -ForegroundColor Green

        $DNSResult |
            Where-Object {
                $_.Type -eq "A"
            } |
            Select-Object Name, IPAddress |
            Format-Table -AutoSize
    }

}
catch {

    Write-Host "[ERROR] DNS resolution failed." -ForegroundColor Red
}

Write-Host ""

# ------------------------------------------------------------
# GOOGLE CONNECTIVITY TEST
# ------------------------------------------------------------

Write-Host "--------------------------------------------------"
Write-Host "EXTERNAL HOST TEST" -ForegroundColor Yellow
Write-Host "--------------------------------------------------"
Write-Host ""

Write-Host "[+] Testing google.com..."

$GoogleTest = Test-Connection `
    -ComputerName "google.com" `
    -Count 2 `
    -Quiet `
    -ErrorAction SilentlyContinue

if ($GoogleTest) {

    Write-Host "[OK] google.com reachable." -ForegroundColor Green

}
else {

    Write-Host "[ERROR] google.com unreachable." -ForegroundColor Red
}

Write-Host ""

# ------------------------------------------------------------
# TRACEROUTE
# ------------------------------------------------------------

Write-Host "--------------------------------------------------"
Write-Host "NETWORK ROUTE" -ForegroundColor Yellow
Write-Host "--------------------------------------------------"
Write-Host ""

Write-Host "[+] Checking route to google.com..."
Write-Host ""

try {

    Test-NetConnection `
        -ComputerName "google.com" `
        -TraceRoute `
        -InformationLevel Detailed

}
catch {

    Write-Host "[!] Traceroute could not be completed." -ForegroundColor Yellow
}

Write-Host ""

# ------------------------------------------------------------
# NETWORK ADAPTER STATUS
# ------------------------------------------------------------

Write-Host "--------------------------------------------------"
Write-Host "NETWORK ADAPTER STATUS" -ForegroundColor Yellow
Write-Host "--------------------------------------------------"
Write-Host ""

try {

    Get-NetAdapter |
        Select-Object Name, InterfaceDescription, Status, LinkSpeed |
        Format-Table -AutoSize

}
catch {

    Write-Host "[ERROR] Unable to retrieve adapter information." -ForegroundColor Red
}

Write-Host ""

# ------------------------------------------------------------
# SUMMARY
# ------------------------------------------------------------

Write-Host "=================================================="
Write-Host "              DIAGNOSTIC COMPLETED                " -ForegroundColor Cyan
Write-Host "==================================================" -ForegroundColor Cyan
Write-Host ""

Write-Host "Diagnostic performed by IT Support Toolkit." -ForegroundColor Gray
Write-Host "Author: Gustavo" -ForegroundColor Gray

Write-Host ""
```
