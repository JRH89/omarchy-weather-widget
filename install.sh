#!/bin/bash

# Omarchy Weather Widget Installation Script
# Modular installer following DHH's Omakub pattern

set -e

# Source common functions
source scripts/common.sh

# List of installation modules
MODULES=(
    "scripts/01-system-check.sh"
    "scripts/02-dependencies.sh" 
    "scripts/03-backup.sh"
    "scripts/04-install-files.sh"
    "scripts/05-environment.sh"
    "scripts/06-waybar-config.sh"
    "scripts/07-css-styling.sh"
    "scripts/08-test.sh"
)

# Main installation flow
main() {
    echo -e "${BLUE}"
    echo "=================================="
    echo "  Omarchy Weather Widget Installer"
    echo "=================================="
    echo -e "${NC}"
    
    print_status "Starting modular installation..."
    
    # Run each module
    for module in "${MODULES[@]}"; do
        if [ -f "$module" ]; then
            print_status "Running module: $(basename "$module")"
            bash "$module"
            print_success "Completed: $(basename "$module")"
        else
            print_error "Module not found: $module"
            exit 1
        fi
    done
    
    echo -e "\n${GREEN}=================================="
    echo "  Installation Complete!"
    echo "==================================${NC}"
    echo
    if [ -f "$HOME/.config/omarchy/env" ] && ! grep -q "YOUR_API_KEY_HERE" "$HOME/.config/omarchy/env"; then
        echo -e "${GREEN}✓ API key configured successfully${NC}"
    else
        echo -e "${YELLOW}⚠ API key not configured - please add it to ~/.config/omarchy/env${NC}"
    fi
    echo
    echo -e "${BLUE}Your weather widget is now installed!${NC}"
    
    # Ask if user wants to restart Waybar now
    echo
    read -p "Restart Waybar now? (y/n): " -n 1 -r
    echo
    if [[ $REPLY =~ ^[Yy]$ ]]; then
        bash scripts/09-restart.sh
    fi
}

# Run main function
main "$@"
