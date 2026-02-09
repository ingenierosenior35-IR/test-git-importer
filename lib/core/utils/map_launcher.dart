import 'package:url_launcher/url_launcher.dart';
import 'dart:io';

/// Utility for deep linking to map applications
class MapLauncher {
  /// Opens the specified location in Maps/Waze
  /// Tries Waze first, then falls back to Google Maps (Android) or Apple Maps (iOS)
  static Future<bool> openMapWithDirections({
    required double latitude,
    required double longitude,
    required String locationName,
  }) async {
    try {
      // Try Waze first
      final wazeUrl = _getWazeUrl(latitude, longitude);
      if (await canLaunchUrl(Uri.parse(wazeUrl))) {
        return await launchUrl(
          Uri.parse(wazeUrl),
          mode: LaunchMode.externalApplication,
        );
      }

      // Fallback to platform-specific maps
      if (Platform.isAndroid) {
        return await _openGoogleMaps(latitude, longitude, locationName);
      } else if (Platform.isIOS) {
        return await _openAppleMaps(latitude, longitude, locationName);
      }

      return false;
    } catch (e) {
      print('Error launching map: $e');
      return false;
    }
  }

  /// Opens Google Maps with the specified location
  static Future<bool> _openGoogleMaps(
    double latitude,
    double longitude,
    String locationName,
  ) async {
    final url = 'https://www.google.com/maps/dir/?api=1&destination=$latitude,$longitude&destination_place_id=$locationName';
    
    if (await canLaunchUrl(Uri.parse(url))) {
      return await launchUrl(
        Uri.parse(url),
        mode: LaunchMode.externalApplication,
      );
    }
    return false;
  }

  /// Opens Apple Maps with the specified location
  static Future<bool> _openAppleMaps(
    double latitude,
    double longitude,
    String locationName,
  ) async {
    final url = 'https://maps.apple.com/?daddr=$latitude,$longitude&q=$locationName';
    
    if (await canLaunchUrl(Uri.parse(url))) {
      return await launchUrl(
        Uri.parse(url),
        mode: LaunchMode.externalApplication,
      );
    }
    return false;
  }

  /// Gets the Waze deep link URL
  static String _getWazeUrl(double latitude, double longitude) {
    return 'waze://?ll=$latitude,$longitude&navigate=yes';
  }

  /// Shows a bottom sheet to choose between Waze, Google Maps, or Apple Maps
  static void showMapChoiceDialog({
    required double latitude,
    required double longitude,
    required String locationName,
    required Function(String) onMapChosen,
  }) {
    // This will be implemented in the UI layer
    // For now, just try Waze then fallback
  }
}
