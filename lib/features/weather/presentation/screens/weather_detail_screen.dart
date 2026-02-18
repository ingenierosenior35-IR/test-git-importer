import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:http/http.dart' as http;
import 'package:Rival/core/constants/colors.dart';
import 'package:Rival/features/weather/data/datasources/sab_remote_data_source.dart';
import 'package:Rival/features/weather/domain/entities/sab_sensor.dart';

/// Weather detail screen showing rainfall data from SAB API
/// Displays stations with their accumulated rainfall and corresponding icons
class WeatherDetailScreen extends StatefulWidget {
  const WeatherDetailScreen({Key? key}) : super(key: key);

  @override
  State<WeatherDetailScreen> createState() => _WeatherDetailScreenState();
}

class _WeatherDetailScreenState extends State<WeatherDetailScreen> {
  late SabRemoteDataSource _dataSource;
  List<SabSensor> _sensors = [];
  bool _isLoading = true;
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    _dataSource = SabRemoteDataSourceImpl(client: http.Client());
    _loadWeatherData();
  }

  Future<void> _loadWeatherData() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      final sensors = await _dataSource.getRainfallSensors();
      setState(() {
        // Filter for visible and active stations only
        _sensors = sensors.where((s) {
          // Basic filtering - in real app would check VISIBLE and ESTADO fields
          return s.station.isNotEmpty && s.locality.isNotEmpty;
        }).toList();
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _errorMessage = 'Error al cargar datos del clima: ${e.toString()}';
        _isLoading = false;
      });
    }
  }

  /// Returns rain level category based on accumulated rainfall
  RainLevel _getRainLevel(double accumulated) {
    if (accumulated == 0.0) {
      return RainLevel.none;
    } else if (accumulated <= 10.0) {
      return RainLevel.low;
    } else if (accumulated <= 30.0) {
      return RainLevel.moderate;
    } else if (accumulated <= 50.0) {
      return RainLevel.high;
    } else {
      return RainLevel.veryHigh;
    }
  }

  /// Returns icon data for rain level
  IconData _getRainIcon(RainLevel level) {
    switch (level) {
      case RainLevel.none:
        return Icons.wb_sunny;
      case RainLevel.low:
        return Icons.grain;
      case RainLevel.moderate:
        return Icons.water_drop;
      case RainLevel.high:
        return Icons.cloud;
      case RainLevel.veryHigh:
        return Icons.thunderstorm;
    }
  }

  /// Returns color for rain level
  Color _getRainColor(RainLevel level) {
    switch (level) {
      case RainLevel.none:
        return AppColors.kYellowAccent;
      case RainLevel.low:
        return AppColors.kGreen;
      case RainLevel.moderate:
        return const Color(0xFF4A90E2);
      case RainLevel.high:
        return AppColors.kOrange;
      case RainLevel.veryHigh:
        return AppColors.kRed;
    }
  }

  /// Returns label for rain level
  String _getRainLabel(RainLevel level) {
    switch (level) {
      case RainLevel.none:
        return 'Sin Lluvias';
      case RainLevel.low:
        return 'Acumulados Bajos';
      case RainLevel.moderate:
        return 'Acumulados Moderados';
      case RainLevel.high:
        return 'Acumulados Altos';
      case RainLevel.veryHigh:
        return 'Acumulados Muy Altos';
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.kDarkBackground,
      appBar: AppBar(
        backgroundColor: AppColors.kDarkCard,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_rounded, color: AppColors.kWhite),
          onPressed: () => Get.back(),
        ),
        title: const Text(
          'Condiciones de Lluvia',
          style: TextStyle(
            color: AppColors.kWhite,
            fontSize: 18,
            fontWeight: FontWeight.w600,
          ),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh_rounded, color: AppColors.kYellowAccent),
            onPressed: _loadWeatherData,
          ),
        ],
      ),
      body: _buildBody(),
    );
  }

  Widget _buildBody() {
    if (_isLoading) {
      return const Center(
        child: CircularProgressIndicator(
          color: AppColors.kYellowAccent,
        ),
      );
    }

    if (_errorMessage != null) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                Icons.error_outline,
                size: 64,
                color: AppColors.kRed.withOpacity(0.5),
              ),
              const SizedBox(height: 16),
              Text(
                _errorMessage!,
                style: const TextStyle(
                  color: AppColors.kGrey,
                  fontSize: 14,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 24),
              ElevatedButton(
                onPressed: _loadWeatherData,
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.kYellowAccent,
                  foregroundColor: AppColors.kBlack,
                  padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
                child: const Text('Reintentar'),
              ),
            ],
          ),
        ),
      );
    }

    if (_sensors.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.cloud_off,
              size: 64,
              color: AppColors.kGrey.withOpacity(0.5),
            ),
            const SizedBox(height: 16),
            const Text(
              'No hay datos de estaciones disponibles',
              style: TextStyle(
                color: AppColors.kGrey,
                fontSize: 14,
              ),
            ),
          ],
        ),
      );
    }

    return RefreshIndicator(
      onRefresh: _loadWeatherData,
      color: AppColors.kYellowAccent,
      backgroundColor: AppColors.kDarkCard,
      child: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          _buildInfoCard(),
          const SizedBox(height: 16),
          _buildLegend(),
          const SizedBox(height: 20),
          const Text(
            'Estaciones de Monitoreo',
            style: TextStyle(
              color: AppColors.kWhite,
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 12),
          ..._sensors.map((sensor) => _buildSensorCard(sensor)).toList(),
        ],
      ),
    );
  }

  Widget _buildInfoCard() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.kDarkCard,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: AppColors.kYellowAccent.withOpacity(0.2),
          width: 1,
        ),
      ),
      child: Row(
        children: [
          Icon(
            Icons.info_outline,
            color: AppColors.kYellowAccent,
            size: 20,
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              'Datos en tiempo real de las estaciones del SAB',
              style: TextStyle(
                color: AppColors.kGreyLight,
                fontSize: 13,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildLegend() {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: AppColors.kDarkCard,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Niveles de Acumulación',
            style: TextStyle(
              color: AppColors.kWhite,
              fontSize: 14,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 10),
          _buildLegendItem(RainLevel.none, '0 mm'),
          const SizedBox(height: 6),
          _buildLegendItem(RainLevel.low, '0 - 10 mm'),
          const SizedBox(height: 6),
          _buildLegendItem(RainLevel.moderate, '10.1 - 30 mm'),
          const SizedBox(height: 6),
          _buildLegendItem(RainLevel.high, '30.1 - 50 mm'),
          const SizedBox(height: 6),
          _buildLegendItem(RainLevel.veryHigh, '> 50 mm'),
        ],
      ),
    );
  }

  Widget _buildLegendItem(RainLevel level, String range) {
    return Row(
      children: [
        Icon(
          _getRainIcon(level),
          color: _getRainColor(level),
          size: 18,
        ),
        const SizedBox(width: 10),
        Expanded(
          child: Text(
            _getRainLabel(level),
            style: const TextStyle(
              color: AppColors.kWhite,
              fontSize: 12,
            ),
          ),
        ),
        Text(
          range,
          style: TextStyle(
            color: AppColors.kGreyLight,
            fontSize: 12,
          ),
        ),
      ],
    );
  }

  Widget _buildSensorCard(SabSensor sensor) {
    final rainLevel = _getRainLevel(sensor.dailyAccumulated);
    final icon = _getRainIcon(rainLevel);
    final color = _getRainColor(rainLevel);
    final label = _getRainLabel(rainLevel);

    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: AppColors.kDarkCard,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: color.withOpacity(0.3),
          width: 1,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: color.withOpacity(0.15),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Icon(
                  icon,
                  color: color,
                  size: 24,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      sensor.station,
                      style: const TextStyle(
                        color: AppColors.kWhite,
                        fontSize: 15,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Row(
                      children: [
                        Icon(
                          Icons.location_on,
                          size: 12,
                          color: AppColors.kGreyLight,
                        ),
                        const SizedBox(width: 4),
                        Expanded(
                          child: Text(
                            sensor.locality,
                            style: TextStyle(
                              color: AppColors.kGreyLight,
                              fontSize: 12,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Text(
                    '${sensor.dailyAccumulated.toStringAsFixed(1)} mm',
                    style: TextStyle(
                      color: color,
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                    decoration: BoxDecoration(
                      color: color.withOpacity(0.2),
                      borderRadius: BorderRadius.circular(6),
                    ),
                    child: Text(
                      label,
                      style: TextStyle(
                        color: color,
                        fontSize: 9,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
          if (sensor.readingDate.isNotEmpty) ...[
            const SizedBox(height: 10),
            Row(
              children: [
                Icon(
                  Icons.access_time,
                  size: 12,
                  color: AppColors.kGreyLight,
                ),
                const SizedBox(width: 4),
                Text(
                  'Última lectura: ${sensor.readingDate}',
                  style: TextStyle(
                    color: AppColors.kGreyLight,
                    fontSize: 11,
                  ),
                ),
              ],
            ),
          ],
        ],
      ),
    );
  }
}

/// Rain level categories based on daily accumulated rainfall
enum RainLevel {
  none,      // 0 mm
  low,       // 0-10 mm
  moderate,  // 10.1-30 mm
  high,      // 30.1-50 mm
  veryHigh,  // >50 mm
}
