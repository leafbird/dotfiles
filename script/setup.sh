#!/bin/bash

rm ~/.profile
rm ~/.bash_profile
rm ~/.gitconfig
rm ~/.vimrc
rm ~/Library/Application\ Support/Sublime\ Text\ 2/Packages/User/Preferences.sublime-settings

ln -s ~/dotfiles/osx/.profile ~/.profile
ln -s ~/dotfiles/osx/.bash_profile ~/.bash_profile
ln -s ~/dotfiles/git/.gitconfig ~/.gitconfig
ln -s ~/dotfiles/vim/_vimrc ~/.vimrc
ln -s ~/dotfiles/sublime/Preferences_mac.sublime-settings ~/Library/Application\ Support/Sublime\ Text\ 2/Packages/User/Preferences.sublime-settings

