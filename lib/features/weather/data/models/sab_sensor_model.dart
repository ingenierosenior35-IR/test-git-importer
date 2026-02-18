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
    super.visible,
    super.estado,
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
      visible: _parseInt(json['VISIBLE']),
      estado: _parseInt(json['ESTADO']),
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
      'VISIBLE': visible,
      'ESTADO': estado,
    };
  }

  static double _parseDouble(dynamic value) {
    if (value == null) return 0.0;
    if (value is double) return value;
    if (value is int) return value.toDouble();
    if (value is String) return double.tryParse(value) ?? 0.0;
    return 0.0;
  }

  static int? _parseInt(dynamic value) {
    if (value == null) return null;
    if (value is int) return value;
    if (value is String) return int.tryParse(value);
    return null;
  }
}
