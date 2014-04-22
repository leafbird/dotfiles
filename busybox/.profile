
umask 022

#PATH=/sbin:/bin:/usr/sbin:/usr/bin:/usr/syno/sbin:/usr/syno/bin:/usr/local/sbin:/usr/local/bin
#export PATH

#This fixes the backspace when telnetting in.
#if [ "$TERM" != "linux" ]; then
#        stty erase
#fi

HOME=/volume1/homes/leafbird
export HOME

TERM=${TERM:-cons25}
export TERM

PAGER=more
export PAGER

PS1="\u:\w \$ "

alias dir="ls -al"
alias ll="ls -la"
alias vi="vim"
