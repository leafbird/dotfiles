@echo off

@echo set home
setx HOME %userprofile%

@echo create gitconfig symbolic link
mklink %userprofile%\.gitconfig %userprofile%\dotfiles\git\.gitconfig

@echo create vimrc symbolic link
mklink %userprofile%\_vimrc %userprofile%\dotfiles\vim\_vimrc
mklink %userprofile%\_gvimrc %userprofile%\dotfiles\vim\_gvimrc

@echo create sublime-settings symbolic link
mklink "%appdata%\Sublime Text 2\Packages\User\Preferences.sublime-settings" %userprofile%\dotfiles\sublime\Preferences.sublime-settings
pause
