#!/bin/bash

# Restart Waybar
set -e

source scripts/common.sh

restart_waybar() {
    print_status "Restarting Waybar..."
    
    if pgrep -x "waybar" > /dev/null; then
        killall -q waybar
        sleep 2
    fi
    
    waybar &
    print_success "Waybar restarted"
}

restart_waybar
