 <#
.SYNOPSIS
    This PowerShell script remediates and verifies STIG WN11-CC-000035.  Configures the host to ignore on-demand NetBIOS name release requests 
    except from trusted WINS servers to prevent network Denial of Service (DoS) attacks.

.NOTES
    Author          : Alton Stewart
    LinkedIn        : N/A
    GitHub          : github.com/l10coding
    Date Created    : 2026-10-08
    Last Modified   : 2026-10-08
    Version         : 1.0
    CVEs            : N/A
    Plugin IDs      : N/A
    STIG-ID         : WN11-CC-000035

.TESTED ON
    Date(s) Tested  : 
    Tested By       : 
    Systems Tested  : 
    PowerShell Ver. : 

.USAGE
    Put any usage instructions here.
    Example syntax:
    PS C:\> .\STIG-ID-WN11-CC-000035.ps1 
#>

$registryPath = "HKLM:\System\CurrentControlSet\Services\NetBT\Parameters"
$valueName    = "NoNameReleaseOnDemand"
$targetData   = 1

Write-Host "--- Remediating STIG WN11-CC-000035 ---" -ForegroundColor Cyan

# 1. Ensure the NetBT Parameters path exists (though it is a native Windows system path)
if (-not (Test-Path -Path $registryPath)) {
    Write-Host "Creating missing parameters path..." -ForegroundColor Gray
    New-Item -Path $registryPath -Force | Out-Null
}

# 2. Apply the compliance configuration (1 = Ignore requests)
New-ItemProperty -Path $registryPath -Name $valueName -Value $targetData -PropertyType DWORD -Force | Out-Null
Write-Host "Remediation applied successfully." -ForegroundColor Gray

Write-Host "`n--- Running Post-Check Verification ---" -ForegroundColor Cyan

# 3. Verify the setting
if (Test-Path -Path $registryPath) {
    $currentValue = Get-ItemPropertyValue -Path $registryPath -Name $valueName -ErrorAction SilentlyContinue
    
    if ($currentValue -eq $targetData) {
        Write-Host "[PASS] STIG WN11-CC-000035 is COMPLIANT. ($valueName is set to $currentValue)" -ForegroundColor Green
    } else {
        Write-Host "[FAIL] STIG WN11-CC-000035 is NON-COMPLIANT. ($valueName is set to '$currentValue' instead of $targetData)" -ForegroundColor Red
    }
} else {
    Write-Host "[FAIL] Registry path could not be verified." -ForegroundColor Red
} 
