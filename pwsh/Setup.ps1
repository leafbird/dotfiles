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

# dotfiles repository의 프로필 파일로 심볼릭 링크를 설정합니다.
New-Item -Path $profile -ItemType SymbolicLink -Value $sourcePath -Force

# $profile의 파일 이름을 'Microsoft.VSCode_profile.ps1'으로 변경
$vsCodeProfile = $profile -replace "Microsoft.PowerShell_profile.ps1", "Microsoft.VSCode_profile.ps1"
New-Item -Path $vsCodeProfile -ItemType SymbolicLink -Value $sourcePath -Force

Write-Host "새로운 파워쉘 프로필 심볼릭 링크를 설정했습니다."
Write-Host "파워쉘을 다시 시작하여 새로운 프로필을 사용하세요."
