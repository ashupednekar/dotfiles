# If not running interactively, don't do anything
[[ $- != *i* ]] && return

# Path
export PATH="$HOME/.cargo/bin:$HOME/go/bin:$HOME/.local/bin:$PATH"

# Defaults
export TERMINAL=ghostty
export BROWSER=zen-browser
export EDITOR=nvim

# Starship prompt
if command -v starship &>/dev/null; then
  eval "$(starship init bash)"
fi

# Zoxide (smarter cd)
if command -v zoxide &>/dev/null; then
  eval "$(zoxide init bash)"
fi

# Aliases
alias ls='ls --color=auto'
alias ll='ls -lah'
alias g='git'
alias v='nvim'
alias t='tmux'
