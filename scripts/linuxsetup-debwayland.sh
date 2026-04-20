#!/usr/bin/env bash
set -euo pipefail

# ─────────────────────────────────────────────────────────────────────────────
# Debian/Ubuntu Wayland (Hyprland) setup — mirrors macsetup.sh / setuphyprland.sh
# ─────────────────────────────────────────────────────────────────────────────

STATE_FILE="$HOME/.cache/debwaylandsetup.state"
DOTFILES_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"

case "${1:-}" in
  --no-cache)
    echo "==> --no-cache: clearing state, re-running all steps"
    rm -f "$STATE_FILE"
    ;;
  --reload)
    echo "==> --reload: re-copying config and reloading Hyprland"
    sed -i '/^copy_config$/d;/^reload_config$/d' "$STATE_FILE" 2>/dev/null || true
    ;;
esac

mkdir -p "$(dirname "$STATE_FILE")"
touch "$STATE_FILE"

log()       { echo ""; echo "==> $1"; }
mark_done() { echo "$1" >> "$STATE_FILE"; }
is_done()   { grep -qx "$1" "$STATE_FILE" 2>/dev/null; }

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

# ─────────────────────────────────────────────────────────────────────────────
# Shell tooling
# ─────────────────────────────────────────────────────────────────────────────
run_step "install_starship" bash -c '
command -v starship >/dev/null 2>&1 && exit 0
curl -fsSL https://starship.rs/install.sh | sh -s -- --yes
'

run_step "install_zoxide" bash -c '
command -v zoxide >/dev/null 2>&1 && exit 0
curl -fsSL https://raw.githubusercontent.com/ajeetdsouza/zoxide/main/install.sh | sh
'

# ─────────────────────────────────────────────────────────────────────────────
# Hyprland — build from source via hyprbuntu (no PPA exists for Noble)
# ─────────────────────────────────────────────────────────────────────────────
run_step "install_hyprland" bash -c '
sudo add-apt-repository universe && sudo apt update && sudo apt install hyprland
echo "  → Hyprland install complete"
'

# ─────────────────────────────────────────────────────────────────────────────
# Wayland tools
# ─────────────────────────────────────────────────────────────────────────────
run_step "wayland_tools" bash -c '
pkgs=""
command -v waybar        >/dev/null 2>&1 || pkgs="$pkgs waybar"
command -v mako          >/dev/null 2>&1 || pkgs="$pkgs mako-notifier"
command -v rofi          >/dev/null 2>&1 || pkgs="$pkgs rofi"
command -v wl-copy       >/dev/null 2>&1 || pkgs="$pkgs wl-clipboard"
command -v grim          >/dev/null 2>&1 || pkgs="$pkgs grim"
command -v slurp         >/dev/null 2>&1 || pkgs="$pkgs slurp"
command -v brightnessctl >/dev/null 2>&1 || pkgs="$pkgs brightnessctl"
command -v playerctl     >/dev/null 2>&1 || pkgs="$pkgs playerctl"
sudo apt install -y \
  xdg-user-dirs xdg-desktop-portal xdg-desktop-portal-wlr \
  polkitd policykit-1-gnome acpid jq network-manager bluez bluez-tools \
  $pkgs
'

# ─────────────────────────────────────────────────────────────────────────────
# Fonts
# ─────────────────────────────────────────────────────────────────────────────
run_step "fonts" bash -c '
fc-list | grep -qi "JetBrains" && exit 0
sudo apt install -y fonts-jetbrains-mono fonts-noto fonts-noto-color-emoji
'

# ─────────────────────────────────────────────────────────────────────────────
# GUI apps (snap)
# ─────────────────────────────────────────────────────────────────────────────
run_step "bootstrap_snap" bash -c '
command -v snap >/dev/null 2>&1 && exit 0
sudo apt install -y snapd
sudo systemctl enable --now snapd.socket
sudo snap install core
'

run_step "install_ghostty" bash -c '
command -v ghostty >/dev/null 2>&1 && exit 0
sudo snap install ghostty --edge 2>/dev/null || true
'

run_step "install_zen" bash -c '
command -v zen-browser >/dev/null 2>&1 && exit 0
sudo snap install zen-browser --edge 2>/dev/null || true
'

# ─────────────────────────────────────────────────────────────────────────────
# Dev tools
# ─────────────────────────────────────────────────────────────────────────────
run_step "dev_tools" bash -c '
pkgs=""
command -v nvim    >/dev/null 2>&1 || pkgs="$pkgs neovim"
command -v tmux    >/dev/null 2>&1 || pkgs="$pkgs tmux"
command -v rg      >/dev/null 2>&1 || pkgs="$pkgs ripgrep"
command -v fdfind  >/dev/null 2>&1 || pkgs="$pkgs fd-find"
command -v git     >/dev/null 2>&1 || pkgs="$pkgs git"
command -v gh      >/dev/null 2>&1 || pkgs="$pkgs gh"
command -v python3 >/dev/null 2>&1 || pkgs="$pkgs python3 python3-pip"
command -v go      >/dev/null 2>&1 || pkgs="$pkgs golang"
command -v rustc   >/dev/null 2>&1 || pkgs="$pkgs rustc cargo"
command -v lua5.4  >/dev/null 2>&1 || pkgs="$pkgs lua5.4"
command -v node    >/dev/null 2>&1 || pkgs="$pkgs nodejs npm"
command -v podman  >/dev/null 2>&1 || pkgs="$pkgs podman buildah skopeo"
sudo apt install -y wget curl unzip rsync openssh-client $pkgs
'

run_step "install_lazygit" bash -c '
command -v lazygit >/dev/null 2>&1 && exit 0
VER=$(curl -s "https://api.github.com/repos/jesseduffield/lazygit/releases/latest" | grep -Po "\"tag_name\": \"v\K[^\"]*")
curl -Lo /tmp/lazygit.tar.gz "https://github.com/jesseduffield/lazygit/releases/latest/download/lazygit_${VER}_Linux_x86_64.tar.gz"
tar xf /tmp/lazygit.tar.gz -C /tmp lazygit
sudo install /tmp/lazygit /usr/local/bin/lazygit
rm -f /tmp/lazygit /tmp/lazygit.tar.gz
echo "  → lazygit $VER installed"
'

run_step "install_kubectl" bash -c '
command -v kubectl >/dev/null 2>&1 && exit 0
curl -fsSL https://pkgs.k8s.io/core:/stable:/v1.31/deb/Release.key \
  | sudo gpg --dearmor -o /etc/apt/keyrings/kubernetes-apt-keyring.gpg
echo "deb [signed-by=/etc/apt/keyrings/kubernetes-apt-keyring.gpg] https://pkgs.k8s.io/core:/stable:/v1.31/deb/ /" \
  | sudo tee /etc/apt/sources.list.d/kubernetes.list
sudo apt update -q
sudo apt install -y kubectl
'

run_step "install_helm" bash -c '
command -v helm >/dev/null 2>&1 && exit 0
curl -fsSL https://raw.githubusercontent.com/helm/helm/main/scripts/get-helm-3 | bash
'

run_step "install_awscli" bash -c '
command -v aws >/dev/null 2>&1 && exit 0
cd /tmp
curl -fsSL "https://awscli.amazonaws.com/awscli-exe-linux-x86_64.zip" -o awscliv2.zip
unzip -q awscliv2.zip
sudo ./aws/install
rm -rf /tmp/aws /tmp/awscliv2.zip
echo "  → awscli v2 installed"
'

run_step "install_bun" bash -c '
command -v bun >/dev/null 2>&1 && exit 0
curl -fsSL https://bun.sh/install | bash
'

run_step "install_opencode" bash -c '
command -v opencode >/dev/null 2>&1 && exit 0
curl -fsSL https://opencode.ai/install.sh | bash
'

# ─────────────────────────────────────────────────────────────────────────────
# Services
# ─────────────────────────────────────────────────────────────────────────────
run_step "enable_services" bash -c '
for svc in NetworkManager bluetooth acpid; do
  systemctl list-unit-files "${svc}.service" >/dev/null 2>&1 && \
    sudo systemctl enable --now "$svc" 2>/dev/null || true
done
'

# ─────────────────────────────────────────────────────────────────────────────
# Autologin on tty1
# ─────────────────────────────────────────────────────────────────────────────
run_step "tty_autologin" sudo bash -c "
mkdir -p /etc/systemd/system/getty@tty1.service.d
cat > /etc/systemd/system/getty@tty1.service.d/override.conf << EOF
[Service]
ExecStart=
ExecStart=-/usr/bin/agetty --autologin $USER_NAME --noclear %I \$TERM
EOF
"

# ─────────────────────────────────────────────────────────────────────────────
# Auto-start Hyprland on tty1 login
# ─────────────────────────────────────────────────────────────────────────────
run_step "bash_profile" bash -c "
cat > '$HOME/.bash_profile' << 'EOF'
if [[ -z \"\$WAYLAND_DISPLAY\" && \"\$XDG_VTNR\" == \"1\" ]]; then
  exec Hyprland
fi
EOF
"

# ─────────────────────────────────────────────────────────────────────────────
# Lid handling (ignore so custom hypridle handler manages suspend)
# ─────────────────────────────────────────────────────────────────────────────
run_step "lid_ignore" sudo bash -c "
mkdir -p /etc/systemd/logind.conf.d
cat > /etc/systemd/logind.conf.d/lid.conf << 'EOF'
[Login]
HandleLidSwitch=ignore
HandleLidSwitchExternalPower=ignore
HandleLidSwitchDocked=ignore
EOF
"

run_step "restart_logind" sudo systemctl restart systemd-logind

# ─────────────────────────────────────────────────────────────────────────────
# Copy configs
# ─────────────────────────────────────────────────────────────────────────────
run_step "copy_config" bash -c "
mkdir -p \"\$HOME/.config\"
rm -rf \"\$HOME/.config/hypr\"
cp -r '$DOTFILES_DIR/.config/hypr-pure' \"\$HOME/.config/hypr\"
chmod +x \"\$HOME/.config/hypr/scripts\"/*.sh
cp -r '$DOTFILES_DIR/.config/waybar'  \"\$HOME/.config/\"
cp -r '$DOTFILES_DIR/.config/mako'    \"\$HOME/.config/\"
cp -r '$DOTFILES_DIR/.config/ghostty' \"\$HOME/.config/\"
cp -r '$DOTFILES_DIR/.config/nvim'    \"\$HOME/.config/\"
cp    '$DOTFILES_DIR/.config/starship.toml' \"\$HOME/.config/\"
echo '  → Config files copied'
"

run_step "set_wallpaper" bash -c "
cp '$DOTFILES_DIR/wallpaper.png' ~/wallpaper.png
echo '  → Wallpaper copied to ~/wallpaper.png'
"

# ─────────────────────────────────────────────────────────────────────────────
# Reload Hyprland config (if running)
# ─────────────────────────────────────────────────────────────────────────────
run_step "reload_config" bash -c '
if [[ -n "${HYPRLAND_INSTANCE_SIGNATURE:-}" ]]; then
  hyprctl reload
  echo "  → Reloaded via hyprctl"
else
  echo "  → Hyprland not running — config will apply on next login"
fi
'

# ─────────────────────────────────────────────────────────────────────────────
# Done
# ─────────────────────────────────────────────────────────────────────────────
echo ""
echo "✔ Setup complete."
echo ""
echo "→ Hyprland + waybar + mako + rofi installed"
echo "→ Super+C/V copy/paste everywhere (including terminal)"
echo "→ Super+D launcher (rofi), Super+Return terminal (split-aware)"
echo "→ Super+Z/X set split direction persistently"
echo "→ Reboot to start — autologin launches Hyprland automatically"
echo ""
echo "Re-run at any time — completed steps are skipped."
echo "  --reload    re-copy config + reload Hyprland"
echo "  --no-cache  re-run all steps from scratch"
