#!/bin/bash

# Setup environment file and API key
set -e

source scripts/common.sh

setup_env() {
    print_status "Setting up environment configuration..."
    
    # Create omarchy config directory if it doesn't exist
    mkdir -p "$HOME/.config/omarchy"
    
    # Prompt for API key
    echo
    echo -e "${YELLOW}To get your free API key:${NC}"
    echo "1. Visit: https://openweathermap.org/api"
    echo "2. Sign up for a free account"
    echo "3. Go to 'API keys' tab and copy your key"
    echo
    
    while true; do
        read -p "Enter your OpenWeatherMap API key (or press Enter to skip): " api_key
        
        if [ -z "$api_key" ]; then
            print_warning "No API key provided. You'll need to add it later to ~/.config/omarchy/env"
            api_key="YOUR_API_KEY_HERE"
            break
        elif [ ${#api_key} -lt 10 ]; then
            print_error "API key seems too short. Please check and try again."
        else
            print_success "API key accepted"
            break
        fi
    done
    
    # Check if env file exists
    if [ -f "$HOME/.config/omarchy/env" ]; then
        if grep -q "OPENWEATHER_API_KEY" "$HOME/.config/omarchy/env"; then
            # Update existing API key
            sed -i "s/export OPENWEATHER_API_KEY=.*/export OPENWEATHER_API_KEY=\"$api_key\"/" "$HOME/.config/omarchy/env"
            print_status "Updated existing API key in ~/.config/omarchy/env"
        else
            echo "" >> "$HOME/.config/omarchy/env"
            echo "# OpenWeatherMap API Key for weather widget" >> "$HOME/.config/omarchy/env"
            echo "export OPENWEATHER_API_KEY=\"$api_key\"" >> "$HOME/.config/omarchy/env"
            print_status "Added API key to ~/.config/omarchy/env"
        fi
    else
        cat > "$HOME/.config/omarchy/env" << EOF
#!/bin/bash
# Omarchy Environment Variables

# OpenWeatherMap API Key
export OPENWEATHER_API_KEY="$api_key"
EOF
        print_status "Created ~/.config/omarchy/env with API key"
    fi
    
    chmod +x "$HOME/.config/omarchy/env"
}

setup_env
