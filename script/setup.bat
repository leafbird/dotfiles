@echo off
pushd "%~dp0"

@echo create gitconfig symbolic link
mklink %userprofile%\.gitconfig %userprofile%\dotfiles\git\.gitconfig

@echo create ssh config symbolic link
set directory=%userprofile%\.ssh
if not exist "%directory%" (
    mkdir "%directory%"
)
mklink %directory%\config %userprofile%\dotfiles\ssh\config

@echo create vimrc symbolic link
mklink %userprofile%\_vimrc %userprofile%\dotfiles\vim\_vimrc
mklink %userprofile%\_gvimrc %userprofile%\dotfiles\vim\_gvimrc

pwsh ..\pwsh\setup.ps1

set directory=%userprofile%\.config\nvim
if not exist "%directory%" (
    mkdir "%directory%"
)

@echo create init.vim symbolic link
mklink %userprofile%\.config\nvim\init.vim %userprofile%\dotfiles\vim\nvim.init

popd
pause
