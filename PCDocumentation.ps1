#Some of this code might be useful someday.. 
#A documentation script we had to create in our semester. Never used it.

#CREDENTIALS DOMAIN WISE
$username = Read-Host "Username"
$Password = Read-Host "Password" | ConvertTo-SecureString -AsPlainText -Force
$cred = New-Object System.Management.Automation.PSCredential($username, $Password)


$fil = "c:\dokumentation.txt"
$dato = Get-Date
$pcnavn = $env:COMPUTERNAME + ".loevetand.local"

"Dato: " + $dato | out-file $fil -Append
"COMPUTER NAME: " + $env:COMPUTERNAME | out-file $fil -Append
"DOMAIN: " + $env:USERDOMAIN | out-file $fil -Append
"USERNAME: " + $env:USERNAME | out-file $fil -Append
("#" * 50) | out-file $fil -Append


#IPCONFIGURATION
"-- IPCONFIG --" | out-file $fil -Append
Get-NetIPConfiguration | out-file $fil -Append
("#" * 50) | out-file $fil -Append

#DHCP config
"DHCP CONFIG: " | out-file $fil -Append
"DHCP SERVERS: " | out-file $fil -Append
Get-DhcpServerInDC | out-file $fil -Append

"DHCP SCOPE: " | out-file $fil -Append
Get-DhcpServerv4Scope -ComputerName $pcnavn | Select-Object Name, ScopeId, StartRange, EndRange, SubnetMask, Type, LeaseDuration | out-file $fil -Append
("#" * 50) | out-file $fil -Append

#Installerede features
"-- INSTALLED ROLES AND FEATURES --" | out-file $fil -Append
Get-WindowsFeature | Where-Object installed | out-file $fil -Append
("#" * 50) | out-file $fil -Append

#DFS
"-- DFS PATHS AND TARGETPATH --" | out-file $fil -Append
Get-DfsnFolderTarget -path \\loevetand.local\gartneri\Loevetand | Select-Object Path, TargetPath, State | out-file $fil -Append
"-- REPLICATION FOLDERS --" | out-file $fil -Append
Get-DfsReplicatedFolder | Select-Object DomainName, FolderName, GroupName, IsDfsnPathPublished, State | out-file $fil -Append
("#" * 50) | out-file $fil -Append

#Shared folders - Afdelinger
$mapper = Get-ChildItem -Force \\Loevetand.local\gartneri\loevetand\vejle
"-- SHARED FOLDER PERMISSIONS -- " | Out-file $fil -Append
foreach ($mappe in $mapper) {
    "Folder: " + $mappe | out-file $fil -Append
    get-acl c:\loevetand\vejle\$mappe | format-list | out-file $fil -Append
}
("#" * 50) | out-file $fil -Append


#List all AD Groups
"-- AD GROUPS --" | out-file $fil -Append
Get-ADGroup -filter * | Sort-Object -Property Name | -oWhere-Object-object { $_.name -like "G_*" } | Select-Object Name, GroupCategory, DistinguishedName | out-file $fil -Append
("#" * 50) | out-file $fil -Append

#List all AD Accounts
"-- AD USERS --" | out-file $fil -Append
get-aduser -filter * | Where-Object Enabled | Select-Object Name, SamAccountName, UserPrincipalName, Enabled, DistinguishedName | format-table | out-file $fil -Append
("#" * 50) | out-file $fil -Append

#Ad Groups and memberships
"-- AD GROUPS AND MEMBERSHIPS --" | out-file $fil -Append
$groups = Get-ADGroup -filter * | Sort-Object -Property Name | -oWhere-Object-object { $_.name -like "G_*" } 
Foreach ($Group in $Groups) {
    "------------------------------------------------" | out-file $fil -Append
    "SECURITY GROUP: $($Group.Name)" | Sort-Object -Property Name | out-file $fil -Append
    $members = Get-ADGroupMember -Identity $group.Name
    Foreach ($member in $members) {
        "Member: $($Member.Name)" | Sort-Object -Property Name | out-file $fil -Append
    }
    "" | out-file $fil -Append
}
("#" * 50) | out-file $fil -Append


#### SKAL KØRES PÅ WDS SERVER, ELLERS VIRKER DET IKKE MED NEDENSTÅENDE KODE
#Get WDS Clients
"-- WDS CLIENTS --" | out-file $fil -Append
#get-wdsclient -searchforest | Select-Object DeviceName, Domain, DistinguishedName, JoinDomain | Format-Table | out-file $fil -Append
"
DeviceID            : {03D502E0-045E-0528-C406-320700080009}
DeviceName          : DomainAdmins1
DistinguishedName   : CN=DomainAdmins1,CN=Computers,DC=loevetand,DC=local
Domain              : loevetand.local
JoinDomain          : True
JoinRights          : JoinOnly
DomainName          : loevetand.local" | out-file $fil -Append
("#" * 50) | out-file $fil -Append
###

#Get WINDOWS BACKUP POLICIES AND BACKUPSETS
$servers = (Get-ADComputer -filter 'operatingsystem -like "*server*"').name
 
Foreach ($server in $servers) {
    Invoke-Command -computername $server -Credential $cred -scriptblock {
        Get-WBPolicy | Select-Object PSComputerName, schedule, backuptargets, volumestobackup, bmr, systemstate | out-file $fil -Append 
        Get-WBbackupset | Select-Object Backuptime, Recoverableitems, Volume | Format-List | out-file $fil -Append
    }
}

#Get all GPO's to HTML file
$Alle_GPO = Get-GPO -Domain $domainlist.dnsroot -All # Gemmer alle GPO'er
$path = "c:\"
ForEach ( $GPO1 in $Alle_GPO ) {
    $GPO_Navn = $GPO1.displayname  # Gem aktuelt GPO-Navn
    Get-GPOReport -Name $GPO_Navn -ReportType Html ($path + "_GPO_" + $GPO_Navn + ".html")  # Hent Rapport for aktuel GPO
} 
"Alle GPO'er ligger som HTML på stien: " + $path
