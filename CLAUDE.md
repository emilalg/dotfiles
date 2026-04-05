# CLAUDE.md

Personal dotfiles repo rooted at `~/.config` (`ZDOTDIR`). macOS-first, Homebrew-based.

## Layout

- `.zshrc` / `.zprofile` — shell config (completion, autosuggestions, keybindings, PATH, aliases)
- `ghostty/config` — Ghostty terminal settings
- `claude/settings.json` — Claude Code settings (symlinked from `~/.claude/settings.json`)
- `git/ignore` — global gitignore
- `opencode/` — opencode config
- `zed/` — Zed editor config

## Claude Code Settings

`~/.claude/settings.json` is a symlink to `claude/settings.json` in this repo. If you reinstall Claude Code or the symlink breaks, restore it:

```sh
ln -sf ~/.config/claude/settings.json ~/.claude/settings.json
```

`settings.local.json` is gitignored globally via `git/ignore`.

## Conventions

- **No plugin manager** — autosuggestions sourced directly from Homebrew, completion via `compinit`.
- **`reload-term`** re-sources `.zshrc`. Ghostty requires `Cmd+Shift+,`.
- **PATH order**: Homebrew (via `.zprofile`), opencode, `~/.local/bin`.
- Test zsh changes with `zsh -n ~/.config/.zshrc` before committing.
- Ghostty config is key-value, no quoting, no trailing commas.
