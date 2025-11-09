#!/bin/bash

# Update CSS styles
set -e

source scripts/common.sh

update_css() {
    print_status "Updating CSS styles..."
    
    CSS_FILE="$HOME/.config/waybar/style.css"
    
    # Check if weather styles already exist
    if grep -q "#custom-weather" "$CSS_FILE"; then
        print_warning "Weather styles already exist in CSS"
        return
    fi
    
    # Add weather styles
    cat >> "$CSS_FILE" << 'EOF'

/* Weather Widget Styles */
#custom-weather {
  margin-left: 10px;
  margin-right: 15px;
  font-size: 12px;
}
EOF
    
    print_success "CSS styles updated"
}

update_css
