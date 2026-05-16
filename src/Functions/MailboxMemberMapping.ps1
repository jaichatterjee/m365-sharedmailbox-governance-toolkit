$MailboxMemberMap = @{}

foreach ($Mailbox in $SharedMailboxes) {

    Write-Host "`nProcessing mailbox:" $Mailbox -ForegroundColor Yellow

    try {
        Get-Mailbox -Identity $Mailbox -ErrorAction Stop | Out-Null
    }
    catch {
        Write-Host "Mailbox not found:" $Mailbox -ForegroundColor Red
        continue
    }

    $Members = Get-SharedMailboxMembers -Mailbox $Mailbox

    if (-not $Members) {
        Write-Host "No members found." -ForegroundColor DarkYellow
        continue
    }

    $MailboxMemberMap[$Mailbox] = $Members
}
