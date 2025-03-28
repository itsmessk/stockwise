import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import '../models/weather_model.dart';
import '../models/user_model.dart';
import '../utils/weather_utils.dart';
import '../utils/date_utils.dart';
import '../constants/theme_constants.dart';

class WeatherCard extends StatelessWidget {
  final Weather weather;
  final UserPreferences preferences;

  const WeatherCard({
    Key? key,
    required this.weather,
    required this.preferences,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final temperatureColor = ThemeConstants.getTemperatureColor(weather.temperature);
    final conditionColor = ThemeConstants.getWeatherConditionColor(weather.condition);
    
    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(16),
          gradient: LinearGradient(
            colors: weather.isDay
                ? [Colors.blue.shade300, Colors.blue.shade600]
                : [Colors.indigo.shade400, Colors.indigo.shade800],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
        ),
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        weather.location,
                        style: Theme.of(context).textTheme.titleLarge?.copyWith(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      Text(
                        weather.country,
                        style: Theme.of(context).textTheme.titleMedium?.copyWith(
                          color: Colors.white.withOpacity(0.8),
                        ),
                      ),
                    ],
                  ),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      Text(
                        DateTimeUtils.formatDate(weather.lastUpdated),
                        style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                          color: Colors.white.withOpacity(0.8),
                        ),
                      ),
                      Text(
                        DateTimeUtils.formatTime(weather.lastUpdated),
                        style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                          color: Colors.white.withOpacity(0.8),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
              const SizedBox(height: 24),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        WeatherUtils.formatTemperature(
                          weather.temperature,
                          preferences.temperatureUnit,
                        ),
                        style: Theme.of(context).textTheme.displayMedium?.copyWith(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      Text(
                        'Feels like ${WeatherUtils.formatTemperature(
                          weather.feelsLike,
                          preferences.temperatureUnit,
                        )}',
                        style: Theme.of(context).textTheme.titleMedium?.copyWith(
                          color: Colors.white.withOpacity(0.8),
                        ),
                      ),
                    ],
                  ),
                  Column(
                    children: [
                      CachedNetworkImage(
                        imageUrl: weather.conditionIcon,
                        width: 80,
                        height: 80,
                        placeholder: (context, url) => const CircularProgressIndicator(),
                        errorWidget: (context, url, error) => const Icon(
                          Icons.error,
                          color: Colors.white,
                          size: 40,
                        ),
                      ),
                      Text(
                        weather.condition,
                        style: Theme.of(context).textTheme.titleMedium?.copyWith(
                          color: Colors.white,
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ],
                  ),
                ],
              ),
              const SizedBox(height: 24),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
                  _buildWeatherDetail(
                    context,
                    Icons.air,
                    WeatherUtils.formatWindSpeed(
                      weather.windSpeed,
                      preferences.windSpeedUnit,
                    ),
                    weather.windDirection,
                  ),
                  _buildWeatherDetail(
                    context,
                    Icons.water_drop,
                    '${weather.humidity.toInt()}%',
                    'Humidity',
                  ),
                  _buildWeatherDetail(
                    context,
                    Icons.umbrella,
                    '${weather.precipitation.toStringAsFixed(1)} mm',
                    'Precipitation',
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildWeatherDetail(
    BuildContext context,
    IconData icon,
    String value,
    String label,
  ) {
    return Column(
      children: [
        Icon(
          icon,
          color: Colors.white,
          size: 24,
        ),
        const SizedBox(height: 8),
        Text(
          value,
          style: Theme.of(context).textTheme.titleMedium?.copyWith(
            color: Colors.white,
            fontWeight: FontWeight.bold,
          ),
        ),
        Text(
          label,
          style: Theme.of(context).textTheme.bodyMedium?.copyWith(
            color: Colors.white.withOpacity(0.8),
          ),
        ),
      ],
    );
  }
}
