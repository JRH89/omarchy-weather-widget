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
    
    # Start Waybar detached from terminal
    nohup waybar >/dev/null 2>&1 &
    print_success "Waybar restarted"
}

restart_waybar
