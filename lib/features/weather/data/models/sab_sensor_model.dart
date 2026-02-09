import 'package:Rival/features/weather/domain/entities/sab_sensor.dart';

/// Data model for SAB weather sensor readings
/// Maps to JSON response from https://app.sab.gov.co/sab/ServletTipoSensores?idtiposensor=5
class SabSensorModel extends SabSensor {
  const SabSensorModel({
    required super.id,
    required super.station,
    required super.latitude,
    required super.longitude,
    required super.locality,
    required super.currentReading,
    required super.dailyAccumulated,
    required super.readingDate,
    super.atmosphericPressure,
  });

  /// Creates a SabSensorModel from JSON
  factory SabSensorModel.fromJson(Map<String, dynamic> json) {
    return SabSensorModel(
      id: json['IDSENSOR']?.toString() ?? '',
      station: json['ESTACION']?.toString() ?? '',
      latitude: _parseDouble(json['LATITUD']),
      longitude: _parseDouble(json['LONGITUD']),
      locality: json['LOCALIDAD']?.toString() ?? '',
      currentReading: _parseDouble(json['VALORLECTURA']),
      dailyAccumulated: _parseDouble(json['ACUMULADODIA']),
      readingDate: json['FECHALECTURA']?.toString() ?? '',
      atmosphericPressure: _parseDouble(json['PRESIONATMOSFERICA']),
    );
  }

  /// Converts model to JSON
  Map<String, dynamic> toJson() {
    return {
      'IDSENSOR': id,
      'ESTACION': station,
      'LATITUD': latitude,
      'LONGITUD': longitude,
      'LOCALIDAD': locality,
      'VALORLECTURA': currentReading,
      'ACUMULADODIA': dailyAccumulated,
      'FECHALECTURA': readingDate,
      'PRESIONATMOSFERICA': atmosphericPressure,
    };
  }

  static double _parseDouble(dynamic value) {
    if (value == null) return 0.0;
    if (value is double) return value;
    if (value is int) return value.toDouble();
    if (value is String) return double.tryParse(value) ?? 0.0;
    return 0.0;
  }
}
