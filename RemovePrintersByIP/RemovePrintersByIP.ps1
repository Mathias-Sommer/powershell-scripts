function RemovePrintersByIP {
    $ipListPath = Join-Path $PSScriptRoot "printers.txt"

    if (-not (Test-Path $ipListPath)) {
        Write-Error "printers.txt not found in script directory: $PSScriptRoot"
        return
    }

    $targetIPs = Get-Content -Path $ipListPath | Where-Object { $_ -match '\d+\.\d+\.\d+\.\d+' }

    if ($targetIPs.Count -eq 0) {
        Write-Warning "No valid IPs found in printers.txt."
        return
    }

    $printers = Get-Printer
    $ports = Get-PrinterPort

    foreach ($port in $ports) {
        $matchingIP = $targetIPs | Where-Object { $port.Name -like "*$_*" }
        if ($matchingIP) {
            $matchedPrinters = $printers | Where-Object { $_.PortName -eq $port.Name }

            foreach ($printer in $matchedPrinters) {
                Write-Host "Removing printer '$($printer.Name)' using port '$($port.Name)'..."
                Remove-Printer -Name $printer.Name -ErrorAction SilentlyContinue
            }

            Write-Host "Removing printer port '$($port.Name)'..."            
            Remove-PrinterPort -Name $port.Name -ErrorAction SilentlyContinue
        }
    }

    Write-Host "Printer cleanup complete."
}

RemovePrintersByIP
