#!/usr/bin/env pwsh
# Install markdown-white.css + .vscode/settings.json into a repo.
#
# Usage:
#   ./install-to-repo.ps1              # current directory
#   ./install-to-repo.ps1 <repo-path>
#
# Copies CSS to <repo>/.vscode/markdown-white.css and merges
# "markdown.styles": [".vscode/markdown-white.css"] into
# <repo>/.vscode/settings.json (preserves other keys).

[CmdletBinding()]
param(
    [string]$Target = "."
)

$ErrorActionPreference = "Stop"

$ScriptDir = Split-Path -Parent $MyInvocation.MyCommand.Path
$CssSrc = Join-Path $ScriptDir "markdown-white.css"

if (-not (Test-Path -LiteralPath $CssSrc -PathType Leaf)) {
    Write-Error "CSS not found: $CssSrc"
    exit 1
}
if (-not (Test-Path -LiteralPath $Target -PathType Container)) {
    Write-Error "target directory not found: $Target"
    exit 1
}

$Target   = (Resolve-Path -LiteralPath $Target).Path
$VsDir    = Join-Path $Target ".vscode"
$CssDst   = Join-Path $VsDir "markdown-white.css"
$Settings = Join-Path $VsDir "settings.json"

New-Item -ItemType Directory -Force -Path $VsDir | Out-Null
Copy-Item -LiteralPath $CssSrc -Destination $CssDst -Force
Write-Output "wrote: $CssDst"

$desired = @(".vscode/markdown-white.css")

# Read existing settings (tolerant of comments / trailing commas), then merge.
$data = [ordered]@{}
if (Test-Path -LiteralPath $Settings -PathType Leaf) {
    $raw = Get-Content -LiteralPath $Settings -Raw -Encoding UTF8
    # strip /* block */ comments
    $raw = [regex]::Replace($raw, "/\*.*?\*/", "", [System.Text.RegularExpressions.RegexOptions]::Singleline)
    # strip // line comments
    $raw = [regex]::Replace($raw, "(^|\s)//[^\n]*", '$1')
    # strip trailing commas
    $raw = [regex]::Replace($raw, ",(\s*[}\]])", '$1')
    if ($raw.Trim()) {
        $obj = $raw | ConvertFrom-Json
        foreach ($prop in $obj.PSObject.Properties) {
            $data[$prop.Name] = $prop.Value
        }
    }
}

$current = $data["markdown.styles"]
if ($null -ne $current -and (Compare-Object $current $desired -SyncWindow 0) -eq $null) {
    Write-Output "unchanged: $Settings"
    exit 0
}

$data["markdown.styles"] = $desired
$json = ($data | ConvertTo-Json -Depth 20)
# write with trailing newline, UTF-8 (no BOM)
[System.IO.File]::WriteAllText($Settings, $json + "`n", (New-Object System.Text.UTF8Encoding $false))
Write-Output "wrote: $Settings"
