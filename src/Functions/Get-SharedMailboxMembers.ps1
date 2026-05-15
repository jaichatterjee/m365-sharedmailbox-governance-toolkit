function Get-SharedMailboxMembers {
    param (
        [Parameter(Mandatory)]
        [string]$Mailbox
    )

    $FullAccessUsers = Get-MailboxPermission -Identity $Mailbox |
        Where-Object {
            $_.AccessRights -contains "FullAccess" -and
            -not $_.IsInherited
        } |
        ForEach-Object {
            $_.User.ToString()
        } |
        Where-Object {
            $_ -match '\.com$' -and
            $_ -notmatch '^NT AUTHORITY\\' -and
            $_ -notmatch '^S-\d-\d+'
        } |
        ForEach-Object {
            [PSCustomObject]@{
                SharedMailbox = $Mailbox
                User          = $_
                AccessType    = "FullAccess"
            }
        }

    $SendAsUsers = Get-RecipientPermission -Identity $Mailbox |
        Where-Object {
            $_.AccessRights -contains "SendAs"
        } |
        ForEach-Object {
            $_.Trustee.ToString()
        } |
        Where-Object {
            $_ -match '\.com$' -and
            $_ -notmatch '^NT AUTHORITY\\' -and
            $_ -notmatch '^S-\d-\d+'
        } |
        ForEach-Object {
            [PSCustomObject]@{
                SharedMailbox = $Mailbox
                User          = $_
                AccessType    = "SendAs"
            }
        }

    $SendOnBehalfUsers = Get-Mailbox -Identity $Mailbox |
        Select-Object -ExpandProperty GrantSendOnBehalfTo |
        ForEach-Object {
            $_.PrimarySmtpAddress
        } |
        Where-Object {
            $_ -match '\.com$' -and
            $_ -notmatch '^NT AUTHORITY\\' -and
            $_ -notmatch '^S-\d-\d+'
        } |
        ForEach-Object {
            [PSCustomObject]@{
                SharedMailbox = $Mailbox
                User          = $_
                AccessType    = "SendOnBehalf"
            }
        }

    return @(
        $FullAccessUsers
        $SendAsUsers
        $SendOnBehalfUsers
    ) |
    Where-Object { $_ } |
    Sort-Object User -Unique
}
