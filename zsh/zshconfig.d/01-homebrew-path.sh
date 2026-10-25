# install homebrew without root privilege:
# /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)" -- --path "$HOME/.homebrew"

export HOMEBREW_NO_SUDO=1

BREW_HOME="$HOME/.homebrew"
if [ -d $BREW_HOME ]; then
    eval "$($BREW_HOME/bin/brew shellenv zsh)"
fi

