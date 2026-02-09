import 'package:Rival/core/errors/exceptions.dart';
import 'package:Rival/core/errors/failures.dart';
import 'package:Rival/core/utils/location_utils.dart';
import 'package:Rival/features/weather/data/datasources/sab_remote_data_source.dart';
import 'package:Rival/features/weather/domain/entities/sab_sensor.dart';
import 'package:Rival/features/weather/domain/entities/weather_condition.dart';
import 'package:Rival/features/weather/domain/repositories/weather_repository.dart';
import 'package:dartz/dartz.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';

class WeatherRepositoryImpl implements WeatherRepository {
  final SabRemoteDataSource remoteDataSource;
  final SharedPreferences sharedPreferences;

  // Cache keys
  static const String _cachedSensorsKey = 'CACHED_SAB_SENSORS';
  static const String _cacheTimeKey = 'CACHE_TIME';
  static const Duration _cacheDuration = Duration(minutes: 30);

  WeatherRepositoryImpl({
    required this.remoteDataSource,
    required this.sharedPreferences,
  });

  @override
  Future<Either<Failure, List<SabSensor>>> getAllSensors() async {
    try {
      // Try cache first
      final cachedSensors = _getCachedSensors();
      if (cachedSensors != null && !_isCacheExpired()) {
        return Right(cachedSensors);
      }

      // Fetch from remote
      final sensors = await remoteDataSource.getRainfallSensors();
      
      // Cache the results
      await _cacheSensors(sensors);
      
      return Right(sensors);
    } on ServerException {
      return Left(ServerFailure());
    } catch (e) {
      return Left(ServerFailure());
    }
  }

  @override
  Future<Either<Failure, WeatherCondition>> getWeatherCondition({
    required double latitude,
    required double longitude,
  }) async {
    try {
      final sensorsResult = await getAllSensors();
      
      return sensorsResult.fold(
        (failure) => Left(failure),
        (sensors) {
          if (sensors.isEmpty) {
            return Left(ServerFailure());
          }

          final nearestSensor = LocationUtils.findNearest<SabSensor>(
            items: sensors,
            targetLat: latitude,
            targetLon: longitude,
            getLatitude: (sensor) => sensor.latitude,
            getLongitude: (sensor) => sensor.longitude,
          );

          if (nearestSensor == null) {
            return Left(ServerFailure());
          }

          final distance = LocationUtils.calculateDistance(
            lat1: latitude,
            lon1: longitude,
            lat2: nearestSensor.latitude,
            lon2: nearestSensor.longitude,
          );

          final condition = WeatherCondition.fromRainfall(
            dailyAccumulatedMm: nearestSensor.dailyAccumulated,
            stationName: nearestSensor.station,
            distanceKm: distance,
          );

          return Right(condition);
        },
      );
    } catch (e) {
      return Left(ServerFailure());
    }
  }

  @override
  Future<Either<Failure, SabSensor>> getNearestSensor({
    required double latitude,
    required double longitude,
  }) async {
    try {
      final sensorsResult = await getAllSensors();
      
      return sensorsResult.fold(
        (failure) => Left(failure),
        (sensors) {
          if (sensors.isEmpty) {
            return Left(ServerFailure());
          }

          final nearestSensor = LocationUtils.findNearest<SabSensor>(
            items: sensors,
            targetLat: latitude,
            targetLon: longitude,
            getLatitude: (sensor) => sensor.latitude,
            getLongitude: (sensor) => sensor.longitude,
          );

          if (nearestSensor == null) {
            return Left(ServerFailure());
          }

          return Right(nearestSensor);
        },
      );
    } catch (e) {
      return Left(ServerFailure());
    }
  }

  // Cache helpers
  List<SabSensor>? _getCachedSensors() {
    try {
      final jsonString = sharedPreferences.getString(_cachedSensorsKey);
      if (jsonString == null) return null;

      final List<dynamic> jsonList = json.decode(jsonString);
      return jsonList.map((json) => 
        SabSensor(
          id: json['id'],
          station: json['station'],
          latitude: json['latitude'],
          longitude: json['longitude'],
          locality: json['locality'],
          currentReading: json['currentReading'],
          dailyAccumulated: json['dailyAccumulated'],
          readingDate: json['readingDate'],
          atmosphericPressure: json['atmosphericPressure'],
        )
      ).toList();
    } catch (e) {
      return null;
    }
  }

  Future<void> _cacheSensors(List<SabSensor> sensors) async {
    try {
      final jsonList = sensors.map((sensor) => {
        'id': sensor.id,
        'station': sensor.station,
        'latitude': sensor.latitude,
        'longitude': sensor.longitude,
        'locality': sensor.locality,
        'currentReading': sensor.currentReading,
        'dailyAccumulated': sensor.dailyAccumulated,
        'readingDate': sensor.readingDate,
        'atmosphericPressure': sensor.atmosphericPressure,
      }).toList();

      await sharedPreferences.setString(_cachedSensorsKey, json.encode(jsonList));
      await sharedPreferences.setInt(_cacheTimeKey, DateTime.now().millisecondsSinceEpoch);
    } catch (e) {
      // Cache write failed, continue without caching
    }
  }

  bool _isCacheExpired() {
    try {
      final cacheTime = sharedPreferences.getInt(_cacheTimeKey);
      if (cacheTime == null) return true;

      final cacheDate = DateTime.fromMillisecondsSinceEpoch(cacheTime);
      final now = DateTime.now();
      
      return now.difference(cacheDate) > _cacheDuration;
    } catch (e) {
      return true;
    }
  }
}
