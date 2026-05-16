function Get-ApproverFromHierarchy {
    [CmdletBinding()]
    param (
        [Parameter(Mandatory)]
        [array]$HierarchyData
    )

    if (-not $HierarchyData -or $HierarchyData.Count -eq 0) {
        throw "Hierarchy data is empty."
    }

    $MinDepth = ($HierarchyData | Measure-Object HierarchyDepth -Minimum).Minimum

    $HierarchyData |
        Where-Object { $_.HierarchyDepth -eq $MinDepth } |
        Sort-Object JobTitle |
        Select-Object -First 1
}
