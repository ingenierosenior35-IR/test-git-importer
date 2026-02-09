import 'package:Rival/features/weather/domain/entities/sab_sensor.dart';
import 'package:Rival/features/weather/domain/entities/weather_condition.dart';
import 'package:dartz/dartz.dart';
import 'package:Rival/core/errors/failures.dart';

/// Repository interface for weather data
abstract class WeatherRepository {
  /// Gets all rainfall sensors from SAB
  Future<Either<Failure, List<SabSensor>>> getAllSensors();
  
  /// Gets weather condition for a specific location
  Future<Either<Failure, WeatherCondition>> getWeatherCondition({
    required double latitude,
    required double longitude,
  });
  
  /// Gets the nearest sensor to a location
  Future<Either<Failure, SabSensor>> getNearestSensor({
    required double latitude,
    required double longitude,
  });
}
