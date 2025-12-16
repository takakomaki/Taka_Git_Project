param(
    [Parameter(Mandatory = $false)]
    [string]$Path = ".",

    [Parameter(Mandatory = $false)]
    [string]$OutputFile = "TREE_UTF8.txt",

    [Parameter(Mandatory = $false)]
    [switch]$ExcludeGit = $true,

    [Parameter(Mandatory = $false)]
    [switch]$Ascii
)

$ErrorActionPreference = "Stop"

# Ensure UTF-8 output (no BOM) so Japanese paths are not garbled in files/logs.
$utf8NoBom = [System.Text.UTF8Encoding]::new($false)
[Console]::OutputEncoding = $utf8NoBom
$OutputEncoding = $utf8NoBom

function Get-TreeLines {
    param(
        [Parameter(Mandatory = $true)]
        [string]$RootPath,

        [Parameter(Mandatory = $false)]
        [string]$Prefix = ""
    )

    $lines = New-Object System.Collections.Generic.List[string]

    $items =
        Get-ChildItem -LiteralPath $RootPath -Force |
        Where-Object { -not $ExcludeGit -or $_.Name -ne ".git" } |
        Sort-Object @{ Expression = { $_.PSIsContainer }; Descending = $true }, Name

    for ($i = 0; $i -lt $items.Count; $i++) {
        $item = $items[$i]
        $isLast = ($i -eq $items.Count - 1)

        if ($Ascii) {
            $connector = $(if ($isLast) { "`-- " } else { "|-- " })
            $nextPrefix = $Prefix + $(if ($isLast) { "    " } else { "|   " })
        }
        else {
            $connector = $(if ($isLast) { "└── " } else { "├── " })
            $nextPrefix = $Prefix + $(if ($isLast) { "    " } else { "│   " })
        }

        $lines.Add($Prefix + $connector + $item.Name)

        if ($item.PSIsContainer) {
            $childLines = Get-TreeLines -RootPath $item.FullName -Prefix $nextPrefix
            foreach ($l in $childLines) { $lines.Add($l) }
        }
    }

    return $lines
}

$resolved = (Resolve-Path -LiteralPath $Path).Path
$rootName = Split-Path -Leaf $resolved

$all = New-Object System.Collections.Generic.List[string]
$all.Add($rootName)

$tree = Get-TreeLines -RootPath $resolved -Prefix ""
foreach ($l in $tree) { $all.Add($l) }

if (-not [string]::IsNullOrWhiteSpace($OutputFile)) {
    Set-Content -LiteralPath $OutputFile -Value $all -Encoding utf8NoBOM
}

$all


