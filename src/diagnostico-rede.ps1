# ============================================================
# IT Support Toolkit
# Script: diagnostico-rede.ps1
# Description: Network diagnostic tool for Windows
# Author: Gustavo
# ============================================================

Clear-Host

Write-Host "==============================================" -ForegroundColor Cyan
Write-Host "       IT SUPPORT TOOLKIT - NETWORK" -ForegroundColor Cyan
Write-Host "==============================================" -ForegroundColor Cyan
Write-Host ""

# Computer information
$ComputerName = $env:COMPUTERNAME
$UserName = $env:USERNAME

Write-Host "[+] Computer : $ComputerName"
Write-Host "[+] User     : $UserName"
Write-Host ""

# IP configuration
Write-Host "----------------------------------------------"
Write-Host "NETWORK CONFIGURATION"
Write-Host "----------------------------------------------"

$Network = Get-NetIPConfiguration |
    Where-Object {
        $_.IPv4DefaultGateway -ne $null
    }

foreach ($Adapter in $Network) {

    Write-Host "Interface : $($Adapter.InterfaceAlias)"
    Write-Host "IPv4      : $($Adapter.IPv4Address.IPAddress)"
    Write-Host "Gateway   : $($Adapter.IPv4DefaultGateway.NextHop)"
    Write-Host "DNS       : $($Adapter.DnsServer.ServerAddresses -join ', ')"
    Write-Host ""
}

# Internet connectivity
Write-Host "----------------------------------------------"
Write-Host "CONNECTIVITY TEST"
Write-Host "----------------------------------------------"

$InternetTest = Test-Connection -ComputerName "8.8.8.8" -Count 2 -Quiet

if ($InternetTest) {

    Write-Host "[ONLINE] Internet connectivity OK" -ForegroundColor Green

} else {

    Write-Host "[OFFLINE] Internet connectivity failed" -ForegroundColor Red
}

# DNS test
Write-Host ""
Write-Host "----------------------------------------------"
Write-Host "DNS TEST"
Write-Host "----------------------------------------------"

try {

    $DNS = Resolve-DnsName "google.com" -ErrorAction Stop

    Write-Host "[OK] DNS resolution working" -ForegroundColor Green

}
catch {

    Write-Host "[ERROR] DNS resolution failed" -ForegroundColor Red
}

# Gateway test
Write-Host ""
Write-Host "----------------------------------------------"
Write-Host "GATEWAY TEST"
Write-Host "----------------------------------------------"

if ($Network) {

    $Gateway = $Network[0].IPv4DefaultGateway.NextHop

    if (Test-Connection -ComputerName $Gateway -Count 2 -Quiet) {

        Write-Host "[OK] Gateway reachable: $Gateway" -ForegroundColor Green

    }
    else {

        Write-Host "[ERROR] Gateway unreachable: $Gateway" -ForegroundColor Red
    }
}

Write-Host ""
Write-Host "=============================================="
Write-Host "         DIAGNOSTIC COMPLETED"
Write-Host "=============================================="

