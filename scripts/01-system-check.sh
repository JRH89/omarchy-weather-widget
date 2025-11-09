#!/bin/bash

# System Compatibility Check
set -e

source scripts/common.sh

check_system() {
    print_status "Checking system compatibility..."
    
    if [ ! -d "$HOME/.config/waybar" ]; then
        print_error "Waybar config directory not found. Are you running Omarchy?"
        exit 1
    fi
    
    if ! command -v python3 &> /dev/null; then
        print_error "Python 3 is required but not installed."
        exit 1
    fi
    
    print_success "System compatibility verified"
}

check_system
