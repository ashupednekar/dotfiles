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
# Wayland Base (NO swaylock here)
# -----------------------------------------------------------------------------

run_step "wayland_base" yay -S --needed --noconfirm \
  sway swayidle waybar mako \
  wl-clipboard xclip grim slurp \
  sway-contrib \
  xdg-user-dirs \
  xdg-desktop-portal xdg-desktop-portal-wlr \
  polkit polkit-gnome acpid \
  brightnessctl playerctl jq \
  networkmanager bluez bluez-utils

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
  lua lazygit \
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
# Auto start sway on login
# -----------------------------------------------------------------------------

run_step "bash_profile" bash -c "
cat > '$HOME_DIR/.bash_profile' << 'EOF'
if [[ -z \"\$WAYLAND_DISPLAY\" && \"\$XDG_VTNR\" == \"1\" ]]; then
  exec sway
fi
EOF
"

# -----------------------------------------------------------------------------
# swayidle config (clean + safe)
# -----------------------------------------------------------------------------

run_step "swayidle_config" bash -c "
mkdir -p '$HOME_DIR/.config/sway'
cat > '$HOME_DIR/.config/sway/idle.conf' << 'EOF'
exec_always swayidle -w \
  timeout 300 'swaylock -f' \
  timeout 600 'systemctl suspend' \
  before-sleep 'swaylock -f'
EOF
"

run_step "include_idle_in_sway" bash -c "
cfg='$HOME_DIR/.config/sway/config'
grep -q 'include ~/.config/sway/idle.conf' \"\$cfg\" 2>/dev/null || \
echo 'include ~/.config/sway/idle.conf' >> \"\$cfg\"
"

# -----------------------------------------------------------------------------
# Pretty swaylock config
# -----------------------------------------------------------------------------

run_step "lockscreen_config" bash -c "
mkdir -p '$HOME_DIR/.config/swaylock'
cat > '$HOME_DIR/.config/swaylock/config' << 'EOF'
clock
timestr=%H:%M
datestr=%A, %d %B
font=JetBrains Mono
indicator
indicator-radius=120
indicator-thickness=10
effect-blur=10x10
fade-in=0.2
EOF
"

# -----------------------------------------------------------------------------
# Lid suspend
# -----------------------------------------------------------------------------

run_step "lid_suspend" sudo bash -c "
mkdir -p /etc/systemd/logind.conf.d
cat > /etc/systemd/logind.conf.d/lid.conf << 'EOF'
[Login]
HandleLidSwitch=suspend
HandleLidSwitchExternalPower=suspend
HandleLidSwitchDocked=suspend
EOF
"

run_step "restart_logind" sudo systemctl restart systemd-logind

# -----------------------------------------------------------------------------
# Copy config files
# -----------------------------------------------------------------------------

run_step "copy_config" bash -c '
mkdir -p ~/.config
cp -r $DOTFILES_DIR/.config/sway ~/.config
cp -r $DOTFILES_DIR/.config/waybar ~/.config
cp -r $DOTFILES_DIR/.config/mako ~/.config
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
echo "→ Start sway"
echo "→ Auto lock after 5 min"
echo "→ Suspend after 10 min"
