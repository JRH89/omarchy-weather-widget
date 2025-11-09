#!/bin/bash

# Weather Widget for Waybar in Omarchy Linux
# This script sources environment variables and runs the Python weather script

# Source Omarchy environment variables
source ~/.config/omarchy/env

# Get the directory of this script
SCRIPT_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" &> /dev/null && pwd )"

# Make the Python script executable if it's not already
chmod +x "$SCRIPT_DIR/weather.py"

# Show current weather by default
if [ "$1" = "--forecast" ]; then
    # Show forecast in tooltip
    "$SCRIPT_DIR/weather.py" --forecast
else
    # Show current weather in status bar
    "$SCRIPT_DIR/weather.py"
fi

exit 0
