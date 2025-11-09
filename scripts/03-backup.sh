#!/bin/bash

# Backup existing files
set -e

source scripts/common.sh

backup_files() {
    print_status "Backing up existing files..."
    
    BACKUP_DIR="$HOME/.config/waybar/backup-$(date +%Y%m%d-%H%M%S)"
    mkdir -p "$BACKUP_DIR"
    
    if [ -f "$HOME/.config/waybar/weather.py" ]; then
        cp "$HOME/.config/waybar/weather.py" "$BACKUP_DIR/"
        print_status "Backed up existing weather.py"
    fi
    
    if [ -f "$HOME/.config/waybar/weather-widget.sh" ]; then
        cp "$HOME/.config/waybar/weather-widget.sh" "$BACKUP_DIR/"
        print_status "Backed up existing weather-widget.sh"
    fi
}

backup_files
