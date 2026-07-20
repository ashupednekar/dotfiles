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
unalias wa 2>/dev/null || true
function _wa_pr_config {
  local config_file
  config_file="$(mktemp "${TMPDIR:-/tmp}/workmux-pr-layout.XXXXXX")" || return

  cat > "$config_file" <<'EOF'
panes:
  - command: codex
    focus: true
  - command: nvim -c 'lua vim.schedule(function() vim.api.nvim_feedkeys(vim.api.nvim_replace_termcodes("<leader>pr", true, false, true), "m", false) end)' .
    split: horizontal
    percentage: 70
  - split: vertical
    size: 10
nerdfont: true
EOF

  print -r -- "$config_file"
}

function _wa_pr_branch_info {
  local target="$1"
  local selector="$target"

  [[ "$selector" == pr/* ]] && selector="${selector#pr/}"
  [[ "$selector" =~ ^#([0-9]+)$ ]] && selector="${match[1]}"

  command -v gh >/dev/null 2>&1 || return 1
  gh pr view "$selector" \
    --json number,headRefName,isCrossRepository \
    --jq '"\(.number)\t\(.headRefName)\t\(.isCrossRepository)"' 2>/dev/null
}

function wa {
  local target="$1"
  shift || true
  local info pr branch cross_ref config_file rc

  if [[ -z "$target" ]]; then
    workmux add "$@"
    return
  fi

  if [[ "$target" == pr/* || "$target" =~ ^#?[0-9]+$ || "$target" =~ github.com/.+/pull/[0-9]+ ]]; then
    if info="$(_wa_pr_branch_info "$target")"; then
      pr="${info%%$'\t'*}"
      info="${info#*$'\t'}"
      branch="${info%%$'\t'*}"
      cross_ref="${info#*$'\t'}"
      config_file="$(_wa_pr_config)" || return
      if [[ -n "$branch" ]]; then
        workmux add --config "$config_file" --open-if-exists --pr "$pr" -p "Please review PR #$pr. Focus on bugs, regressions, and missing tests." "$@" "$branch"
      else
        workmux add --config "$config_file" --open-if-exists --pr "$pr" -p "Please review PR #$pr. Focus on bugs, regressions, and missing tests." "$@"
      fi
      rc=$?
      rm -f "$config_file"
      return "$rc"
    fi
  fi

  if [[ "$target" == pr/* ]]; then
    print -u2 -- "wa: could not resolve '$target' to a pull request; opening it as a branch worktree"
  fi
  workmux add "$target" "$@"
}
