#!/bin/bash

# Omarchy Weather Widget Uninstall Script

set -e

# Colors
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m'

print_status() {
    echo -e "${BLUE}[INFO]${NC} $1"
}

print_success() {
    echo -e "${GREEN}[SUCCESS]${NC} $1"
}

print_warning() {
    echo -e "${YELLOW}[WARNING]${NC} $1"
}

print_error() {
    echo -e "${RED}[ERROR]${NC} $1"
}

# Remove widget files
remove_files() {
    print_status "Removing weather widget files..."
    
    if [ -f "$HOME/.config/waybar/weather.py" ]; then
        rm "$HOME/.config/waybar/weather.py"
        print_success "Removed weather.py"
    fi
    
    if [ -f "$HOME/.config/waybar/weather-widget.sh" ]; then
        rm "$HOME/.config/waybar/weather-widget.sh"
        print_success "Removed weather-widget.sh"
    fi
}

# Clean Waybar config
clean_waybar_config() {
    print_status "Cleaning Waybar configuration..."
    
    CONFIG_FILE="$HOME/.config/waybar/config.jsonc"
    
    if [ -f "$CONFIG_FILE" ]; then
        # Use Python to properly clean the JSON configuration
        python3 << EOF
import json
import sys

config_file = "$CONFIG_FILE"

try:
    with open(config_file, 'r') as f:
        config = json.load(f)
    
    # Remove weather widget from modules arrays
    for module_list in ['modules-left', 'modules-center', 'modules-right']:
        if module_list in config and 'custom/weather' in config[module_list]:
            config[module_list].remove('custom/weather')
    
    # Remove custom/weather configuration
    if 'custom/weather' in config:
        del config['custom/weather']
    
    # Write back to file with proper formatting
    with open(config_file, 'w') as f:
        json.dump(config, f, indent=2)
    
    print("Waybar configuration cleaned successfully")
    
except Exception as e:
    print(f"Error cleaning config: {e}")
    sys.exit(1)
EOF
        
        print_success "Cleaned Waybar configuration"
    fi
}

# Clean CSS styles
clean_css() {
    print_status "Cleaning CSS styles..."
    
    CSS_FILE="$HOME/.config/waybar/style.css"
    
    if [ -f "$CSS_FILE" ]; then
        # Remove weather widget styles
        sed -i '/#custom-weather {/,/}/d' "$CSS_FILE"
        sed -i '/\/\* Weather Widget Styles \*\//,/}/d' "$CSS_FILE"
        
        print_success "Cleaned CSS styles"
    fi
}

# Restart Waybar
restart_waybar() {
    print_status "Restarting Waybar..."
    
    if pgrep -x "waybar" > /dev/null; then
        killall -q waybar
        sleep 2
    fi
    
    # Start Waybar detached from terminal
    nohup waybar >/dev/null 2>&1 &
    print_success "Waybar restarted"
}

main() {
    echo -e "${BLUE}"
    echo "=================================="
    echo "  Omarchy Weather Widget Uninstaller"
    echo "=================================="
    echo -e "${NC}"
    
    echo -e "${RED}WARNING: This will remove the weather widget from your system.${NC}"
    echo
    read -p "Are you sure you want to continue? (y/n): " -n 1 -r
    echo
    if [[ ! $REPLY =~ ^[Yy]$ ]]; then
        echo "Uninstall cancelled."
        exit 0
    fi
    
    remove_files
    clean_waybar_config
    clean_css
    
    echo -e "\n${GREEN}=================================="
    echo "  Uninstall Complete!"
    echo "==================================${NC}"
    echo
    echo -e "${YELLOW}Note:${NC} Your API key in ~/.config/omarchy/env was not removed."
    echo "If you want to remove it, edit the file manually."
    echo
    
    read -p "Restart Waybar now? (y/n): " -n 1 -r
    echo
    if [[ $REPLY =~ ^[Yy]$ ]]; then
        restart_waybar
    fi
}

main "$@"
