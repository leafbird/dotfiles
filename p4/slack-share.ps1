param(
    [Parameter(Mandatory = $true)]
    [string]$Change
)

$ErrorActionPreference = 'Stop'
[Console]::OutputEncoding = [System.Text.Encoding]::UTF8
$OutputEncoding = [System.Text.Encoding]::UTF8

$logPath = Join-Path $PSScriptRoot 'slack-share.log'
function Write-Log([string]$msg) {
    "$([DateTime]::Now.ToString('s'))  $msg" | Out-File -FilePath $logPath -Append -Encoding utf8
}

function Show-Error([string]$msg) {
    Write-Log "ERROR: $msg"
    Add-Type -AssemblyName System.Windows.Forms
    [System.Windows.Forms.MessageBox]::Show($msg, 'p4 slack-share', 'OK', 'Error') | Out-Null
}

Write-Log "Invoked with Change=$Change"

$p4 = (Get-Command p4 -ErrorAction SilentlyContinue)
if (-not $p4) {
    Show-Error "p4.exe not found in PATH.`nPATH=$env:Path"
    exit 1
}
Write-Log "p4 = $($p4.Source)"

try {
    $spec = & p4 -C utf8 change -o $Change 2>&1
    if ($LASTEXITCODE -ne 0) {
        Show-Error "p4 change -o $Change failed (exit=$LASTEXITCODE):`n$($spec -join "`n")"
        exit 1
    }
} catch {
    Show-Error $_.Exception.Message
    exit 1
}

$user = ''
$date = ''
$desc = New-Object System.Collections.Generic.List[string]
$inDesc = $false

foreach ($line in $spec) {
    if (-not $inDesc) {
        if ($line -match '^User:\s+(.+)$')        { $user = $matches[1].Trim(); continue }
        if ($line -match '^Date:\s+(.+)$')        { $date = $matches[1].Trim(); continue }
        if ($line -match '^Description:\s*$')     { $inDesc = $true; continue }
    } else {
        if ($line -match '^[A-Za-z][A-Za-z0-9]*:\s') { $inDesc = $false; continue }
        if ($line -match '^\t(.*)$')                 { $desc.Add($matches[1]); continue }
        if ($line.Trim() -eq '')                     { $desc.Add(''); continue }
    }
}

while ($desc.Count -gt 0 -and $desc[$desc.Count - 1].Trim() -eq '') {
    $desc.RemoveAt($desc.Count - 1)
}

$dateFormatted = $date
if ($date -match '^(\d{4})/(\d{2})/(\d{2})\s+(\d{2}):(\d{2}):(\d{2})$') {
    $dt = Get-Date -Year $matches[1] -Month $matches[2] -Day $matches[3] `
                   -Hour $matches[4] -Minute $matches[5] -Second $matches[6]
    $ampm = if ($dt.Hour -ge 12) { 'PM' } else { 'AM' }
    $hour12 = $dt.Hour % 12
    if ($hour12 -eq 0) { $hour12 = 12 }
    $dateFormatted = '{0:yyyy-MM-dd} {1} {2}:{3:00}' -f $dt, $ampm, $hour12, $dt.Minute
}

$lines = @()
$lines += '```'
$lines += "Change: $Change"
$lines += "Date: $dateFormatted"
$lines += "User: $user"
$lines += 'Description:'
$lines += $desc
$lines += '```'

$text = ($lines -join "`r`n")
Set-Clipboard -Value $text
Write-Log "OK: copied $($text.Length) chars to clipboard"
