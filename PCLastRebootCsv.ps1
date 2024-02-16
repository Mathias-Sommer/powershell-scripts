#Powershell script to check Last Reboot Time on a list of machines included in a text file
$machines = Get-Content -path "C:\path_to_your_txt.txt"
$report = @()
$object = @()

foreach($machine in $machines){
  $machine
  $object = gwmi win32_operatingsystem -ComputerName $machine | select csname, @{LABEL='LastBootUpTime';EXPRESSION={$_.ConverttoDateTime($_.lastbootuptime)}}
  $report += $object
  }

$report | Export-csv "C:\path\ServerLastReboot.csv"
