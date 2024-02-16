#This script allows you send an email from powershell.
#I've used this to test if our SMTP works.

$EmailTo = "email_to@email.com"
$EmailFrom = "smtp_email@mail.com"
$Subject = "Testing SMTP" 
$Body = "Body in the test email" 

$SMTPServer = "your.smtp-server.com" 
$SMTPMessage = New-Object System.Net.Mail.MailMessage($EmailFrom,$EmailTo,$Subject,$Body)
$SMTPClient = New-Object Net.Mail.SmtpClient($SmtpServer, 587) #<-- could be running different port 
$SMTPClient.EnableSsl = $true 
$SMTPClient.Credentials = New-Object System.Net.NetworkCredential("smtp_email@mail.com", "Your_Top_Secret_Password"); 
$SMTPClient.Send($SMTPMessage)
