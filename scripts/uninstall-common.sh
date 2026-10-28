# Shared by the POSIX sh uninstallers; also compatible with bash and zsh.
set -eu

uninstall_link() (
    source_path=$1
    target_path=$2

    if [ ! -L "$target_path" ]; then
        printf 'Skipped (not a managed link): %s\n' "$target_path"
        return 0
    fi

    link_source=$(readlink "$target_path") || return 1
    case "$link_source" in
        /*) ;;
        *) link_source="$(dirname "$target_path")/$link_source" ;;
    esac
    # Compare the stored path too, so missing repository files can be unlinked.
    if [ "$link_source" = "$source_path" ] || [ "$source_path" -ef "$target_path" ]; then
        rm -- "$target_path" || return 1
        printf 'Unlinked: %s\n' "$target_path"
    else
        printf 'Skipped (not a managed link): %s\n' "$target_path"
    fi
)
