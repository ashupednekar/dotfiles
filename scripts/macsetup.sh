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
brew install sketchybar
brew install awscli
brew tap FelixKratz/formulae
brew install sketchybar
curl -L https://github.com/kvndrsslr/sketchybar-app-font/releases/download/v2.0.28/sketchybar-app-font.ttf -o $HOME/Library/Fonts/sketchybar-app-font.ttf
brew install helm
brew install kubectl

