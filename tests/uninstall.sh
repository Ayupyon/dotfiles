#!/bin/sh
# Run: sh ./tests/uninstall.sh
set -eu
test_dir=$(CDPATH= cd -- "$(dirname "$0")" && pwd -P)
repo_dir=$(CDPATH= cd -- "$test_dir/.." && pwd -P)
. "$repo_dir/scripts/uninstall-common.sh"
test_root=$(mktemp -d "${TMPDIR:-/tmp}/dotfiles-uninstall-XXXXXXXX")
test_root=$(CDPATH= cd -- "$test_root" && pwd -P)
trap 'rm -rf "$test_root"' EXIT

fail() { printf '%s\n' "$1" >&2; exit 1; }
assert_absent() { [ ! -e "$1" ] && [ ! -L "$1" ] || fail "Entry remains: $1"; }

source_path="$test_root/source file"
target_path="$test_root/target file"
printf 'repository\n' > "$source_path"
ln -s "$source_path" "$target_path"
uninstall_link "$source_path" "$target_path"
assert_absent "$target_path"
uninstall_link "$source_path" "$target_path"
[ "$(cat "$source_path")" = repository ] || fail 'Source file changed'

printf 'original\n' > "$target_path"
uninstall_link "$source_path" "$target_path"
[ "$(cat "$target_path")" = original ] || fail 'Regular file changed'
mkdir "$test_root/regular directory"
uninstall_link "$source_path" "$test_root/regular directory"
[ -d "$test_root/regular directory" ] || fail 'Regular directory removed'

ln -s "$test_root/unrelated missing source" "$test_root/unrelated link"
uninstall_link "$source_path" "$test_root/unrelated link"
[ -L "$test_root/unrelated link" ] || fail 'Unrelated broken link removed'
ln -s "$source_path" "$test_root/retained link"
uninstall_link "$test_root/another source" "$test_root/retained link"
[ -L "$test_root/retained link" ] || fail 'Unrelated working link removed'

ln -s "$test_root/missing source" "$test_root/broken link"
uninstall_link "$test_root/missing source" "$test_root/broken link"
assert_absent "$test_root/broken link"
ln -s 'source file' "$test_root/relative link"
uninstall_link "$source_path" "$test_root/relative link"
assert_absent "$test_root/relative link"
ln -s 'missing source' "$test_root/relative broken link"
uninstall_link "$test_root/missing source" "$test_root/relative broken link"
assert_absent "$test_root/relative broken link"

mkdir "$test_root/source directory"
printf 'keep\n' > "$test_root/source directory/.hidden"
ln -s "$test_root/source directory" "$test_root/directory link"
uninstall_link "$test_root/source directory" "$test_root/directory link"
assert_absent "$test_root/directory link"
[ "$(cat "$test_root/source directory/.hidden")" = keep ] || fail 'Directory source contents changed'

ln -s "$source_path" "$test_root/failing link"
(
    rm() { return 1; }
    if uninstall_link "$source_path" "$test_root/failing link"; then
        fail 'Removal failure was not reported'
    fi
)
[ -L "$test_root/failing link" ] || fail 'Failed removal changed link'

for file in "$repo_dir"/uninstall.sh "$repo_dir"/*/uninstall.sh "$repo_dir"/scripts/uninstall-common.sh "$test_dir/uninstall.sh"; do
    sh -n "$file"
    if command -v zsh >/dev/null 2>&1; then zsh -n "$file"; fi
done

fixture_repo="$test_root/repository with spaces"
mkdir -p "$fixture_repo/scripts"
for app in herdr starship tmux wezterm zsh code_agent; do
    cp -R "$repo_dir/$app" "$fixture_repo/$app"
done
cp "$repo_dir/install.sh" "$repo_dir/uninstall.sh" "$fixture_repo/"
cp "$repo_dir/scripts/install-common.sh" "$repo_dir/scripts/uninstall-common.sh" "$fixture_repo/scripts/"

run_configuration_case() (
    case_name=$1
    shell_command=$2
    HOME="$test_root/$case_name/home"
    export HOME
    unset XDG_CONFIG_HOME HERDR_CONFIG_PATH STARSHIP_CONFIG WEZTERM_CONFIG_FILE ZDOTDIR CODEX_HOME
    mkdir -p "$HOME"
    if [ "$case_name" != default ]; then
        XDG_CONFIG_HOME="$test_root/$case_name/config with spaces"
        export XDG_CONFIG_HOME
        mkdir -p "$XDG_CONFIG_HOME/tmux"
        printf 'tmux\n' > "$XDG_CONFIG_HOME/tmux/tmux.conf"
    fi
    if [ "$case_name" = overrides ]; then
        HERDR_CONFIG_PATH="$test_root/$case_name/custom/herdr.toml"
        STARSHIP_CONFIG="$test_root/$case_name/custom/starship.toml"
        WEZTERM_CONFIG_FILE="$test_root/$case_name/custom/wezterm.lua"
        ZDOTDIR="$test_root/$case_name/zsh directory"
        CODEX_HOME="$test_root/$case_name/codex directory"
        export HERDR_CONFIG_PATH STARSHIP_CONFIG WEZTERM_CONFIG_FILE ZDOTDIR CODEX_HOME
    fi
    cd "$test_root"
    "$shell_command" "$fixture_repo/install.sh" </dev/null
    find "$test_root/$case_name" -type l > "$test_root/$case_name/installed-links"
    [ -s "$test_root/$case_name/installed-links" ] || fail 'No configuration links installed'

    # Preserve unrelated entries and backups; remove links to deleted skills too.
    printf 'backup\n' > "$HOME/.zshrc.dotfiles-backup-test"
    printf 'personal\n' > "$HOME/.agents/skills/personal"
    ln -s "$source_path" "$HOME/.agents/skills/unrelated"
    ln -s "$fixture_repo/code_agent/skills/removed" "$HOME/.agents/skills/removed"
    if [ "$case_name" != default ]; then rm "$XDG_CONFIG_HOME/tmux/tmux.conf"; fi

    "$shell_command" "$fixture_repo/uninstall.sh" </dev/null
    while IFS= read -r installed_link; do assert_absent "$installed_link"; done < "$test_root/$case_name/installed-links"
    assert_absent "$HOME/.agents/skills/removed"
    [ "$(cat "$HOME/.zshrc.dotfiles-backup-test")" = backup ] || fail 'Backup changed'
    [ "$(cat "$HOME/.agents/skills/personal")" = personal ] || fail 'Personal skill changed'
    [ -L "$HOME/.agents/skills/unrelated" ] || fail 'Unrelated skill link removed'
    [ -f "$fixture_repo/zsh/.zshrc" ] || fail 'Repository source removed'
    "$shell_command" "$fixture_repo/uninstall.sh" </dev/null > "$test_root/$case_name/repeat.log"
    if grep '^Unlinked:' "$test_root/$case_name/repeat.log"; then fail 'Repeated uninstall changed links'; fi
)

run_configuration_case default sh
run_configuration_case xdg sh
run_configuration_case overrides sh
if command -v zsh >/dev/null 2>&1; then
    run_configuration_case zsh zsh
    # Direct per-application execution must also work with no installed skills.
    mkdir -p "$test_root/empty-home"
    env -i PATH="$PATH" HOME="$test_root/empty-home" zsh "$fixture_repo/code_agent/uninstall.sh"
    env -i PATH="$PATH" HOME="$test_root/empty-home" zsh "$fixture_repo/zsh/uninstall.sh"
fi

cat > "$fixture_repo/scripts/uninstall-common.sh" <<'EOF'
set -eu
uninstall_link() {
    printf '%s\n' "$1" >> "$DOTFILES_TEST_PLAN"
    case "$1" in */herdr/*) return 1 ;; esac
}
EOF
DOTFILES_TEST_PLAN="$test_root/failure-plan"
export DOTFILES_TEST_PLAN
if sh "$fixture_repo/uninstall.sh"; then fail 'Global uninstaller did not report failure'; fi
grep '/zsh/.zsh_plugins.txt$' "$DOTFILES_TEST_PLAN" >/dev/null || fail 'Uninstaller stopped after failure'
grep '/code_agent/AGENTS.md$' "$DOTFILES_TEST_PLAN" >/dev/null || fail 'Final application was not processed'
printf 'POSIX shell uninstaller checks passed.\n'
