#!/bin/bash

#################################################
## "run this script" directions for new users! ##
#################################################

########################
## !ALACRITTY NOTICE! ##
########################

# This script works for Debian Stable BUT was intended for Unstable branch.
# alacritty theme changing WILL NOT work **(YET)** with installed .toml config files.
# I suggest building alacritty from source if you want to stay on Stable branch.
# visit https://github.com/alacritty/alacritty/blob/master/INSTALL.md#debianubuntu
# also believe me when I tell you this is your best option.. 
# I tried converting terminals but alacritty is the best IMO and it's worth building from source!

##################
## !DIRECTIONS! ##
##################

# open a terminal
# sudo apt install git dos2unix -y
# git clone https://github.com/dillacorn/dotfiles
# cd dotfiles
# chmod +x setup_installer.sh
# dos2unix setup_installer.sh
# sudo ./setup_installer.sh
# follow installer

#################################################
##              end of directions              ##
#################################################

# Install git if it's not already installed
apt update
apt install -y git

# Clone the dotfiles repository into the home directory if it doesn't already exist
if [ ! -d "/home/$SUDO_USER/dotfiles" ]; then
    git clone https://github.com/dillacorn/dotfiles "/home/$SUDO_USER/dotfiles"
    if [ $? -ne 0 ]; then
        echo "Failed to clone the dotfiles repository. Exiting."
        exit 1
    fi
else
    echo "dotfiles repository already exists in /home/$SUDO_USER"
fi

# Navigate to ~/dotfiles/scripts and make scripts executable
cd "/home/$SUDO_USER/dotfiles/scripts" || exit
chmod +x *

# Run install_my_i3_apps.sh and install_my_flatpaks.sh before proceeding
echo "Running install_my_i3_apps.sh..."
./install_my_i3_apps.sh
if [ $? -ne 0 ]; then
    echo "install_my_i3_apps.sh failed. Exiting."
    exit 1
fi

#echo "Running install_my_flatpaks.sh..."
./install_my_flatpaks.sh
if [ $? -ne 0 ]; then
    echo "install_my_flatpaks.sh failed. Exiting."
    exit 1
fi

# Run other scripts
./ranger_image_preview.sh

# Copy X11 configuration
echo "You may need to run the following command with sudo:"
echo "cp /home/$SUDO_USER/dotfiles/etc/X11/xinit/xinitrc /etc/X11/xinit"
cp "/home/$SUDO_USER/dotfiles/etc/X11/xinit/xinitrc" /etc/X11/xinit/
if [ $? -ne 0 ]; then
    echo "Failed to copy xinitrc. Exiting."
    exit 1
fi

# Copy other configuration files
echo "Copying Xresources..."
cp "/home/$SUDO_USER/dotfiles/Xresources" "/home/$SUDO_USER/.Xresources"
if [ $? -ne 0 ]; then
    echo "Failed to copy Xresources. Exiting."
    exit 1
fi

echo "Copying alacritty config..."
cp -r "/home/$SUDO_USER/dotfiles/config/alacritty" "/home/$SUDO_USER/.config"
if [ $? -ne 0 ]; then
    echo "Failed to copy alacritty config. Exiting."
    exit 1
fi

echo "Copying dunst config..."
cp -r "/home/$SUDO_USER/dotfiles/config/dunst" "/home/$SUDO_USER/.config"
if [ $? -ne 0 ]; then
    echo "Failed to copy dunst config. Exiting."
    exit 1
fi

echo "Copying i3 config..."
cp -r "/home/$SUDO_USER/dotfiles/config/i3" "/home/$SUDO_USER/.config"
if [ $? -ne 0 ]; then
    echo "Failed to copy i3 config. Exiting."
    exit 1
fi

echo "Copying rofi config..."
cp -r "/home/$SUDO_USER/dotfiles/config/rofi" "/home/$SUDO_USER/.config"
if [ $? -ne 0 ]; then
    echo "Failed to copy rofi config. Exiting."
    exit 1
fi

# Wait for files to appear
echo "Waiting for configuration files to be available..."
for file in "/home/$SUDO_USER/.config/i3/custom_res.sh" "/home/$SUDO_USER/.config/i3/i3exit.sh" "/home/$SUDO_USER/.config/i3/rotate_configs.sh"; do
    while [ ! -f "$file" ]; do
        echo "Waiting for $file to appear..."
        sleep 1
    done
done

# Set directory permissions
echo "Setting permissions on configuration files and directories..."
find /home/$SUDO_USER/.config/ -type d -exec chmod 755 {} +
find /home/$SUDO_USER/.config/ -type f -exec chmod 644 {} +

# Make specific i3-related scripts executable after setting general permissions
echo "Making i3-related scripts executable..."
chmod 755 "/home/$SUDO_USER/.config/i3/custom_res.sh"
chmod 755 "/home/$SUDO_USER/.config/i3/i3exit.sh"
chmod 755 "/home/$SUDO_USER/.config/i3/rotate_configs.sh"

# Make all files in the themes folder executable
echo "Making all files in /home/$SUDO_USER/.config/i3/themes executable..."
chmod 755 /home/$SUDO_USER/.config/i3/themes/*

# Navigate to alacritty and make the installation script executable
cd "/home/$SUDO_USER/.config/alacritty" || exit
chmod 755 install_alacritty_themes.sh
./install_alacritty_themes.sh

# Copy .desktop files to local applications directory
echo "You may need to run the following command with sudo:"
echo "cp -r /home/$SUDO_USER/dotfiles/local/share/applications/. /home/$SUDO_USER/.local/share/applications"
cp -r "/home/$SUDO_USER/dotfiles/local/share/applications/." "/home/$SUDO_USER/.local/share/applications"
if [ $? -ne 0 ]; then
    echo "Failed to copy .desktop files. Exiting."
    exit 1
fi

# Set alternatives for editor and terminal emulator
echo "You may need to run the following commands with sudo:"
echo "update-alternatives --set editor /usr/bin/micro"
echo "update-alternatives --set x-terminal-emulator /usr/bin/alacritty"
update-alternatives --set editor /usr/bin/micro
update-alternatives --set x-terminal-emulator /usr/bin/alacritty

# Set default file manager for directories
xdg-mime default thunar.desktop inode/directory application/x-gnome-saved-search

# Change ownership of all files in .config to the sudo user
chown -R $SUDO_USER:$SUDO_USER /home/$SUDO_USER/.config

echo "All tasks completed!"
