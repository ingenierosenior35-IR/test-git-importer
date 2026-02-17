import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:Rival/core/constants/colors.dart';
import 'package:intl/intl.dart';

class WeatherScreen extends StatefulWidget {
  const WeatherScreen({Key? key}) : super(key: key);

  @override
  State<WeatherScreen> createState() => _WeatherScreenState();
}

class _WeatherScreenState extends State<WeatherScreen> {
  // Mock weather data - in a real app, this would come from the weather repository
  final List<Map<String, dynamic>> _forecast = [
    {
      'day': 'Hoy',
      'temp': '24°',
      'icon': Icons.wb_sunny,
      'condition': 'Soleado',
      'humidity': '45%',
      'wind': '12 km/h',
    },
    {
      'day': 'Mañana',
      'temp': '22°',
      'icon': Icons.cloud,
      'condition': 'Nublado',
      'humidity': '60%',
      'wind': '15 km/h',
    },
    {
      'day': 'Miércoles',
      'temp': '20°',
      'icon': Icons.grain,
      'condition': 'Lluvia',
      'humidity': '80%',
      'wind': '20 km/h',
    },
    {
      'day': 'Jueves',
      'temp': '23°',
      'icon': Icons.wb_cloudy,
      'condition': 'Parcialmente Nublado',
      'humidity': '55%',
      'wind': '10 km/h',
    },
    {
      'day': 'Viernes',
      'temp': '25°',
      'icon': Icons.wb_sunny,
      'condition': 'Soleado',
      'humidity': '40%',
      'wind': '8 km/h',
    },
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.kDarkBackground,
      appBar: AppBar(
        backgroundColor: AppColors.kDarkCard,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: AppColors.kWhite),
          onPressed: () => Get.back(),
        ),
        title: Text(
          'CLIMA PARA ENTRENAR',
          style: const TextStyle(
            color: AppColors.kWhite,
            fontSize: 16,
            fontWeight: FontWeight.bold,
            letterSpacing: 1.2,
          ),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.my_location, color: AppColors.kYellowAccent),
            onPressed: () {
              // In a real app, this would request location permission and update weather
            },
          ),
        ],
      ),
      body: RefreshIndicator(
        onRefresh: () async {
          // In a real app, this would refresh weather data
          await Future.delayed(const Duration(seconds: 1));
        },
        color: AppColors.kYellowAccent,
        backgroundColor: AppColors.kDarkCard,
        child: ListView(
          padding: const EdgeInsets.all(20),
          children: [
            // Current weather card
            _buildCurrentWeatherCard(),
            const SizedBox(height: 24),
            // Forecast title
            Text(
              'Pronóstico de 5 días',
              style: TextStyle(
                color: AppColors.kWhite,
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),
            // Forecast list
            ..._forecast.map((weather) => _buildForecastCard(weather)).toList(),
            const SizedBox(height: 24),
            // Tips card
            _buildTipsCard(),
          ],
        ),
      ),
    );
  }

  Widget _buildCurrentWeatherCard() {
    final currentWeather = _forecast[0];
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            AppColors.kYellowAccent.withOpacity(0.8),
            AppColors.kYellowAccent,
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(24),
      ),
      child: Column(
        children: [
          Row(
            children: [
              Icon(
                Icons.location_on,
                color: AppColors.kBlack,
                size: 20,
              ),
              const SizedBox(width: 4),
              Text(
                'Tu ubicación',
                style: TextStyle(
                  color: AppColors.kBlack.withOpacity(0.8),
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
          const SizedBox(height: 24),
          Icon(
            currentWeather['icon'],
            size: 80,
            color: AppColors.kBlack,
          ),
          const SizedBox(height: 16),
          Text(
            currentWeather['temp'],
            style: TextStyle(
              color: AppColors.kBlack,
              fontSize: 64,
              fontWeight: FontWeight.bold,
            ),
          ),
          Text(
            currentWeather['condition'],
            style: TextStyle(
              color: AppColors.kBlack.withOpacity(0.8),
              fontSize: 20,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 24),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              _buildWeatherStat(Icons.water_drop, 'Humedad', currentWeather['humidity']),
              _buildWeatherStat(Icons.air, 'Viento', currentWeather['wind']),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildWeatherStat(IconData icon, String label, String value) {
    return Column(
      children: [
        Icon(icon, color: AppColors.kBlack, size: 24),
        const SizedBox(height: 4),
        Text(
          label,
          style: TextStyle(
            color: AppColors.kBlack.withOpacity(0.7),
            fontSize: 12,
          ),
        ),
        const SizedBox(height: 2),
        Text(
          value,
          style: TextStyle(
            color: AppColors.kBlack,
            fontSize: 16,
            fontWeight: FontWeight.bold,
          ),
        ),
      ],
    );
  }

  Widget _buildForecastCard(Map<String, dynamic> weather) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.kDarkCard,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Row(
        children: [
          Icon(
            weather['icon'],
            color: AppColors.kYellowAccent,
            size: 32,
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  weather['day'],
                  style: TextStyle(
                    color: AppColors.kWhite,
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  weather['condition'],
                  style: TextStyle(
                    color: AppColors.kGreyLight,
                    fontSize: 14,
                  ),
                ),
              ],
            ),
          ),
          Text(
            weather['temp'],
            style: TextStyle(
              color: AppColors.kWhite,
              fontSize: 24,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTipsCard() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppColors.kDarkCard,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: AppColors.kYellowAccent.withOpacity(0.3),
          width: 1,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                Icons.lightbulb_outline,
                color: AppColors.kYellowAccent,
                size: 24,
              ),
              const SizedBox(width: 8),
              Text(
                'Consejo del día',
                style: TextStyle(
                  color: AppColors.kYellowAccent,
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Text(
            'El clima es perfecto para entrenar al aire libre. No olvides hidratarte bien durante tu entrenamiento.',
            style: TextStyle(
              color: AppColors.kGreyLight,
              fontSize: 14,
              height: 1.5,
            ),
          ),
        ],
      ),
    );
  }
}
