export KUBE_EDITOR=nvim

export PATH="/Users/$USER/.local/bin:$PATH"
export PATH="/home/$USER/.cargo/bin:$PATH"
export PATH="/snap/bin/go:$PATH"
export PATH="$HOME/go/bin/:$PATH"
export PATH="/opt/homebrew/opt/ruby/bin:$PATH"
export NVM_DIR="$HOME/.nvm"
[ -s "$NVM_DIR/nvm.sh" ] && \. "$NVM_DIR/nvm.sh"                  
[ -s "$NVM_DIR/bash_completion" ] && \. "$NVM_DIR/bash_completion" 
eval "$(zoxide init bash)"

alias cd=z
alias vi=nvim
alias k=kubectl
alias docker-compose="docker compose"

export _ZO_DOCTOR=0
export _ZO_EXCLUDE_DIRS="$HOME/worktrees/*"

eval "$(direnv hook zsh)"
eval "$(starship init zsh)"
eval "$(zoxide init zsh)"

. "$HOME/.cargo/env"

export PATH=/Users/ashu/.opencode/bin:$PATH
export PATH="/Users/ashu/.antigravity/antigravity/bin:$PATH"

alias wr="workmux remove --force"
wa() {
  local target="$1"
  shift || true

  if [[ -z "$target" ]]; then
    workmux add "$@"
  elif [[ "$target" =~ ^[0-9]+$ ]]; then
    workmux add --pr "$target" "$@"
  elif [[ "$target" =~ ^pr/([0-9]+)$ ]]; then
    workmux add --pr "${match[1]}" "$@"
  else
    workmux add "$target" "$@"
  fi
}
