#!/bin/bash

# Restart Waybar
set -e

source scripts/common.sh

restart_waybar() {
    print_status "Restarting Waybar..."
    
    # Try systemd first (preferred in Omarchy)
    if systemctl --user is-active --quiet waybar 2>/dev/null; then
        systemctl --user restart waybar
        print_success "Waybar restarted via systemd"
        return 0
    fi
    
    # Fall back to manual process management
    if pgrep -x "waybar" > /dev/null; then
        killall -q waybar
        sleep 2
    fi
    
    # Start Waybar detached from terminal
    nohup waybar >/dev/null 2>&1 &
    print_success "Waybar restarted manually"
}

restart_waybar
