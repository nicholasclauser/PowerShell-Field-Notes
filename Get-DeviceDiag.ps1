#Requires -Version 7
#Requires -Modules ActiveDirectory
<#
.SYNOPSIS
    pulls AD info + checks if a device is reachable on the network. needs RSAT or it'll fail.
.NOTES
    run it: .\get-devicediag.ps1
    or scripted: .\get-devicediag.ps1 -ComputerName PC-1234 -NonInteractive
#>

param(
    [string]$ComputerName,
    [switch]$NonInteractive
)

try {
    Import-Module ActiveDirectory -UseWindowsPowerShell -WarningAction SilentlyContinue -ErrorAction Stop
} catch {
    Import-Module ActiveDirectory -WarningAction SilentlyContinue
}

if (-not $ComputerName) {
    $ComputerName = Read-Host "Enter hostname (e.g. PC-1234)"
}
$computerName = $ComputerName.Trim()

Write-Host "`n=== ad object ===" -ForegroundColor Cyan

$comp = Get-ADComputer -Identity $computerName -Properties `
    Enabled, DistinguishedName, LastLogonDate, PasswordLastSet,
    OperatingSystem, OperatingSystemVersion, Description, ManagedBy,
    IPv4Address, DNSHostName -ErrorAction SilentlyContinue

if (-not $comp) {
    Write-Host "couldn't find $computerName in AD - check the hostname and try again" -ForegroundColor Red
    if (-not $NonInteractive) { Read-Host "`npress enter to exit" }
    exit
}

[PSCustomObject]@{
    Name           = $comp.Name
    Enabled        = $comp.Enabled
    OU             = ($comp.DistinguishedName -replace '^CN=[^,]+,', '')
    LastLogonDate  = $comp.LastLogonDate
    PasswordLastSet = $comp.PasswordLastSet
    OS             = $comp.OperatingSystem
    OSVersion      = $comp.OperatingSystemVersion
    DNSHostName    = $comp.DNSHostName
    IPv4Address    = $comp.IPv4Address
    Description    = $comp.Description
} | Format-List

Write-Host "`n=== ping ===" -ForegroundColor Cyan
$ping = Test-Connection -ComputerName $computerName -Count 3 -ErrorAction SilentlyContinue
if ($ping) {
    $ping | Select-Object Address, Latency, Status | Format-Table -AutoSize
} else {
    Write-Host "no icmp response from $computerName" -ForegroundColor Yellow
}

Write-Host "`n=== dns ===" -ForegroundColor Cyan
try {
    $dns = Resolve-DnsName -Name $computerName -ErrorAction Stop
    $dns | Select-Object Name, Type, IPAddress | Format-Table -AutoSize
} catch {
    Write-Host "dns lookup failed: $_" -ForegroundColor Yellow
}

Write-Host "`n=== ports (rpc / smb / winrm / rdp) ===" -ForegroundColor Cyan
$ports = @(
    @{ Port = 135; Label = 'RPC' },
    @{ Port = 445; Label = 'SMB' },
    @{ Port = 5985; Label = 'WinRM' },
    @{ Port = 3389; Label = 'RDP' }
)
$portResults = foreach ($p in $ports) {
    $tcp = $null
    try {
        $tcp = [System.Net.Sockets.TcpClient]::new()
        $async = $tcp.BeginConnect($computerName, $p.Port, $null, $null)
        $wait = $async.AsyncWaitHandle.WaitOne(500)
        $open = $wait -and $tcp.Connected
    } catch { $open = $false }
    finally { if ($tcp) { $tcp.Close() } }
    [PSCustomObject]@{
        Port = $p.Port
        Service = $p.Label
        Open = $open
    }
}
$portResults | Format-Table -AutoSize

Write-Host "`n=== dc reachability ===" -ForegroundColor Cyan
try {
    $dcList = (Get-ADDomainController -Filter *).HostName
    $dcResults = foreach ($dc in $dcList) {
        $dcPing = Test-Connection -ComputerName $dc -Count 1 -ErrorAction SilentlyContinue
        [PSCustomObject]@{
            DC = $dc
            Ping = if ($dcPing) { 'OK' } else { 'FAIL' }
            RTT_ms = if ($dcPing) { ($dcPing | Select-Object -First 1).Latency } else { 'N/A' }
        }
    }
    $dcResults | Format-Table -AutoSize
} catch {
    Write-Host "couldn't query DCs: $_" -ForegroundColor Yellow
}

Write-Host "`n=== done ===" -ForegroundColor Green
if (-not $NonInteractive) { Read-Host "`npress enter to exit" }
