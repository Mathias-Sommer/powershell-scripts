# This function generates a random password with UPPERCASE, lowercase a-Z letters, numbers and special characters
function Generate-RandomPassword {
    param(
    # these are default options if you don't specify any in line 41.
        [int]$length = 15, 
        [bool]$lowerCase = $true,
        [bool]$upperCase = $true,
        [bool]$numbers = $true,
        [bool]$specialCharacters = $true
        )

    $random = New-Object System.Random
    $characters = ""
    $password = ""

    if ($lowerCase) {
        $characters += "abcdefghijklmnopqrstuvwxyz"
    }

    if ($upperCase) {
        $characters += "ABCDEFGHIJKLMNOPQRSTUVWXYZ"
    }

    if ($numbers) {
        $characters += "0123456789"
    }

    if ($specialCharacters) {
        $characters += "!@#$%&+/?.,-"
    }

    for ($i = 0; $i -lt $length; $i++) {
        $index = $random.Next(0, $characters.Length)
        $password += $characters[$index]
    }

    return $password
}

# $true means turned on. If you want to exclude certan things put $false instead.
$randomPassword = Generate-RandomPassword -length 24 -Lowercase $true -Uppercase $true -Numbers $true -SpecialCharacters $true
Write-Host "Password: " -NoNewline -ForegroundColor Green
Write-Host $randomPassword 
