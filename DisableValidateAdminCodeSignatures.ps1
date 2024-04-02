# This script changes a value in regedit.
# Specify the path under $registryPath. Specify the thing you wanna target under $valueName

Set-ExecutionPolicy RemoteSigned -Scope CurrentUser -Force
$registryPath = "HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\Policies\System"
$valueName = "ValidateAdminCodeSignatures"
$valueData = 0
if (Test-Path $registryPath) {
    Set-ItemProperty -Path $registryPath -Name $valueName -Value $valueData
    Write-Host "Registry value '$valueName' set to $valueData"
    }
    else {
        Write-Host "Registry path not found: $registryPath" -ForegroundColor Red
        }
