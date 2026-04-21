#!/usr/bin/env bash
set -euo pipefail

STATE_FILE="$HOME/.cache/waylandsetup.state"
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
# Bootstrap yay
# -----------------------------------------------------------------------------

run_step "bootstrap_yay" bash -c '
command -v yay >/dev/null 2>&1 && exit 0
sudo pacman -S --needed --noconfirm base-devel git
cd /tmp
rm -rf yay
git clone https://aur.archlinux.org/yay.git
cd yay
makepkg -si --noconfirm
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
# FFmpeg
# -----------------------------------------------------------------------------
run_step "ffmpeg" yay -S ffmpeg --noconfirm


# -----------------------------------------------------------------------------
# Wayland Base
# -----------------------------------------------------------------------------
run_step "wayland_base" yay -S --needed --noconfirm \
  wl-clipboard xclip grim slurp \
  xdg-user-dirs \
  xdg-desktop-portal xdg-desktop-portal-wlr \
  polkit polkit-gnome acpid \
  brightnessctl playerctl jq \
  networkmanager bluez bluez-utils \
  wlr-randr

# -----------------------------------------------------------------------------
# Fonts
# -----------------------------------------------------------------------------

run_step "fonts" yay -S --needed --noconfirm \
  ttf-jetbrains-mono \
  ttf-jetbrains-mono-nerd \
  noto-fonts noto-fonts-emoji noto-fonts-cjk

# -----------------------------------------------------------------------------
# GUI / AUR
# -----------------------------------------------------------------------------

run_step "gui_apps" yay -S --needed --noconfirm \
  swaylock-effects \
  ghostty \
  zen-browser-bin

# -----------------------------------------------------------------------------
# Dev tools
# -----------------------------------------------------------------------------

run_step "dev_tools" yay -S --needed --noconfirm \
  neovim tmux ripgrep fd wget curl unzip \
  git github-cli \
  python python-pip \
  go rust \
  lua lazygit opencode \
  nodejs npm \
  podman buildah skopeo \
  kubectl helm aws-cli \
  openssh rsync

run_step "install_bun" bash -c '
command -v bun >/dev/null 2>&1 && exit 0
curl -fsSL https://bun.sh/install | bash
'

# -----------------------------------------------------------------------------
# Enable services
# -----------------------------------------------------------------------------

run_step "enable_services" sudo systemctl enable --now \
  NetworkManager bluetooth acpid

# -----------------------------------------------------------------------------
# Copy config files
# -----------------------------------------------------------------------------

run_step "copy_config" bash -c '
mkdir -p ~/.config
cp -r ../.config/sway ~/.config
cp -r ../.config/waybar ~/.config
cp -r ../.config/mako ~/.config
cp -r ../.config/nvim ~/.config
cp -r ../.config/swaylock ~/.config
'

run_step "install_swaybg" yay -S --needed --noconfirm swaybg

# -----------------------------------------------------------------------------
# Wallpaper
# -----------------------------------------------------------------------------

run_step "set_wallpaper" bash -c '
'

# -----------------------------------------------------------------------------
# Done
# -----------------------------------------------------------------------------

echo ""
echo "✔ Setup complete."
echo "Reboot now."
echo "System will:"
echo "→ Autologin"
echo "→ Start sway"
echo "→ Auto lock after 5 min"
echo "→ Suspend after 10 min"
