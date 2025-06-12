Connect-ExchangeOnline

$rooms = Get-Mailbox -RecipientTypeDetails RoomMailbox

foreach ($room in $rooms) {
    Write-Output "Room: $($room.DisplayName) <$($room.Alias)>"

    $calendarSettings = Get-CalendarProcessing -Identity $room.Identity

    # Check group assignments
    $bookInPolicy = $calendarSettings.BookInPolicy
    $requestInPolicy = $calendarSettings.RequestInPolicy
    $requestOutOfPolicy = $calendarSettings.RequestOutOfPolicy

    if ($bookInPolicy -or $requestInPolicy -or $requestOutOfPolicy) {
        Write-Output "  BookInPolicy: $bookInPolicy"
        Write-Output "  RequestInPolicy: $requestInPolicy"
        Write-Output "  RequestOutOfPolicy: $requestOutOfPolicy"
    } else {
        Write-Output "  No specific groups or users assigned."
    }

    Write-Output ""
}
