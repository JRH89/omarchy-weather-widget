#!/bin/bash

# Get the directory where this script is located
SCRIPT_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" &> /dev/null && pwd )"

# Run the Python script with the API key and forecast flag
python3 "$SCRIPT_DIR/weather_widget.py" --api-key "$OPENWEATHER_API_KEY" --forecast

exit 0
