feh --bg-fill ~/wallpapers/goodwallpaper.png
export PATH="/home/ashu/.cargo/bin:$PATH"
export PATH="/snap/bin/go:$PATH"
export PATH="$HOME/go/bin/:$PATH"

export NVM_DIR="$HOME/.nvm"
[ -s "$NVM_DIR/nvm.sh" ] && \. "$NVM_DIR/nvm.sh"                  
[ -s "$NVM_DIR/bash_completion" ] && \. "$NVM_DIR/bash_completion" 
eval "$(zoxide init bash)"

alias cd=z
alias vi='f() {
    if [ $# -eq 0 ]; then
        nvim --server "$NVIM" --remote-send "<C-\\><C-n>:Oil $(pwd)<CR>"
    else
        nvim --server "$NVIM" --remote "$@"
    fi
}; f'
alias k=kubectl
alias nats='nats -s localhost:30042'
alias random="echo $(cat /dev/urandom | tr -dc 'a-zA-Z0-9' | head -c 10)"
export KUBE_EDITOR=nvim
export _ZO_DOCTOR=0

eval "$(starship init bash)"
eval "$(/home/linuxbrew/.linuxbrew/bin/brew shellenv)"

source ~/.gitenv
. "$HOME/.cargo/env"

alias curl='function _curlt() {
  curl -s -w "\n🚀 Time: %{time_total} s\n" "$@" | tee /dev/tty | awk '"'"'/^🚀 Time:/ {printf "⏱️ Total time: %.0f ms\n", $3 * 1000}'"'"'
}; _curlt'
alias push="git pull --rebase && git push"

clear
