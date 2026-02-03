#!/usr/bin/env bash
set -euo pipefail

STATE_FILE="/tmp/macsetup.state"

log() {
  echo ""
  echo "==> $1"
}

mark_done() {
  echo "$1" >> "$STATE_FILE"
}

is_done() {
  grep -qx "$1" "$STATE_FILE" 2>/dev/null
}

run_step() {
  local name="$1"
  shift
  if is_done "$name"; then
    echo "✔ Skipping $name (already done)"
  else
    log "$name"
    "$@"
    mark_done "$name"
  fi
}

# -------------------------------
# SUDO (ask once, keep alive)
# -------------------------------
log "Requesting sudo access"
sudo -v
(
  while true; do
    sudo -n true
    sleep 60
  done
) &
SUDO_KEEPALIVE_PID=$!
trap 'kill $SUDO_KEEPALIVE_PID' EXIT

# -------------------------------
# Shell + tooling bootstrap
# -------------------------------
run_step "copy_zshrc" cp ../.zshrc ~

run_step "install_homebrew" bash -c \
  '/bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)" < /dev/null'

eval "$(/opt/homebrew/bin/brew shellenv)"

# Ensure /usr/local/bin exists (Apple Silicon)
sudo mkdir -p /usr/local/bin || true

run_step "install_starship" bash -c \
  'curl -fsSL https://starship.rs/install.sh | sh -s -- --yes'

run_step "install_zoxide" bash -c \
  'curl -fsSL https://raw.githubusercontent.com/ajeetdsouza/zoxide/main/install.sh | sh'

run_step "source_zshrc" bash -c 'source ~/.zshrc || true'

# -------------------------------
# Wallpaper (non-fatal)
# -------------------------------
run_step "set_wallpaper" bash -c '
WALLPAPER_URL="https://wallpapercave.com/download/4k-studio-ghibli-wallpapers-wp12510494"
if curl -L --fail "$WALLPAPER_URL" -o "$HOME/wallpaper.png"; then
  osascript -e "tell application \"System Events\" to set picture of every desktop to POSIX file \"$HOME/wallpaper.png\""
else
  echo "Wallpaper not available, continuing without it"
fi
'

# -------------------------------
# Brew packages (each separately)
# -------------------------------
run_step "install_wget" brew install wget
run_step "install_nvim" brew install nvim
run_step "install_jq" brew install jq
run_step "install_gh" brew install gh
run_step "install_tmux" brew install tmux
run_step "install_awscli" brew install awscli
run_step "install_helm" brew install helm
run_step "install_kubectl" brew install kubectl
run_step "install_switchaudio" brew install switchaudio-osx
run_step "install_zen_browser" brew install zen-browser
run_step "install_yabai" brew install koekeishiya/formulae/yabai
run_step "install_skhd" brew install koekeishiya/formulae/skhd

# Lazygit via go install
run_step "install_lazygit" go install github.com/jesseduffield/lazygit@latest || true

# Casks (separate)
run_step "install_ghostty" brew install --cask ghostty
run_step "install_colima" brew install colima

# -------------------------------
# OpenCode
# -------------------------------
run_step "install_opencode" bash -c 'curl -fsSL https://opencode.ai/install | bash'

# -------------------------------
# Config files
# -------------------------------
run_step "copy_config" bash -c '
mkdir -p ~/.config
cp -r ../.config/mac/* ~/.config
'

# -------------------------------
# Languages
# -------------------------------
run_step "install_rust" sudo bash -c 'curl --proto "=https" --tlsv1.2 -sSf https://sh.rustup.rs | sh -s -- -y --no-modify-path'
source "$HOME/.cargo/env"     
run_step "install_go" brew install go
run_step "install_python" brew install python@3.11
run_step "install_lua" brew install lua

# -------------------------------
# Fonts (via Homebrew Casks where possible)
# -------------------------------
run_step "install fonts" bash -c '
brew install --cask sf-symbols
brew install --cask font-sf-mono
brew install --cask font-sf-pro
brew install --cask font-jetbrains-mono
brew install --cask font-hack-nerd-font
brew install --cask font-meslo-lg-nerd-font
'

# -------------------------------
# Tmux
# -------------------------------
run_step "tmux_setup" bash -c '
curl -fsSL "https://github.com/gpakosz/.tmux/raw/refs/heads/master/install.sh" | bash
echo "set-option -g status-position top" >> ~/.tmux.conf
'

# -------------------------------
# Sketchybar
# -------------------------------
run_step "sketchybar_setup" bash -c '
brew tap FelixKratz/formulae
brew install sketchybar

mkdir -p ~/.config/sketchybar/plugins
cp /opt/homebrew/opt/sketchybar/share/sketchybar/examples/sketchybarrc ~/.config/sketchybar/sketchybarrc
cp -r /opt/homebrew/opt/sketchybar/share/sketchybar/examples/plugins/* ~/.config/sketchybar/plugins/
chmod +x ~/.config/sketchybar/plugins/*

brew services restart sketchybar || brew services start sketchybar
sketchybar --reload
'

# -------------------------------
# macOS UI tweaks
# -------------------------------
run_step "menu_bar_refresh" bash -c '
osascript -e "tell application \"System Events\" to set autohide menu bar of dock preferences to true"
osascript -e "tell application \"System Events\" to set autohide menu bar of dock preferences to false"
'

# -------------------------------
# Window management
# -------------------------------
run_step "start window manager" bash -c '
yabai --start-service
skhd --start-service
sudo yabai --load-sa
sketchybar --reload
'

run_step "start kubernetes" bash -c '
colima start --kubernetes --memory 12 --cpu 6
'

log "Setup complete. Re-run script to resume any failed steps."

