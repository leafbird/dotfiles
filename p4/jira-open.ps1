param(
    [Parameter(Mandatory = $true)]
    [string]$Change
)

$ErrorActionPreference = 'Stop'
[Console]::OutputEncoding = [System.Text.Encoding]::UTF8
$OutputEncoding = [System.Text.Encoding]::UTF8

function Show-Info([string]$msg) {
    Add-Type -AssemblyName System.Windows.Forms
    [System.Windows.Forms.MessageBox]::Show($msg, 'p4 jira-open', 'OK', 'Information') | Out-Null
}
function Show-Error([string]$msg) {
    Add-Type -AssemblyName System.Windows.Forms
    [System.Windows.Forms.MessageBox]::Show($msg, 'p4 jira-open', 'OK', 'Error') | Out-Null
}

if (-not (Get-Command p4 -ErrorAction SilentlyContinue)) {
    Show-Error "p4.exe not found in PATH."
    exit 1
}

try {
    $spec = & p4 -C utf8 change -o $Change 2>&1
    if ($LASTEXITCODE -ne 0) {
        Show-Error "p4 change -o $Change failed:`n$($spec -join "`n")"
        exit 1
    }
} catch {
    Show-Error $_.Exception.Message
    exit 1
}

$desc = ($spec | Where-Object { $_ -match '^\t' }) -join "`n"
$match = [regex]::Match($desc, 'NF-\d+')
if (-not $match.Success) {
    Show-Info "CL $Change description 에 NF-#### 패턴이 없습니다."
    exit 0
}

$url = "https://madngine.atlassian.net/browse/$($match.Value)"
Start-Process $url
