#!/usr/bin/env bash
set -e

USER_NAME="$(whoami)"
DOTFILES_DIR="$HOME/dotfiles"

echo "==> Installing base Wayland stack"

sudo pacman -S --needed --noconfirm \
  sway \
  waybar \
  mako \
  wl-clipboard \
  grim \
  slurp \
  xdg-user-dirs \
  xdg-desktop-portal-wlr \
  polkit \
  polkit-gnome \
  acpid

echo "==> Installing fonts"

sudo pacman -S --needed --noconfirm \
  ttf-jetbrains-mono \
  noto-fonts \
  noto-fonts-emoji

if ! command -v yay >/dev/null 2>&1; then
  echo "ERROR: yay not found. Install yay first."
  exit 1
fi

echo "==> Installing AUR packages (actual daily tools)"

yay -S --needed --noconfirm \
  swaylock-effects \
  vicinae \
  ghostty \
  zen-browser-bin

echo "==> Linking dotfiles"

mkdir -p ~/.config

ln -sf "$DOTFILES_DIR/sway" ~/.config/sway
ln -sf "$DOTFILES_DIR/waybar" ~/.config/waybar
ln -sf "$DOTFILES_DIR/mako" ~/.config/mako

echo "==> bash_profile: auto-start sway"

cat > ~/.bash_profile <<'EOF'
if [[ -z "$WAYLAND_DISPLAY" && "$XDG_VTNR" == "1" ]]; then
  exec sway
fi
EOF

echo "==> Enabling TTY autologin"

sudo systemctl edit getty@tty1 <<EOF
[Service]
ExecStart=
ExecStart=-/usr/bin/agetty --autologin $USER_NAME --noclear %I \$TERM
EOF

sudo systemctl daemon-reexec
sudo systemctl enable --now acpid

echo "==> DONE"
echo "Reboot → sway → swaylock-effects → unlock → desktop"
