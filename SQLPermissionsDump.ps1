#I copied lots of this code, and added stuff to my liking.
#This basically dumps all the login users and their permissions from a SQL server.
#Run this on the server hosting the SQL. Remember to fulfill the SQL instance/instance+name(server name when you connect via SSMS).

Function GetDBUserInfo($Dbase){
    if ($dbase.status -eq "Normal"){
        $users = $Dbase.users | where {$_.login -eq $SQLLogin.name}
            foreach ($u in $users){
                if ($u){
                    $DBRoles = $u.enumroles()
                        foreach ($role in $DBRoles){
                            if ($role -eq "db_owner") {
                                write-host $role "on"$Dbase.name -foregroundcolor "red"  #if db_owner set text color to red
                                }
                                    else {
                                        write-host $role "on"$Dbase.name
                                    }
                        }
                        foreach($perm in $Dbase.EnumObjectPermissions($u.Name)){
                            write-host  $perm.permissionstate $perm.permissiontype "on" $perm.objectname "in" $DBase.name }
                            }
                        }
                    }
                }

[reflection.assembly]::LoadWithPartialName("Microsoft.SqlServer.Smo") | out-null
$server_name_instance = read-host "Indtast SQL server navn + instance fx SQL\SQL"
foreach ($SQLsvr in $server_name_instance){
    $svr = new-object ("Microsoft.SqlServer.Management.Smo.Server") $SQLsvr
    write-host "================================================================================="
    write-host "SQL Instance: " $svr.name
    write-host "SQL Version:" $svr.VersionString
    write-host "Edition:" $svr.Edition
    write-host "Login Mode:" $svr.LoginMode
    write-host "================================================================================="
    $SQLLogins = $svr.logins
        foreach ($SQLLogin in $SQLLogins){
            write-host    "Login          : " $SQLLogin.name
            write-host    "Login Type     : " $SQLLogin.LoginType
            write-host    "Created        : " $SQLLogin.CreateDate
            write-host    "Default DB     : " $SQLLogin.DefaultDatabase
            Write-Host    "Disabled       : " $SQLLogin.IsDisabled
            $SQLRoles = $SQLLogin.ListMembers()
                if ($SQLRoles) {
                    if ($SQLRoles -eq "SysAdmin"){ write-host    "Server Role    : " $SQLRoles -foregroundcolor "red"}
                        else{ 
                            write-host    "Server Role    : " $SQLRoles
                            }                             
                    } 
                            else {"Server Role    :  Public"}

     If ($SQLLogin.LoginType -eq "WindowsGroup"){ 
           write-host "Group Members:"
                try {
                       $ADGRoupMembers = get-adgroupmember  $SQLLogin.name.Split("\")[1] -Recursive
                       foreach($member in $ADGRoupMembers){
                       write-host "   Account: " $member.name "("$member.SamAccountName")"                                                    
                       }
                   }
                   catch{
                        write-host "Unable to locate group "  $SQLLogin.name.Split("\")[1] " in the AD Domain" -foregroundcolor Red
                   }
      }

    if ($SQLLogin.EnumDatabaseMappings()){
       write-host "Permissions:"
            foreach ( $DB in $svr.Databases){
                GetDBUserInfo($DB)
            }
      }
    Else{
       write-host "None."
        }
write-host "-------------------------------------------------------------------------------"
  }
}
