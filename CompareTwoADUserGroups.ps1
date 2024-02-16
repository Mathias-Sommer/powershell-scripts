#Comparing 2 AD user accounts and returns the groups the other part is not a member of.
#I'm using this when adding groups to users, from a reference person. 
#Then i can just copy/paste the groups and the job is done.

$FirstUser = Read-Host "First user SAMACCOUNT NAME"
$SecondUser = Read-Host "Second user SAMACCOUNT NAME"
$FirstUGM = (get-aduser $Firstuser -Properties memberof).memberof | Sort-Object
$FullName1 = get-aduser $FirstUser -Properties Name | Sort-Object
$SecondUGM = (get-aduser $SecondUser -Properties memberof).memberof | Sort-Object
$FullName2 = get-aduser $SecondUser -Properties Name | Sort-Object
$ThirdUGM = (get-aduser $SecondUser -Properties memberof).memberof | Sort-Object
$FourthUGM = (get-aduser $Firstuser -Properties memberof).memberof | Sort-Object
clear
""
write-host $FullName1.Name.ToUpper() "" -NoNewLine -ForegroundColor Green
write-host $FirstUser.ToUpper() -NoNewLine -Foregroundcolor Cyan
write-host " er medlem af" -ForegroundColor Yellow

foreach ($F in $FirstUGM)
{
    $FGroupName = (get-adobject $F).name
    $Matched = $False
    $TotalADGroupsFirst = $FGroupName

    foreach ($S in $SecondUGM)
    {
        $SGroupName = (get-adobject $S).name
        if ($FGroupName -eq $SGroupName){$Matched = $True;break}
    }
    if ($Matched -eq $False){write-host "$FGroupName"}
}
""
""
write-host $FullName2.Name.ToUpper() "" -NoNewLine -ForegroundColor Green
write-host $SecondUser.ToUpper() -NoNewLine -ForegroundColor Cyan
write-host  " er medlem af" -ForegroundColor Yellow

foreach ($F in $ThirdUGM){
$FGroupName = (get-adobject $F).name
$Matched = $False
$TotalADGroupsSecond = $FGroupName
    foreach ($S in $FourthUGM){
        $SGroupName = (get-adobject $S).name
        if ($FGroupName -eq $SGroupName){$Matched = $True;break}
    }
    if ($Matched -eq $False){write-host "$FGroupName"}
}
