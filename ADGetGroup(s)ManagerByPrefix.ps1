#This lets you get all the groups with a specific prefix. Then it returns Group name, Description, Manager Name in "Name" form and not Distinguished name.
#Useful when you need the managers of lets say all groups staring with "SQL" or whatever.

$GroupMembers = @()
#Put group prefix here. This takes every group that has "IT" in it.
$groupNamePrefix = "IT" #replace with whatever 

$Groups = Get-ADGroup -Filter "Name -like '*$groupNamePrefix*'" -Properties *

foreach ($g in $Groups) {
    if ($g.ManagedBy -eq $null) {
        $managerName = "No Manager"
    } else {
        $manager = Get-ADUser -Identity $g.ManagedBy
        $managerName = $manager.Name
    }

    $Info = New-Object psObject 
    $Info | Add-Member -MemberType NoteProperty -Name "GroupName" -Value $g.Name
    $Info | Add-Member -MemberType NoteProperty -Name "Description" -Value $g.description
    $Info | Add-Member -MemberType NoteProperty -Name "ManagedBy" -Value $managerName
   
    $GroupMembers += $Info
    $info
}
#Remove the # from this, if you want to export this as csv. Then add your desired path.
#$GroupMembers | Sort-Object GroupName | Export-CSV -Path "C:\Temp\groupdist2.csv" -NoTypeInformation -Encoding unicode -Delimiter "," 
