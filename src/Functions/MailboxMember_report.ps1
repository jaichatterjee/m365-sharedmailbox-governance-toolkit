$MailboxMemberMap.GetEnumerator() |
ForEach-Object {
    $Mailbox = $_.Key

    $_.Value |
    Group-Object User |
    ForEach-Object {
        [PSCustomObject]@{
            Mailbox   = $Mailbox
            MemberUPN = $_.Name
        }
    }
} |
Export-Csv "C:\SharedMailboxReports\MailboxMemberMap.csv" `
    -NoTypeInformation -Encoding UTF8
