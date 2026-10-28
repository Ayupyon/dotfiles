#!/bin/sh
app_dir=$(CDPATH= cd -- "$(dirname "$0")" && pwd -P)
. "$app_dir/../scripts/uninstall-common.sh"

uninstall_link "$app_dir/AGENTS.md" "${CODEX_HOME:-$HOME/.codex}/AGENTS.md"

# Inspect installed entries so removed repository skills can also be unlinked.
if [ -n "${ZSH_VERSION:-}" ]; then setopt NONOMATCH; fi
for skill_link in "$HOME/.agents/skills/"*; do
    [ -L "$skill_link" ] || continue
    uninstall_link "$app_dir/skills/$(basename "$skill_link")" "$skill_link"
done
