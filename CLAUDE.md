# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## What This Is

Personal dotfiles repo rooted at `~/.config`. Tracks shell config (zsh), terminal config (Ghostty), editor config (Zed), and tool config (opencode, git). Primary target is macOS (Homebrew, Ghostty, Zed); maintain Linux compatibility where possible without cluttering configs with platform branches.

## Repo Layout

- `.zshrc` — main shell config (completion, keybindings, PATH, aliases). Sources Nix daemon, Homebrew, bun completions.
- `.zprofile` — Homebrew shellenv bootstrap (`/opt/homebrew/bin/brew shellenv`).
- `ghostty/config` — Ghostty terminal emulator settings.
- `git/ignore` — global gitignore (currently ignores `.claude/settings.local.json`).
- `opencode/` — opencode AI tool config (node package).
- `zed/` — Zed editor config (conversations, prompts, themes).
- `.gitignore` — keeps zsh runtime files, sensitive service configs (`gcloud/`, `stripe/`, `containers/`), and Zed local state out of the repo.

## Conventions

- **ZDOTDIR is `~/.config`** — zsh loads `.zshrc` and `.zprofile` from this directory, not `$HOME`. All zsh dotfile paths are relative to this repo root.
- **No plugin manager** — zsh config is self-contained. Completion is set up via `compinit` directly.
- **Reload workflow** — `reload-term` / `reload-terminal` re-sources `.zshrc`. Ghostty config requires `Cmd+Shift+,` (no CLI reload).
- **PATH additions** go at the end of `.zshrc`. Current order: Nix, Homebrew (via `.zprofile`), opencode, Zed, `~/.local/bin`.
- **macOS-first, Linux-aware** — use `if` guards for macOS-specific paths (e.g., the Zed app bundle check). Prefer portable shell constructs. Ghostty `macos-*` keys are silently ignored on Linux.

## When Editing

- Test zsh changes with `zsh -n ~/.config/.zshrc` (syntax check) before committing.
- Ghostty config is key-value, no quoting, no trailing commas. Refer to Ghostty docs for valid keys.
- Keep configs minimal — only override defaults that matter.
