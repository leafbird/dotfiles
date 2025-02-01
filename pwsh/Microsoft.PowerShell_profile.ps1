oh-my-posh init pwsh --config "$env:POSH_THEMES_PATH\atomic.omp.json" | Invoke-Expression

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