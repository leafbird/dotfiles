#!/bin/bash

# ------- 기본 설정 : .zshrc, vim, git -------
mv ~/.zshrc ~/.zshrc.bak
mv ~/.oh-my-zsh/themes/agnoster.zsh-theme ~/.oh-my-zsh/themes/agnoster.zsh-theme.bak
mv ~/.gitconfig ~/.gitconfig.bak
mv ~/.vimrc ~/.vimrc.bak

ln -s ~/dotfiles/osx/.zshrc ~/.zshrc
ln -s ~/dotfiles/osx/agnoster.zsh-theme ~/.oh-my-zsh/themes/agnoster.zsh-theme 
ln -s ~/dotfiles/git/.gitconfig ~/.gitconfig
ln -s ~/dotfiles/vim/_vimrc ~/.vimrc

# ------- pwsh 설정 -------
pwsh ~/dotfiles/pwsh/setup.ps1

# ------- nvim 설정 -------
# ~/.config 아래에 nvim 폴더가 없으면 만듭니다.
if [ ! -d ~/.config/nvim ]; then
  mkdir ~/.config/nvim
fi

mv ~/.config/nvim/nvim.init ~/.config/nvim/nvim.init.bak
ln -s ~/dotfiles/vim/nvim.init ~/.config/nvim/nvim.init
