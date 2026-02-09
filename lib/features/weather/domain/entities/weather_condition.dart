import 'package:equatable/equatable.dart';

/// Field condition based on weather data
enum FieldCondition {
  excellent, // No rain, dry field
  good, // Light rain, mostly playable
  fair, // Moderate rain, playable but slippery
  poor, // Heavy rain, difficult conditions
  unplayable, // Extreme rain, dangerous
}

/// Weather condition summary
class WeatherCondition extends Equatable {
  final FieldCondition fieldCondition;
  final double rainfallMm;
  final String description;
  final String stationName;
  final double distanceKm;

  const WeatherCondition({
    required this.fieldCondition,
    required this.rainfallMm,
    required this.description,
    required this.stationName,
    required this.distanceKm,
  });

  /// Derives field condition from rainfall data
  static WeatherCondition fromRainfall({
    required double dailyAccumulatedMm,
    required String stationName,
    required double distanceKm,
  }) {
    late FieldCondition condition;
    late String description;

    if (dailyAccumulatedMm == 0) {
      condition = FieldCondition.excellent;
      description = 'Seco - Condiciones excelentes';
    } else if (dailyAccumulatedMm < 2) {
      condition = FieldCondition.excellent;
      description = 'Despejado - Excelente para jugar';
    } else if (dailyAccumulatedMm < 5) {
      condition = FieldCondition.good;
      description = 'Llovizna ligera - Buenas condiciones';
    } else if (dailyAccumulatedMm < 10) {
      condition = FieldCondition.fair;
      description = 'Lluvia moderada - Campo húmedo';
    } else if (dailyAccumulatedMm < 20) {
      condition = FieldCondition.poor;
      description = 'Lluvia intensa - Condiciones difíciles';
    } else {
      condition = FieldCondition.unplayable;
      description = 'Lluvia extrema - No recomendado';
    }

    return WeatherCondition(
      fieldCondition: condition,
      rainfallMm: dailyAccumulatedMm,
      description: description,
      stationName: stationName,
      distanceKm: distanceKm,
    );
  }

  @override
  List<Object?> get props => [
        fieldCondition,
        rainfallMm,
        description,
        stationName,
        distanceKm,
      ];
}
