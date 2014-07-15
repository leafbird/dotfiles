@echo off

@echo create gitconfig symbolic link
mklink %userprofile%\.gitconfig %userprofile%\dotfiles\git\.gitconfig

@echo create vimrc symbolic link
mklink %userprofile%\_vimrc %userprofile%\dotfiles\vim\_vimrc
mklink %userprofile%\_gvimrc %userprofile%\dotfiles\vim\_gvimrc

@echo create sublime-settings symbolic link
if exist "%appdata%\Sublime Text 2\Packages\User\Preferences.sublime-settings" del "%appdata%\Sublime Text 2\Packages\User\Preferences.sublime-settings"
mklink "%appdata%\Sublime Text 2\Packages\User\Preferences.sublime-settings" %userprofile%\dotfiles\sublime\Preferences.sublime-settings

@echo crate blog commands
rem robocopy %userprofile%\dotfiles\blog %userprofile%\blog /NJH /NDL
rem mklink /J %userprofile%\blog %userprofile%\dotfiles\blog

pause
