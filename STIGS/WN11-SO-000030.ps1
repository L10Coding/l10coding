 <#
.SYNOPSIS
    This PowerShell script remediates and verifies STIG WN11-SO-000030.  Forces granular audit policy subcategory settings to override legacy category settings
    by modifying the SCENoApplyLegacyAuditPolicy DWORD value.

.NOTES
    Author          : Alton Stewart
    LinkedIn        : N/A
    GitHub          : github.com/l10coding
    Date Created    : 2026-10-08
    Last Modified   : 2026-10-08
    Version         : 1.0
    CVEs            : N/A
    Plugin IDs      : N/A
    STIG-ID         : WN11-SO-000030

.TESTED ON
    Date(s) Tested  : 
    Tested By       : 
    Systems Tested  : 
    PowerShell Ver. : 

.USAGE
    Put any usage instructions here.
    Example syntax:
    PS C:\> .\STIG-ID-WN11-SO-000030.ps1 
#>

$registryPath = "HKLM:\SYSTEM\CurrentControlSet\Control\Lsa"
$valueName    = "SCENoApplyLegacyAuditPolicy"
$targetData   = 1

Write-Host "--- Remediating STIG WN11-SO-000030 ---" -ForegroundColor Cyan

# 1. Ensure the Lsa registry path exists
if (-not (Test-Path -Path $registryPath)) {
    Write-Host "Creating missing Lsa path structure..." -ForegroundColor Gray
    New-Item -Path $registryPath -Force | Out-Null
}

# 2. Apply the compliance configuration (1 = Force subcategories)
New-ItemProperty -Path $registryPath -Name $valueName -Value $targetData -PropertyType DWORD -Force | Out-Null
Write-Host "Remediation applied successfully." -ForegroundColor Gray

Write-Host "`n--- Running Post-Check Verification ---" -ForegroundColor Cyan

# 3. Verify the setting
if (Test-Path -Path $registryPath) {
    $currentValue = Get-ItemPropertyValue -Path $registryPath -Name $valueName -ErrorAction SilentlyContinue
    
    if ($currentValue -eq $targetData) {
        Write-Host "[PASS] STIG WN11-SO-000030 is COMPLIANT. ($valueName is set to $currentValue)" -ForegroundColor Green
    } else {
        Write-Host "[FAIL] STIG WN11-SO-000030 is NON-COMPLIANT. ($valueName is set to '$currentValue' instead of $targetData)" -ForegroundColor Red
    }
} else {
    Write-Host "[FAIL] Registry path could not be verified." -ForegroundColor Red
} 
