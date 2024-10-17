


# Set Mac Name
scutil --set ComputerName "MacMini-M1-James"

# Set Localhost
scutil --set LocalHostName "MacMini-M1-James"

# Remove Dock Items
defaults write com.apple.dock persistent-apps -array && killall Dock

# Use list view
defaults write com.apple.finder FXPreferredViewStyle -string "Nlsv"

# Show path bar
defaults write com.apple.finder ShowPathbar -bool true

# Show status bar
defaults write com.apple.finder ShowStatusBar -bool true

# Show filename extensions
defaults write NSGlobalDomain AppleShowAllExtensions -bool true

# Search the current folder by default
defaults write com.apple.finder FXDefaultSearchScope -string "SCcf"

# Keep folders on top when sorting by name
defaults write com.apple.finder _FXSortFoldersFirst -bool true && killall Finder

# Screenshots to Desktop
defaults write com.apple.screencapture "location" -string "~/Desktop"
defaults write com.apple.screencapture "show-thumbnail" -bool "false"
killall SystemUIServer





