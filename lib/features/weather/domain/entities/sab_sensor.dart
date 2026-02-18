import 'package:equatable/equatable.dart';

/// Domain entity for SAB weather sensor
class SabSensor extends Equatable {
  final String id;
  final String station;
  final double latitude;
  final double longitude;
  final String locality;
  final double currentReading; // mm of rainfall
  final double dailyAccumulated; // mm accumulated today
  final String readingDate;
  final double? atmosphericPressure;
  final int? visible; // 1 = visible, 0 = hidden
  final int? estado; // 1 = active, 0 = inactive

  const SabSensor({
    required this.id,
    required this.station,
    required this.latitude,
    required this.longitude,
    required this.locality,
    required this.currentReading,
    required this.dailyAccumulated,
    required this.readingDate,
    this.atmosphericPressure,
    this.visible,
    this.estado,
  });

  @override
  List<Object?> get props => [
        id,
        station,
        latitude,
        longitude,
        locality,
        currentReading,
        dailyAccumulated,
        readingDate,
        atmosphericPressure,
        visible,
        estado,
      ];
}
