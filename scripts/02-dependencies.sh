#!/bin/bash

# Install Python dependencies
set -e

source scripts/common.sh

install_dependencies() {
    print_status "Installing Python dependencies..."
    
    if ! python3 -c "import requests" 2>/dev/null; then
        print_status "Installing requests module..."
        pip3 install requests --user
    else
        print_success "requests module already installed"
    fi
}

install_dependencies
