<#
Cheat sheet for my most used exchange cmdlets.
#>

####Modules####
Install-Module ExchangeOnlineManagement
Import-Module ExchangeOnlineManagement
Connect-ExchangeOnline -UserPrincipalName user@domain.dk

####MAILBOX& CALENDAR####
Get-Mailbox mailbox@domain.com | Format-List MessageCopyForSentAsEnabled, MessageCopyForSendOnBehalfEnabled
Set-Mailbox mailbox@domain.com -MessageCopyForSentAsEnabled $true -MessageCopyForSendOnBehalfEnabled $true
 
Get-MailboxFolderPermission -Identity mailbox@domain.com:\Kalender -user user@domain.com
Add-MailboxFolderPermission -Identity mailbox@domain.com:\Kalender -user user@domain.com -AccessRights Owner
Remove-MailboxPermissions -identity mailbox@domain.dk -user user@domain.com -accessrights FullAccess
 
####Group extractions####
Get-DistributionGroupMember -Identity DISTRIBUTIONSLISTE -ResultSize Unlimited | Select DisplayName #Extracts memberships of distribution lists
Get-UnifiedGroup -Identity SECURITYGROUP | Get-UnifiedGroupLinks -LinkType Member | select displayname #Extracts memberships of groups
