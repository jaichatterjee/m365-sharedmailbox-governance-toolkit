function Connect-M365 {
    [CmdletBinding()]
    param ()

    try {
        Write-Host "Connecting to Microsoft Graph..."
        Connect-MgGraph -Scopes "User.Read.All","Directory.Read.All"

        Write-Host "Connecting to Exchange Online..."
        Connect-ExchangeOnline -ShowBanner:$false

        Write-Host "Microsoft 365 connections established successfully."
    }
    catch {
        Write-Error "Connection to Microsoft 365 failed. $_"
        throw
    }
}
