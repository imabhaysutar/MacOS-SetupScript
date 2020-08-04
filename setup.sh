#!/bin/sh
SECONDS=0 #used to get time elapsed at the end

# Check if running macOS
if ! [[ "$OSTYPE" =~ darwin* ]]; then
  echo "This is meant to be run on macOS only"
  exit
fi

# Sudo permissions
function ask_for_sudo() {
    info "Prompting for sudo password"
    if sudo --validate; then
        # Keep-alive
        while true; do sudo --non-interactive true; \
            sleep 10; kill -0 "$$" || exit; done 2>/dev/null &
        success "Sudo password updated"
    else
        error "Sudo password update failed"
        exit 1
    fi
}


# XCode Command Line Tools
echo "Installing Xcode CLI tools..."
xcode-select -p
if [ $? -eq 0 ]; then
    echo "Found XCode Tools"
else
    echo "Installing XCode Tools"

    xcode-select --install
fi

# Chage shell script files to run
chmod +x *.sh

# *******************************************************************************
# Homebrew / 01

# Install Homebrew
echo "Installing Homebrew"
/bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/master/install.sh)"
brew update
echo "Homebrew is Ready!"

echo "Installing all binaries and applications from Brewfile"
brew bundle # install all stuff from brew from Brewfile

# Cleanup
echo "Cleaning up"
brew cleanup

# *******************************************************************************
# System Settings 
# *******************************************************************************
echo "Making changes to System Settings"
    
    # Disable Gatekeeper for getting rid of unknown developers error
    sudo spctl --master-disable
    # Disable natural scrolling
    ####defaults write NSGlobalDomain com.apple.swipescrolldirection -bool false
    # Disable macOS startup chime sound
    ####sudo defaults write com.apple.loginwindow LoginHook $LOGIN_HOOK_PATH
    ####sudo defaults write com.apple.loginwindow LogoutHook $LOGOUT_HOOK_PATH
    # Enable tap to click
    defaults write com.apple.AppleMultitouchTrackpad Clicking -bool true
    # Configure keyboard repeat https://apple.stackexchange.com/a/83923/200178
    defaults write -g InitialKeyRepeat -int 15
    defaults write -g KeyRepeat -int 2
    # Disable "Correct spelling automatically"
    defaults write -g NSAutomaticSpellingCorrectionEnabled -bool false
    # Enable full keyboard access for all controls which enables Tab selection in modal dialogs
    ####defaults write NSGlobalDomain AppleKeyboardUIMode -int 3
    # Show battery percentage in menu bar
    ####defaults write com.apple.systemuiserver "NSStatusItem Visible com.apple.menuextra.battery" -bool true
    ####defaults write com.apple.menuextra.battery '{ ShowPercent = YES; }'


# *******************************************************************************
# Configure Dock
# *******************************************************************************
echo "Making changes to Dock"
    quit "Dock"
    # Don’t show recent applications in Dock
    defaults write com.apple.dock show-recents -bool false
    # Set the icon size of Dock items to 36 pixels
    defaults write com.apple.dock tilesize -int 36
    # Remove all (default) app icons from the Dock
    defaults write com.apple.dock persistent-apps -array
    defaults write com.apple.dock recent-apps -array
    # Show only open applications in the Dock
    ####defaults write com.apple.dock static-only -bool true
    # Don’t animate opening applications from the Dock
    ####defaults write com.apple.dock launchanim -bool false
    # Disable Dashboard
    defaults write com.apple.dashboard mcx-disabled -bool true
    # Don’t show Dashboard as a Space
    defaults write com.apple.dock dashboard-in-overlay -bool true
    # Automatically hide and show the Dock
    ####defaults write com.apple.dock autohide -bool true
    # Remove the auto-hiding Dock delay
    ####defaults write com.apple.dock autohide-delay -float 0
    # Disable the Launchpad gesture (pinch with thumb and three fingers)
    defaults write com.apple.dock showLaunchpadGestureEnabled -int 0
    # Disable automatically rearranging of Spaces based on most recent use
    defaults write com.apple.dock mru-spaces -bool false

    # List of dock icons
    dockIcons=(
    /System/Applications/Launchpad.app
    /Applications/Safari.app
    /Applications/Notion.app
    /Applications/Spotify.app
    /System/Applications/Utilities/Terminal.app
    /Applications/Visual Studio Code.app
    /Applications/Telegram.app
    # Adding icons
    for icon in "${dockIcons[@]}"
    do
    echo "Adding $icon to the dock…"
    defaults write com.apple.dock persistent-apps -array-add "<dict><key>tile-data</key><dict><key>file-data</key><dict><key>_CFURLString</key><string>$icon</string><key>_CFURLStringType</key><integer>0</integer></dict></dict></dict>"
    done

# *******************************************************************************
# Configure Hotcorners
# *******************************************************************************
echo "Enabling Hot Corners"
    ## Hot corners
    ## Possible values:
    ##  0: no-op
    ##  2: Mission Control
    ##  3: Show application windows
    ##  4: Desktop
    ##  5: Start screen saver
    ##  6: Disable screen saver
    ##  7: Dashboard
    ## 10: Put display to sleep
    ## 11: Launchpad
    ## 12: Notification Center
    ## Top left screen corner → Nothing
    defaults write com.apple.dock wvous-tl-corner -int 0
    defaults write com.apple.dock wvous-tl-modifier -int 0
    ## Top right screen corner → Nothing
    defaults write com.apple.dock wvous-tr-corner -int 0
    defaults write com.apple.dock wvous-tr-modifier -int 0
    ## Bottom left screen corner → Mission Control
    defaults write com.apple.dock wvous-bl-corner -int 2
    defaults write com.apple.dock wvous-bl-modifier -int 2
    ## Bottom right screen corner → Desktop
    defaults write com.apple.dock wvous-br-corner -int 4
    defaults write com.apple.dock wvous-br-modifier -int 4
    open "Dock"

# *******************************************************************************
# Configure Finder
# *******************************************************************************
echo "Changing Finder Preferences"
    # Save screenshots to Downloads folder
    defaults write com.apple.screencapture location -string "${HOME}/Downloads"
    # Require password immediately after sleep or screen saver begins
    defaults write com.apple.screensaver askForPassword -int 1
    defaults write com.apple.screensaver askForPasswordDelay -int 0
    # allow quitting via ⌘ + q; doing so will also hide desktop icons
    defaults write com.apple.finder QuitMenuItem -bool true
    # disable window animations and Get Info animations
    defaults write com.apple.finder DisableAllAnimations -bool true
    # Set Downloads as the default location for new Finder windows
    defaults write com.apple.finder NewWindowTarget -string "PfLo"
    defaults write com.apple.finder NewWindowTargetPath -string \
        "file://${HOME}/Downloads/"
    # disable status bar
    defaults write com.apple.finder ShowStatusBar -bool false
    # enable path bar
    defaults write com.apple.finder ShowPathbar -bool true
    # Display full POSIX path as Finder window title
    ####defaults write com.apple.finder _FXShowPosixPathInTitle -bool true
    # Keep folders on top when sorting by name
    defaults write com.apple.finder _FXSortFoldersFirst -bool true
    # When performing a search, search the current folder by default
    defaults write com.apple.finder FXDefaultSearchScope -string "SCcf"
    # Disable disk image verification
    defaults write com.apple.frameworks.diskimages \
        skip-verify -bool true
    defaults write com.apple.frameworks.diskimages \
        skip-verify-locked -bool true
    defaults write com.apple.frameworks.diskimages \
        skip-verify-remote -bool true
    # Use list view in all Finder windows by default
    # Four-letter codes for view modes: icnv, clmv, Flwv, Nlsv
    defaults write com.apple.finder FXPreferredViewStyle -string clmv
    # Disable the warning before emptying the Trash
    defaults write com.apple.finder WarnOnEmptyTrash -bool false
    # Display file extensions in Finder
    ####defaults write NSGlobalDomain AppleShowAllExtensions -bool true
    # Disable the warning when changing a file extension
    defaults write com.apple.finder FXEnableExtensionChangeWarning -bool false
    # Disable screenshot preview thumbnails
    ####defaults write com.apple.screencapture show-thumbnail -bool false

# *******************************************************************************
# Cleaning up
# *******************************************************************************

echo "Cleaning up..."
#Check if running as root and if not elevate
amiroot=$(sudo -n uptime 2>&1 | grep -c "load")
if [ "$amiroot" -eq 0 ]; then
	printf "Maid Service Require Root Access. Please Enter Your Password.\n"
	sudo -v
	printf "\n"
fi

#Install Updates.
printf "Installing needed updates.\n"
softwareupdate -i -a >/dev/null 2>&1

# from https://github.com/jgamblin/MacOS-Maid
#Taking out the trash.
printf "Emptying the trash.\n"
sudo rm -rfv /Volumes/*/.Trashes >/dev/null 2>&1
sudo rm -rfv ~/.Trash >/dev/null 2>&1

#Clean the logs.
printf "Emptying the system log files.\n"
sudo rm -rfv /private/var/log/* >/dev/null 2>&1
sudo rm -rfv /Library/Logs/DiagnosticReports/* >/dev/null 2>&1

printf "Deleting the quicklook files.\n"
sudo rm -rf /private/var/folders/ >/dev/null 2>&1

#Cleaning Up Homebrew.
printf "Cleaning up Homebrew.\n"

brew update >/dev/null 2>&1
brew upgrade >/dev/null 2>&1
mas upgrade
brew cask upgrade
brew cleanup --force -s >/dev/null 2>&1
brew cask cleanup >/dev/null 2>&1
rm -rfv /Library/Caches/Homebrew/* >/dev/null 2>&1
brew tap --repair >/dev/null 2>&1

#Cleaning Up Ruby.
printf "Cleanup up Ruby.\n"
gem cleanup >/dev/null 2>&1

# Kill affected applications
for app in "Activity Monitor" "Calendar" "Contacts" "cfprefsd" \
	"Dock" "Finder" "Mail" "Messages" \
	"Safari" "SystemUIServer" \
	; do
	killall "${app}" &>/dev/null
done

#Purging Memory.
printf "Purging memory.\n"
sudo purge >/dev/null 2>&1

#Securly Erasing Data.
printf "Securely erasing free space (This will take a while). \n"
diskutil secureErase freespace 0 "$(df -h / | tail -n 1 | awk '{print $1}')" >/dev/null 2>&1
echo "ok"

# *******************************************************************************
# Finishing
ELAPSED="Elapsed: $((SECONDS / 3600))hrs $((SECONDS / 60 % 60))min $((SECONDS % 60))sec"

echo "time Elapsed : ""$ELAPSED"" !"

echo "Almost done"
read -r -p "Do you wanna restart your mac to apply all changes ? [y|n] " response
if [[ -z $response || $response =~ ^(y|Y) ]]; then
  echo "Restarting..."
  osascript -e 'tell app "System Events" to restart'
  exit
fi
