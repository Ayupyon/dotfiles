# Shared by the POSIX sh installers; also compatible with bash and zsh.
# Each entry point sets app_dir before sourcing this file.
set -eu

install_link() (
    source_path=$1
    target_path=$2

    if [ ! -e "$source_path" ]; then
        printf 'Missing source: %s\n' "$source_path" >&2
        return 1
    fi
    if [ -L "$target_path" ] && [ "$source_path" -ef "$target_path" ]; then
        printf 'Already linked: %s\n' "$target_path"
        return 0
    fi

    backup_path=
    if [ -e "$target_path" ] || [ -L "$target_path" ]; then
        printf 'Replace %s with a link to %s? [y/N] ' "$target_path" "$source_path"
        answer=
        IFS= read -r answer || answer=
        case "$answer" in
            y|Y|yes|YES|Yes) ;;
            *) printf 'Skipped: %s\n' "$target_path"; return 0 ;;
        esac
        backup_path="${target_path}.dotfiles-backup-$(date +%Y%m%d%H%M%S)-$$"
        while [ -e "$backup_path" ] || [ -L "$backup_path" ]; do
            backup_path="${backup_path}-1"
        done
        # Move the entry itself, including a symlink, without deleting its contents.
        mv "$target_path" "$backup_path"
        printf 'Backup: %s\n' "$backup_path"
    fi

    if mkdir -p "$(dirname "$target_path")" && ln -s "$source_path" "$target_path"; then
        printf 'Linked: %s -> %s\n' "$target_path" "$source_path"
    else
        if [ -n "$backup_path" ]; then
            mv "$backup_path" "$target_path"
        fi
        printf 'Failed to link: %s\n' "$target_path" >&2
        return 1
    fi
)
