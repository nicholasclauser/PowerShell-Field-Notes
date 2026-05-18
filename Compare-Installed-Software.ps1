#Requires -Version 7
<#
.SYNOPSIS
    compares installed software across two or more devices via SCCM inventory.
    enter device names one at a time, blank to finish. shows what's different between them.
.NOTES
    run it: .\Compare-InstalledSoftware.ps1 -SccmServer 'SCCMSRV01' -SccmNamespace 'root\SMS\site_ABC'
    needs sccm wmi access to your site server.
#>

param(
    [Parameter(Mandatory)]
    [string]$SccmServer,
    [Parameter(Mandatory)]
    [string]$SccmNamespace
)

$sccmServer    = $SccmServer
$sccmNamespace = $SccmNamespace

# --- collect device names ---
Write-Host "`nenter device names one at a time (e.g. PC-1234). blank line when done." -ForegroundColor Cyan
$deviceNames = @()
while ($true) {
    $input = (Read-Host "device").Trim()
    if (-not $input) { break }
    $deviceNames += $input
}

if ($deviceNames.Count -lt 2) {
    Write-Host "`nneed at least 2 devices to compare. exiting." -ForegroundColor Red
    exit
}

# --- pull software for each device ---
$deviceSoftware = @{}

foreach ($name in $deviceNames) {
    Write-Host "`n=== looking up $name ===" -ForegroundColor Cyan

    $sys = Get-WmiObject -Namespace $sccmNamespace -ComputerName $sccmServer `
        -Class SMS_R_System -Filter "Name = '$name'" -ErrorAction SilentlyContinue

    if (-not $sys) {
        Write-Host "  $name not found in SCCM" -ForegroundColor Red
        $deviceSoftware[$name] = $null
        continue
    }

    $rid = $sys.ResourceID
    Write-Host "  resourceid: $rid" -ForegroundColor DarkGray

    $software = Get-WmiObject -Namespace $sccmNamespace -ComputerName $sccmServer `
        -Class SMS_G_System_INSTALLED_SOFTWARE -Filter "ResourceID = $rid" -ErrorAction SilentlyContinue |
        Select-Object -ExpandProperty ProductName |
        Where-Object { $_ } |
        Sort-Object

    Write-Host "  $($software.Count) programs found" -ForegroundColor DarkGray
    $deviceSoftware[$name] = $software
}

# --- filter to devices that returned data ---
$valid = $deviceSoftware.GetEnumerator() | Where-Object { $_.Value -ne $null }
if (($valid | Measure-Object).Count -lt 2) {
    Write-Host "`nnot enough devices with data to compare. exiting." -ForegroundColor Red
    exit
}

# --- build union of all programs ---
$allPrograms = $deviceSoftware.Values | Where-Object { $_ } | ForEach-Object { $_ } | Sort-Object -Unique

# --- compare ---
Write-Host "`n=== comparison ===" -ForegroundColor Cyan
Write-Host "only showing programs that differ between devices.`n" -ForegroundColor DarkGray

$rows = foreach ($prog in $allPrograms) {
    $row = [ordered]@{ Program = $prog }
    $differs = $false
    foreach ($name in $deviceNames) {
        $has = $deviceSoftware[$name] -contains $prog
        $row[$name] = if ($has) { 'yes' } else { '---' }
        if (-not $has) { $differs = $true }
    }
    if ($differs) { [PSCustomObject]$row }
}

if (-not $rows) {
    Write-Host "no differences found - all devices have the same software." -ForegroundColor Green
} else {
    $rows | Format-Table -AutoSize | Out-String -Width 500 | Write-Host
    Write-Host "$($rows.Count) program(s) differ across devices." -ForegroundColor Yellow
}

Write-Host "`n=== done ===" -ForegroundColor Green
Read-Host "`npress enter to exit"
