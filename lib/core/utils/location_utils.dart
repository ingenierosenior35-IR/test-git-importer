import 'dart:math';

/// Utility class for location-based calculations
class LocationUtils {
  /// Earth's radius in kilometers
  static const double earthRadiusKm = 6371.0;

  /// Calculates the distance between two points using the Haversine formula
  /// Returns distance in kilometers
  static double calculateDistance({
    required double lat1,
    required double lon1,
    required double lat2,
    required double lon2,
  }) {
    final dLat = _toRadians(lat2 - lat1);
    final dLon = _toRadians(lon2 - lon1);

    final a = sin(dLat / 2) * sin(dLat / 2) +
        cos(_toRadians(lat1)) *
            cos(_toRadians(lat2)) *
            sin(dLon / 2) *
            sin(dLon / 2);

    final c = 2 * atan2(sqrt(a), sqrt(1 - a));

    return earthRadiusKm * c;
  }

  /// Converts degrees to radians
  static double _toRadians(double degrees) {
    return degrees * pi / 180.0;
  }

  /// Finds the nearest item from a list based on lat/lng
  static T? findNearest<T>({
    required List<T> items,
    required double targetLat,
    required double targetLon,
    required double Function(T) getLatitude,
    required double Function(T) getLongitude,
  }) {
    if (items.isEmpty) return null;

    T? nearest;
    double minDistance = double.infinity;

    for (final item in items) {
      final distance = calculateDistance(
        lat1: targetLat,
        lon1: targetLon,
        lat2: getLatitude(item),
        lon2: getLongitude(item),
      );

      if (distance < minDistance) {
        minDistance = distance;
        nearest = item;
      }
    }

    return nearest;
  }

  /// Finds the N nearest items from a list based on lat/lng
  static List<T> findNearestN<T>({
    required List<T> items,
    required double targetLat,
    required double targetLon,
    required double Function(T) getLatitude,
    required double Function(T) getLongitude,
    required int count,
  }) {
    if (items.isEmpty) return [];

    // Create list of items with distances
    final itemsWithDistance = items.map((item) {
      final distance = calculateDistance(
        lat1: targetLat,
        lon1: targetLon,
        lat2: getLatitude(item),
        lon2: getLongitude(item),
      );
      return {'item': item, 'distance': distance};
    }).toList();

    // Sort by distance
    itemsWithDistance.sort((a, b) =>
        (a['distance'] as double).compareTo(b['distance'] as double));

    // Return top N items
    return itemsWithDistance
        .take(count)
        .map((e) => e['item'] as T)
        .toList();
  }
}
