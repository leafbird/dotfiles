<#
.SYNOPSIS
    P4V 커스텀 툴 설치/갱신 — "슬랙 공유 포맷" · "Jira 이슈 열기"

.DESCRIPTION
    P4V 의 customtools.xml 에 두 커스텀 툴을 등록한다.

    · 기존 커스텀 툴은 보존한다. 같은 이름의 항목만 갈아끼운다.
    · 멱등하다. 이미 올바로 등록돼 있으면 파일을 건드리지 않는다.
    · .ps1 절대경로는 설치 시점에 이 머신 기준으로 박아 넣는다.
      (P4V 는 Arguments 안의 %USERPROFILE% 를 자기 치환토큰 %U 로 오해하므로
       환경변수를 쓸 수 없다.)

    로컬에 이 repo 가 있으면 그 자리의 .ps1 을 그대로 가리킨다.
    없으면(웹에서 바로 실행한 경우) GitHub 에서 받아 -ToolsDir 에 둔다.

.PARAMETER SourceDir
    slack-share.ps1 / jira-open.ps1 이 있는 폴더. 생략하면 자동 판단.

.PARAMETER ToolsDir
    웹에서 받아올 때 스크립트를 놓을 위치. 기본 %USERPROFILE%\.p4tools

.PARAMETER CustomToolsPath
    P4V 커스텀 툴 정의 파일. 기본 %USERPROFILE%\.p4qt\customtools.xml

.PARAMETER Force
    P4V 가 실행 중이어도 진행한다. 권장하지 않는다 — P4V 는 종료할 때
    이 파일을 자기 메모리 내용으로 되덮어쓰므로 설치가 날아간다.

.EXAMPLE
    irm https://raw.githubusercontent.com/leafbird/dotfiles/main/p4/install.ps1 | iex

.EXAMPLE
    .\install.ps1
#>
[CmdletBinding()]
param(
    [string]$SourceDir,
    [string]$ToolsDir        = (Join-Path $env:USERPROFILE '.p4tools'),
    [string]$CustomToolsPath = (Join-Path $env:USERPROFILE '.p4qt\customtools.xml'),
    [switch]$Force
)

$ErrorActionPreference = 'Stop'

# 팀원에게 뿌리는 설치 스크립트다. 실패는 스택트레이스가 아니라 한 줄로 보여준다.
$script:Wrote = $false
trap {
    Write-Host ''
    Write-Host "  설치 실패: $($_.Exception.Message)" -ForegroundColor Red
    if ($script:Wrote) {
        Write-Host "  customtools.xml 은 이미 갱신된 뒤입니다. 되돌리려면 백업을 쓰세요:" -ForegroundColor Red
        Write-Host "    $CustomToolsPath.bak" -ForegroundColor Red
    } else {
        Write-Host '  customtools.xml 은 건드리지 않았습니다.' -ForegroundColor Red
    }
    Write-Host ''
    exit 1
}

$RawBase = 'https://raw.githubusercontent.com/leafbird/dotfiles/main/p4'

# Name → 스크립트 파일명. Name 이 customtools.xml 안에서의 식별자다.
$Tools = [ordered]@{
    '슬랙 공유 포맷'  = 'slack-share.ps1'
    'Jira 이슈 열기' = 'jira-open.ps1'
}

function Write-Step([string]$msg) { Write-Host "  $msg" }
function Write-Ok  ([string]$msg) { Write-Host "  OK   $msg" -ForegroundColor Green }
function Write-Warn([string]$msg) { Write-Host "  경고 $msg" -ForegroundColor Yellow }

Write-Host ''
Write-Host 'P4V 커스텀 툴 설치' -ForegroundColor Cyan
Write-Host ''

# ── 1. P4V 가 떠 있으면 중단 ────────────────────────────────────────────────
# P4V 는 customtools.xml 을 시작할 때 읽고 종료할 때 되쓴다. 실행 중에 고치면
# 종료 시점에 예전 내용으로 덮여 설치가 조용히 사라진다.
$p4v = Get-Process -Name 'p4v' -ErrorAction SilentlyContinue
if ($p4v) {
    if (-not $Force) {
        Write-Host ''
        Write-Host '  P4V 가 실행 중입니다. 종료한 뒤 다시 실행해 주세요.' -ForegroundColor Red
        Write-Host '  (P4V 는 종료할 때 customtools.xml 을 되덮어쓰기 때문에,' -ForegroundColor Red
        Write-Host '   켜둔 채로 설치하면 설치 내용이 사라집니다.)' -ForegroundColor Red
        Write-Host ''
        exit 1
    }
    Write-Warn 'P4V 실행 중 — -Force 로 진행합니다. 설치 후 P4V 를 재시작하세요.'
}

# ── 2. 스크립트 위치 결정 ───────────────────────────────────────────────────
function Test-SourceDir([string]$dir) {
    if ([string]::IsNullOrWhiteSpace($dir)) { return $false }
    if (-not (Test-Path -LiteralPath $dir)) { return $false }
    foreach ($f in $Tools.Values) {
        if (-not (Test-Path -LiteralPath (Join-Path $dir $f))) { return $false }
    }
    return $true
}

if ($SourceDir) {
    if (-not (Test-SourceDir $SourceDir)) {
        throw "-SourceDir 에 slack-share.ps1 / jira-open.ps1 이 없습니다: $SourceDir"
    }
    $resolved = (Resolve-Path -LiteralPath $SourceDir).Path
    Write-Step "스크립트 위치 : $resolved (지정됨)"
}
elseif (Test-SourceDir $PSScriptRoot) {
    # repo 를 클론해 install.ps1 을 직접 실행한 경우. 그 자리를 그대로 쓴다.
    $resolved = (Resolve-Path -LiteralPath $PSScriptRoot).Path
    Write-Step "스크립트 위치 : $resolved (이 폴더)"
}
else {
    # irm | iex 로 웹에서 바로 실행한 경우. 받아온다.
    if (-not (Test-Path -LiteralPath $ToolsDir)) {
        $null = New-Item -ItemType Directory -Path $ToolsDir -Force
    }
    $resolved = (Resolve-Path -LiteralPath $ToolsDir).Path
    Write-Step "스크립트 위치 : $resolved (내려받음)"

    try { [Net.ServicePointManager]::SecurityProtocol = [Net.SecurityProtocolType]::Tls12 } catch {}

    foreach ($f in $Tools.Values) {
        $dst = Join-Path $resolved $f
        Invoke-WebRequest -Uri "$RawBase/$f" -OutFile $dst -UseBasicParsing
        Write-Ok "$f 받음"
    }
}

# ── 3. 등록할 항목 조립 ─────────────────────────────────────────────────────
$Command = 'powershell.exe'
$wanted = [ordered]@{}
foreach ($name in $Tools.Keys) {
    $path = Join-Path $resolved $Tools[$name]
    $wanted[$name] = "-NoProfile -ExecutionPolicy Bypass -WindowStyle Hidden -File $path -Change %c"
}

# ── 4. 기존 정의 읽기 ───────────────────────────────────────────────────────
$doc = New-Object System.Xml.XmlDocument
$doc.PreserveWhitespace = $false
$existed = Test-Path -LiteralPath $CustomToolsPath

if ($existed) {
    try {
        $doc.Load($CustomToolsPath)
    } catch {
        throw "customtools.xml 을 읽지 못했습니다 ($CustomToolsPath): $($_.Exception.Message)"
    }
    if (-not $doc.DocumentElement -or $doc.DocumentElement.Name -ne 'CustomToolDefList') {
        throw "customtools.xml 형식이 예상과 다릅니다 (루트=$($doc.DocumentElement.Name))."
    }
} else {
    $null = $doc.AppendChild($doc.CreateXmlDeclaration('1.0', 'UTF-8', $null))
    $null = $doc.AppendChild($doc.CreateComment('perforce-xml-version=1'))
    $root = $doc.CreateElement('CustomToolDefList')
    $root.SetAttribute('varName', 'customtooldeflist')
    $null = $doc.AppendChild($root)
}
$root = $doc.DocumentElement

# 자식 요소 접근은 반드시 인덱서로. $node.Definition.Name 은 자식 <Name> 이 아니라
# XmlElement 자신의 .Name 속성("Definition")을 돌려준다 — 조용히 틀린다.
function Get-Child([System.Xml.XmlElement]$el, [string]$name) {
    if (-not $el) { return $null }
    $c = $el[$name]
    if ($c) { return $c.InnerText } else { return $null }
}

function Find-ToolNode([string]$name) {
    foreach ($n in $root.SelectNodes('CustomToolDef')) {
        $def = $n['Definition']
        if ((Get-Child $def 'Name') -eq $name) { return $n }
    }
    return $null
}

# ── 5. 이미 최신이면 아무것도 하지 않는다 (멱등) ────────────────────────────
$current = $true
foreach ($name in $wanted.Keys) {
    $node = Find-ToolNode $name
    if (-not $node) { $current = $false; break }
    $def = $node['Definition']
    if ((Get-Child $def 'Command')   -ne $Command)      { $current = $false; break }
    if ((Get-Child $def 'Arguments') -ne $wanted[$name]) { $current = $false; break }
    if ((Get-Child $node 'AddToContext') -ne 'true')     { $current = $false; break }
}

if ($current) {
    Write-Host ''
    Write-Ok '이미 최신 상태입니다. 변경한 것 없음.'
    Write-Host "       $CustomToolsPath"
    Write-Host ''
    exit 0
}

# ── 6. 백업 ─────────────────────────────────────────────────────────────────
# 실제로 바꿀 때만 뜬다. 멱등 실행에서는 백업도 생기지 않는다.
if ($existed) {
    $bak = "$CustomToolsPath.bak"
    Copy-Item -LiteralPath $CustomToolsPath -Destination $bak -Force
    Write-Step "백업          : $bak"

    $others = @()
    foreach ($n in $root.SelectNodes('CustomToolDef')) {
        $nm = Get-Child $n['Definition'] 'Name'
        if ($nm -and -not $wanted.Contains($nm)) { $others += $nm }
    }
    if ($others.Count -gt 0) {
        Write-Step "보존할 기존 툴: $($others -join ', ')"
    }
}

# ── 7. 우리 항목만 교체 ─────────────────────────────────────────────────────
function New-ToolNode([string]$name, [string]$arguments) {
    $def = $doc.CreateElement('CustomToolDef')

    $d = $doc.CreateElement('Definition')
    foreach ($pair in @(@('Name', $name), @('Command', $Command), @('Arguments', $arguments), @('Shortcut', ''))) {
        $e = $doc.CreateElement($pair[0])
        $e.InnerText = $pair[1]
        $null = $d.AppendChild($e)
    }
    $null = $def.AppendChild($d)

    $con = $doc.CreateElement('Console')
    $ce = $doc.CreateElement('CloseOnExit')
    $ce.InnerText = 'true'
    $null = $con.AppendChild($ce)
    $null = $def.AppendChild($con)

    $ac = $doc.CreateElement('AddToContext')
    $ac.InnerText = 'true'
    $null = $def.AppendChild($ac)

    return $def
}

foreach ($name in $wanted.Keys) {
    $old = Find-ToolNode $name
    $new = New-ToolNode $name $wanted[$name]
    if ($old) {
        $null = $root.ReplaceChild($new, $old)   # 순서 유지
        Write-Ok "$name — 갱신"
    } else {
        $null = $root.AppendChild($new)
        Write-Ok "$name — 추가"
    }
}

# ── 8. 저장 (BOM 없는 UTF-8 · LF — P4V 가 쓰는 형태) ────────────────────────
$dir = Split-Path -Parent $CustomToolsPath
if ($dir -and -not (Test-Path -LiteralPath $dir)) {
    $null = New-Item -ItemType Directory -Path $dir -Force
}

$settings = New-Object System.Xml.XmlWriterSettings
$settings.Encoding       = New-Object System.Text.UTF8Encoding($false)
$settings.Indent         = $true
$settings.IndentChars    = '  '
$settings.NewLineChars   = "`n"
$settings.OmitXmlDeclaration = $false

$writer = [System.Xml.XmlWriter]::Create($CustomToolsPath, $settings)
try {
    $doc.Save($writer)
} finally {
    $writer.Dispose()
}
$script:Wrote = $true
Write-Step "저장          : $CustomToolsPath"

# ── 9. 환경 점검 ────────────────────────────────────────────────────────────
# 여기서부터는 설치가 이미 끝났다. 점검이 실패해도 설치를 실패로 보고하지 않는다.
Write-Host ''
if (-not (Get-Command p4 -ErrorAction SilentlyContinue)) {
    Write-Warn 'p4.exe 가 PATH 에 없습니다. 두 도구 모두 p4 CLI 를 씁니다.'
    Write-Warn '     보통 C:\Program Files\Perforce 입니다.'
} else {
    try {
        $charset = (& p4 set P4CHARSET 2>$null) -join ''
        if ($charset -notmatch 'utf8') {
            Write-Warn "P4CHARSET 이 utf8 이 아닙니다. 한글 description 이 깨질 수 있습니다."
            Write-Warn '     고치려면: p4 set P4CHARSET=utf8'
        }
    } catch {
        Write-Warn "P4CHARSET 을 확인하지 못했습니다: $($_.Exception.Message)"
    }
}

Write-Host ''
Write-Host '  완료. P4V 를 (다시) 실행하고 Submitted CL 을 우클릭하세요.' -ForegroundColor Cyan
Write-Host ''

# 명시적으로 0. 이게 없으면 직전 네이티브 명령의 종료코드가 그대로 남아,
# p4.exe 가 없는 자리에서는 설치가 성공해도 실패로 읽힌다.
exit 0
