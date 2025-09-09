Import-Module ActiveDirectory
$user = "<SAMACCOUNTNAME>"

Get-ADPrincipalGroupMembership -Identity $user |
    Select-Object -ExpandProperty SamAccountName
