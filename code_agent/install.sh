#!/bin/sh
app_dir=$(CDPATH= cd -- "$(dirname "$0")" && pwd -P)
. "$app_dir/../scripts/install-common.sh"

install_link "$app_dir/AGENTS.md" "${CODEX_HOME:-$HOME/.codex}/AGENTS.md"

for skill_directory in "$app_dir"/skills/*; do
    [ -d "$skill_directory" ] || continue
    [ -f "$skill_directory/SKILL.md" ] || continue
    install_link "$skill_directory" "$HOME/.agents/skills/$(basename "$skill_directory")"
done
