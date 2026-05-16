# ===================================
# Load Configuration
# ===================================

. "$PSScriptRoot\Config\config.ps1"

# ===================================
# Load Logging
# ===================================

Get-ChildItem `
"$PSScriptRoot\Logging\*.ps1" |
ForEach-Object {

    . $_

}

# ===================================
# Load Functions
# ===================================

Get-ChildItem `
"$PSScriptRoot\Functions\*.ps1" |
ForEach-Object {

    . $_

}

Write-Log `
-Message "Shared Mailbox Governance Toolkit started"

try {

    # ==========================
    # CONNECT TO SERVICES
    # ==========================

    Connect-M365

    # ==========================
    # IMPORT CSV
    # ==========================
    $CSVData = Import-SharedMailboxCSV

    $SharedMailboxes = $CSVData |
    Select-Object -ExpandProperty PrimarySmtpAddress |
    Where-Object { $_ -match '@' } |
    Sort-Object -Unique

    Write-Host "`nUnique shared mailboxes loaded:" -ForegroundColor Cyan
    $SharedMailboxes

    # =======================================================
    # PROCESS EACH SHARED MAILBOX & STORE RESULTS
    # =======================================================

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


    # ====================================================
    # EXPORT INDIVIDUAL CSV PER SHARED MAILBOX
    # ====================================================

    $ExportRoot = "C:\SharedMailboxReports"

    if (-not (Test-Path $ExportRoot)) {
    New-Item -Path $ExportRoot -ItemType Directory | Out-Null
    }

    foreach ($Mailbox in $MailboxMemberMap.Keys) {

    $ExportData =
        $MailboxMemberMap[$Mailbox] |
        Group-Object User |
        ForEach-Object {
            [PSCustomObject]@{
                Mailbox   = $Mailbox
                MemberUPN = $_.Name
            }
        }

    $SafeName = $Mailbox -replace '@','_' -replace '\.','_'
    $Path = Join-Path $ExportRoot "$SafeName.csv"

    $ExportData |
        Export-Csv -Path $Path -NoTypeInformation -Encoding UTF8

    Write-Host "Exported:" $Path -ForegroundColor Green
    }

    # =================================
    # ENTRA ID USER DETAILS
    # =================================

    $MailboxUserDetails = @{}

    foreach ($Mailbox in $MailboxMemberMap.Keys) {

    $UserDetails = foreach ($Entry in $MailboxMemberMap[$Mailbox]) {

        $UserUPN = $Entry.User 

        try {
            $U = Get-MgUser -UserId $UserUPN -Property Id,DisplayName,JobTitle,Department
        }
        catch {
            Write-Host "Entra ID lookup failed for $UserUPN" -ForegroundColor Red
            continue
        }

        [PSCustomObject]@{
            Id          = $U.Id
            DisplayName = $U.DisplayName
            JobTitle    = $U.JobTitle
            Department  = $U.Department
            UserUPN     = $UserUPN
        }
    }

    $MailboxUserDetails[$Mailbox] = $UserDetails
    }   


    $MailboxUserDetails.GetEnumerator() |
    ForEach-Object {
    $Mailbox = $_.Key
    $_.Value | Select-Object @{n='Mailbox';e={$Mailbox}},
                               UserUPN, DisplayName, JobTitle, Department
    } | Export-Csv "C:\SharedMailboxReports\MailboxUserDetails.csv" `
    -NoTypeInformation -Encoding UTF8
    # ======================================
    # APPLY HIERARCHY PER MAILBOX
    # ======================================

    $MailboxHierarchyReports = @{}

    foreach ($Mailbox in $MailboxUserDetails.Keys) {

    $HierarchyReport = foreach ($User in $MailboxUserDetails[$Mailbox]) {

        $Depth = Get-HierarchyDepth -UserId $User.Id

        [PSCustomObject]@{
            DisplayName    = $User.DisplayName
            JobTitle       = $User.JobTitle
            Department     = $User.Department
            UserUPN        = $User.UserUPN
            HierarchyDepth = $Depth
            EvaluatedOn    = Get-Date
        }
    }

    $MailboxHierarchyReports[$Mailbox] = $HierarchyReport
    }

    $MailboxHierarchyReports.GetEnumerator() |
    ForEach-Object {
    $Mailbox = $_.Key
    foreach ($User in $_.Value) {
        [PSCustomObject]@{
            Mailbox        = $Mailbox
            UserUPN        = $User.UserUPN
            DisplayName    = $User.DisplayName
            JobTitle       = $User.JobTitle
            Department     = $User.Department
            HierarchyDepth = $User.HierarchyDepth
            EvaluatedOn    = $User.EvaluatedOn
        }
    }
    } |
    Export-Csv "C:\SharedMailboxReports\MailboxHierarchyReports.csv" `
    -NoTypeInformation -Encoding UTF8

    # ================================================
    # RELSOVE APPROVER PER SHARED MAILBOX
    # ================================================

    $MailboxApprovers = @{}

    foreach ($Mailbox in $MailboxHierarchyReports.Keys) {

    $Approver = Get-ApproverFromHierarchy `
        -HierarchyData $MailboxHierarchyReports[$Mailbox]

    $MailboxApprovers[$Mailbox] = $Approver
    }
 
    # ===================================
    # FINAL APPROVER REPORT
    # ===================================

    $FinalApproverReport = foreach ($Mailbox in $MailboxApprovers.Keys) {

    $A = $MailboxApprovers[$Mailbox]

    [PSCustomObject]@{
        Mailbox        = $Mailbox
        ApproverUPN    = $A.UserUPN
        DisplayName    = $A.DisplayName
        JobTitle       = $A.JobTitle
        Department     = $A.Department
        HierarchyDepth = $A.HierarchyDepth
    }
    }

    $FinalApproverReport |
    Export-Csv "C:\SharedMailboxReports\Mailbox_Approvers.csv" `
    -NoTypeInformation -Encoding UTF8

    
    catch {

    Write-Log `
    -Message $_ `
    -Level ERROR

    }


