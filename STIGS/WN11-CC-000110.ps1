 <#
.SYNOPSIS
    This PowerShell script remediates and verifies STIG WN11-CC-000110.  Disables client-side Internet printing over HTTP to prevent system data leakages 
    and unauthorized external data transfers.
.NOTES
    Author          : Alton Stewart
    LinkedIn        : N/A
    GitHub          : github.com/l10coding
    Date Created    : 2026-10-09
    Last Modified   : 2026-10-09
    Version         : 1.0
    CVEs            : N/A
    Plugin IDs      : N/A
    STIG-ID         : WN11-CC-000110

.TESTED ON
    Date(s) Tested  : 
    Tested By       : 
    Systems Tested  : 
    PowerShell Ver. : 

.USAGE
    Put any usage instructions here.
    Example syntax:
    PS C:\> .\STIG-ID-WN11-CC-000110.ps1 
#>

$registryPath = "HKLM:\SOFTWARE\Policies\Microsoft\Windows NT\Printers"
$valueName    = "DisableHTTPPrinting"
$targetData   = 1

Write-Host "--- Remediating STIG WN11-CC-000110 ---" -ForegroundColor Cyan

# 1. Ensure the administrative templates policy path exists
if (-not (Test-Path -Path $registryPath)) {
    Write-Host "Creating missing Printers policy path structure..." -ForegroundColor Gray
    New-Item -Path $registryPath -Force | Out-Null
}

# 2. Apply the compliance configuration (1 = Disable HTTP Printing)
New-ItemProperty -Path $registryPath -Name $valueName -Value $targetData -PropertyType DWORD -Force | Out-Null
Write-Host "Remediation applied successfully." -ForegroundColor Gray

Write-Host "`n--- Running Post-Check Verification ---" -ForegroundColor Cyan

# 3. Verify the setting
if (Test-Path -Path $registryPath) {
    $currentValue = Get-ItemPropertyValue -Path $registryPath -Name $valueName -ErrorAction SilentlyContinue
    
    if ($currentValue -eq $targetData) {
        Write-Host "[PASS] STIG WN11-CC-000110 is COMPLIANT. ($valueName is set to $currentValue - Printing over HTTP is Disabled)" -ForegroundColor Green
    } else {
        Write-Host "[FAIL] STIG WN11-CC-000110 is NON-COMPLIANT. ($valueName is set to '$currentValue' instead of $targetData)" -ForegroundColor Red
    }
} else {
    Write-Host "[FAIL] Policy registry path could not be verified." -ForegroundColor Red
} 
