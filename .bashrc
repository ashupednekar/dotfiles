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
alias cd=z
alias vi=nvim
alias k=kubectl

export NVM_DIR="$HOME/.nvm"
[ -s "$NVM_DIR/nvm.sh" ] && \. "$NVM_DIR/nvm.sh"                  
[ -s "$NVM_DIR/bash_completion" ] && \. "$NVM_DIR/bash_completion" 

export _ZO_DOCTOR=0
export _ZO_EXCLUDE_DIRS="$HOME/worktrees/*"

eval "$(starship init bash)"
eval "$(zoxide init bash)"

export PATH=/Users/ashu/.opencode/bin:$PATH
export PATH="/Users/ashu/.antigravity/antigravity/bin:$PATH"
