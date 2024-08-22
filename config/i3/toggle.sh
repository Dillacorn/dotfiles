#!/bin/bash

# This script copies "super.config" to sway "config" and/or "mixture.config" to sway "config".
# Purpose: toggle MOD functionality. -> mixture.config = mixture mod1+mod4 keybinds | super.config = mod4(win/super) only keybinds

# Paths to the files
config=~/.config/i3/config
mixture_config=~/.config/i3/mixture.config
super_config=~/.config/i3/super.config

# Determine which config is currently active
if cmp -s "$config" "$super_config"; then
    echo "Switching to default config..."
    cp "$mixture_config" "$config"
else
    echo "Switching to windowed config..."
    cp "$super_config" "$config"
fi

# Reload the sway window manager
i3 reload
