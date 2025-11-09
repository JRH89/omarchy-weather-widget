#!/bin/bash

# Install widget files
set -e

source scripts/common.sh

install_files() {
    print_status "Installing weather widget files..."
    
    # Copy Python script
    cp weather.py "$HOME/.config/waybar/"
    chmod +x "$HOME/.config/waybar/weather.py"
    
    # Copy shell script
    cp weather-widget.sh "$HOME/.config/waybar/"
    chmod +x "$HOME/.config/waybar/weather-widget.sh"
    
    print_success "Widget files installed"
}

install_files
