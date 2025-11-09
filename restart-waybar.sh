#!/bin/bash

# Simple Waybar restart script for Omarchy
set -e

# Colors
GREEN='\033[0;32m'
BLUE='\033[0;34m'
YELLOW='\033[1;33m'
NC='\033[0m'

print_status() {
    echo -e "${BLUE}[INFO]${NC} $1"
}

print_success() {
    echo -e "${GREEN}[SUCCESS]${NC} $1"
}

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
        print_status "Stopping existing Waybar process..."
        killall -q waybar
        sleep 2
    fi
    
    # Start Waybar detached from terminal
    print_status "Starting Waybar..."
    nohup waybar >/dev/null 2>&1 &
    print_success "Waybar restarted manually"
}

echo -e "${BLUE}=================================="
echo "  Waybar Restart Script"
echo "==================================${NC}"
echo

restart_waybar

echo
echo -e "${BLUE}Waybar has been restarted!${NC}"
echo -e "${YELLOW}If you don't see the bar, try:${NC}"
echo -e "${YELLOW}  systemctl --user restart waybar${NC}"
echo -e "${YELLOW}  # or${NC}"
echo -e "${YELLOW}  waybar &${NC}"
