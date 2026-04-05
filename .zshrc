# History
HISTFILE=${ZDOTDIR:-$HOME}/.zsh_history
HISTSIZE=50000
SAVEHIST=50000
setopt SHARE_HISTORY INC_APPEND_HISTORY HIST_IGNORE_DUPS

# Key bindings via terminfo
typeset -g -A key
[[ -n "$terminfo[kdch1]" ]] && key[Delete]=$terminfo[kdch1]
[[ -n "$terminfo[khome]" ]] && key[Home]=$terminfo[khome]
[[ -n "$terminfo[kend]" ]] && key[End]=$terminfo[kend]
[[ -n "$terminfo[kcuu1]" ]] && key[Up]=$terminfo[kcuu1]
[[ -n "$terminfo[kcud1]" ]] && key[Down]=$terminfo[kcud1]

[[ -n ${key[Delete]} ]] && bindkey "${key[Delete]}" delete-char
[[ -n ${key[Home]} ]] && bindkey "${key[Home]}" beginning-of-line
[[ -n ${key[End]} ]] && bindkey "${key[End]}" end-of-line
[[ -n ${key[Up]} ]] && bindkey "${key[Up]}" up-line-or-search
[[ -n ${key[Down]} ]] && bindkey "${key[Down]}" down-line-or-search

# Completion system
autoload -Uz compinit
compinit

# Better completion behavior
zstyle ':completion:*' menu select
zstyle ':completion:*' matcher-list 'm:{a-zA-Z}={A-Za-z}'
zstyle ':completion:*' list-maxitems 200
zstyle ':completion:*' list-prompt '%S%M matches%s'
setopt AUTO_MENU
setopt COMPLETE_IN_WORD
setopt ALWAYS_TO_END
setopt AUTO_LIST
setopt AUTO_PARAM_SLASH

# Default prompt
PS1="%n@%m %1~ %# "

# bun completions
[ -s "$HOME/.bun/_bun" ] && source "$HOME/.bun/_bun"

# opencode
export PATH="$HOME/.opencode/bin:$PATH"
alias oc="opencode"

# claude code
alias cc="claude"

# zed (CLI wrapper installed via Zed > Install CLI at /usr/local/bin/zed)
export EDITOR="zed --wait"
export VISUAL="zed --wait"

# Aliases
alias ls="ls -la"

# Autosuggestions (install: brew install zsh-autosuggestions)
[ -r /opt/homebrew/share/zsh-autosuggestions/zsh-autosuggestions.zsh ] && \
  source /opt/homebrew/share/zsh-autosuggestions/zsh-autosuggestions.zsh

# Reload zsh and remind about Ghostty
reload-terminal() {
  source "${ZDOTDIR:-$HOME}/.zshrc"
  print "Ghostty: press Cmd+Shift+, to reload config."
}
alias reload-term="reload-terminal"
export PATH="$HOME/.local/bin:$PATH"
