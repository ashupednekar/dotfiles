/bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"

#main stuff
brew install zen-browser
brew install nvim
brew install --cask ghostty
brew install koekeishiya/formulae/yabai
brew install koekeishiya/formulae/skhd

# Languages 
curl --proto '=https' --tlsv1.2 -sSf https://sh.rustup.rs | sh 
brew install go
brew install python@3.11
brew install lua

# Fonts
brew install --cask sf-symbols
brew install --cask font-sf-mono
brew install --cask font-sf-pro
brew install --cask font-jetbrains-mono

# Misc 
cargo install starship
cargo install zoxide
go install github.com/jesseduffield/lazygit@latest
brew install --cask microsoft-teams
brew install --cask rancher
brew tap FelixKratz/formulae
brew install awscli
brew install sketchybar
curl -L https://github.com/kvndrsslr/sketchybar-app-font/releases/download/v2.0.28/sketchybar-app-font.ttf -o $HOME/Library/Fonts/sketchybar-app-font.ttf
brew install helm
brew install kubectl

#Sketchybar
osascript -e 'tell application "System Events" to set autohide menu bar of dock preferences to true'
osascript -e 'tell application "System Events" to set autohide menu bar of dock preferences to false'
brew tap FelixKratz/formulae
brew install sketchybar
mkdir -p ~/.config/sketchybar/plugins
cp /opt/homebrew/opt/sketchybar/share/sketchybar/examples/sketchybarrc ~/.config/sketchybar/sketchybarrc
cp -r /opt/homebrew/opt/sketchybar/share/sketchybar/examples/plugins/ ~/.config/sketchybar/plugins/
chmod +x ~/.config/sketchybar/plugins/*
brew services restart felixkratz/formulae/sketchybar
brew services start sketchybar
sketchybar --reload
brew tap homebrew/cask-fonts
brew install --cask font-hack-nerd-font
brew install --cask font-meslo-lg-nerd-font
brew install --cask sf-symbols
brew install jq
brew install gh
brew install switchaudio-osx
curl -L https://github.com/kvndrsslr/sketchybar-app-font/releases/download/v1.0.23/sketchybar-app-font.ttf -o $HOME/Library/Fonts/sketchybar-app-font.ttf
sketchybar --reload

