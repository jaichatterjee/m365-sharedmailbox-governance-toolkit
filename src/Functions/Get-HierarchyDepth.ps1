function Get-HierarchyDepth {
    [CmdletBinding()]
    param (
        [Parameter(Mandatory)]
        [string]$UserId
    )

    $Depth   = 0
    $Visited = @{}

    while ($true) {
        try {
            $Manager = Get-MgUserManager -UserId $UserId -ErrorAction Stop
        }
        catch {
            break
        }

        if (-not $Manager -or $Visited.ContainsKey($Manager.Id)) {
            break
        }

        $Visited[$Manager.Id] = $true
        $UserId = $Manager.Id
        $Depth++
    }

    return $Depth
}
