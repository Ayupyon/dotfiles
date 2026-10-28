#!/bin/sh
app_dir=$(CDPATH= cd -- "$(dirname "$0")" && pwd -P)
. "$app_dir/../scripts/install-common.sh"

# The repository's startup files load this directory explicitly, independently of XDG.
install_link "$app_dir/zshconfig.d" "$HOME/.config/zsh/zshconfig.d"
install_link "$app_dir/.zshenv" "${ZDOTDIR:-$HOME}/.zshenv"
install_link "$app_dir/.zshrc" "${ZDOTDIR:-$HOME}/.zshrc"
install_link "$app_dir/.zsh_plugins.txt" "${ZDOTDIR:-$HOME}/.zsh_plugins.txt"
