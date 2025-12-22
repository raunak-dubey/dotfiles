# If not running interactively, don't do anything
[[ $- != *i* ]] && return

# Shared environment
[ -f "$HOME/.env" ] && source "$HOME/.env"

alias ls='ls --color=auto'
alias grep='grep --color=auto'

PS1='[\u@\h \W]\$ '
