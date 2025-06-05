#!/bin/bash

if [[ $(id -u) -ne 0 ]]; then
	echo "This script must be run with sudo or as root."
	exit 1
fi

# Global variables
new_username=""
package_list="apt_packages.txt"
snap_list="snap_packages.txt"

RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[0;33m'
NC='\033[0m'

install_apt_packages() {
	echo -e "\n#######################################"
	echo -e "# 2. System Package Installation      #"
	echo -e "#######################################"

	echo -e "${YELLOW}Installing i3"
	/usr/lib/apt/apt-helper download-file https://debian.sur5r.net/i3/pool/main/s/sur5r-keyring/sur5r-keyring_2024.03.04_all.deb keyring.deb SHA256:f9bb4340b5ce0ded29b7e014ee9ce788006e9bbfe31e96c09b2118ab91fca734
	sudo apt install ./keyring.deb
	echo "deb http://debian.sur5r.net/i3/ $(grep '^DISTRIB_CODENAME=' /etc/lsb-release | cut -f2 -d=) universe" | sudo tee /etc/apt/sources.list.d/sur5r-i3.list
	sudo apt update
	sudo apt install i3

	echo -e "${YELLOW}Installing APT packages...${NC}"
	packages=(
		"cmake"
		"pkg-config"
		"curl"
		"git"
		"htop"
		"net-tools"
		"cmake"
		"libfuse2"
		"python3-pip"
		"python3-venv"
		"python3-dev"
		"keepassxc"
		"stow"
		"picom"
		"feh"
		"dunst"
		"rofi"
		"nitrogen"
		"cowsay"
		"tmux"
		"build-essential"
		"libmagic1"
		"libpq-dev"
		"libaio1"
		"libsasl2-dev"
		"libldap2-dev"
		"libssl-dev"
		"tree"
		"libgit2-dev"
		"libldap-dev"
		"clamav-daemon"
		"redis-tools"
		"xclip"
		"blueman"
		"polybar"
    "flatpak"
    "gnome-software-plugin-flatpak"
    "autoconf"
    "maim"
    "xclip"
	)

	for package in "${packages[@]}"; do
		printf "%-50s" "$package"
		sudo apt install -y $package >/dev/null 2>&1

		if [ $? -eq 0 ]; then
			echo -e "${GREEN}[✓]${NC}"
		else
			echo -e "${RED}[✗]${NC}"
		fi
	done

	echo -e "\n${GREEN}APT package installation complete.${NC}\n"
}

install_snap_packages() {
	echo -e "\n#######################################"
	echo -e "# 3. Snap Package Installation       #"
	echo -e "#######################################"

	echo -e "${YELLOW}Installing Snap packages...${NC}"
	packages=(
		"code --classic"
		"sublime-text --classic"
		"helm --classic"
		"nvim --classic"
		"go --classic"
		"obs-studio --classic"
		"postman --classic"
		"obsidian --classic"
		"alacritty --classic"
		"dbeaver-ce"
		"trivy"
		"k6"
		"notion-snap-reborn"
	)

	echo -e "${YELLOW}Installing go packages"
	go install github.com/nats-io/natscli/nats@latest

	for package in "${packages[@]}"; do
		printf "%-50s" "$package"
		sudo snap install $package >/dev/null 2>&1

		if [ $? -eq 0 ]; then
			echo -e "${GREEN}[✓]${NC}"
		else
			echo -e "${RED}[✗]${NC}"
		fi
	done

	echo -e "\n${GREEN}Snap package installation complete.${NC}\n"
  flatpak remote-add --if-not-exists flathub https://dl.flathub.org/repo/flathub.flatpakrepo
  echo "flatpak set up" 
}



install_devtools() {
	echo -e "\n#######################################"
	echo -e "# 4. Other devtools  #"
	echo -e "#######################################"

	if ! command -v cargo &>/dev/null; then
		echo -e "${YELLOW}Installing Rust and Dependencies...${NC}"
    curl --proto '=https' --tlsv1.2 -sSf https://sh.rustup.rs | sh
	else
		echo "Rust is installed, skipping"
	fi

	if [ ! -f /opt/jetbrains/jetbrains-toolbox ]; then
		echo -e "${YELLOW}Installing JetBrains Toolbox...${NC}"
		wget https://download-cdn.jetbrains.com/toolbox/jetbrains-toolbox-2.2.3.20090.tar.gz -O jetbrainstoolbox.tar.gz
		tar -xzf jetbrainstoolbox.tar.gz
		mkdir /opt/jetbrains
		sudo cp jetbrains-toolbox-2.2.3.20090/jetbrains-toolbox /opt/jetbrains/jetbrains-toolbox
	else
		echo "Jetbrains toolbox already exists, skipping"
	fi

	if ! command -v docker &>/dev/null; then
		echo -e "${YELLOW}Installing Docker...${NC}"
		curl -fsSL https://get.docker.com -o get-docker.sh
		sh get-docker.sh
		sudo usermod -aG docker "$new_username"
	else
		echo "Docker is installed, skipping"
	fi

	echo -e "${YELLOW}Installing K3s...${NC}"
	curl -fsSL https://get.k3s.io | sh -
	chmod 444 /etc/rancher/k3s/k3s.yaml # Set ownership for k3s config
	chown $new_username:$new_username /etc/rancher/k3s/k3s.yaml
	mkdir /home/$new_username/.kube
	cp /etc/rancher/k3s/k3s.yaml /home/$new_usersname/.kube/config

	if ! command -v mons &>/dev/null; then
		echo "Installing mons"
		git clone --recursive https://github.com/Ventto/mons.git
		cd mons
		sudo make install
		cd ..
		sudo rm -rf mons
	else
		echo "mons already exists, skipping"
	fi

	if ! command -v google-chrome &>/dev/null; then
		echo -e "${YELLOW}Installing Google Chrome...${NC}"
		wget https://dl.google.com/linux/direct/google-chrome-stable_current_amd64.deb
		sudo dpkg -i google-chrome-stable_current_amd64.deb
		rm -f google-chrome-stable_current_amd64.deb # Install Google Chrome
	else
		echo "Chrome already present, skipping"
	fi

	echo -e "${YELLOW}Blocking USB access...${NC}"
	sudo touch /etc/modprobe.d/usb-storage.conf
	sudo echo "install usb-storage /bin/true" | sudo tee /etc/modprobe.d/usb-storage.conf
}

update_repo_dependencies() {
	echo -e "\n#######################################"
	echo -e "# 0. Update and Install Repo          #"
	echo -e "#######################################"

	echo -e "${GREEN}Updating package lists${NC}"
	sudo apt update -y

	echo -e "${GREEN}Upgrading existing packages${NC}"
	sudo apt upgrade -y

	echo -e "${GREEN}Adding KeepassXC repository${NC}"
	sudo add-apt-repository ppa:phoerious/keepassxc -y
}

setup_desktop_entries() {
	cat <<EOF >/usr/share/xsessions/i3.desktop
[Desktop Entry]
Name=i3
Comment=improved dynamic tiling window manager
Exec=i3
TryExec=i3
Type=Application
X-LightDM-DesktopName=i3
DesktopNames=i3
Keywords=tiling;wm;windowmanager;window;manager;
EOF
	cat <<EOF >/usr/share/applications/toolbox.desktop
[Desktop Entry]
Name=toolbox
Comment=jetbrains toolbox
Exec=/opt/jetbrains/jetbrains-toolbox
Type=Application
EOF
}

install_misc(){

  echo "installing nerdfont"
  FONT_NAME="JetBrainsMono"
  NERD_FONT_NAME="${FONT_NAME} Nerd Font"
  FONT_DIR="$HOME/.local/share/fonts/NerdFonts"
  mkdir -p "$FONT_DIR"
  echo "Downloading $NERD_FONT_NAME..."
  wget -O /tmp/${FONT_NAME}.zip "https://github.com/ryanoasis/nerd-fonts/releases/latest/download/${FONT_NAME}.zip"
  echo "Installing fonts to $FONT_DIR..."
  unzip -o /tmp/${FONT_NAME}.zip -d "$FONT_DIR"
  echo "Refreshing font cache..."
  fc-cache -fv
  rm /tmp/${FONT_NAME}.zip
  echo "$NERD_FONT_NAME installed successfully 🎉"

  echo "installing rust-based tools"
  cargo install zoxide
  cargo install starship
  cargo install ripgrep

  echo "installing go-based tools"
  go install github.com/jesseduffield/lazygit@latest
  go install github.com/nats-io/natscli/nats@latest

  echo "installing zen browser"
  flatpak install flathub app.zen_browser.zen -y

  echo "installing i3 gaps"
  apt install -y meson ninja-build libxcb1-dev libxcb-keysyms1-dev libpango1.0-dev \
libxcb-util0-dev libxcb-icccm4-dev libyajl-dev libev-dev libxcb-xkb-dev \
libxcb-cursor-dev libxkbcommon-dev libxcb-xinerama0-dev libxkbcommon-x11-dev \
libstartup-notification0-dev libxcb-randr0-dev libxcb-xrm0 libxcb-xrm-dev \
libxcb-shape0-dev build-essential git
  git clone https://www.github.com/Airblader/i3 i3-gaps
  cd i3-gaps
  meson setup build
  ninja -C build
  sudo ninja -C build install

  echo "installing virtualbox"
  echo "[*] Adding VirtualBox repository and keys..."
  sudo apt update
  sudo apt install -y wget gnupg lsb-release software-properties-common
  wget -q https://www.virtualbox.org/download/oracle_vbox_2016.asc -O- | sudo gpg --dearmor -o /usr/share/keyrings/oracle-virtualbox-archive-keyring.gpg
  echo "deb [arch=amd64 signed-by=/usr/share/keyrings/oracle-virtualbox-archive-keyring.gpg] https://download.virtualbox.org/virtualbox/debian $(lsb_release -cs) contrib" | sudo tee /etc/apt/sources.list.d/virtualbox.list
  sudo apt update
  sudo apt install -y virtualbox-7.0
  echo "[✔] VirtualBox 7 installed successfully!"

  echo 'export PATH="/home/ashu/.cargo/bin:$PATH"' >> ~/.bashrc
  echo 'export PATH="/snap/bin/go:$PATH"' >> ~/.bashrc
  echo 'export PATH="$HOME/go/bin/:$PATH"' >> ~/.bashrc
}

setup_dotfiles() {
	dotfiles_repo=""
	read -p "Enter dotfiles repo: " dotfiles_repo
	git clone $dotfiles_repo
	mkdir -p /home/$new_user/.config
	sudo cp -r dotfiles/.config /home/$new_user/.config
	sudo cp dotfiles/.bashrc /home/$new_user/.bashrc
	sudo rm -rf dotfiles
}

start_services() {
	sudo systemctl enable clamav-daemon
	sudo systemctl start clamav-daemon
	sudo systemctl status clamav-daemon
}

main() {
	update_repo_dependencies
	install_apt_packages
	install_snap_packages
	install_devtools
  install_misc
	setup_desktop_entries
	start_services
	setup_dotfiles
	sleep 5
	sudo reboot
}

main
