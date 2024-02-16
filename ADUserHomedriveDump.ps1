$users = Import-Csv "C:\temp\ps\ETSEUserHomeDriveDump\puids.csv"

foreach ($user in $users.puid){
    $variabel = get-aduser -Identity $user -properties homedirectory | select SamAccountName, Name, UserPrincipalName, HomeDirectory | out-file "C:\temp\ps\ETSEUserHomeDriveDump\userdump.txt" -Append
    $variabel
}
write-host "Homedrive dump is located at:", "C:\temp\ps\ETSEUserHomeDriveDump\userdump.txt"
