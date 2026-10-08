 <#
.SYNOPSIS
    This PowerShell script remediates and verifies STIG WN11-AU-000505.  Sets the maximum Security Event Log size to the required STIG baseline of 
    1,024,000 KB (1 GB) via Group Policy registry enforcement.

.NOTES
    Author          : Alton Stewart
    LinkedIn        : N/A
    GitHub          : github.com/l10coding
    Date Created    : 2026-10-08
    Last Modified   : 2026-10-08
    Version         : 1.0
    CVEs            : N/A
    Plugin IDs      : N/A
    STIG-ID         : WN11-AU-000505

.TESTED ON
    Date(s) Tested  : 
    Tested By       : 
    Systems Tested  : 
    PowerShell Ver. : 

.USAGE
    Put any usage instructions here.
    Example syntax:
    PS C:\> .\STIG-ID-WN11-AU-000505.ps1 
#>

$registryPath = "HKLM:\SOFTWARE\Policies\Microsoft\Windows\EventLog\Security"
$valueName    = "MaxSize"
$targetSizeKB = 1024000 # 1,024,000 KB satisfies the "at least one week" standard

Write-Host "--- Remediating STIG WN11-AU-000505 ---" -ForegroundColor Cyan

# 1. Ensure the EventLog Security policy path exists
if (-not (Test-Path -Path $registryPath)) {
    Write-Host "Creating missing EventLog Security path structure..." -ForegroundColor Gray
    New-Item -Path $registryPath -Force | Out-Null
}

# 2. Apply the compliance configuration
New-ItemProperty -Path $registryPath -Name $valueName -Value $targetSizeKB -PropertyType DWORD -Force | Out-Null
Write-Host "Remediation applied successfully to Group Policy paths." -ForegroundColor Gray

Write-Host "`n--- Running Post-Check Verification ---" -ForegroundColor Cyan

# 3. Verify the registry policy setting
if (Test-Path -Path $registryPath) {
    $currentPolicyValue = Get-ItemPropertyValue -Path $registryPath -Name $valueName -ErrorAction SilentlyContinue
    
    if ($currentPolicyValue -ge $targetSizeKB) {
        Write-Host "[PASS] STIG WN11-AU-000505 Policy is COMPLIANT. (Policy MaxSize is $currentPolicyValue KB)" -ForegroundColor Green
    } else {
        Write-Host "[FAIL] STIG WN11-AU-000505 Policy is NON-COMPLIANT. (Policy MaxSize is '$currentPolicyValue' KB instead of >= $targetSizeKB KB)" -ForegroundColor Red
    }
} else {
    Write-Host "[FAIL] Policy Registry path could not be verified." -ForegroundColor Red
}

# 4. Corrected active runtime check using Get-WinEvent
try {
    $activeLogSize = (Get-WinEvent -ListLog Security).MaximumSizeInBytes / 1KB
    Write-Host "Active Event Log Runtime Size: $activeLogSize KB" -ForegroundColor Gray
} catch {
    Write-Host "Warning: Unable to query active runtime engine container metrics." -ForegroundColor Yellow
} 
