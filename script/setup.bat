@echo off

@echo create gitconfig symbolic link
mklink %userprofile%\.gitconfig %userprofile%\dotfiles\git\.gitconfig

@echo create vimrc symbolic link
mklink %userprofile%\_vimrc %userprofile%\dotfiles\vim\_vimrc
mklink %userprofile%\_gvimrc %userprofile%\dotfiles\vim\_gvimrc

pause
