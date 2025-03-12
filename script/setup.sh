#!/bin/bash

# .ssh 폴더가 없으면 만듭니다.
if [ ! -d ~/.ssh ]; then
  mkdir ~/.ssh
fi

# ------- 기본 설정 : git, ssh config -------
mv ~/.gitconfig ~/.gitconfig.bak
mv ~/.ssh/config ~/.ssh/config.bak

ln -s ~/dotfiles/git/.gitconfig ~/.gitconfig
ln -s ~/dotfiles/ssh/config ~/.ssh/config

# ------- pwsh 설정 -------
pwsh ~/dotfiles/pwsh/setup.ps1

# nvim, starship 등은 stow로 개별 설정합니다.
