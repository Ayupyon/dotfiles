#!/bin/sh
app_dir=$(CDPATH= cd -- "$(dirname "$0")" && pwd -P)
. "$app_dir/../scripts/uninstall-common.sh"

# Check every supported location even if the main configuration has been removed.
uninstall_link "$app_dir/tmux.conf.local" "$HOME/.tmux.conf.local"
if [ -n "${XDG_CONFIG_HOME:-}" ] && [ "$XDG_CONFIG_HOME" != "$HOME/.config" ]; then
    uninstall_link "$app_dir/tmux.conf.local" "$XDG_CONFIG_HOME/tmux/tmux.conf.local"
fi
uninstall_link "$app_dir/tmux.conf.local" "$HOME/.config/tmux/tmux.conf.local"
