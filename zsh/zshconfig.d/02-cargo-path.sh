CARGO_HOME="$HOME/.cargo"

if command -v brew >/dev/null 2>&1 && brew --prefix --installed rustup &>/dev/null; then
    # homebrew managed rustup
    PATH=$(brew --prefix rustup)/bin:"${CARGO_HOME:-$HOME/.cargo}/bin":$PATH
elif [ -x $CARGO_HOME/env ]; then
    # official installer installed rustup
    . "$CARGO_HOME/env"
fi

