#!/usr/bin/env bash
set -euo pipefail

STATE_FILE="$HOME/.cache/fedora-hyprsetup.state"
DOTFILES_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
USER_NAME="$(whoami)"

mkdir -p "$(dirname "$STATE_FILE")"
touch "$STATE_FILE"

log() { echo ""; echo "==> $1"; }
mark_done() { echo "$1" >> "$STATE_FILE"; }
is_done() { grep -qx "$1" "$STATE_FILE" 2>/dev/null; }

run_step() {
  local name="$1"
  shift
  if is_done "$name"; then
    echo "✔ Skipping $name"
  else
    log "$name"
    "$@"
    mark_done "$name"
  fi
}

log "Requesting sudo access"
sudo -v
(
  while true; do
    sudo -n true
    sleep 60
  done
) &
SUDO_KEEPALIVE_PID=$!
trap 'kill $SUDO_KEEPALIVE_PID 2>/dev/null || true' EXIT

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
# Fedora packages for pure Hyprland
# -----------------------------------------------------------------------------

run_step "dnf_update" sudo dnf -y upgrade --refresh

run_step "hyprland_base" sudo dnf install -y \
  hyprland hyprpaper hyprlock hypridle \
  waybar mako \
  wl-clipboard xclip grim slurp \
  xdg-user-dirs xdg-utils \
  xdg-desktop-portal xdg-desktop-portal-gtk xdg-desktop-portal-hyprland \
  polkit polkit-gnome \
  brightnessctl playerctl jq \
  NetworkManager bluez bluez-tools \
  pipewire pipewire-alsa pipewire-pulseaudio wireplumber \
  flatpak

run_step "fonts" sudo dnf install -y \
  jetbrains-mono-fonts \
  google-noto-sans-fonts \
  google-noto-emoji-color-fonts \
  google-noto-cjk-fonts

run_step "dev_tools" sudo dnf install -y \
  neovim tmux ripgrep fd-find wget curl unzip \
  git gh \
  python3 python3-pip \
  golang rust cargo \
  lua nodejs npm \
  podman buildah skopeo \
  openssh rsync

run_step "install_bun" bash -c '
command -v bun >/dev/null 2>&1 && exit 0
curl -fsSL https://bun.sh/install | bash
'

run_step "install_opencode" bash -c '
command -v opencode >/dev/null 2>&1 && exit 0
curl -fsSL https://opencode.ai/install | bash
'

# -----------------------------------------------------------------------------
# GUI apps via Flathub
# -----------------------------------------------------------------------------

run_step "enable_flathub" bash -c '
flatpak remote-add --if-not-exists flathub https://flathub.org/repo/flathub.flatpakrepo
'

run_step "gui_apps" bash -c '
flatpak install -y flathub com.mitchellh.ghostty 2>/dev/null || true
flatpak install -y flathub com.zen_browser.zen 2>/dev/null || true
'

# -----------------------------------------------------------------------------
# System services and login behavior
# -----------------------------------------------------------------------------

run_step "enable_services" sudo systemctl enable --now \
  NetworkManager bluetooth

run_step "tty_autologin" sudo bash -c "
mkdir -p /etc/systemd/system/getty@tty1.service.d
cat > /etc/systemd/system/getty@tty1.service.d/override.conf << EOF
[Service]
ExecStart=
ExecStart=-/usr/bin/agetty --autologin $USER_NAME --noclear %I \$TERM
EOF
"

run_step "bash_profile" bash -c "
cat > '$HOME/.bash_profile' << 'EOF'
if [[ -z \"\$WAYLAND_DISPLAY\" && \"\$XDG_VTNR\" == \"1\" ]]; then
  exec Hyprland
fi
EOF
"

# -----------------------------------------------------------------------------
# Dotfiles / config (pure Hyprland only)
# -----------------------------------------------------------------------------

run_step "copy_config" bash -c "
mkdir -p '$HOME/.config'
rm -rf '$HOME/.config/hypr'
cp -r '$DOTFILES_DIR/.config/hypr-pure' '$HOME/.config/hypr'
cp -r '$DOTFILES_DIR/.config/waybar' '$HOME/.config'
cp -r '$DOTFILES_DIR/.config/mako' '$HOME/.config'
cp -r '$DOTFILES_DIR/.config/nvim' '$HOME/.config'
cp -r '$DOTFILES_DIR/.config/ghostty' '$HOME/.config'
cp '$DOTFILES_DIR/.config/starship.toml' '$HOME/.config'
chmod +x '$HOME/.config/hypr/scripts/'*.sh 2>/dev/null || true
"

run_step "set_wallpaper" bash -c "
cp '$DOTFILES_DIR/wallpaper.png' '$HOME/wallpaper.png'
"

run_step "set_defaults" bash -c '
mkdir -p "$HOME/.config/environment.d"
cat > "$HOME/.config/environment.d/terminal.conf" << EOF
TERMINAL=ghostty
EOF
for desktop in io.github.zen_browser.zen.desktop zen-browser.desktop zen.desktop; do
  if xdg-settings set default-web-browser "$desktop" 2>/dev/null; then
    xdg-mime default "$desktop" x-scheme-handler/http
    xdg-mime default "$desktop" x-scheme-handler/https
    break
  fi
done
'

echo ""
echo "✔ Fedora pure Hyprland setup complete."
echo "Reboot or log out/in to start Hyprland on tty1."
