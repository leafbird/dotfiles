@echo off

@echo set home
setx HOME %homedrive%%homepath%

@echo create vimrc symbolic link
mklink %homedrive%%homepath%\_vimrc %homedrive%%homepath%\dotfiles\vim\_vimrc
mklink %homedrive%%homepath%\_gvimrc %homedrive%%homepath%\dotfiles\vim\_gvimrc

@echo create sublime-settings symbolic link
mklink "%appdata%\Sublime Text 2\Packages\User\Preferences.sublime-settings" %userprofile%\dotfiles\sublime\Preferences.sublime-settings
pause
