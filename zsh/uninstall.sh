#!/bin/sh
app_dir=$(CDPATH= cd -- "$(dirname "$0")" && pwd -P)
. "$app_dir/../scripts/uninstall-common.sh"

uninstall_link "$app_dir/zshconfig.d" "$HOME/.config/zsh/zshconfig.d"
uninstall_link "$app_dir/.zshenv" "${ZDOTDIR:-$HOME}/.zshenv"
uninstall_link "$app_dir/.zshrc" "${ZDOTDIR:-$HOME}/.zshrc"
uninstall_link "$app_dir/.zsh_plugins.txt" "${ZDOTDIR:-$HOME}/.zsh_plugins.txt"
