export KUBE_EDITOR=nvim

export PATH="/home/ashu/.cargo/bin:$PATH"
export PATH="/snap/bin/go:$PATH"
export PATH="$HOME/go/bin/:$PATH"

export NVM_DIR="$HOME/.nvm"
[ -s "$NVM_DIR/nvm.sh" ] && \. "$NVM_DIR/nvm.sh"                  
[ -s "$NVM_DIR/bash_completion" ] && \. "$NVM_DIR/bash_completion" 
eval "$(zoxide init bash)"

alias cd=z
alias vi=nvim
alias k=kubectl
alias nats='nats -s localhost:30042'
alias psql="docker exec -it postgres psql -U consoleuser -d console"
alias random="echo $(cat /dev/urandom | tr -dc 'a-zA-Z0-9' | head -c 10)"
export _ZO_DOCTOR=0

eval "$(starship init zsh)"
eval "$(/home/linuxbrew/.linuxbrew/bin/brew shellenv)"

source ~/.gitenv
. "$HOME/.cargo/env"

clear
