#!/bin/bash

mv ~/.zshrc ~/.zshrc.bak
mv ~/.oh-my-zsh/themes/agnoster.zsh-theme ~/.oh-my-zsh/themes/agnoster.zsh-theme.bak
mv ~/.gitconfig ~/.gitconfig.bak
mv ~/.vimrc ~/.vimrc.bak

ln -s ~/dotfiles/osx/.zshrc ~/.zshrc
ln -s ~/dotfiles/osx/agnoster.zsh-theme ~/.oh-my-zsh/themes/agnoster.zsh-theme 
ln -s ~/dotfiles/git/.gitconfig ~/.gitconfig
ln -s ~/dotfiles/vim/_vimrc ~/.vimrc

pwsh ../pwsh/setup.ps1