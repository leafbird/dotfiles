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

# 디렉토리 이동
function mc() {
  mkdir -p $args[0]
  cd $args[0]
}

function h() { cd $env:USERPROFILE }
Set-Alias -Name c -Value "cls"
function l() { eza -lah --icons=always }
function lt() { eza -lT --icons=always }

function sshconfig()
{
  Get-Content $env:USERPROFILE\.ssh\config | 
    Select-String -Raw "(?<=^Host\s).*" | 
    ForEach-Object { $_ -replace "^Host\s+", "ssh " } | 
    fzf | 
    Invoke-Expression

}

# what is my ip
function myip() {
  curl http://ipecho.net/plain
}

# google
function google() {
  Start-Process "https://www.google.com/search?q=$args"
}

# web
function web() {
  $url = $args -join " "

  # "http://" 또는 "https://"가 없으면 "https://"를 추가
  if (-not ($url -match "^(http://|https://)")) {
    $url = "https://$url"
  }

  Start-Process $url
}

# batdiff
function batdiff() {
  git diff --name-only --relative --diff-filter=d | ForEach-Object { bat --diff $_ }
}

# zoxide
Invoke-Expression (& { (zoxide init powershell | Out-String) })

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

<#
# translate below to powershell - not working. should define as function
alias gs='git rev-parse --git-dir > /dev/null 2>&1 && git status || eza'
alias ga='git add'
alias gaa='git add .'
alias gpo='git push -u origin'
alias gc='git commit -m'
alias gco='git checkout'
alias gb='git branch'
alias gba='git branch --all'
alias gbd='git branch -D'
alias gcp='git cherry-pick'
alias gd='git diff -w'
alias gu='git reset --soft HEAD~1'
alias gpr='git remote prune origin'
alias ff='gpr && git pull --ff-only'
alias grd='git fetch origin && git rebase origin/$(git rev-parse --abbrev-ref HEAD)'
alias gbb='git-switchbranch'
alias gbf='git branch | head -1 | xargs' # top branch
alias git-current-branch="git branch | grep \* | cut -d ' ' -f2"
alias grc='git rebase --continue'
alias gra='git rebase --abort'
alias gl='git log --oneline --graph --all'
#>

function gs() {
  # check if git directory
  if (git rev-parse --git-dir 2>$null) {
    git status
  } else {
    eza
  }
}

# fzf
$env:_PSFZF_FZF_DEFAULT_OPTS = '--height 40% --reverse --border --ansi --prompt "fzf> "'
# $env:_PSFZF_FZF_DEFAULT_OPTS = '--preview "bat --color=always --style=header,grid --line-range :500 {}"'

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
