<#
.SYNOPSIS
  Export on-prem Active Directory privileged groups and their members to CSV.

.NOTES
  - Run as Domain Admin (or equivalent).
  - Requires only the ActiveDirectory PowerShell module (RSAT or DC).
  - Outputs one consolidated CSV file with all privileged groups + members.
#>

param(
  [string] $OutFile = ".\ADPrivilegedGroups.csv"
)

# Ensure AD module is present
if (-not (Get-Module -ListAvailable -Name ActiveDirectory)) {
    Write-Error "ActiveDirectory module not found. Install RSAT (RSAT:ActiveDirectory.DS-LDS.Tools)."
    exit
}
Import-Module ActiveDirectory

# Built-in privileged groups in AD
$PrivGroups = @(
    "Domain Admins",
    "Enterprise Admins",
    "Schema Admins",
    "Administrators",
    "Account Operators",
    "Server Operators",
    "Backup Operators",
    "Print Operators",
    "DnsAdmins",
    "Cert Publishers"
)

$rows = New-Object System.Collections.Generic.List[object]

foreach ($g in $PrivGroups) {
    Write-Host "Processing group: $g" -ForegroundColor Yellow
    try {
        $members = Get-ADGroupMember -Identity $g -Recursive -ErrorAction Stop
        foreach ($m in $members) {
            if ($m.objectClass -eq "user") {
                $user = Get-ADUser $m -Properties mail,displayName,samAccountName,lastLogonDate
                $rows.Add([pscustomobject]@{
                    GroupName      = $g
                    DisplayName    = $user.DisplayName
                    SamAccountName = $user.SamAccountName
                    Email          = $user.Mail
                    LastLogon      = $user.LastLogonDate
                })
            }
        }
    }
    catch {
        Write-Warning "Could not query group $g : $_"
    }
}

# Export to CSV
$rows | Sort-Object GroupName, DisplayName | Export-Csv -Path $OutFile -NoTypeInformation -Encoding UTF8

Write-Host "Done. Exported to $OutFile" -ForegroundColor Green
