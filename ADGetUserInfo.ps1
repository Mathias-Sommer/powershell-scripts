#This gets useful information of a user.
#**Note if your domain controllers haven't synced, then the date/time can way be off. Please keep that in mind.
$samAccountName = read-host "Enter SamAccountName" 

$user = Get-ADUser -Filter {SamAccountName -eq $samAccountName} -Properties lastLogon, WhenCreated, PwdLastSet, Manager | Select-Object Name, SamAccountName, @{
    Name="LastLogon"; 
    Expression={[DateTime]::FromFileTime($_.lastLogon)}
}, @{
    Name="WhenCreated"; 
    Expression={[DateTime]::Parse($_.WhenCreated)}
}, @{
    Name="PwdLastSet"; 
    Expression={[DateTime]::FromFileTime($_.PwdLastSet)}
}, Manager

Write-host "User Information:"
Write-host "------------------" -ForegroundColor Gray

if($user.Name -eq $null){
    Write-host "Name           : N/A" -ForegroundColor gray
    } else{
        Write-host "Name           : $($user.Name)" -ForegroundColor Green
        }

if($user.SamAccountName -eq $null){
    Write-host "SamAccountName : N/A" -ForegroundColor gray
    } else{
        Write-host "SamAccountName : $($user.SamAccountName)" -ForegroundColor Green
        }

if($user.Manager -eq $null){
    Write-host "Manager        : N/A" -ForegroundColor gray
    }
    else{
        $manager = Get-ADUser $user.Manager -Properties Name, EmailAddress, TelephoneNumber
        $user.Manager = $manager.Name + " | " + $manager.SamAccountName + " | " + $manager.EmailAddress + " | " + $manager.TelephoneNumber
        Write-host "Manager        : $($user.Manager)" -ForegroundColor green
        }

if($user.LastLogon -eq $null -or $user.LastLogon -eq '01-01-1601 01:00:00'){
    Write-host "LastLogon      : Never" -ForegroundColor gray
    } else{
        Write-host "LastLogon      : $($user.LastLogon.ToString("dd-MM-yyyy HH:mm:ss"))" -ForegroundColor Cyan
        }

if($user.WhenCreated -eq $null -or $user.WhenCreated -eq '01-01-1601 01:00:00'){
    Write-host "WhenCreated    : N/A" -ForegroundColor gray
    }
    else{
        Write-host "WhenCreated    : $($user.WhenCreated.ToString("dd-MM-yyyy HH:mm:ss"))" -ForegroundColor Cyan
        }

if($user.PwdLastSet -eq $null -or $user.PwdLastSet -eq '01-01-1601 01:00:00'){
    Write-host "PwdLastSet     : Never" -ForegroundColor gray
    }
    else{
        Write-host "PwdLastSet     : $($user.PwdLastSet.ToString("dd-MM-yyyy HH:mm:ss"))" -ForegroundColor Cyan
        }
