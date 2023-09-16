#!/bin/bash

rm ~/.profile
rm ~/.bash_profile
rm ~/.gitconfig
rm ~/.vimrc

ln -s ~/dotfiles/osx/.profile ~/.profile
ln -s ~/dotfiles/osx/.bash_profile ~/.bash_profile
ln -s ~/dotfiles/git/.gitconfig ~/.gitconfig
ln -s ~/dotfiles/vim/_vimrc ~/.vimrc

