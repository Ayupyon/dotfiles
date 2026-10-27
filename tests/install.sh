#!/bin/sh
# Run: sh ./tests/install.sh
set -eu
test_dir=$(CDPATH= cd -- "$(dirname "$0")" && pwd -P)
repo_dir=$(CDPATH= cd -- "$test_dir/.." && pwd -P)
. "$repo_dir/scripts/install-common.sh"
test_root=$(mktemp -d "$test_dir/tmp-XXXXXXXX")
printf 'Test fixtures: %s\n' "$test_root"

fail() { printf '%s\n' "$1" >&2; exit 1; }
source_path="$test_root/source file"
target_path="$test_root/nested/target file"
if [ "${1:-}" != --plan-only ]; then
printf 'repository\n' > "$source_path"
install_link "$source_path" "$target_path"
[ -L "$target_path" ] || fail 'Missing file symlink'
install_link "$source_path" "$target_path" > "$test_root/repeat.log"
[ ! -s "$test_root/repeat.log" ] || case "$(cat "$test_root/repeat.log")" in
    'Already linked:'*) ;;
    *) fail 'Existing correct link was not skipped' ;;
esac

conflict="$test_root/existing file"
printf 'original\n' > "$conflict"
for reply in n '' unexpected; do
    printf '%s\n' "$reply" | install_link "$source_path" "$conflict"
    [ "$(cat "$conflict")" = original ] || fail 'Declined overwrite changed content'
done
install_link "$source_path" "$conflict" < /dev/null
[ "$(cat "$conflict")" = original ] || fail 'EOF changed content'
printf 'yes\n' | install_link "$source_path" "$conflict"
[ -L "$conflict" ] || fail 'Confirmed replacement missing'
set -- "$conflict".dotfiles-backup-*
[ "$#" -eq 1 ] && [ "$(cat "$1")" = original ] || fail 'Backup content lost'

mkdir "$test_root/source directory" "$test_root/target directory"
printf 'keep\n' > "$test_root/target directory/.hidden"
printf 'y\n' | install_link "$test_root/source directory" "$test_root/target directory"
[ -L "$test_root/target directory" ] || fail 'Missing directory symlink'
set -- "$test_root/target directory".dotfiles-backup-*
[ -f "$1/.hidden" ] || fail 'Directory backup lost hidden file'

ln -s "$test_root/missing" "$test_root/broken link"
printf 'y\n' | install_link "$source_path" "$test_root/broken link"
[ "$(cat "$test_root/broken link")" = repository ] || fail 'Broken link was not replaced'

printf 'restore me\n' > "$test_root/rollback"
(
    ln() { return 1; }
    if printf 'y\n' | install_link "$source_path" "$test_root/rollback"; then
        fail 'Link failure was not reported'
    fi
)
[ "$(cat "$test_root/rollback")" = 'restore me' ] || fail 'Failed creation did not restore original'
fi

for file in "$repo_dir"/install.sh "$repo_dir"/*/install.sh "$repo_dir"/scripts/install-common.sh; do
    sh -n "$file"
    if command -v zsh >/dev/null 2>&1; then
        zsh -n "$file"
    fi
done

# Run the full installer from another directory, capturing destinations only.
fixture_repo="$test_root/repository with spaces"
mkdir -p "$fixture_repo/scripts"
for app in herdr starship tmux wezterm zsh code_agent; do
    cp -R "$repo_dir/$app" "$fixture_repo/$app"
done
cp "$repo_dir/install.sh" "$fixture_repo/install.sh"
cat > "$fixture_repo/scripts/install-common.sh" <<'EOF'
set -eu
install_link() {
    [ -e "$1" ] || return 1
    printf '%s\t%s\n' "$1" "$2" >> "$DOTFILES_TEST_PLAN"
    case "$1" in
        */herdr/*) [ "${DOTFILES_TEST_FAIL:-}" != herdr ] || return 1 ;;
    esac
    return 0
}
EOF
export DOTFILES_TEST_PLAN="$test_root/plan"
(cd "$test_root" && sh "$fixture_repo/install.sh")
skill_count=0
for skill_directory in "$fixture_repo"/code_agent/skills/*; do
    [ -d "$skill_directory" ] && [ -f "$skill_directory/SKILL.md" ] || continue
    skill_count=$((skill_count + 1))
    expected_link=$(printf '%s\t%s' "$skill_directory" "$HOME/.agents/skills/$(basename "$skill_directory")")
    grep -Fx "$expected_link" "$DOTFILES_TEST_PLAN" > /dev/null || fail 'Wrong skill link'
done
expected_link=$(printf '%s\t%s' "$fixture_repo/code_agent/AGENTS.md" "${CODEX_HOME:-$HOME/.codex}/AGENTS.md")
grep -Fx "$expected_link" "$DOTFILES_TEST_PLAN" > /dev/null || fail 'Wrong Codex global instructions path'
expected_link_count=$((8 + skill_count))
[ "$(wc -l < "$DOTFILES_TEST_PLAN" | tr -d ' ')" -eq "$expected_link_count" ] || fail 'Unexpected Linux installation plan'
if grep -E '/(pwsh)/' "$DOTFILES_TEST_PLAN"; then
    fail 'Unexpected pwsh installation on Linux'
fi
export DOTFILES_TEST_PLAN="$test_root/failure-plan"
if DOTFILES_TEST_FAIL=herdr sh "$fixture_repo/install.sh"; then
    fail 'Global installer did not report failure'
fi
[ "$(wc -l < "$DOTFILES_TEST_PLAN" | tr -d ' ')" -eq "$expected_link_count" ] || fail 'Global installer did not continue after failure'
if command -v zsh >/dev/null 2>&1; then
    export DOTFILES_TEST_PLAN="$test_root/zsh-plan"
    zsh "$fixture_repo/install.sh"
    zsh "$fixture_repo/tmux/install.sh"
    zsh "$fixture_repo/zsh/install.sh"
    zsh "$fixture_repo/code_agent/install.sh"
fi
printf 'POSIX shell installer checks passed.\n'
