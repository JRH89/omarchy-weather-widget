# Omarchy Weather Widget

A beautiful weather widget for Waybar in Omarchy that displays current weather with a 3-day forecast on hover.

<img src="https://drive.google.com/uc?export=view&id=1YlIQZvLBQx4EqYwSdEpZS0tY_2f7MSnb" alt="image" />
<img src="https://drive.google.com/uc?export=view&id=1h31Ez6vgHg5Qun5NdB_-QTPGVk-3ud3l" alt="image" />




## 🌟 Features

- 🌤️ **Current weather** with emoji icons that change based on conditions
- 🌡️ **Temperature display** in Fahrenheit or Celsius
- 📍 **Automatic location detection** via IP geolocation
- 📅 **3-day forecast** on hover with detailed weather information
- ⚡ **Smart caching** to reduce API calls and improve performance
- 🔧 **Easy installation** with automated setup script
- 🎨 **Customizable styling** to match your Omarchy theme
- 🔄 **Automatic updates** every 15 minutes (configurable)

## 📸 Preview

### Normal State
```
☀️ 72°F
```

### Hover State (Tooltip)
```
📍 San Francisco, US
☀️ Clear Sky - 72°F (Feels like 75°F)
💨 Wind: 5 mph NW
💧 Humidity: 65%
🌅 Sunrise: 6:42 AM | 🌇 Sunset: 7:28 PM

📅 3-Day Forecast:
🌤️ Tomorrow: 68°F/55°F - Partly Cloudy
🌧️ Thursday: 62°F/48°F - Light Rain
☀️ Friday: 70°F/58°F - Sunny
```

The widget appears in the center of Waybar next to the clock, showing current temperature with an icon. Hover to see detailed weather information and a 3-day forecast.

## 📋 Requirements

### System Requirements
- **Omarchy Linux** with Waybar installed
- **Python 3.6+** (pre-installed in Omarchy)
- **Internet connection** for weather data

### API Requirements
- **OpenWeatherMap API key** (free tier available)
  - Free account allows 1,000 calls/day
  - Weather widget uses ~96 calls/day (every 15 minutes)

### Python Dependencies
- `requests` package (auto-installed by setup script)

## 🚀 Installation

### ⚡ Quick Install (Recommended)

The automated installer handles everything for you:

```bash
# Clone the repository
git clone https://github.com/jrh89/omarchy-weather-widget.git
cd omarchy-weather-widget

# Run the installation script
./install.sh
```

**The modular installer will:**
- ✅ Check system compatibility
- ✅ Install Python dependencies
- ✅ Backup existing configuration files
- ✅ Install widget files to correct locations
- ✅ Set up environment configuration
- ✅ Update Waybar configuration
- ✅ Add CSS styles
- ✅ Test the installation

### 🔧 Module-by-Module Installation

For debugging or custom installations, you can run individual modules:

```bash
# Run specific modules
./scripts/run-module.sh 1  # System check
./scripts/run-module.sh 2  # Dependencies
./scripts/run-module.sh 3  # Backup
./scripts/run-module.sh 4  # Install files
./scripts/run-module.sh 5  # Environment setup
./scripts/run-module.sh 6  # Waybar config
./scripts/run-module.sh 7  # CSS styling
./scripts/run-module.sh 8  # Test installation
./scripts/run-module.sh 9  # Restart Waybar
```

Each module can also be run directly:
```bash
bash scripts/01-system-check.sh
bash scripts/02-dependencies.sh
# ... etc
```

### 🔧 Manual Install

If you prefer manual installation, follow these steps:

#### Step 1: Install Dependencies
```bash
# Install Python requests package
pip3 install requests --user
```

#### Step 2: Copy Widget Files
```bash
# Create waybar config directory if needed
mkdir -p ~/.config/waybar

# Copy widget files
cp weather.py ~/.config/waybar/
cp weather-widget.sh ~/.config/waybar/
chmod +x ~/.config/waybar/weather.py ~/.config/waybar/weather-widget.sh
```

#### Step 3: Configure API Key
```bash
# Create omarchy config directory
mkdir -p ~/.config/omarchy

# Create environment file
cat > ~/.config/omarchy/env << 'EOF'
#!/bin/bash
# Omarchy Environment Variables

# OpenWeatherMap API Key
export OPENWEATHER_API_KEY="your_api_key_here"
EOF

# Make it executable
chmod +x ~/.config/omarchy/env
```

#### Step 4: Update Waybar Configuration
Edit `~/.config/waybar/config.jsonc`:

```jsonc
{
  // ... your existing config ...
  "modules-center": ["clock", "custom/weather", "custom/update", "custom/screenrecording-indicator"],
  
  // Add this module configuration
  "custom/weather": {
    "exec": "~/.config/waybar/weather-widget.sh --forecast",
    "return-type": "json",
    "interval": 900,
    "tooltip": true
  },
  // ... rest of your config ...
}
```

#### Step 5: Add CSS Styles
Add to `~/.config/waybar/style.css`:

```css
/* Weather Widget Styles */
#custom-weather {
  margin-left: 10px;
  margin-right: 15px;
  font-size: 12px;
}

#custom-weather:hover {
  opacity: 0.8;
}
```

#### Step 6: Restart Waybar
```bash
killall -q waybar && waybar &
```

## ⚙️ Configuration

### 🔑 Get OpenWeatherMap API Key

1. **Sign up**: Visit [OpenWeatherMap](https://openweathermap.org/api)
2. **Register**: Create a free account
3. **Get API Key**: Navigate to API keys section and copy your key
4. **Verify Email**: Check your email and verify your account
5. **Wait**: API keys may take 10-30 minutes to activate

### 📍 Configure API Key

#### Method 1: Edit Environment File (Recommended)
```bash
nano ~/.config/omarchy/env
```
Replace `YOUR_API_KEY_HERE` with your actual API key:
```bash
export OPENWEATHER_API_KEY="your_actual_api_key_here"
```

#### Method 2: Set Environment Variable
```bash
echo 'export OPENWEATHER_API_KEY="your_actual_api_key_here"' >> ~/.bashrc
source ~/.bashrc
```

### 🎨 Customization Options

#### Temperature Units
Edit `weather.py` and change the units parameter:
```python
# For Fahrenheit (default)
units = "imperial"

# For Celsius
units = "metric"
```

#### Update Interval
Change `interval` in your Waybar config:
```json
"interval": 900,  // 15 minutes (default)
"interval": 1800, // 30 minutes
"interval": 300,  // 5 minutes (not recommended - may exceed API limits)
```

#### Location Override
The widget automatically detects location via IP. To set a manual location:
```python
# In weather.py, replace the geolocation section with:
lat = 37.7749   # San Francisco latitude
lon = -122.4194 # San Francisco longitude
city = "San Francisco"
country = "US"
```

#### Styling
Modify the CSS in `~/.config/waybar/style.css`:
```css
#custom-weather {
  margin-left: 10px;
  margin-right: 15px;
  font-size: 12px;
  color: #ffffff;        /* Change text color */
  background: #4a90e2;   /* Add background */
  padding: 2px 8px;      /* Add padding */
  border-radius: 4px;    /* Rounded corners */
}
```

## 🗂️ File Structure

```
omarchy-weather-widget/
├── README.md              # This documentation
├── install.sh             # Main modular installation script
├── install.sh.backup      # Original monolithic installer (backup)
├── uninstall.sh           # Uninstallation script
├── weather.py             # Main weather widget script
├── weather-widget.sh      # Shell wrapper for environment variables
├── weather_widget.py      # Alternative widget with caching
├── weather-style.css      # Additional CSS styles
├── waybar-weather.sh      # Legacy compatibility script
└── scripts/               # Modular installation scripts
    ├── common.sh          # Shared functions and colors
    ├── 01-system-check.sh # System compatibility check
    ├── 02-dependencies.sh # Python dependencies
    ├── 03-backup.sh       # Backup existing files
    ├── 04-install-files.sh # Install widget files
    ├── 05-environment.sh  # API key and environment setup
    ├── 06-waybar-config.sh # Waybar JSON configuration
    ├── 07-css-styling.sh  # CSS style updates
    ├── 08-test.sh         # Installation validation
    ├── 09-restart.sh      # Waybar restart
    └── run-module.sh      # Run individual modules for debugging
```

### Installed Files Location
After installation, files are placed in:
- `~/.config/waybar/weather.py` - Main widget script
- `~/.config/waybar/weather-widget.sh` - Shell wrapper
- `~/.config/omarchy/env` - Environment variables
- `~/.config/waybar/config.jsonc` - Updated Waybar config
- `~/.config/waybar/style.css` - Updated CSS styles

## ❓ Frequently Asked Questions

### Q: How much does this cost to run?
**A:** The OpenWeatherMap free tier allows 1,000 API calls per day. The widget makes ~96 calls daily (every 15 minutes), so it's completely free to use.

### Q: Can I use this outside of Omarchy?
**A:** Yes! This widget works with any Waybar setup on Linux. Just ensure you have Waybar installed and configured.

### Q: Why is my location incorrect?
**A:** The widget uses IP geolocation which may not always be accurate. You can override the location by editing the coordinates in `weather.py`.

### Q: How do I change from Fahrenheit to Celsius?
**A:** Edit `weather.py` and change `units="imperial"` to `units="metric"`.

### Q: Can I run individual installation steps?
**A:** Yes! Use the modular system to run specific steps:
```bash
./scripts/run-module.sh 1  # Just check system compatibility
./scripts/run-module.sh 5  # Just set up API key
./scripts/run-module.sh 9  # Just restart Waybar
```

### Q: What happened to the original install.sh?
**A:** It's been backed up as `install.sh.backup`. The new `install.sh` uses a modular approach inspired by DHH's Omakub for better maintainability and debugging.

### Q: How do I debug installation issues?
**A:** Run modules individually to isolate problems:
```bash
# Test system compatibility
bash scripts/01-system-check.sh

# Test just the API key setup
bash scripts/05-environment.sh

# Test Waybar configuration
bash scripts/06-waybar-config.sh
```

### Q: Why isn't the widget updating?
**A:** Check your internet connection and API key. You can also test manually by running `~/.config/waybar/weather-widget.sh` in your terminal.

## 🔧 Troubleshooting

### API Key Issues

#### Problem: "No API Key" error
**Solution:**
1. Verify your API key is correct in `~/.config/omarchy/env`
2. Ensure your OpenWeatherMap account is verified
3. Wait 10-30 minutes after account verification for activation

#### Problem: API key not working
**Solution:**
1. Check email verification status at OpenWeatherMap
2. Verify the key isn't expired or revoked
3. Test the key manually:
   ```bash
   curl "https://api.openweathermap.org/data/2.5/weather?q=London&appid=YOUR_API_KEY"
   ```

### Widget Display Issues

#### Problem: Widget shows "N/A" or error
**Solution:**
1. Check internet connection
2. Verify API key is valid and activated
3. Run manual test:
   ```bash
   ~/.config/waybar/weather-widget.sh
   ```
4. Check system logs for errors

#### Problem: Widget not appearing in Waybar
**Solution:**
1. Verify Waybar config contains the weather module
2. Check that scripts are executable:
   ```bash
   chmod +x ~/.config/waybar/weather.py ~/.config/waybar/weather-widget.sh
   ```
3. Restart Waybar:
   ```bash
   killall -q waybar && waybar &
   ```

### Location Issues

#### Problem: Wrong location detected
**Solution:**
1. Test your IP location:
   ```bash
   curl http://ip-api.com/json/
   ```
2. If incorrect, manually set coordinates in `weather.py`

### Performance Issues

#### Problem: Widget updates too slowly/quickly
**Solution:**
1. Adjust `interval` in Waybar config (in seconds)
2. Recommended minimum: 300 seconds (5 minutes)
3. Recommended maximum: 3600 seconds (1 hour)

## 🗑️ Uninstallation

### Automated Uninstallation (Recommended)
```bash
# Navigate to the cloned repository
cd omarchy-weather-widget

# Run the uninstallation script
./uninstall.sh
```

### Manual Uninstallation
```bash
# Remove widget files
rm -f ~/.config/waybar/weather.py
rm -f ~/.config/waybar/weather-widget.sh
rm -f ~/.config/waybar/weather_widget.py

# Remove API key from environment (optional)
sed -i '/OPENWEATHER_API_KEY/d' ~/.config/omarchy/env

# Remove weather module from Waybar config
# Edit ~/.config/waybar/config.jsonc and remove "custom/weather" entries

# Remove CSS styles
# Edit ~/.config/waybar/style.css and remove #custom-weather styles

# Remove cached weather data
rm -rf ~/.cache/waybar-weather

# Restart Waybar
killall -q waybar && waybar &
```

## 🤝 Contributing

Contributions are welcome! Please follow these steps:

1. **Fork** the repository
2. **Create a feature branch**: `git checkout -b feature/amazing-feature`
3. **Make your changes** and test thoroughly
4. **Commit your changes**: `git commit -m 'Add amazing feature'`
5. **Push to branch**: `git push origin feature/amazing-feature`
6. **Open a Pull Request** with a clear description

### Development Guidelines
- Follow existing code style
- Add comments for complex logic
- Test with different configurations
- Update documentation as needed

## 📄 License

MIT License - feel free to use and modify for your Omarchy setup!

## 🆘 Support

- **Issues**: [GitHub Issues](https://github.com/jrh89/omarchy-weather-widget/issues)
- **Omarchy Community**: [Discord/Forum link]
- **API Support**: [OpenWeatherMap Documentation](https://openweathermap.org/api)

## 🙏 Acknowledgments

- [OpenWeatherMap](https://openweathermap.org/) for providing weather data API
- [Waybar](https://github.com/Alexays/Waybar) for the excellent status bar
- Omarchy Linux community for feedback and testing
