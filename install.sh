#!/bin/bash

# Omarchy Weather Widget Installation Script
# Installs the weather widget for Waybar in Omarchy Linux

set -e

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Function to print colored output
print_status() {
    echo -e "${BLUE}[INFO]${NC} $1"
}

print_success() {
    echo -e "${GREEN}[SUCCESS]${NC} $1"
}

print_warning() {
    echo -e "${YELLOW}[WARNING]${NC} $1"
}

print_error() {
    echo -e "${RED}[ERROR]${NC} $1"
}

# Check if running on Omarchy/Linux
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

# Install Python dependencies
install_dependencies() {
    print_status "Installing Python dependencies..."
    
    if ! python3 -c "import requests" 2>/dev/null; then
        print_status "Installing requests module..."
        pip3 install requests --user
    else
        print_success "requests module already installed"
    fi
}

# Backup existing files
backup_files() {
    print_status "Backing up existing files..."
    
    BACKUP_DIR="$HOME/.config/waybar/backup-$(date +%Y%m%d-%H%M%S)"
    mkdir -p "$BACKUP_DIR"
    
    if [ -f "$HOME/.config/waybar/weather.py" ]; then
        cp "$HOME/.config/waybar/weather.py" "$BACKUP_DIR/"
        print_status "Backed up existing weather.py"
    fi
    
    if [ -f "$HOME/.config/waybar/weather-widget.sh" ]; then
        cp "$HOME/.config/waybar/weather-widget.sh" "$BACKUP_DIR/"
        print_status "Backed up existing weather-widget.sh"
    fi
}

# Install widget files
install_files() {
    print_status "Installing weather widget files..."
    
    # Copy Python script
    cp weather.py "$HOME/.config/waybar/"
    chmod +x "$HOME/.config/waybar/weather.py"
    
    # Copy shell script
    cp weather-widget.sh "$HOME/.config/waybar/"
    chmod +x "$HOME/.config/waybar/weather-widget.sh"
    
    print_success "Widget files installed"
}

# Setup environment file
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

# Update Waybar config
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
    
    # Add weather widget to modules-center
    sed -i 's/"modules-center": \["clock", "custom\/update", "custom\/screenrecording-indicator"/"modules-center": ["clock", "custom\/weather", "custom\/update", "custom\/screenrecording-indicator"/g' "$CONFIG_FILE"
    
    # Add weather widget configuration
    cat >> "$CONFIG_FILE" << 'EOF'

  "custom/weather": {
    "exec": "~/.config/waybar/weather-widget.sh --forecast",
    "return-type": "json",
    "interval": 900,
    "tooltip": true
  },
EOF
    
    print_success "Waybar configuration updated"
}

# Update CSS styles
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

# Test installation
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

# Restart Waybar
restart_waybar() {
    print_status "Restarting Waybar..."
    
    if pgrep -x "waybar" > /dev/null; then
        killall -q waybar
        sleep 2
    fi
    
    waybar &
    print_success "Waybar restarted"
}

# Main installation flow
main() {
    echo -e "${BLUE}"
    echo "=================================="
    echo "  Omarchy Weather Widget Installer"
    echo "=================================="
    echo -e "${NC}"
    
    check_system
    install_dependencies
    backup_files
    install_files
    setup_env
    update_waybar_config
    update_css
    test_installation
    
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
        restart_waybar
    fi
}

# Run main function
main "$@"
