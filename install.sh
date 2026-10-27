#!/bin/sh
set -eu
repo_dir=$(CDPATH= cd -- "$(dirname "$0")" && pwd -P)

failed=
for app in herdr starship tmux wezterm zsh code_agent; do
    printf '\nInstalling %s configuration...\n' "$app"
    if ! sh "$repo_dir/$app/install.sh"; then
        failed="$failed $app"
    fi
done
if [ -n "$failed" ]; then
    printf 'Installation failed for:%s\n' "$failed" >&2
    exit 1
fi
