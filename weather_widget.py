#!/usr/bin/env python3

import json
import os
import requests
import sys
from datetime import datetime, timedelta
from pathlib import Path

# Configuration
CACHE_DIR = Path.home() / ".cache/waybar-weather"
CACHE_FILE = CACHE_DIR / "weather.json"
CACHE_EXPIRY = 1800  # 30 minutes in seconds
ICON_MAP = {
    "01": "☀️",  # clear sky
    "02": "⛅",  # few clouds
    "03": "☁️",  # scattered clouds
    "04": "☁️",  # broken clouds
    "09": "🌧️",  # shower rain
    "10": "🌦️",  # rain
    "11": "⛈️",  # thunderstorm
    "13": "❄️",  # snow
    "50": "🌫️",  # mist
}

def ensure_cache_dir():
    CACHE_DIR.mkdir(parents=True, exist_ok=True)

def get_cached_weather():
    if not CACHE_FILE.exists():
        return None
    
    try:
        data = json.loads(CACHE_FILE.read_text())
        last_updated = datetime.fromisoformat(data['last_updated'])
        if (datetime.now() - last_updated).total_seconds() < CACHE_EXPIRY:
            return data['weather']
    except Exception as e:
        print(f"Error reading cache: {e}", file=sys.stderr)
    
    return None

def save_weather_to_cache(weather_data):
    ensure_cache_dir()
    data = {
        'last_updated': datetime.now().isoformat(),
        'weather': weather_data
    }
    CACHE_FILE.write_text(json.dumps(data))

def get_weather_icon(icon_code):
    return ICON_MAP.get(icon_code[:2], "🌡️")

def get_weather(api_key, lat=None, lon=None, city_name=None):
    # Check cache first
    cached = get_cached_weather()
    if cached is not None:
        return cached
    
    # Build the API URL
    base_url = "http://api.openweathermap.org/data/2.5/onecall"
    params = {
        'appid': api_key,
        'units': 'metric',
        'exclude': 'minutely,hourly,alerts'
    }
    
    if lat and lon:
        params.update({'lat': lat, 'lon': lon})
    elif city_name:
        # If no lat/lon, try to get by city name (less accurate)
        geo_url = "http://api.openweathermap.org/geo/1.0/direct"
        geo_params = {
            'q': city_name,
            'limit': 1,
            'appid': api_key
        }
        try:
            response = requests.get(geo_url, params=geo_params)
            response.raise_for_status()
            location = response.json()[0]
            params.update({'lat': location['lat'], 'lon': location['lon']})
        except Exception as e:
            print(f"Error getting location: {e}", file=sys.stderr)
            return None
    else:
        # Try to get location from system using geoclue2
        try:
            # First try geoclue2
            try:
                import geoclue2
                client = geoclue2.Simple()
                location = client.get_location()
                if location and 'latitude' in location and 'longitude' in location:
                    params.update({
                        'lat': location['latitude'],
                        'lon': location['longitude']
                    })
            except Exception as e:
                print(f"Geoclue2 not available: {e}", file=sys.stderr)
                
            # Fall back to geocoder.ip if geoclue2 fails
            if 'lat' not in params or 'lon' not in params:
                try:
                    import geocoder
                    g = geocoder.ip('me')
                    if g.ok and g.lat and g.lng:
                        params.update({'lat': g.lat, 'lon': g.lng})
                except Exception as e:
                    print(f"Geocoder.ip failed: {e}", file=sys.stderr)
            
            # If all else fails, use a default location (can be changed by user)
            if 'lat' not in params or 'lon' not in params:
                print("Could not determine location, using default", file=sys.stderr)
                # Default to Omarchy's location (Vancouver, Canada)
                params.update({'lat': 49.2827, 'lon': -123.1207})
                
        except Exception as e:
            print(f"Error getting location: {e}", file=sys.stderr)
            return None
    
    try:
        response = requests.get(base_url, params=params)
        response.raise_for_status()
        weather_data = response.json()
        
        # Process the data
        current = weather_data.get('current', {})
        daily = weather_data.get('daily', [])[:5]  # Next 5 days
        
        processed = {
            'current': {
                'temp': round(current.get('temp', 0)),
                'feels_like': round(current.get('feels_like', 0)),
                'humidity': current.get('humidity', 0),
                'wind_speed': current.get('wind_speed', 0),
                'weather': current.get('weather', [{}])[0],
                'dt': current.get('dt', 0)
            },
            'daily': []
        }
        
        for day in daily:
            processed['daily'].append({
                'dt': day.get('dt', 0),
                'temp': {
                    'min': round(day.get('temp', {}).get('min', 0)),
                    'max': round(day.get('temp', {}).get('max', 0)),
                },
                'weather': day.get('weather', [{}])[0]
            })
        
        # Save to cache
        save_weather_to_cache(processed)
        return processed
        
    except Exception as e:
        print(f"Error getting weather: {e}", file=sys.stderr)
        return None

def format_weather_output(weather_data, show_forecast=False):
    if not weather_data:
        return json.dumps({
            'text': 'N/A',
            'tooltip': 'Weather data unavailable'
        })
    
    current = weather_data['current']
    weather_icon = get_weather_icon(current['weather'].get('icon', ''))
    
    if not show_forecast:
        return json.dumps({
            'text': f"{weather_icon} {current['temp']}°C",
            'tooltip': f"{current['weather']['description'].title()}\n"
                     f"Feels like: {current['feels_like']}°C\n"
                     f"Humidity: {current['humidity']}%\n"
                     f"Wind: {current['wind_speed']} m/s"
        })
    else:
        import locale
        locale.setlocale(locale.LC_TIME, 'en_US.UTF-8')
        
        tooltip = [
            f"{current['weather']['description'].title()}, {current['temp']}°C\n"
            f"Feels like: {current['feels_like']}°C\n"
            f"Humidity: {current['humidity']}%\n"
            f"Wind: {current['wind_speed']} m/s\n\n"
            "Forecast:\n"
        ]
        
        for day in weather_data['daily']:
            date = datetime.fromtimestamp(day['dt'])
            day_name = date.strftime('%A')
            weather_icon = get_weather_icon(day['weather'].get('icon', ''))
            tooltip.append(
                f"{day_name}: {weather_icon} "
                f"{day['weather']['description'].title()} "
                f"({day['temp']['min']}°C/{day['temp']['max']}°C)\n"
            )
        
        return json.dumps({
            'text': f"{weather_icon} {current['temp']}°C",
            'tooltip': ''.join(tooltip).strip()
        })

if __name__ == "__main__":
    import argparse
    
    parser = argparse.ArgumentParser(description='Weather widget for Waybar')
    parser.add_argument('--api-key', help='OpenWeatherMap API key')
    parser.add_argument('--forecast', action='store_true', help='Show forecast in tooltip')
    args = parser.parse_args()
    
    api_key = args.api_key or os.environ.get('OPENWEATHER_API_KEY')
    if not api_key:
        print('Error: No API key provided. Set OPENWEATHER_API_KEY environment variable or use --api-key')
        sys.exit(1)
    
    weather_data = get_weather(api_key)
    print(format_weather_output(weather_data, args.forecast))
