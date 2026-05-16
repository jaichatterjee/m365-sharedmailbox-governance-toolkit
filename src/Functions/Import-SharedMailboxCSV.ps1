function Import-SharedMailboxCSV {
    Add-Type -AssemblyName System.Windows.Forms

    $OpenFileDialog = New-Object System.Windows.Forms.OpenFileDialog
    $OpenFileDialog.Title = "Select Shared Mailbox CSV"
    $OpenFileDialog.Filter = "CSV Files (*.csv)|*.csv"
    $OpenFileDialog.InitialDirectory = "C:\"

    if ($OpenFileDialog.ShowDialog() -ne "OK") {
        throw "CSV selection cancelled."
    }

    $CsvPath = $OpenFileDialog.FileName
    $CsvData = Import-Csv -Path $CsvPath

    Write-Host "CSV imported successfully" -ForegroundColor Green
    Write-Host "Row count:" $CsvData.Count -ForegroundColor Cyan

    return $CsvData
}

$CSVData = Import-SharedMailboxCSV

$SharedMailboxes = $CSVData |
    Select-Object -ExpandProperty PrimarSmtpAddress |
    Where-Object { $_ -match '@' } |
    Sort-Object -Unique

Write-Host "`nUnique shared mailboxes loaded:" -ForegroundColor Cyan
$SharedMailboxes
