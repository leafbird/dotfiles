#!/bin/bash

# .ssh 폴더가 없으면 만듭니다.
if [ ! -d ~/.ssh ]; then
  mkdir ~/.ssh
fi

# ------- 기본 설정 : .zshrc, vim, git -------
mv ~/.zshrc ~/.zshrc.bak
mv ~/.oh-my-zsh/themes/agnoster.zsh-theme ~/.oh-my-zsh/themes/agnoster.zsh-theme.bak
mv ~/.gitconfig ~/.gitconfig.bak
mv ~/.vimrc ~/.vimrc.bak
mv ~/.ssh/config ~/.ssh/config.bak

ln -s ~/dotfiles/osx/.zshrc ~/.zshrc
ln -s ~/dotfiles/osx/agnoster.zsh-theme ~/.oh-my-zsh/themes/agnoster.zsh-theme 
ln -s ~/dotfiles/git/.gitconfig ~/.gitconfig
ln -s ~/dotfiles/vim/_vimrc ~/.vimrc
ln -s ~/dotfiles/ssh/config ~/.ssh/config

# ------- pwsh 설정 -------
pwsh ~/dotfiles/pwsh/setup.ps1

# nvim, starship 등은 stow로 개별 설정합니다.
