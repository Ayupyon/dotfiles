## set network proxy (dafault use localhost:7890)
PROXY_URL=http://127.0.0.1:7890

proxy_on() {
    export http_proxy=$PROXY_URL
    export https_proxy=$PROXY_URL
    echo "turn on http proxy with url: $PROXY_URL"
}

proxy_off() {
    unset http_proxy
    unset https_proxy
}

## set a list of custom installed app path
export PATH=$PATH

## set aliases
alias ls="ls --color=auto"

## enable zsh history
HISTFILE=~/.zsh_history
HISTSIZE=10000
SAVEHIST=10000

## setup zsh plugins
PLUGIN_HOME=~/.zsh_plugins
source $PLUGIN_HOME/zsh-autosuggestions/zsh-autosuggestions.zsh
source $PLUGIN_HOME/zsh-syntax-highlighting/zsh-syntax-highlighting.zsh

## set shell prompt (default use starship)
eval "$(starship init zsh)"

