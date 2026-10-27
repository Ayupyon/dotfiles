#!/bin/sh
app_dir=$(CDPATH= cd -- "$(dirname "$0")" && pwd -P)
. "$app_dir/../scripts/install-common.sh"

# Oh my tmux! reads its .local file alongside the main configuration.
main_config="$HOME/.tmux.conf"
if [ ! -f "$main_config" ]; then
    if [ -f "${XDG_CONFIG_HOME:-$HOME/.config}/tmux/tmux.conf" ]; then
        main_config="${XDG_CONFIG_HOME:-$HOME/.config}/tmux/tmux.conf"
    elif [ -f "$HOME/.config/tmux/tmux.conf" ]; then
        main_config="$HOME/.config/tmux/tmux.conf"
    fi
fi
install_link "$app_dir/tmux.conf.local" "$main_config.local"
if [ ! -f "$main_config" ]; then
    printf 'Note: install Oh my tmux! separately; %s is required to load this .local configuration.\n' "$main_config"
fi
