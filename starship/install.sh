#!/bin/sh
app_dir=$(CDPATH= cd -- "$(dirname "$0")" && pwd -P)
. "$app_dir/../scripts/install-common.sh"

install_link "$app_dir/starship.toml" "${STARSHIP_CONFIG:-$HOME/.config/starship.toml}"
