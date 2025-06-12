Connect-ExchangeOnline
$GroupEmail = "GroupEmailAddress"
$UserEmail = "UserEmailAddress"

$Owners = Get-UnifiedGroupLinks -Identity $GroupEmail -LinkType Owners
$Members = Get-UnifiedGroupLinks -Identity $GroupEmail -LinkType Members
$AllUsers = $Owners + $Members
$AllUsers | Select-Object DisplayName, PrimarySmtpAddress

Add-MailboxPermission -Identity $GroupEmail -User $UserEmail -AccessRights FullAccess

$mailbox = Get-Mailbox -Identity $GroupEmail
$folders = Get-MailboxFolderStatistics -Identity $mailbox.DistinguishedName | Where-Object { $_.FolderType -eq "User Created" }

foreach ($folder in $folders) {
    $folderPath = $folder.FolderPath -replace '\\', '/'
    Add-MailboxFolderPermission -Identity "${GroupEmail}:${folderPath}" -User ${UserEmail} -AccessRights PublishingEditor
}
