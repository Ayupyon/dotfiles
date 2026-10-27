#!/bin/sh
app_dir=$(CDPATH= cd -- "$(dirname "$0")" && pwd -P)
. "$app_dir/../scripts/install-common.sh"

install_link "$app_dir/config.toml" "${HERDR_CONFIG_PATH:-${XDG_CONFIG_HOME:-$HOME/.config}/herdr/config.toml}"
