@echo off
setlocal enabledelayedexpansion
pushd "%~dp0\.."

set "DOTFILES=%CD%"

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
set "CLAUDE_ROOT=%DOTFILES%\claude\.claude"
set "CLAUDE_MD_SOURCE=%CLAUDE_ROOT%\CLAUDE.md"
if not exist "%CLAUDE_MD_SOURCE%" set "CLAUDE_MD_SOURCE=%DOTFILES%\claude-shared\CLAUDE.md"

if not exist "%userprofile%\.claude" mkdir "%userprofile%\.claude"
if exist "%userprofile%\.claude\settings.json" (
    echo [SKIP] claude settings.json already exists
) else if not exist "%CLAUDE_ROOT%\settings.json" (
    echo [SKIP] claude settings.json source missing
) else (
    mklink "%userprofile%\.claude\settings.json" "%CLAUDE_ROOT%\settings.json" && echo [ OK ] claude settings.json || echo [FAIL] claude settings.json
)
if exist "%userprofile%\.claude\statusline-command.sh" (
    echo [SKIP] claude statusline-command.sh already exists
) else if not exist "%CLAUDE_ROOT%\statusline-command.sh" (
    echo [SKIP] claude statusline-command.sh source missing
) else (
    mklink "%userprofile%\.claude\statusline-command.sh" "%CLAUDE_ROOT%\statusline-command.sh" && echo [ OK ] claude statusline-command.sh || echo [FAIL] claude statusline-command.sh
)
if exist "%userprofile%\.claude\CLAUDE.md" (
    echo [SKIP] claude CLAUDE.md already exists
) else if not exist "%CLAUDE_MD_SOURCE%" (
    echo [SKIP] claude CLAUDE.md source missing
) else (
    mklink "%userprofile%\.claude\CLAUDE.md" "%CLAUDE_MD_SOURCE%" && echo [ OK ] claude CLAUDE.md || echo [FAIL] claude CLAUDE.md
)
if not exist "%userprofile%\.claude\skills" mkdir "%userprofile%\.claude\skills"
if exist "%userprofile%\.claude\skills\confluence" (
    echo [SKIP] claude skills/confluence already exists
) else if not exist "%CLAUDE_ROOT%\skills\confluence" (
    echo [SKIP] claude skills/confluence source missing
) else (
    mklink /d "%userprofile%\.claude\skills\confluence" "%CLAUDE_ROOT%\skills\confluence" && echo [ OK ] claude skills/confluence || echo [FAIL] claude skills/confluence
)

:: ------- autohotkey: esc_force_english (vim) -------
set "AHK_EXE=C:\Program Files\AutoHotkey\AutoHotkeyU64.exe"
if not exist "%AHK_EXE%" set "AHK_EXE=C:\Program Files\AutoHotkey\AutoHotkey.exe"
set "AHK_SCRIPT=%DOTFILES%\vim\esc_force_english.ahk"
set "AHK_LNK=%APPDATA%\Microsoft\Windows\Start Menu\Programs\Startup\esc_force_english.lnk"
if exist "%AHK_LNK%" (
    echo [SKIP] esc_force_english startup shortcut already exists
) else if not exist "%AHK_EXE%" (
    echo [SKIP] AutoHotkey v1 not installed ^(winget install AutoHotkey.AutoHotkey --version 1.1.37.02^)
) else (
    powershell -NoProfile -Command "$w=New-Object -ComObject WScript.Shell; $s=$w.CreateShortcut('%AHK_LNK%'); $s.TargetPath='%AHK_EXE%'; $s.Arguments='\"%AHK_SCRIPT%\"'; $s.WorkingDirectory='%DOTFILES%\vim'; $s.Save()" && echo [ OK ] esc_force_english startup shortcut || echo [FAIL] esc_force_english startup shortcut
)

echo.
echo Done.
popd
endlocal
pause
