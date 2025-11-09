#!/bin/bash

# Test installation
set -e

source scripts/common.sh

test_installation() {
    print_status "Testing weather widget..."
    
    if [ -f "$HOME/.config/omarchy/env" ] && grep -q "YOUR_API_KEY_HERE" "$HOME/.config/omarchy/env"; then
        print_warning "API key was not set during installation. Please update it in ~/.config/omarchy/env"
        echo "Get your free API key from: https://openweathermap.org/api"
    else
        print_success "API key is configured"
    fi
    
    # Test the widget script
    if "$HOME/.config/waybar/weather-widget.sh" >/dev/null 2>&1; then
        print_success "Widget script test passed"
    else
        print_warning "Widget script test failed (may need API key)"
    fi
}

test_installation
