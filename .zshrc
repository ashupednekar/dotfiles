export ZSH="$HOME/.oh-my-zsh"
ZSH_THEME="candy"
CASE_SENSITIVE="true"

DISABLE_MAGIC_FUNCTIONS="true"
DISABLE_AUTO_TITLE="true"

plugins=(git)
source $ZSH/oh-my-zsh.sh

. "$HOME/.cargo/env"            
[[ ! -f ~/.p10k.zsh ]] || source ~/.p10k.zsh

source $HOME/.cargo/env


export NVM_DIR="$HOME/.nvm"
  [ -s "/opt/homebrew/opt/nvm/nvm.sh" ] && \. "/opt/homebrew/opt/nvm/nvm.sh"    [ -s "/opt/homebrew/opt/nvm/etc/bash_completion.d/nvm" ] && \. "/opt/homebrew/opt/nvm/etc/bash_completion.d/nvm"  
eval "$(zoxide init zsh)"

source ~/.virtualenvs/base/bin/activate
alias cd=z
alias vi=nvim
alias k=kubectl
alias cat="bat --plain"

export GOPATH=$HOME/go
export GOROOT="$(brew --prefix golang)/libexec"
export PATH="$PATH:${GOPATH}/bin:${GOROOT}/bin:$HOME/.local/bin"

export PATH="/Users/ashutoshpednekar/.rd/bin:$PATH"
export MODULAR_HOME="/Users/ashutoshpednekar/.modular"
export PATH="/Users/ashutoshpednekar/.modular/pkg/packages.modular.com_mojo/bin:$PATH"
export PATH=$PATH:$HOME/Library/Android/platform-tools


export LD_LIBRARY_PATH=$LD_LIBRARY_PATH:.
export ANDROID_HOME=$HOME/Library/Android/sdk
export PATH="/opt/homebrew/opt/libpq/bin:$PATH"
export PATH="/opt/homebrew/opt/libpq/bin:$PATH"
export MOZ_DISABLE_SAFE_MODE_KEY=1

alias lc=leetcode

export APP_PASSWORD='vzzi lhaq khan lsar'

### MANAGED BY RANCHER DESKTOP START (DO NOT EDIT)
export PATH="/Users/ashutoshpednekar/.rd/bin:$PATH"
### MANAGED BY RANCHER DESKTOP END (DO NOT EDIT)
