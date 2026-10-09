 <#
.SYNOPSIS
    This PowerShell script remediates and verifies STIG WN11-AU-000081.  Enforces 'Audit File Share' advanced tracking policy to log 'Failure' events
    using auditpol.exe and validates the active operating system configuration.
.NOTES
    Author          : Alton Stewart
    LinkedIn        : N/A
    GitHub          : github.com/l10coding
    Date Created    : 2026-10-09
    Last Modified   : 2026-10-09
    Version         : 1.0
    CVEs            : N/A
    Plugin IDs      : N/A
    STIG-ID         : WN11-AU-000081

.TESTED ON
    Date(s) Tested  : 
    Tested By       : 
    Systems Tested  : 
    PowerShell Ver. : 

.USAGE
    Put any usage instructions here.
    Example syntax:
    PS C:\> .\STIG-ID-WN11-AU-000081.ps1 
#>

Write-Host "--- Remediating STIG WN11-AU-000081 ---" -ForegroundColor Cyan

# 1. Apply compliance configuration using auditpol subcategory name
Write-Host "Setting 'File Share' auditing subcategory to 'Failure'..." -ForegroundColor Gray
auditpol.exe /set /subcategory:"File Share" /failure:enable | Out-Null

Write-Host "`n--- Running Post-Check Verification ---" -ForegroundColor Cyan

# 2. Safely extract the full Object Access policy to avoid subcategory query bugs
# This approach works across all language versions of Windows 11
$auditCheck = auditpol.exe /get /category:"Object Access" /r

# 3. Look for the File Share entry line and verify compliance state
# The CSV/report output (/r) gives us clean comma-separated values to evaluate
$fileShareLine = $auditCheck | Where-Object { $_ -match "File Share" -or $_ -match "0cceeac2-166e-435b-86a1-384cdffd3524" }

if ($fileShareLine -match "Failure") {
    Write-Host "[PASS] STIG WN11-AU-000081 is COMPLIANT. 'File Share' tracks Failure events." -ForegroundColor Green
    Write-Host "Current State: $fileShareLine" -ForegroundColor Gray
} else {
    Write-Host "[FAIL] STIG WN11-AU-000081 is NON-COMPLIANT." -ForegroundColor Red
    if ($fileShareLine) {
        Write-Host "Current State: $fileShareLine" -ForegroundColor Yellow
    } else {
        Write-Host "Could not retrieve the File Share subcategory status." -ForegroundColor Yellow
    }
} 

