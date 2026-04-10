#!/usr/bin/env bash
set -euo pipefail

# ─────────────────────────────────────────────────────────────────────────────
# Hyprland setup — mirrors macsetup.sh pattern (idempotent, state-file based)
# Supports: omarchy-installed systems (layered config) + pure Hyprland
# ─────────────────────────────────────────────────────────────────────────────

STATE_FILE="$HOME/.cache/setuphyprland.state"
mkdir -p "$(dirname "$STATE_FILE")"
touch "$STATE_FILE"

DOTFILES_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"

log()      { echo ""; echo "==> $1"; }
mark_done() { echo "$1" >> "$STATE_FILE"; }
is_done()  { grep -qx "$1" "$STATE_FILE" 2>/dev/null; }

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

# ─────────────────────────────────────────────────────────────────────────────
# Detect omarchy
# ─────────────────────────────────────────────────────────────────────────────
IS_OMARCHY=false
if [[ -d "$HOME/.local/share/omarchy" ]]; then
  IS_OMARCHY=true
  log "Omarchy detected — will use omarchy-compatible config overrides"
else
  log "Pure Hyprland mode — will install full standalone config"
fi

# ─────────────────────────────────────────────────────────────────────────────
# Sudo keepalive (same as macsetup.sh)
# ─────────────────────────────────────────────────────────────────────────────
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

# ─────────────────────────────────────────────────────────────────────────────
# Full system upgrade (-Syu) first
# ─────────────────────────────────────────────────────────────────────────────
run_step "syu" sudo pacman -Syu --noconfirm

# ─────────────────────────────────────────────────────────────────────────────
# Bootstrap yay (AUR helper)
# ─────────────────────────────────────────────────────────────────────────────
run_step "bootstrap_yay" bash -c '
command -v yay >/dev/null 2>&1 && exit 0
sudo pacman -S --needed --noconfirm base-devel git
cd /tmp
rm -rf yay
git clone https://aur.archlinux.org/yay.git
cd yay
makepkg -si --noconfirm
'

# ─────────────────────────────────────────────────────────────────────────────
# Rust (for cargo-based tools)
# ─────────────────────────────────────────────────────────────────────────────
run_step "install_rust" bash -c '
command -v rustc >/dev/null 2>&1 && exit 0
command -v rustup >/dev/null 2>&1 && exit 0
curl --proto "=https" --tlsv1.2 -sSf https://sh.rustup.rs | sh -s -- -y --no-modify-path
'
# shellcheck source=/dev/null
[[ -f "$HOME/.cargo/env" ]] && source "$HOME/.cargo/env"

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
# Base Hyprland packages
# ─────────────────────────────────────────────────────────────────────────────
if [[ "$IS_OMARCHY" == "false" ]]; then
  run_step "install_hyprland" yay -S --needed --noconfirm \
    hyprland hyprpaper hyprlock hypridle \
    xdg-desktop-portal-hyprland \
    waybar mako swaybg \
    wl-clipboard cliphist \
    xdg-utils xdg-user-dirs \
    xdg-desktop-portal xdg-desktop-portal-gtk \
    polkit polkit-gnome \
    grim slurp \
    brightnessctl playerctl \
    networkmanager bluez bluez-utils acpid \
    pipewire pipewire-alsa pipewire-pulse wireplumber \
    walker-bin \
    swayosd-git
else
  # Omarchy already has Hyprland; just ensure clipboard + screenshot tools
  run_step "install_hypr_extras" yay -S --needed --noconfirm \
    wl-clipboard cliphist grim slurp xdg-utils
fi

# ─────────────────────────────────────────────────────────────────────────────
# Terminal + browser (AUR)
# ─────────────────────────────────────────────────────────────────────────────
run_step "install_ghostty" yay -S --needed --noconfirm ghostty
run_step "install_zen"     yay -S --needed --noconfirm zen-browser-bin

# ─────────────────────────────────────────────────────────────────────────────
# Dev tools
# ─────────────────────────────────────────────────────────────────────────────
run_step "install_dev_tools" yay -S --needed --noconfirm \
  neovim tmux ripgrep fd wget curl unzip \
  git github-cli jq \
  go python python-pip \
  lua \
  nodejs npm \
  lazygit \
  podman buildah skopeo \
  kubectl helm aws-cli \
  openssh rsync

run_step "install_bun" bash -c '
command -v bun >/dev/null 2>&1 && exit 0
curl -fsSL https://bun.sh/install | bash
'

run_step "install_opencode" bash -c '
command -v opencode >/dev/null 2>&1 && exit 0
curl -fsSL https://opencode.ai/install | bash
'

# ─────────────────────────────────────────────────────────────────────────────
# Fonts
# ─────────────────────────────────────────────────────────────────────────────
run_step "install_fonts" yay -S --needed --noconfirm \
  ttf-jetbrains-mono \
  ttf-jetbrains-mono-nerd \
  noto-fonts noto-fonts-emoji noto-fonts-cjk \
  otf-font-awesome

# ─────────────────────────────────────────────────────────────────────────────
# Config files
# ─────────────────────────────────────────────────────────────────────────────
run_step "copy_config" bash -c "
mkdir -p \"\$HOME/.config\"

if [[ '$IS_OMARCHY' == 'true' ]]; then
  # Omarchy mode: copy only the user-override layer
  # Omarchy sources these from ~/.config/hypr/ and applies them on top of its defaults
  cp -r '$DOTFILES_DIR/.config/hypr' \"\$HOME/.config/\"
  echo '  → Copied hypr user overrides (omarchy-compatible)'
else
  # Pure Hyprland: install the full standalone config
  rm -rf \"\$HOME/.config/hypr\"
  cp -r '$DOTFILES_DIR/.config/hypr-pure' \"\$HOME/.config/hypr\"
  echo '  → Copied standalone hypr config'
fi

# Common configs (always)
cp -r '$DOTFILES_DIR/.config/ghostty' \"\$HOME/.config/\"
cp -r '$DOTFILES_DIR/.config/nvim'    \"\$HOME/.config/\"
cp -r '$DOTFILES_DIR/.config/mako'    \"\$HOME/.config/\"
cp    '$DOTFILES_DIR/.config/starship.toml' \"\$HOME/.config/\"

# Waybar (only for pure hyprland — omarchy manages its own)
if [[ '$IS_OMARCHY' == 'false' ]]; then
  cp -r '$DOTFILES_DIR/.config/waybar' \"\$HOME/.config/\"
fi
"

# ─────────────────────────────────────────────────────────────────────────────
# Dotfiles
# ─────────────────────────────────────────────────────────────────────────────
run_step "copy_zshrc" cp "$DOTFILES_DIR/.zshrc" ~

# ─────────────────────────────────────────────────────────────────────────────
# Wallpaper
# ─────────────────────────────────────────────────────────────────────────────
run_step "set_wallpaper" bash -c "
cp '$DOTFILES_DIR/wallpaper.png' ~/wallpaper.png
echo '  → Wallpaper copied to ~/wallpaper.png'
"

# ─────────────────────────────────────────────────────────────────────────────
# Default browser — Zen
# ─────────────────────────────────────────────────────────────────────────────
run_step "set_default_browser" bash -c '
# Try the desktop file name variants zen-browser ships with
for desktop in zen-browser.desktop zen.desktop io.github.zen_browser.zen.desktop; do
  if xdg-settings set default-web-browser "$desktop" 2>/dev/null; then
    xdg-mime default "$desktop" x-scheme-handler/http
    xdg-mime default "$desktop" x-scheme-handler/https
    echo "  → Default browser set to $desktop"
    break
  fi
done
'

# ─────────────────────────────────────────────────────────────────────────────
# Default terminal — Ghostty
# ─────────────────────────────────────────────────────────────────────────────
run_step "set_default_terminal" bash -c '
mkdir -p "$HOME/.config/environment.d"
cat > "$HOME/.config/environment.d/terminal.conf" << EOF
TERMINAL=ghostty
EOF
echo "  → TERMINAL=ghostty written to ~/.config/environment.d/terminal.conf"

# Also set xdg terminal (for file managers, etc.)
xdg-mime default com.mitchellh.ghostty.desktop x-scheme-handler/terminal 2>/dev/null || true
'

# ─────────────────────────────────────────────────────────────────────────────
# Tmux
# ─────────────────────────────────────────────────────────────────────────────
run_step "tmux_setup" bash -c '
curl -fsSL "https://github.com/gpakosz/.tmux/raw/refs/heads/master/install.sh" | bash
echo "set-option -g status-position top" >> ~/.tmux.conf
'

# ─────────────────────────────────────────────────────────────────────────────
# Cleanup bloat apps
# ─────────────────────────────────────────────────────────────────────────────
run_step "cleanup_bloat" bash -c '
echo "  Removing bloat packages (if installed)..."

BLOAT_PKGS=(
  basecamp
  chatgpt-desktop
  chatgpt-desktop-bin
  caprine
  slack-desktop
  teams
  zoom
)

for pkg in "${BLOAT_PKGS[@]}"; do
  if yay -Q "$pkg" >/dev/null 2>&1; then
    echo "  → Removing $pkg"
    yay -Rns --noconfirm "$pkg" 2>/dev/null || true
  fi
done

echo "  Removing bloat desktop entries..."
BLOAT_ENTRIES=(
  "basecamp"
  "chatgpt"
  "ChatGPT"
  "caprine"
)

for entry in "${BLOAT_ENTRIES[@]}"; do
  find "$HOME/.local/share/applications" \
       /usr/share/applications \
       /usr/local/share/applications \
       -iname "*${entry}*" -delete 2>/dev/null || true
done

# Remove omarchy-created webapp entries for these apps (stored in ~/.local/share/applications/)
if [[ -d "$HOME/.local/share/omarchy" ]]; then
  echo "  Cleaning omarchy webapp entries..."
  find "$HOME/.local/share/applications" \
    -name "*.desktop" \
    -exec grep -l -i -E "basecamp|chatgpt|grok\.com|caprine" {} \; \
    | xargs rm -f 2>/dev/null || true
fi

# Update desktop database
update-desktop-database "$HOME/.local/share/applications" 2>/dev/null || true
echo "  → Bloat cleanup done"
'

# ─────────────────────────────────────────────────────────────────────────────
# Pure Hyprland only: autologin + auto-start Hyprland
# ─────────────────────────────────────────────────────────────────────────────
if [[ "$IS_OMARCHY" == "false" ]]; then
  USER_NAME="$(whoami)"

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
fi

# ─────────────────────────────────────────────────────────────────────────────
# System services
# ─────────────────────────────────────────────────────────────────────────────
run_step "enable_services" bash -c '
SERVICES=(NetworkManager bluetooth acpid)
for svc in "${SERVICES[@]}"; do
  if systemctl list-unit-files "${svc}.service" >/dev/null 2>&1; then
    sudo systemctl enable --now "$svc" 2>/dev/null || true
  fi
done
'

# ─────────────────────────────────────────────────────────────────────────────
# Lid handling (macOS clamshell style — pure only, omarchy handles its own)
# ─────────────────────────────────────────────────────────────────────────────
if [[ "$IS_OMARCHY" == "false" ]]; then
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
fi

# ─────────────────────────────────────────────────────────────────────────────
# Reload Hyprland config (if running)
# ─────────────────────────────────────────────────────────────────────────────
run_step "reload_config" bash -c '
if [[ -n "${HYPRLAND_INSTANCE_SIGNATURE:-}" ]]; then
  if [[ "'"$IS_OMARCHY"'" == "true" ]] && command -v omarchy-refresh-hyprland >/dev/null 2>&1; then
    omarchy-refresh-hyprland
    echo "  → Reloaded via omarchy-refresh-hyprland"
  else
    hyprctl reload
    echo "  → Reloaded via hyprctl"
  fi
else
  echo "  → Hyprland not running — config will apply on next login"
fi
'

# ─────────────────────────────────────────────────────────────────────────────
# Done
# ─────────────────────────────────────────────────────────────────────────────
echo ""
echo "✔ Hyprland setup complete."
echo ""
if [[ "$IS_OMARCHY" == "true" ]]; then
  echo "→ Omarchy mode: user config overrides applied to ~/.config/hypr/"
  echo "→ Keybindings: Super+C (copy), Super+V (paste)"
  echo "→ Tiling:      Super+Z (horizontal split), Super+X (vertical split)"
  echo "→ hjkl focus + hjkl window move"
  echo "→ ChatGPT/Grok binding removed"
  echo "→ Browser: zen  |  Terminal: ghostty"
else
  echo "→ Pure Hyprland: full config in ~/.config/hypr/"
  echo "→ Reboot or log out and back in to start Hyprland"
fi
echo ""
echo "Re-run the script at any time — completed steps are skipped automatically."
