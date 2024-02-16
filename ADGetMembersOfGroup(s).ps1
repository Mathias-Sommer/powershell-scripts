#This script lets you know all the users for specific group(s) in AD.
#You can add the full group name or the prefix ex. 'test' and it will look for all groups containing 'test'.

#importexcel module has to be installed for this to work.
Import-Module ImportExcel

# Specify the starting string for group names
$groupNamePrefix = "INSERTGROUPNAME/PREFIXFORGROUPS"

# Get groups that start with the specified prefix
$groups = Get-ADGroup -Filter "Name -like '$groupNamePrefix*'" -Properties *

# Create an array to store the results
$results = @()

# Loop through each group
foreach ($group in $groups) {
    # Get members of the current group
    $members = Get-ADGroupMember -Identity $group

    # Loop through each member of the group
    foreach ($member in $members) {

    if($group.ManagedBy -eq $null){
        $manager = $false
        }
        else{
        $manager = Get-ADUser -Identity $group.ManagedBy 
        }

        # Create an object with group and member details
        $resultObject = [PSCustomObject]@{
            'GroupName' = $group.Name
            'MemberName' = $member.Name
            'PUID' = if ($member.SamAccountName -ne $member.name) { $member.SamAccountName } else { "" }
            'Manager' = if ($manager) { $manager.Name } else { "" }
        }

        # Add the object to the results array
        $results += $resultObject
    }
}

# Print results to console
$results | Format-Table -AutoSize

# Export results to CSV
$results | Export-Excel "${groupNamePrefix}.xlsx" -Append -WorksheetName "$groupNamePrefix" -TableStyle Medium9 -title "$groupNamePrefix" -TitleBold -AutoSize
