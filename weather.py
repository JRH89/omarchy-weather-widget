#!/usr/bin/env python3

import json
import os
import requests
import sys
from datetime import datetime, timedelta

# Get API key from environment variable
API_KEY = os.getenv('OPENWEATHER_API_KEY')

if not API_KEY:
    print('{"text":"❓ No API Key", "alt":"No API Key"}')
    sys.exit(1)

# Get location from IP geolocation
try:
    location = requests.get('http://ip-api.com/json/').json()
    lat = location['lat']
    lon = location['lon']
    city = location['city']
    country = location['countryCode']
except:
    print('{"text":"🌍 Location Error", "alt":"Location Error"}')
    sys.exit(1)

# Weather condition codes with Nerd Font icons
WEATHER_ICONS = {
    '01d': '☀️',  # clear sky (day)
    '01n': '🌙',  # clear sky (night)
    '02d': '⛅',  # few clouds (day)
    '02n': '☁️',  # few clouds (night)
    '03d': '☁️',  # scattered clouds
    '03n': '☁️',
    '04d': '☁️',  # broken clouds
    '04n': '☁️',
    '09d': '🌧️',  # shower rain
    '09n': '🌧️',
    '10d': '🌦️',  # rain (day)
    '10n': '🌧️',  # rain (night)
    '11d': '⛈️',  # thunderstorm
    '11n': '⛈️',
    '13d': '❄️',  # snow
    '13n': '❄️',
    '50d': '🌫️',  # mist
    '50n': '🌫️',
}

def get_weather():
    # Get current weather and forecast
    try:
        # Current weather
        current_url = f'https://api.openweathermap.org/data/2.5/weather?lat={lat}&lon={lon}&appid={API_KEY}&units=imperial'
        current_response = requests.get(current_url)
        
        if current_response.status_code != 200:
            error_data = current_response.json()
            if current_response.status_code == 401:
                # API key not working, use mock data
                return get_mock_weather()
            raise Exception(f"API Error {current_response.status_code}: {error_data.get('message', 'Unknown error')}")
        
        current = current_response.json()
        
        # Forecast (5 days, 3-hour intervals)
        forecast_url = f'https://api.openweathermap.org/data/2.5/forecast?lat={lat}&lon={lon}&appid={API_KEY}&units=imperial'
        forecast_response = requests.get(forecast_url)
        
        if forecast_response.status_code != 200:
            error_data = forecast_response.json()
            if forecast_response.status_code == 401:
                # API key not working, use mock data
                return get_mock_weather()
            raise Exception(f"API Error {forecast_response.status_code}: {error_data.get('message', 'Unknown error')}")
        
        forecast = forecast_response.json()
        
        return current, forecast, city, country
    except Exception as e:
        print(f'{{"text":"❌ API Error", "alt":"API Error: {str(e)[:30]}..."}}', file=sys.stderr)
        sys.exit(1)

def get_mock_weather():
    # Mock data for testing when API key is not activated
    mock_current = {
        'main': {'temp': 72},  # Fahrenheit
        'weather': [{'icon': '01d', 'description': 'clear sky'}]
    }
    
    mock_forecast = {
        'list': []
    }
    
    # Generate mock forecast data
    for i in range(1, 4):
        date = datetime.now() + timedelta(days=i)
        for hour in [0, 12]:
            dt = date.replace(hour=hour).timestamp()
            mock_forecast['list'].append({
                'dt': dt,
                'main': {'temp': 68 + i + (hour/12)},  # Fahrenheit
                'weather': [{'icon': '01d' if i % 2 == 0 else '02d'}]
            })
    
    return mock_current, mock_forecast, city, country

def format_forecast(forecast_data):
    # Group forecast by day
    daily_forecast = {}
    for entry in forecast_data['list']:
        date = datetime.fromtimestamp(entry['dt']).strftime('%Y-%m-%d')
        if date not in daily_forecast:
            daily_forecast[date] = []
        daily_forecast[date].append(entry)
    
    # Get next 3 days
    forecast_days = sorted(daily_forecast.items())[1:4]  # Skip today
    
    forecast_text = []
    for date, entries in forecast_days:
        # Get min/max temp for the day
        temps = [entry['main']['temp'] for entry in entries]
        min_temp = min(temps)
        max_temp = max(temps)
        
        # Get most common weather condition
        weather_condition = max(
            set(e['weather'][0]['icon'] for e in entries),
            key=lambda x: sum(1 for e in entries if e['weather'][0]['icon'] == x)
        )
        
        day_name = datetime.strptime(date, '%Y-%m-%d').strftime('%a')
        forecast_text.append(
            f"{day_name}: {WEATHER_ICONS.get(weather_condition, '?')} "
            f"{max_temp:.0f}°/{min_temp:.0f}°"
        )
    
    return "\n".join(forecast_text)

if __name__ == "__main__":
    if len(sys.argv) > 1 and sys.argv[1] == "--forecast":
        # Return current weather with forecast in tooltip
        try:
            current, forecast, city, country = get_weather()
            temp = current['main']['temp']
            icon = WEATHER_ICONS.get(current['weather'][0]['icon'], '?')
            forecast_text = format_forecast(forecast)
            
            # Build tooltip with current weather + forecast
            tooltip_lines = [
                f"{city}, {country}",
                f"{current['weather'][0]['description'].title()}",
                f"Current: {temp:.0f}°F (feels like {current['main']['feels_like']:.0f}°F)",
                f"Humidity: {current['main']['humidity']}%",
                f"Wind: {current.get('wind', {}).get('speed', 0):.1f} mph",
                "",
                "3-Day Forecast:",
                forecast_text
            ]
            
            print(json.dumps({
                'text': f"{icon} {temp:.0f}°F",
                'alt': f"{city}, {country}",
                'tooltip': '\n'.join(tooltip_lines)
            }))
        except Exception as e:
            print(json.dumps({
                'text': '❓ Weather',
                'alt': f'Error: {str(e)[:30]}...',
                'tooltip': 'Click to retry'
            }))
    else:
        # Return current weather for status bar (original behavior)
        try:
            current, _, city, country = get_weather()
            temp = current['main']['temp']
            icon = WEATHER_ICONS.get(current['weather'][0]['icon'], '?')
            print(json.dumps({
                'text': f"{icon} {temp:.0f}°F",
                'alt': f"{city}, {country}",
                'tooltip': f"{city}, {country} - Click for forecast"
            }))
        except Exception as e:
            print(json.dumps({
                'text': '❓ Weather',
                'alt': f'Error: {str(e)[:30]}...',
                'tooltip': 'Click to retry'
            }))
