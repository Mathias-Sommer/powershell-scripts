$managerUsername = read-host "Indtast Manager initialer"
$managerDN = (Get-ADUser -Filter {SamAccountName -eq $managerUsername}-ErrorAction SilentlyContinue ).DistinguishedName 
$managerFullName = get-aduser -Filter "SamAccountName -eq '$managerUsername'" | Select-Object name, samaccountname
$directReports = Get-ADUser -Filter {Manager -eq $managerDN} -Properties SamAccountName, DisplayName | sort-object

if ($directReports.Count -eq 0) {
    Write-Host $managerFullName.name.ToUpper() $managerUsername.ToUpper() "er ikke manager for nogen!" -ForegroundColor Red
} else {
    Write-Host $managerFullName.Name.ToUpper() $managerUsername.ToUpper() "er manager for" -ForegroundColor Green
    ""
    $directReports | ForEach-Object {
        Write-Host $_.SamAccountName.ToUpper() -NoNewline -ForegroundColor Yellow 
        write-host ", " -NoNewline -ForegroundColor Yellow
        write-host  $_.DisplayName.ToUpper() -ForegroundColor Cyan
    }
}
