# printers.txt
1. Udfyld IP adresser i "printers.txt"
2. Pak mappen RemovePrintersByIP til .intunewin
3. Opret pakken i Intune med nedenstående paremetre

# Kør Scriptet:
powershell.exe -ExecutionPolicy Bypass -File .\RemovePrintersByIP.ps1

# Afinstaller Scriptet:
cmd.exe /c exit 0
