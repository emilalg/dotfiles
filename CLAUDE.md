# CLAUDE.md

Personal dotfiles repo rooted at `~/.config` (`ZDOTDIR`). macOS-first, Homebrew-based.

## Layout

- `.zshrc` / `.zprofile` — shell config (completion, autosuggestions, keybindings, PATH, aliases)
- `ghostty/config` — Ghostty terminal settings
- `claude/` — Claude Code user config: `settings.json`, `agents/`, `commands/`, `skills/`, `bootstrap.sh` (each symlinked into `~/.claude/`)
- `git/ignore` — global gitignore
- `opencode/` — opencode config
- `zed/` — Zed editor config

## Claude Code Settings

`~/.claude/settings.json`, `agents/`, `commands/`, and `skills/` are symlinks into `claude/` in this repo. To restore the symlinks after a Claude Code reinstall or on a fresh machine, run:

```sh
./claude/bootstrap.sh
```

It's idempotent and backs up any pre-existing files it would replace (to `~/.claude/<name>.bak-<timestamp>`).

`settings.local.json` is gitignored globally via `git/ignore`.

## Conventions

- **No plugin manager** — autosuggestions sourced directly from Homebrew, completion via `compinit`.
- **`reload-term`** re-sources `.zshrc`. Ghostty requires `Cmd+Shift+,`.
- **PATH order**: Homebrew (via `.zprofile`), opencode, `~/.local/bin`.
- Test zsh changes with `zsh -n ~/.config/.zshrc` before committing.
- Ghostty config is key-value, no quoting, no trailing commas.
