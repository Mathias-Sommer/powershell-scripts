#This script lets you know all the users for specific group(s) in AD.
#You can add the full group name or the prefix ex. 'test' and it will look for all groups containing 'test'.

#importexcel module has to be installed for this to work. Comment this #Import-Module ImportExcel if you don't want to export to excel.
Import-Module ImportExcel

# Specify the starting string for group names
$groupNamePrefix = "access"


$groups = Get-ADGroup -Filter "Name -like '*$groupNamePrefix*'" -Properties *
$results = @()
foreach ($group in $groups) {
    $members = Get-ADGroupMember -Identity $group

    foreach ($member in $members) {

    if($group.ManagedBy -eq $null){
        $manager = $false
        } else{
            $manager = Get-ADUser -Identity $group.ManagedBy 
            }

        $resultObject = [PSCustomObject]@{
            'GroupName' = $group.Name
            'MemberName' = $member.Name
            'PUID' = if ($member.SamAccountName -ne $member.name) { $member.SamAccountName } else { "" }
            'Manager' = if ($manager) { $manager.Name } else { "No Manager" } 
            }

         $results += $resultObject
        }
}

$results | Format-Table -AutoSize

# Export results to excel. Comment the $results out if you don't want to export to excel.
$results | Export-Excel -Path C:\Temp\${groupNamePrefix}.xlsx -Append -WorksheetName "1" -TableStyle Medium9 -AutoSize
