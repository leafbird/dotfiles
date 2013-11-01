#!/bin/bash

echo "set bash configuration"
rm ~/.profile
rm ~/.bash_profile

ln -s ~/dotfiles/osx/.profile ~/.profile
ln -s ~/dotfiles/osx/.bash_profile ~/.bash_profile

echo "create gitconfig symbolic link"
ln -s ~/dotfiles/git/.gitconfig ~/.gitconfig

echo "create vimrc symbolic link"
ln -s ~/dotfiles/vim/_vimrc ~/.vimrc
ln -s ~/dotfiles/vim/_gvimrc ~/.gvimrc
