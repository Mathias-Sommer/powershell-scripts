#This gets useful information of a user.
#**Note if your domain controllers haven't synced, then the date/time can way be off. Please keep that in mind.

$user = Get-ADUser -Filter {SamAccountName -eq "ENTER_SAMACCOUNTNAME"} -Properties lastLogon, WhenCreated, PwdLastSet, Manager | Select-Object Name, SamAccountName, @{
    Name="LastLogon"; 
    Expression={[DateTime]::FromFileTime($_.lastLogon)}
}, @{
    Name="WhenCreated"; 
    Expression={[DateTime]::Parse($_.WhenCreated)}
}, @{
    Name="PwdLastSet"; 
    Expression={[DateTime]::FromFileTime($_.PwdLastSet)}
}, Manager

$manager = Get-ADUser $user.Manager -Properties Name

Write-host "User Information:"
Write-host "------------------"
Write-host "Name           : $($user.Name)" -ForegroundColor Green
Write-host "SamAccountName : $($user.SamAccountName)" -ForegroundColor Yellow
Write-host "LastLogon      : $($user.LastLogon.ToString("dd-MM-yyyy HH:mm:ss"))" -ForegroundColor Cyan
Write-host "WhenCreated    : $($user.WhenCreated.ToString("dd-MM-yyyy HH:mm:ss"))" -ForegroundColor Cyan
Write-host "PwdLastSet     : $($user.PwdLastSet.ToString("dd-MM-yyyy HH:mm:ss"))" -ForegroundColor Cyan
Write-host "Manager        : $($manager.Name) $($manager.SamAccountName)" -ForegroundColor DarkGray
