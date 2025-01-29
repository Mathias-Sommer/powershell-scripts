@echo off
:: Sætter variabel til scriptets sti
set scriptPath=%~dp0Installer_Printere.ps1

:: Starter PowerShell som administrator og kører scriptet
powershell -NoProfile -ExecutionPolicy Bypass -Command "Start-Process PowerShell -ArgumentList '-NoProfile', '-ExecutionPolicy Bypass', '-File', '%scriptPath%' -Verb RunAs"
