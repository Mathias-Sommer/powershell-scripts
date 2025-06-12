Connect-ExchangeOnline
$mailbox = "mailbox@domain.com"
$mailboxAlias = "mailboxAlias@domain.com"

Set-Mailbox $mailbox -EmailAddresses @{add="${mailboxAlias}"}
