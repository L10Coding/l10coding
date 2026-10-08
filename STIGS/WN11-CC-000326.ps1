 <#
.SYNOPSIS
    Remediates and verifies STIG WN11-CC-000326.

.DESCRIPTION
    Ensures 'Turn on PowerShell Script Block Logging' is set to 'Enabled'.
    Creates the required registry structure, applies the DWORD value, and verifies it.
#>

$registryPath = "HKLM:\SOFTWARE\Policies\Microsoft\Windows\PowerShell\ScriptBlockLogging"
$valueName    = "EnableScriptBlockLogging"
$targetData   = 1

Write-Host "--- Remediating STIG WN11-CC-000326 ---" -ForegroundColor Cyan

# 1. Ensure the registry path exists
if (-not (Test-Path -Path $registryPath)) {
    Write-Host "Creating missing registry path..." -ForegroundColor Gray
    New-Item -Path $registryPath -Force | Out-Null
}

# 2. Apply the compliance configuration
New-ItemProperty -Path $registryPath -Name $valueName -Value $targetData -PropertyType DWORD -Force | Out-Null
Write-Host "Remediation applied successfully." -ForegroundColor Gray

Write-Host "`n--- Running Post-Check Verification ---" -ForegroundColor Cyan

# 3. Verify the setting
if (Test-Path -Path $registryPath) {
    $currentValue = Get-ItemPropertyValue -Path $registryPath -Name $valueName -ErrorAction SilentlyContinue
    
    if ($currentValue -eq $targetData) {
        Write-Host "[PASS] STIG WN11-CC-000326 is COMPLIANT. ($valueName is set to $currentValue)" -ForegroundColor Green
    } else {
        Write-Host "[FAIL] STIG WN11-CC-000326 is NON-COMPLIANT. ($valueName is set to '$currentValue' instead of $targetData)" -ForegroundColor Red
    }
} else {
    Write-Host "[FAIL] Registry path could not be verified." -ForegroundColor Red
} 
