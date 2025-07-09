param(
    [Parameter()]
    [Switch]$Delete,
    [Parameter()]
    [Switch]$Add,
    [Parameter()]
    [String]$NewPath
)

function Show-Menu {
    param (
        [string]$Title = 'Path 환경변수 관리'
    )
    Clear-Host
    Write-Host "=============== $Title ===============`n"
}

function Get-PathEntries {
    # 사용자 환경변수 Path 가져오기
    $userPath = [Environment]::GetEnvironmentVariable("Path", [EnvironmentVariableTarget]::User)
    $userEntries = $userPath -split ";" | Where-Object { $_ -ne "" }
    
    # 시스템 환경변수 Path 가져오기
    $systemPath = [Environment]::GetEnvironmentVariable("Path", [EnvironmentVariableTarget]::Machine)
    $systemEntries = $systemPath -split ";" | Where-Object { $_ -ne "" }
    
    # 결과 반환
    return @{
        "User" = $userEntries
        "System" = $systemEntries
    }
}

function Show-PathEntries {
    param (
        [Parameter(Mandatory=$true)]
        [hashtable]$Entries
    )
    
    $index = 1
    $pathMap = @{}
    
    # 사용자 Path 표시
    Write-Host "사용자 Path 환경변수:" -ForegroundColor Green
    foreach ($entry in $Entries.User) {
        Write-Host ("{0,3}: " -f $index) -NoNewline -ForegroundColor Cyan
        Write-Host "$entry [User]" -ForegroundColor Yellow
        $pathMap[$index] = @{
            "Path" = $entry
            "Type" = "User"
        }
        $index++
    }
    
    # 시스템 Path 표시
    Write-Host "`n시스템 Path 환경변수:" -ForegroundColor Green
    foreach ($entry in $Entries.System) {
        Write-Host ("{0,3}: " -f $index) -NoNewline -ForegroundColor Cyan
        Write-Host "$entry [System]" -ForegroundColor Magenta
        $pathMap[$index] = @{
            "Path" = $entry
            "Type" = "System"
        }
        $index++
    }
    
    return $pathMap
}

function Remove-PathEntry {
    param (
        [Parameter(Mandatory=$true)]
        [int]$Selection,
        [Parameter(Mandatory=$true)]
        [hashtable]$PathMap
    )
    
    if (-not $PathMap.ContainsKey($Selection)) {
        Write-Host "유효하지 않은 선택입니다: $Selection" -ForegroundColor Red
        return $false
    }
    
    $entry = $PathMap[$Selection]
    $pathType = $entry.Type
    $pathValue = $entry.Path
    
    # 환경변수 대상 설정
    $target = if ($pathType -eq "User") { [EnvironmentVariableTarget]::User } else { [EnvironmentVariableTarget]::Machine }
    
    # 관리자 권한 확인
    if ($pathType -eq "System" -and -not ([Security.Principal.WindowsPrincipal][Security.Principal.WindowsIdentity]::GetCurrent()).IsInRole([Security.Principal.WindowsBuiltInRole]::Administrator)) {
        Write-Host "시스템 환경변수를 수정하기 위해서는 관리자 권한이 필요합니다." -ForegroundColor Red
        return $false
    }
    
    # 현재 Path 가져오기
    $currentPath = [Environment]::GetEnvironmentVariable("Path", $target)
    $pathEntries = $currentPath -split ";" | Where-Object { $_ -ne "" -and $_ -ne $pathValue }
    
    # 새 Path 설정
    $newPath = $pathEntries -join ";"
    
    try {
        [Environment]::SetEnvironmentVariable("Path", $newPath, $target)
        Write-Host "`n성공적으로 제거되었습니다: $pathValue" -ForegroundColor Green
        return $true
    }
    catch {
        Write-Host "`n오류 발생: $_" -ForegroundColor Red
        return $false
    }
}

function Add-PathEntry {
    param (
        [Parameter(Mandatory=$true)]
        [string]$NewPath,
        [Parameter(Mandatory=$true)]
        [string]$PathType
    )
    
    # 환경변수 대상 설정
    $target = if ($PathType -eq "User") { [EnvironmentVariableTarget]::User } else { [EnvironmentVariableTarget]::Machine }
    
    # 관리자 권한 확인
    if ($PathType -eq "System" -and -not ([Security.Principal.WindowsPrincipal][Security.Principal.WindowsIdentity]::GetCurrent()).IsInRole([Security.Principal.WindowsBuiltInRole]::Administrator)) {
        Write-Host "시스템 환경변수를 수정하기 위해서는 관리자 권한이 필요합니다." -ForegroundColor Red
        return $false
    }
    
    # 현재 Path 가져오기
    $currentPath = [Environment]::GetEnvironmentVariable("Path", $target)
    
    # 중복 확인
    $pathEntries = $currentPath -split ";"
    if ($pathEntries -contains $NewPath) {
        Write-Host "`n지정한 경로는 이미 Path 환경변수에 존재합니다: $NewPath" -ForegroundColor Yellow
        return $false
    }
    
    # 새 Path 추가
    if ($currentPath.EndsWith(";")) {
        $newPath = $currentPath + $NewPath
    }
    else {
        $newPath = $currentPath + ";" + $NewPath
    }
    
    try {
        [Environment]::SetEnvironmentVariable("Path", $newPath, $target)
        Write-Host "`n성공적으로 추가되었습니다: $NewPath" -ForegroundColor Green
        return $true
    }
    catch {
        Write-Host "`n오류 발생: $_" -ForegroundColor Red
        return $false
    }
}

# 메인 로직
if ($Delete) {
    Show-Menu "Path 환경변수 삭제"
    
    # Path 항목 가져오기 및 표시
    $pathEntries = Get-PathEntries
    $pathMap = Show-PathEntries -Entries $pathEntries
    
    # 사용자 입력 받기
    Write-Host "`n삭제할 Path 항목 번호를 입력하세요 (취소: 0): " -NoNewline -ForegroundColor Green
    $selection = Read-Host
    
    # 취소 처리
    if ($selection -eq "0") {
        Write-Host "작업이 취소되었습니다." -ForegroundColor Yellow
        exit 0
    }
    
    # 입력 검증
    if (-not [int]::TryParse($selection, [ref]$null)) {
        Write-Host "유효한 숫자를 입력해야 합니다." -ForegroundColor Red
        exit 1
    }
    
    # Path 항목 삭제
    $result = Remove-PathEntry -Selection ([int]$selection) -PathMap $pathMap
    if (-not $result) {
        exit 1
    }
}
elseif ($Add) {
    Show-Menu "Path 환경변수 추가"
    
    if (-not $NewPath) {
        Write-Host "추가할 경로를 입력하세요: " -NoNewline -ForegroundColor Green
        $NewPath = Read-Host
        
        if ([string]::IsNullOrWhiteSpace($NewPath)) {
            Write-Host "경로가 지정되지 않았습니다. 작업이 취소되었습니다." -ForegroundColor Yellow
            exit 0
        }
    }
    
    # 경로 존재 확인
    if (-not (Test-Path -Path $NewPath -IsValid)) {
        Write-Host "유효하지 않은 경로입니다: $NewPath" -ForegroundColor Red
        exit 1
    }
    
    # 사용자/시스템 선택
    Write-Host "`n환경변수 유형을 선택하세요:" -ForegroundColor Green
    Write-Host "1: 사용자 환경변수" -ForegroundColor Yellow
    Write-Host "2: 시스템 환경변수" -ForegroundColor Magenta
    Write-Host "선택 (기본: 1): " -NoNewline -ForegroundColor Green
    $typeSelection = Read-Host
    
    $pathType = if ($typeSelection -eq "2") { "System" } else { "User" }
    
    # Path 항목 추가
    $result = Add-PathEntry -NewPath $NewPath -PathType $pathType
    if (-not $result) {
        exit 1
    }
}
else {
    Show-Menu "Path 환경변수 관리"
    
    # Path 항목 가져오기 및 표시
    $pathEntries = Get-PathEntries
    $pathMap = Show-PathEntries -Entries $pathEntries
    
    Write-Host "`n사용법:" -ForegroundColor Green
    Write-Host "  .\EditPath -Delete      : Path 환경변수 삭제" -ForegroundColor Yellow
    Write-Host "  .\EditPath -Add [-NewPath 경로]  : Path 환경변수 추가" -ForegroundColor Yellow
}