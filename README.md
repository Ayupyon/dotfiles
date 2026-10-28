# dotfiles

Install this repository's application configurations using symbolic links. The scripts install configuration only; install applications and plugins separately. Run the installers again if you move the repository.

## Installation

On Windows, use PowerShell 7 (`pwsh`). Enable Windows Developer Mode to allow symbolic links, or run an administrator terminal:

```powershell
pwsh -NoProfile -File .\install.ps1
# Install a single application's configuration:
pwsh -NoProfile -File .\pwsh\install.ps1
```

On Linux / macOS, run from sh, bash, or zsh without sudo:

```sh
sh ./install.sh
# Install a single application's configuration:
sh ./tmux/install.sh
```

Scripts locate the repository relative to themselves, so they can be called from any working directory. The Windows installer processes herdr, pwsh, starship, wezterm, and code_agent in order. The Linux / macOS installer processes herdr, starship, tmux, wezterm, zsh, and code_agent in order. If an application fails, the global installer continues with the remaining applications and returns a failure status at the end.

## Default destinations

In this table, `~` means PowerShell's `$HOME` on Windows and `$HOME` on Linux / macOS.

| Application | Windows | Linux / macOS |
| --- | --- | --- |
| herdr | `%APPDATA%/herdr/config.toml` | `~/.config/herdr/config.toml` |
| pwsh | `$PROFILE.CurrentUserCurrentHost` and `~/.config/pwsh/pwshconfig.d` | Not installed |
| starship | `~/.config/starship.toml` | `~/.config/starship.toml` |
| tmux | Not installed | `~/.tmux.conf.local` (see below) |
| wezterm | `~/.config/wezterm/wezterm.lua` | `~/.config/wezterm/wezterm.lua` |
| zsh | Not installed | `~/.zshenv`, `~/.zshrc`, `~/.zsh_plugins.txt`, and `~/.config/zsh/zshconfig.d` |
| code_agent | `~/.codex/AGENTS.md` and `~/.agents/skills/<skill-name>` | Same as Windows |

Configuration entry files are linked individually. The pwsh / zsh module directories are linked as directories, keeping installer scripts out of application configuration directories.

- herdr and wezterm respect `XDG_CONFIG_HOME`, using `herdr/config.toml` and `wezterm/wezterm.lua` under that directory when set.
- If `HERDR_CONFIG_PATH`, `STARSHIP_CONFIG`, or `WEZTERM_CONFIG_FILE` is set, the corresponding installer links directly to that file. Starship otherwise always uses `~/.config/starship.toml`.
- When `ZDOTDIR` is set, zsh's entry files and `.zsh_plugins.txt` are linked there. Modules still use `~/.config/zsh/zshconfig.d`, as specified by the repository's startup files.
- pwsh uses the current PowerShell host's actual profile path, including Documents / OneDrive redirection.
- The tmux file extends [Oh my tmux!](https://github.com/gpakosz/.tmux), whose main configuration must be installed separately. The installer looks for `~/.tmux.conf`, `$XDG_CONFIG_HOME/tmux/tmux.conf`, then `~/.config/tmux/tmux.conf`, linking the extension to the adjacent `.local` file. If no main configuration exists, it still creates `~/.tmux.conf.local` and prints a dependency notice.
- For WSL, run the Linux installer inside WSL. tmux and zsh are excluded from the Windows installer.
- WezTerm's `--config-file` argument and `wezterm.lua` beside a portable Windows executable can take precedence over the paths above.
- code_agent links `AGENTS.md` to Codex's global user instructions file, respecting `CODEX_HOME` when set. Each immediate directory under `code_agent/skills` containing `SKILL.md` is linked separately to `~/.agents/skills/<directory-name>`, preserving unrelated installed skills. The skills destination does not change with `CODEX_HOME`. An existing `AGENTS.override.md` takes precedence over `AGENTS.md` in Codex. Run `pwsh -NoProfile -File ./code_agent/install.ps1` on Windows or `sh ./code_agent/install.sh` on Linux / macOS to install these links separately.

## Existing configuration

If a destination exists, including a file, directory, or broken link, the installer displays the paths and prompts with `[y/N]`. Only `y` or `yes` confirms replacement; an empty answer, refusal, or end of input skips it. Symbolic links already pointing to the corresponding repository paths are skipped without prompting.

After confirmation, the existing entry is renamed to `original-name.dotfiles-backup-timestamp-unique-suffix` in the same directory before creating the link. If link creation fails, the original entry is restored. Existing links are backed up as links, leaving their targets untouched. To restore a backup manually, remove the new link and rename the backup to its original name.

Path references: [Herdr configuration](https://herdr.dev/docs/configuration/), [PowerShell profiles](https://learn.microsoft.com/en-us/powershell/module/microsoft.powershell.core/about/about_profiles), [Starship configuration](https://starship.rs/config/), [WezTerm configuration](https://wezterm.org/config/files.html), [Zsh startup files](https://zsh.sourceforge.io/Doc/Release/Files.html), [Codex global instructions](https://learn.chatgpt.com/docs/agent-configuration/agents-md), and [Codex skills](https://learn.chatgpt.com/docs/build-skills).

## Uninstallation

On Windows, run `pwsh -NoProfile -File ./uninstall.ps1`. On Linux / macOS, run `sh ./uninstall.sh`. Each application also has a matching uninstaller, such as `pwsh -NoProfile -File ./pwsh/uninstall.ps1` or `sh ./zsh/uninstall.sh`.

Uninstallers remove only symbolic links pointing to that application's paths in this checkout, including broken managed links. They preserve regular files, directories, unrelated links, repository files, and installer backups. They do not restore backups automatically or remove applications and plugins. Rerunning an uninstaller is safe. Global uninstallers continue after an application fails and report failure at the end.

Use the same destination environment variables and PowerShell host as during installation. The tmux uninstaller checks all supported destinations even if its main configuration has been removed. The code_agent uninstaller also removes managed links to skills that no longer exist in the checkout.

## Installer and uninstaller checks

Run `pwsh -NoProfile -File ./tests/install.ps1` on Windows or `sh ./tests/install.sh` on Linux / macOS. Checks use temporary directories under `tests/`, exercise confirmation, backups, repeated installation, broken links, and rollback, and leave fixtures for inspection. They also check the global installation plan without changing actual user configuration. Windows checks require permission to create symbolic links; add `-PlanOnly` to check parsing and destinations without creating links. The shell equivalent is `sh ./tests/install.sh --plan-only`. Shell checks also use zsh when available.

Run `pwsh -NoProfile -File ./tests/uninstall.ps1` on Windows or `sh ./tests/uninstall.sh` on Linux / macOS to check removal, repeated uninstallation, preservation of unrelated entries and backups, destination overrides, and global failure reporting. These checks use temporary paths without changing actual user configuration. Windows checks require permission to create symbolic links; `-PlanOnly` checks parsing and destinations only.
