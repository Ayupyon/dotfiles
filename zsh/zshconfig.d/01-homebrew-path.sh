case "$OSTYPE" in
    linux*)
        # Install homebrew without root:
        # HOMEBREW_NO_SUDO=1 /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)" -- --path "$HOME/.homebrew"
        export HOMEBREW_NO_SUDO=1
        BREW_HOME="$HOME/.homebrew"
        ;;
    darwin*)
        if [[ "$(uname -m)" == arm64 ]]; then
            BREW_HOME="/opt/homebrew"
        else
            BREW_HOME="/usr/local"
        fi
        ;;
esac

if [[ -n "${BREW_HOME:-}" && -x "$BREW_HOME/bin/brew" ]]; then
    eval "$("$BREW_HOME/bin/brew" shellenv zsh)"
fi

