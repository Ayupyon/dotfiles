# Created by newuser for 5.9

# plugins setting
ZSH_PLUGIN_DIR=/usr/share/zsh/plugins/
source $ZSH_PLUGIN_DIR/zsh-autosuggestions/zsh-autosuggestions.zsh
source $ZSH_PLUGIN_DIR/zsh-syntax-highlighting/zsh-syntax-highlighting.zsh

# history setting
HISTFILE=~/.zsh_history
HISTSIZE=10000
SAVEHIST=10000
setopt appendhistory

# alias setting
alias ls="ls --color=auto"

# PATH setting
PATH=$PATH:/home/rin/.local/bin

# enable oh-my-posh
eval "$(oh-my-posh init zsh --config ~/.config/oh-my-posh/onehalf.minimal.omp.json)"