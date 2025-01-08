# 스크립트 파일의 경로를 가져와서 그 디렉터리로 이동
$scriptPath = $MyInvocation.MyCommand.Path
$scriptDirectory = Split-Path $scriptPath
Set-Location $scriptDirectory
# Write-Output "current directory: $scriptDirectory"

# --------------------------------------------

$sourcePath = ".\Microsoft.PowerShell_profile.ps1" | Resolve-Path
if (-Not (Test-Path -Path $sourcePath)) {
    Write-Error "파워쉘 프로필 파일이 존재하지 않습니다: $sourcePath"
    return
}

Write-Output "파워쉘 설정을 시작합니다. profile path: $profile"

# 백업할 프로필 파일의 경로와 백업 파일 경로를 설정합니다.
$backupPath = "$PROFILE.bak"

# 백업 파일이 이미 존재하면 덮어쓰지 않도록 합니다.
if (-Not (Test-Path -Path $backupPath -PathType Leaf)) {
    Copy-Item -Path $profile -Destination $backupPath
    Write-Host "기존 파워쉘 프로필을 백업했습니다: $backupPath"
} else {
    Write-Host "백업된 프로필 파일이 이미 존재합니다: $backupPath"
}

# dotfiles repository의 프로필 파일로 심볼릭 링크를 설정합니다.
New-Item -Path $profile -ItemType SymbolicLink -Value $sourcePath -Force

Write-Host "새로운 파워쉘 프로필 심볼릭 링크를 설정했습니다."
Write-Host "파워쉘을 다시 시작하여 새로운 프로필을 사용하세요."
