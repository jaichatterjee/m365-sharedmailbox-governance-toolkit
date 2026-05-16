function Write-Log {
    [CmdletBinding()]
    param (
        [Parameter(Mandatory)]
        [string]$Message,

        [ValidateSet("INFO","WARN","ERROR")]
        [string]$Level="INFO"
    )

    $timestamp = Get-Date -Format "yyyy-MM-dd HH:mm:ss"

    $logMessage = "$timestamp [$Level] $Message"

    Write-Host $logMessage

    if ($Global:GovernanceConfig.LogPath) {

        if (!(Test-Path $Global:GovernanceConfig.LogPath)) {

            New-Item `
                -Path $Global:GovernanceConfig.LogPath `
                -ItemType Directory | Out-Null
        }

        Add-Content `
            -Path (
                Join-Path `
                $Global:GovernanceConfig.LogPath `
                "governance.log"
            ) `
            -Value $logMessage
    }
}
