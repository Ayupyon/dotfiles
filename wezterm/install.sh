#!/bin/sh
app_dir=$(CDPATH= cd -- "$(dirname "$0")" && pwd -P)
. "$app_dir/../scripts/install-common.sh"

install_link "$app_dir/.wezterm.lua" "${WEZTERM_CONFIG_FILE:-${XDG_CONFIG_HOME:-$HOME/.config}/wezterm/wezterm.lua}"
