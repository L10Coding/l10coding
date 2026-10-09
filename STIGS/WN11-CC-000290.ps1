 <#
.SYNOPSIS
    This PowerShell script remediates and verifies STIG WN11-CC-000290.  Enforces "High Level" 128-bit encryption for all Remote Desktop Services sessions.
    Creates the policy registry path if it is missing, sets the DWORD value, and verifies it.
.NOTES
    Author          : Alton Stewart
    LinkedIn        : N/A
    GitHub          : github.com/l10coding
    Date Created    : 2026-10-09
    Last Modified   : 2026-10-09
    Version         : 1.0
    CVEs            : N/A
    Plugin IDs      : N/A
    STIG-ID         : WN11-CC-000290

.TESTED ON
    Date(s) Tested  : 
    Tested By       : 
    Systems Tested  : 
    PowerShell Ver. : 

.USAGE
    Put any usage instructions here.
    Example syntax:
    PS C:\> .\STIG-ID-WN11-CC-000290.ps1 
#>

$registryPath = "HKLM:\SOFTWARE\Policies\Microsoft\Windows NT\Terminal Services"
$valueName    = "MinEncryptionLevel"
$targetData   = 3  # Value 3 corresponds to "High Level" encryption

Write-Host "--- Remediating STIG WN11-CC-000290 ---" -ForegroundColor Cyan

# 1. Ensure the administrative template registry path exists
if (-not (Test-Path -Path $registryPath)) {
    Write-Host "Creating missing Terminal Services policy path structure..." -ForegroundColor Gray
    New-Item -Path $registryPath -Force | Out-Null
}

# 2. Apply the compliance configuration (3 = High Level)
New-ItemProperty -Path $registryPath -Name $valueName -Value $targetData -PropertyType DWORD -Force | Out-Null
Write-Host "Remediation applied successfully." -ForegroundColor Gray

Write-Host "`n--- Running Post-Check Verification ---" -ForegroundColor Cyan

# 3. Verify the setting
if (Test-Path -Path $registryPath) {
    $currentValue = Get-ItemPropertyValue -Path $registryPath -Name $valueName -ErrorAction SilentlyContinue
    
    if ($currentValue -eq $targetData) {
        Write-Host "[PASS] STIG WN11-CC-000290 is COMPLIANT. ($valueName is set to $currentValue - High Level Encryption)" -ForegroundColor Green
    } else {
        Write-Host "[FAIL] STIG WN11-CC-000290 is NON-COMPLIANT. ($valueName is set to '$currentValue' instead of $targetData)" -ForegroundColor Red
    }
} else {
    Write-Host "[FAIL] Policy registry path could not be verified." -ForegroundColor Red
} 
