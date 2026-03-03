@echo off
setlocal enabledelayedexpansion
pushd "%~dp0"

set DOTFILES=%userprofile%\dotfiles

:: ------- gitconfig -------
if exist "%userprofile%\.gitconfig" (
    echo [SKIP] .gitconfig already exists
) else (
    mklink "%userprofile%\.gitconfig" "%DOTFILES%\git\.gitconfig" && echo [ OK ] .gitconfig || echo [FAIL] .gitconfig
)

:: ------- ssh config -------
set SSHDIR=%userprofile%\.ssh
if not exist "%SSHDIR%" mkdir "%SSHDIR%"

if exist "%SSHDIR%\config" (
    echo [SKIP] ssh config already exists
) else (
    echo.
    echo Select SSH config:
    echo   1^) home
    echo   2^) office
    set /p SSH_CHOICE="  Choice [1/2]: "
    if "!SSH_CHOICE!"=="1" (
        mklink "%SSHDIR%\config" "%DOTFILES%\ssh\config-home" && echo [ OK ] ssh config-home || echo [FAIL] ssh config
    ) else if "!SSH_CHOICE!"=="2" (
        mklink "%SSHDIR%\config" "%DOTFILES%\ssh\config-office" && echo [ OK ] ssh config-office || echo [FAIL] ssh config
    ) else (
        echo [WARN] invalid choice, skipping ssh config
    )
)

:: ------- vimrc -------
if exist "%userprofile%\_vimrc" (
    echo [SKIP] _vimrc already exists
) else (
    mklink "%userprofile%\_vimrc" "%DOTFILES%\vim\_vimrc" && echo [ OK ] _vimrc || echo [FAIL] _vimrc
)

if exist "%userprofile%\_gvimrc" (
    echo [SKIP] _gvimrc already exists
) else (
    mklink "%userprofile%\_gvimrc" "%DOTFILES%\vim\_gvimrc" && echo [ OK ] _gvimrc || echo [FAIL] _gvimrc
)

:: ------- powershell -------
where pwsh >nul 2>&1 && (
    pwsh "%DOTFILES%\pwsh\Setup.ps1" && echo [ OK ] pwsh || echo [FAIL] pwsh
) || (
    echo [INFO] pwsh not found, skipping
)

:: ------- neovim -------
if exist "%userprofile%\AppData\Local\nvim" (
    echo [SKIP] nvim already exists
) else (
    mklink /j "%userprofile%\AppData\Local\nvim" "%DOTFILES%\nvim\.config\nvim" && echo [ OK ] nvim || echo [FAIL] nvim
)

:: ------- wslconfig -------
if exist "%userprofile%\.wslconfig" (
    echo [SKIP] .wslconfig already exists
) else (
    mklink "%userprofile%\.wslconfig" "%DOTFILES%\wsl\.wslconfig" && echo [ OK ] .wslconfig || echo [FAIL] .wslconfig
)

:: ------- claude -------
if not exist "%userprofile%\.claude" mkdir "%userprofile%\.claude"
if exist "%userprofile%\.claude\settings.json" (
    echo [SKIP] claude settings.json already exists
) else (
    mklink "%userprofile%\.claude\settings.json" "%DOTFILES%\claude\.claude\settings.json" && echo [ OK ] claude settings.json || echo [FAIL] claude settings.json
)
if exist "%userprofile%\.claude\statusline-command.sh" (
    echo [SKIP] claude statusline-command.sh already exists
) else (
    mklink "%userprofile%\.claude\statusline-command.sh" "%DOTFILES%\claude\.claude\statusline-command.sh" && echo [ OK ] claude statusline-command.sh || echo [FAIL] claude statusline-command.sh
)

echo.
echo Done.
popd
endlocal
pause
