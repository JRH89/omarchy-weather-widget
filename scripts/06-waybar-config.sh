#!/bin/bash

# Update Waybar configuration
set -e

source scripts/common.sh

update_waybar_config() {
    print_status "Updating Waybar configuration..."
    
    CONFIG_FILE="$HOME/.config/waybar/config.jsonc"
    
    # Check if weather widget is already configured
    if grep -q "custom/weather" "$CONFIG_FILE"; then
        print_warning "Weather widget already configured in Waybar"
        return
    fi
    
    # Create backup of config
    cp "$CONFIG_FILE" "$CONFIG_FILE.backup-$(date +%Y%m%d-%H%M%S)"
    
    # Use Python to properly update the JSON configuration
    python3 << EOF
import json
import sys

config_file = "$CONFIG_FILE"

try:
    with open(config_file, 'r') as f:
        config = json.load(f)
    
    # Add weather widget to modules-center if it exists
    if 'modules-center' in config:
        if 'custom/weather' not in config['modules-center']:
            config['modules-center'].insert(1, 'custom/weather')
    
    # Add weather widget configuration
    config['custom/weather'] = {
        "exec": "~/.config/waybar/weather-widget.sh --forecast",
        "return-type": "json",
        "interval": 900,
        "tooltip": True
    }
    
    # Write back to file with proper formatting
    with open(config_file, 'w') as f:
        json.dump(config, f, indent=2)
    
    print("Waybar configuration updated successfully")
    
except Exception as e:
    print(f"Error updating config: {e}")
    sys.exit(1)
EOF
    
    if [ $? -eq 0 ]; then
        print_success "Waybar configuration updated"
    else
        print_error "Failed to update Waybar configuration"
        return 1
    fi
}

update_waybar_config
