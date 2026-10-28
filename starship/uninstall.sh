#!/bin/sh
app_dir=$(CDPATH= cd -- "$(dirname "$0")" && pwd -P)
. "$app_dir/../scripts/uninstall-common.sh"

uninstall_link "$app_dir/starship.toml" "${STARSHIP_CONFIG:-$HOME/.config/starship.toml}"
