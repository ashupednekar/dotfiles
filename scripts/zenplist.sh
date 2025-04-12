wget https://raw.githubusercontent.com/mcandre/dotfiles/refs/heads/main/src/setenv.MOZ_DISABLE_SAFE_MODE_KEY.plist 
cp setenv.MOZ_DISABLE_SAFE_MODE_KEY.plist "$HOME/Library/LaunchAgents/"
launchctl load -w "$HOME/Library/LaunchAgents/setenv.MOZ_DISABLE_SAFE_MODE_KEY.plist"
