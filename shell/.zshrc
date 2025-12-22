# Navigation
eval "$(zoxide init zsh)"

# Shared environment
[ -f "$HOME/.env" ] && source "$HOME/.env"

# History
HISTFILE=~/.zsh_history
HISTSIZE=10000
SAVEHIST=10000
setopt inc_append_history
setopt share_history

# FZF integration
source <(fzf --zsh)

# Oh My Zsh
export ZSH="$HOME/.oh-my-zsh"
ZSH_THEME="robbyrussell"
ENABLE_CORRECTION="true"

plugins=(git zsh-autosuggestions npm nvm sudo zsh-syntax-highlighting)

source $ZSH/oh-my-zsh.sh

# Custom function
fdcd() {
  cd "$(fd -t d . ~ | fzf)"
}
ff() {
  fd . ~ | fzf
}

bindkey -s '^G' 'fdcd\n'
