# oh-my-posh init pwsh --config "$env:POSH_THEMES_PATH\atomic.omp.json" | Invoke-Expression

# starship
$ENV:STARSHIP_CONFIG = "$HOME\.config\starship.toml"
Invoke-Expression (&starship init powershell)

# alias
Set-Alias -Name vi -Value nvim
Set-Alias -Name vim -Value nvim

# rc 파일을 열고, 적용
function rc() { nvim $PROFILE }
function s() { . $PROFILE }

Write-Output "hello world"

# 디렉토리 이동
function mc() {
  mkdir -p $args[0]
  cd $args[0]
}

function h() { cd $env:USERPROFILE }
Set-Alias -Name c -Value "cls"
function l() { eza -lah }
function lt() { eza -lT }

# what is my ip
function myip() {
  curl http://ipecho.net/plain
}

# google
function google() {
  Start-Process "https://www.google.com/search?q=$args"
}

# git add, commit, push
# args[0]: commit message
# args[1]: branch name
#
# gitacp "commit message" "branch name"
# gitacp "update README.md" "main"
function gitacp() {
  git add .
  git commit -m "$args[0]"
  git push origin $args[1]
}


# fzf
$script:enableFzf = $false
function Enable-Fzf {
    if ($script:enableFzf) {
        Write-Host "Fzf가 이미 활성화되어 있습니다."
        return
    }

    $script:enableFzf = $true

    $script:stopwatch = [System.Diagnostics.Stopwatch]::StartNew()

    if (-not (Get-Module -ListAvailable -Name PsFzf)) {
        Write-Host "PsFzf 모듈을 설치합니다..."
        Install-Module -Name PsFzf -Scope CurrentUser -Force
    }

    Write-Host "탭 완성을 위한 설정을 추가합니다..."
    Set-PSReadLineKeyHandler -Key Tab -ScriptBlock { Invoke-FzfTabCompletion }
    Set-PsFzfOption -TabExpansion

    Write-Host "Ctrl+t / Ctrl+r 키 입력을 설정합니다..."
    Set-PsFzfOption -PSReadlineChordProvider 'Ctrl+t' -PSReadlineChordReverseHistory 'Ctrl+r'

    # Ensure posh-git module is installed and loaded
    if (-not (Get-Module -ListAvailable -Name posh-git)) {
        Write-Host "posh-git 모듈을 설치합니다..."
        Install-Module -Name posh-git -Scope CurrentUser -Force
    }

    Write-Host "posh-git 모듈을 로드합니다..."
    Import-Module -Name posh-git

    Write-Host "Fzf 활성화가 완료되었습니다."
    $script:stopwatch.Stop()
    Write-Host "소요 시간: $($script:stopwatch.ElapsedMilliseconds)ms"
}

if ($host.Name -eq 'ConsoleHost')
{
    Import-Module PSReadLine

	Set-PSReadLineOption -EditMode Windows
	Set-PSReadLineOption -PredictionViewStyle ListView
	Set-PSReadLineOption -PredictionSource HistoryAndPlugin
}
