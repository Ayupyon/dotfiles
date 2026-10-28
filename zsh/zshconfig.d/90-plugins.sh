ANTIDOTE_ENTRY=$HOMEBREW_PREFIX/opt/antidote/share/antidote/antidote.zsh

if command -v brew >/dev/null 2>&1 && [[ -f $ANTIDOTE_ENTRY ]]; then
    source $ANTIDOTE_ENTRY

    autoload -Uz compinit
    compinit

    antidote load
fi
