#!/bin/bash

rm ~/.zshrc
rm ~/.gitconfig
rm ~/.vimrc

ln -s ~/dotfiles/osx/.zshrc ~/.zshrc
ln -s ~/dotfiles/git/.gitconfig ~/.gitconfig
ln -s ~/dotfiles/vim/_vimrc ~/.vimrc

