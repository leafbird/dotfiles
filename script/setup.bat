@echo off

@echo set home
setx HOME %homedrive%%homepath%

@echo create vimrc symbolic link
mklink %homedrive%%homepath%\_vimrc %homedrive%%homepath%\dotfiles\vim\_vimrc
mklink %homedrive%%homepath%\_gvimrc %homedrive%%homepath%\dotfiles\vim\_gvimrc

pause
