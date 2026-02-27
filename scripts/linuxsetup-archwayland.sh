#!/usr/bin/env bash
set -euo pipefail

# =============================================================================
# Resume / State handling
# =============================================================================

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

# =============================================================================
# Bootstrap yay (ONLY pacman usage)
# =============================================================================

run_step "bootstrap_yay" bash -c '
command -v yay >/dev/null 2>&1 && exit 0

sudo pacman -S --needed --noconfirm base-devel git
cd /tmp
rm -rf yay
git clone https://aur.archlinux.org/yay.git
cd yay
makepkg -si --noconfirm
'

# =============================================================================
# Base system + Wayland (yay for everything)
# =============================================================================

run_step "wayland_base" yay -S --needed --noconfirm \
  sway swayidle swaylock waybar mako \
  wl-clipboard grim slurp \
  sway-contrib \
  xdg-user-dirs \
  xdg-desktop-portal xdg-desktop-portal-wlr \
  polkit polkit-gnome acpid \
  brightnessctl playerctl jq \
  networkmanager bluez bluez-utils

# =============================================================================
# Fonts
# =============================================================================

run_step "fonts" yay -S --needed --noconfirm \
  ttf-jetbrains-mono \
  noto-fonts noto-fonts-emoji noto-fonts-cjk

# =============================================================================
# GUI / UX (AUR + official mixed)
# =============================================================================

run_step "gui_apps" yay -S --needed --noconfirm \
  swaylock-effects \
  ghostty \
  zen-browser-bin

# =============================================================================
# Dev tools (macsetup parity)
# =============================================================================

run_step "dev_tools" yay -S --needed --noconfirm \
  neovim tmux ripgrep fd wget curl unzip \
  git github-cli \
  python python-pip \
  go rust \
  lua \
  nodejs npm \
  podman buildah skopeo \
  kubectl helm aws-cli \
  openssh rsync

# =============================================================================
# lazygit (Go install like macsetup)
# =============================================================================

run_step "install_lazygit" bash -c '
command -v lazygit >/dev/null 2>&1 || \
  go install github.com/jesseduffield/lazygit@latest
'

# =============================================================================
# k3s (instead of colima)
# =============================================================================

run_step "install_k3s" bash -c '
command -v k3s >/dev/null 2>&1 || \
  curl -sfL https://get.k3s.io | sh -
'

run_step "k3s_kubectl_access" sudo bash -c "
mkdir -p /home/$USER_NAME/.kube
cp /etc/rancher/k3s/k3s.yaml /home/$USER_NAME/.kube/config
chown -R $USER_NAME:$USER_NAME /home/$USER_NAME/.kube
chmod 600 /home/$USER_NAME/.kube/config
"

# =============================================================================
# Dotfiles linking
# =============================================================================

run_step "link_dotfiles" bash -c "
mkdir -p '$HOME_DIR/.config'
for dir in sway waybar mako nvim tmux starship; do
  rm -rf '$HOME_DIR/.config/\$dir'
  ln -s '$DOTFILES_DIR/\$dir' '$HOME_DIR/.config/\$dir'
done
"

# =============================================================================
# swaylock config
# =============================================================================

run_step "lockscreen_config" bash -c "
mkdir -p '$HOME_DIR/.config/swaylock'
cat > '$HOME_DIR/.config/swaylock/config' << 'EOF'
clock
timestr=%H:%M
datestr=%A, %d %B

font=JetBrains Mono
font-size=32

indicator
indicator-radius=120
indicator-thickness=10

inside-color=00000088
ring-color=ffffff88
key-hl-color=88c0d0ff

inside-ver-color=88c0d0aa
ring-ver-color=88c0d0ff

inside-wrong-color=bf616aaa
ring-wrong-color=bf616aff

text-color=ffffffff

effect-blur=10x10
effect-vignette=0.4:0.4
fade-in=0.2

ignore-empty-password
disable-caps-lock-text
EOF
"

# =============================================================================
# swayidle (idempotent)
# =============================================================================

run_step "swayidle_config" bash -c "
cfg='$HOME_DIR/.config/sway/config'
mkdir -p \"\$(dirname \"\$cfg\")\"
grep -q '### Idle / Lock / Suspend' \"\$cfg\" 2>/dev/null && exit 0

cat >> \"\$cfg\" << 'EOF'

### Idle / Lock / Suspend
exec swayidle -w \
  timeout 300 'swaylock -f' \
  timeout 600 'systemctl suspend' \
  before-sleep 'swaylock -f'

bindswitch --reload --locked lid:on exec swaylock -f
EOF
"

# =============================================================================
# Auto-start sway on tty1
# =============================================================================

run_step "bash_profile" bash -c "
cat > '$HOME_DIR/.bash_profile' << 'EOF'
if [[ -z \"\$WAYLAND_DISPLAY\" && \"\$XDG_VTNR\" == \"1\" ]]; then
  exec sway
fi
EOF
"

# =============================================================================
# Lid close → suspend
# =============================================================================

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

# =============================================================================
# Enable services
# =============================================================================

run_step "enable_services" sudo bash -c "
systemctl daemon-reexec
systemctl enable --now \
  NetworkManager \
  bluetooth \
  acpid \
  k3s
"

# =============================================================================
# Neovim bootstrap
# =============================================================================

run_step "nvim_bootstrap" bash -c '
nvim --headless "+Lazy! sync" +qa || true
'

# =============================================================================
# Done
# =============================================================================

echo ""
echo "==> FULL Wayland + Dev + k3s setup complete"
echo "State file: $STATE_FILE"
echo "Reboot → sway → lock → resume → nvim → kubectl get nodes"