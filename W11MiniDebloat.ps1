# TODO when setting up new W11 PC:
## Remove Bing from search menu

New-Item -Path "HKCU:\Software\Policies\Microsoft\Windows\Explorer" -Force
Set-ItemProperty -Path "HKCU:\Software\Policies\Microsoft\Windows\Explorer" -Name "DisableSearchBoxSuggestions" -Type DWord -Value 1

## Revert right click context menu to W10
New-Item -Path "HKCU:\Software\Classes\CLSID\{86ca1aa0-34aa-4e8b-a509-50c905bae2a2}\InprocServer32" -Force | Out-Null
Set-ItemProperty -Path "HKCU:\Software\Classes\CLSID\{86ca1aa0-34aa-4e8b-a509-50c905bae2a2}\InprocServer32" -Name "(default)" -Value "" -Force

## Restart explorer or reboot the pc
Stop-Process -Name explorer -Force

##IF explorer does not auto start:
Start-Process explorer
