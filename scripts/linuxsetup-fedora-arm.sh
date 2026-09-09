#!/usr/bin/env bash
# Bootstrap a conventional Fedora Asahi Remix installation on Apple Silicon.
# It is re-runnable: package installation is idempotent and existing dotfiles
# are moved to a dated backup before they are replaced.
set -Eeuo pipefail

readonly DOTFILES_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
readonly BACKUP_DIR="$HOME/.local/state/fedora-asahi-hyprland-backups/$(date +%Y%m%d-%H%M%S)"
readonly LOGIN_USER="$(id -un)"

log() { printf '\n==> %s\n' "$*"; }
die() { printf 'Error: %s\n' "$*" >&2; exit 1; }
require_path() { [[ -e "$1" ]] || die "Required dotfiles asset is missing: $1"; }

preflight() {
  [[ ${EUID} -ne 0 ]] || die "Run this as your normal login user, not root."
  command -v dnf >/dev/null || die "This is a DNF-based Fedora Asahi Remix script."
  # Fedora Asahi Remix may identify itself as either Fedora or a Fedora-derived
  # remix; accept both forms and rely on the Apple Silicon check below.
  local os_id os_id_like
  . /etc/os-release
  os_id="${ID:-}"
  os_id_like="${ID_LIKE:-}"
  [[ "$os_id $os_id_like" == *fedora* ]] || die "Fedora Asahi Remix was not detected."
  [[ $(uname -m) == aarch64 ]] || die "This script supports Apple Silicon (aarch64) only."
  [[ -r /proc/device-tree/compatible ]] || die "Apple Silicon hardware was not detected."
  tr '\0' '\n' </proc/device-tree/compatible | grep -qi apple || die "Apple Silicon hardware was not detected."

  # Atomic Fedora images need rpm-ostree layering and a reboot between layers.
  ! command -v rpm-ostree >/dev/null || ! rpm-ostree status >/dev/null 2>&1 || \
    die "An rpm-ostree deployment was detected; this script is for conventional Fedora Asahi Remix."

  require_path "$DOTFILES_DIR/.config/hypr-pure"
  require_path "$DOTFILES_DIR/.config/waybar"
  require_path "$DOTFILES_DIR/.config/mako"
  require_path "$DOTFILES_DIR/.config/nvim"
  require_path "$DOTFILES_DIR/.config/ghostty"
  require_path "$DOTFILES_DIR/.config/starship.toml"
}

install_packages() {
  log "Updating Fedora Asahi Remix"
  sudo dnf --refresh -y upgrade

  log "Installing the Hyprland desktop and runtime dependencies"
  sudo dnf install -y \
    hyprland hyprlock hypridle \
    waybar mako rofi-wayland \
    wl-clipboard grim slurp \
    xdg-user-dirs xdg-utils \
    xdg-desktop-portal xdg-desktop-portal-gtk xdg-desktop-portal-hyprland \
    polkit polkit-gnome \
    brightnessctl playerctl jq \
    NetworkManager bluez bluez-tools \
    pipewire pipewire-alsa pipewire-pulseaudio wireplumber \
    xorg-x11-server-Xwayland \
    ghostty flatpak

  log "Installing fonts and development tools"
  sudo dnf install -y \
    jetbrains-mono-fonts \
    google-noto-sans-fonts google-noto-color-emoji-fonts google-noto-cjk-fonts \
    neovim tmux ripgrep fd-find wget curl unzip \
    git gh python3 python3-pip golang rust cargo lua nodejs npm \
    podman buildah skopeo openssh rsync starship zoxide
}

install_optional_tools() {
  log "Installing Bun and OpenCode"
  command -v bun >/dev/null 2>&1 || curl -fsSL https://bun.sh/install | bash
  command -v opencode >/dev/null 2>&1 || curl -fsSL https://opencode.ai/install | bash
}

install_flatpaks() {
  log "Installing Zen from Flathub"
  flatpak --user remote-add --if-not-exists flathub https://flathub.org/repo/flathub.flatpakrepo
  flatpak --user install -y flathub app.zen_browser.zen
}

configure_services() {
  log "Enabling network and Bluetooth services"
  sudo systemctl enable --now NetworkManager bluetooth

  log "Keeping the GNOME login and lock screen"
  sudo systemctl set-default graphical.target
  sudo systemctl enable gdm.service

  # Remove only the tty1 override created by older versions of this script.
  local getty_override="/etc/systemd/system/getty@tty1.service.d/override.conf"
  if sudo test -f "$getty_override" && sudo grep -Fqx "ExecStart=-/usr/bin/agetty --autologin $LOGIN_USER --noclear %I \$TERM" "$getty_override"; then
    sudo rm -f "$getty_override"
    sudo rmdir /etc/systemd/system/getty@tty1.service.d 2>/dev/null || true
    sudo systemctl daemon-reload
  fi
}

verify_hyprland_session() {
  local session_file="/usr/share/wayland-sessions/hyprland.desktop"
  [[ -f "$session_file" ]] || die "Hyprland installed without its GDM session file: $session_file"
  log "Hyprland is available in GDM's session chooser"
}

backup_and_copy() {
  local source="$1" target="$2"
  if [[ -e "$target" || -L "$target" ]]; then
    mkdir -p "$BACKUP_DIR"
    mv "$target" "$BACKUP_DIR/$(basename "$target")"
  fi
  mkdir -p "$(dirname "$target")"
  cp -a "$source" "$target"
}

configure_dotfiles() {
  log "Installing dotfiles (replaced files are backed up under $BACKUP_DIR)"
  backup_and_copy "$DOTFILES_DIR/.config/hypr-pure" "$HOME/.config/hypr"
  backup_and_copy "$DOTFILES_DIR/.config/waybar" "$HOME/.config/waybar"
  backup_and_copy "$DOTFILES_DIR/.config/mako" "$HOME/.config/mako"
  backup_and_copy "$DOTFILES_DIR/.config/nvim" "$HOME/.config/nvim"
  backup_and_copy "$DOTFILES_DIR/.config/ghostty" "$HOME/.config/ghostty"
  backup_and_copy "$DOTFILES_DIR/.config/starship.toml" "$HOME/.config/starship.toml"
  chmod +x "$HOME/.config/hypr/scripts/"*.sh

  mkdir -p "$HOME/.config/environment.d"
  xdg-user-dirs-update
  cat >"$HOME/.config/environment.d/terminal.conf" <<'EOF'
TERMINAL=ghostty
BROWSER=flatpak run app.zen_browser.zen
EOF
}

set_defaults() {
  log "Setting Zen as the default browser"
  xdg-mime default app.zen_browser.zen.desktop x-scheme-handler/http
  xdg-mime default app.zen_browser.zen.desktop x-scheme-handler/https
  xdg-mime default app.zen_browser.zen.desktop text/html

  # Keep the existing GNOME session Mac-like until the switch to Hyprland.
  if command -v gsettings >/dev/null; then
    gsettings set org.gnome.desktop.wm.preferences button-layout 'close,minimize,maximize:'
  fi
}

main() {
  preflight
  log "Requesting sudo access"
  sudo -v
  install_packages
  install_optional_tools
  install_flatpaks
  configure_services
  verify_hyprland_session
  configure_dotfiles
  set_defaults

  printf '\n✔ Fedora Asahi Remix Hyprland setup complete.\n'
  printf 'Reboot, choose your user in GDM, then use the gear icon to choose Hyprland.\n'
  printf 'Any replaced dotfiles were saved under: %s\n' "$BACKUP_DIR"
}

main "$@"
