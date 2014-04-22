#!/bin/bash

rm ~/.profile
rm ~/.gitconfig
rm ~/.vimrc

ln -s ~/dotfiles/busybox/.profile ~/.profile
ln -s ~/dotfiles/git/.gitconfig ~/.gitconfig
ln -s ~/dotfiles/vim/_vimrc ~/.vimrc

