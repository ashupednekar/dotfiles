#!/usr/bin/env bash
set -euo pipefail

STATE_FILE="$HOME/.cache/x11setup.state"
mkdir -p "$(dirname "$STATE_FILE")"
touch "$STATE_FILE"

log() { echo ""; echo "==> $1"; }
mark_done() { echo "$1" >> "$STATE_FILE"; }
is_done() { grep -qx "$1" "$STATE_FILE" 2>/dev/null; }

run_step() {
  local name="$1"; shift
  if is_done "$name"; then
    echo "✔ Skipping $name"
  else
    log "$name"
    "$@"
    mark_done "$name"
  fi
}

USER_NAME="$(whoami)"
HOME_DIR="$HOME"
DOTFILES_DIR="$HOME_DIR/dotfiles"

# -----------------------------------------------------------------------------
# Bootstrap snap
# -----------------------------------------------------------------------------

run_step "bootstrap_snap" bash -c '
command -v snap >/dev/null 2>&1 && exit 0
sudo apt update
sudo apt install -y snapd
sudo systemctl enable --now snapd.socket
sudo snap install core
'

# -----------------------------------------------------------------------------
# Shell tooling
# -----------------------------------------------------------------------------

run_step "install_starship" bash -c '
command -v starship >/dev/null 2>&1 && exit 0
curl -fsSL https://starship.rs/install.sh | sh -s -- --yes
'

run_step "install_zoxide" bash -c '
command -v zoxide >/dev/null 2>&1 && exit 0
curl -fsSL https://raw.githubusercontent.com/ajeetdsouza/zoxide/main/install.sh | sh
'

# -----------------------------------------------------------------------------
# X11 Base
# -----------------------------------------------------------------------------

run_step "x11_base" sudo apt install -y \
  i3 \
  i3status \
  i3lock \
  i3lock-fancy \
  xautolock \
  xdotool \
  xclip \
  xsel \
  scrot \
  xdg-user-dirs \
  xdg-desktop-portal \
  polkit \
  polkit-gnome \
  acpid \
  brightnessctl \
  playerctl \
  jq \
  network-manager \
  bluez \
  bluez-tools

# -----------------------------------------------------------------------------
# Fonts
# -----------------------------------------------------------------------------

run_step "fonts" sudo apt install -y \
  fonts-jetbrains-mono \
  fonts-noto \
  fonts-noto-color-emoji

# -----------------------------------------------------------------------------
# GUI / Snap apps
# -----------------------------------------------------------------------------

run_step "gui_apps" bash -c '
sudo snap install ghostty --edge 2>/dev/null || true
sudo snap install zen-browser --edge 2>/dev/null || true
'

# -----------------------------------------------------------------------------
# Dev tools
# -----------------------------------------------------------------------------

run_step "dev_tools" sudo apt install -y \
  neovim \
  tmux \
  ripgrep \
  fd-find \
  wget \
  curl \
  unzip \
  git \
  gh \
  python3 \
  python3-pip \
  golang \
  rustc \
  cargo \
  lua5.4 \
  lazygit \
  nodejs \
  npm \
  podman \
  buildah \
  skopeo \
  kubectl \
  helm \
  awscli \
  openssh \
  rsync

run_step "install_bun" bash -c '
command -v bun >/dev/null 2>&1 && exit 0
curl -fsSL https://bun.sh/install | bash
'

run_step "install_opencode" bash -c '
command -v opencode >/dev/null 2>&1 && exit 0
curl -fsSL https://opencode.ai/install.sh | bash
'

# -----------------------------------------------------------------------------
# Enable services
# -----------------------------------------------------------------------------

run_step "enable_services" sudo systemctl enable --now \
  NetworkManager bluetooth acpid

# -----------------------------------------------------------------------------
# Autologin on tty1
# -----------------------------------------------------------------------------

run_step "tty_autologin" sudo bash -c "
mkdir -p /etc/systemd/system/getty@tty1.service.d
cat > /etc/systemd/system/getty@tty1.service.d/override.conf << EOF
[Service]
ExecStart=
ExecStart=-/usr/bin/agetty --autologin $USER_NAME --noclear %I \$TERM
EOF
"

# -----------------------------------------------------------------------------
# Auto start i3 on login
# -----------------------------------------------------------------------------

run_step "bash_profile" bash -c "
cat > '$HOME_DIR/.bash_profile' << 'EOF'
if [[ -z \"\$DISPLAY\" && \"\$XDG_VTNR\" == \"1\" ]]; then
  exec i3
fi
EOF
"

# -----------------------------------------------------------------------------
# xautolock config
# -----------------------------------------------------------------------------

run_step "xautolock_config" bash -c "
mkdir -p '$HOME_DIR/.config/i3'
cat > '$HOME_DIR/.config/i3/autolock.sh' << 'EOF'
#!/bin/bash
xautolock -time 5 -locker 'i3lock-fancy -f' -nowlkp && systemctl suspend
EOF
chmod +x '$HOME_DIR/.config/i3/autolock.sh'
"

run_step "include_autolock_in_i3" bash -c "
cfg='$HOME_DIR/.config/i3/config'
grep -q 'exec --no-startup-id xautolock' \"\$cfg\" 2>/dev/null || \
echo 'exec --no-startup-id xautolock -time 5 -locker "i3lock-fancy -f"' >> \"\$cfg\"
"

# -----------------------------------------------------------------------------
# Copy config files
# -----------------------------------------------------------------------------

run_step "copy_config" bash -c '
mkdir -p ~/.config
cp -r $DOTFILES_DIR/.config/i3 ~/.config
cp -r $DOTFILES_DIR/.config/nvim ~/.config
'

# -----------------------------------------------------------------------------
# Wallpaper
# -----------------------------------------------------------------------------

run_step "set_wallpaper" bash -c '
cp $DOTFILES_DIR/wallpaper.png ~/wallpaper.png
'

# -----------------------------------------------------------------------------
# Done
# -----------------------------------------------------------------------------

echo ""
echo "✔ Setup complete."
echo "Reboot now."
echo "System will:"
echo "→ Autologin"
echo "→ Start i3"
echo "→ Auto lock after 5 min"
