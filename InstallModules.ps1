# Installs all modules in parallel

#Requires -RunAsAdministrator

# SCCM and RSAT must already be installed or this will fail

$modules = @(
    'ExchangeOnlineManagement',
    'PnP.PowerShell',
    'ImportExcel',
    'Az',
    'Microsoft.Graph'
)

Write-Host "Installing modules..."

$jobs = $modules | ForEach-Object {
    $mod = $_
    Start-Job -ScriptBlock {
        if (-not (Get-Module -ListAvailable -Name $using:mod)) {
            Install-Module $using:mod -Scope CurrentUser -Force -AllowClobber
        }
    }
}

$jobs | Wait-Job | Receive-Job
$jobs | Remove-Job

Write-Host "All modules installed."
