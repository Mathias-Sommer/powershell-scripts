Set-ExecutionPolicy Bypass -Scope Process -Force

$powershellPath = $PSScriptRoot
$driverPath = Join-Path $powershellPath "Driver"

$printerDrivers = @(
    @{ InfPath = "$driverPath\Brother\brpom22a.inf" }, #driver til importering i systemet
    @{ InfPath = "$driverPath\Brother\brimm22a.inf" }
)

$printers = @(
    @{ Name = "HP1"; IP = "192.168.1.12"; DriverName = "Brother DCP-B7548W Printer" },
    @{ Name = "HP2"; IP = "192.168.1.13"; DriverName = "Brother MFC-L2922DW Printer" },
    @{ Name = "HP3"; IP = "192.168.1.14"; DriverName = "Brother HL-L2464DW Printer" },
    @{ Name = "HP4"; IP = "192.168.1.15"; DriverName = "Brother DCP-B7548W Printer" },
    @{ Name = "HP5"; IP = "192.168.1.16"; DriverName = "Brother DCP-B7548W Printer" },
    @{ Name = "HP6"; IP = "192.168.1.17"; DriverName = "Brother DCP-B7548W Printer" },
    @{ Name = "HP7"; IP = "192.168.1.18"; DriverName = "Brother DCP-B7548W Printer" },
    @{ Name = "HP8"; IP = "192.168.1.19"; DriverName = "Brother DCP-B7548W Printer" }
)

# Importer driver
foreach ($driver in $printerDrivers) {     
    try {        
        pnputil /add-driver $driver.InfPath /install
    }
    catch {
        Write-Host "Fejl ved importering af driver fra: $($driver.InfPath) - $_`n" -ForegroundColor Red
    }
}

# Installer driver
foreach($DriverName in $printers){
    try{
        add-PrinterDriver -Name $DriverName.DriverName          
        Write-Host "Driver installeret:" $DriverName.DriverName`n -ForegroundColor DarkGray
    }
    catch{
        Write-Host "Fejl ved installation af driver - $_`n" -ForegroundColor Red
    }        
}

# Installer printer
foreach ($printer in $printers) {
    $portName = "IP_" + $printer.IP

    try {        
        Add-PrinterPort -Name $portName -PrinterHostAddress $printer.IP 
        Write-Host "Printerport tilføjet: $portName`n" -ForegroundColor DarkYellow
        
        Add-Printer -Name $printer.Name -DriverName $printer.DriverName -PortName $portName 
        Write-Host "Printer: $($printer.Name) installeret med driver: $($printer.DriverName)`n" -ForegroundColor Green
        Write-Host "--=== Printerne er installeret og klar til brug! ===-- `n"
    }
    catch {
        Write-Host "Fejl ved installation af printer $($printer.Name) - $_`n" -ForegroundColor Red
    }
}

Read-Host "Tryk på tasten ENTER for at lukke programmet"
