if command -v nvim >/dev/null 2>&1 && [ -d "$HOME/.local/share/nvim/mason/bin" ]; then
    export PATH="$HOME/.local/share/nvim/mason/bin:$PATH"
fi
