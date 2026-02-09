import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:Rival/features/weather/data/models/sab_sensor_model.dart';

/// Remote data source for SAB weather API
abstract class SabRemoteDataSource {
  /// Fetches rainfall sensor data from SAB endpoint
  Future<List<SabSensorModel>> getRainfallSensors();
}

class SabRemoteDataSourceImpl implements SabRemoteDataSource {
  final http.Client client;
  
  // SAB endpoint for rainfall sensors (idtiposensor=5)
  static const String _baseUrl = 'https://app.sab.gov.co/sab/ServletTipoSensores';
  static const String _rainfallSensorId = '5';

  SabRemoteDataSourceImpl({required this.client});

  @override
  Future<List<SabSensorModel>> getRainfallSensors() async {
    try {
      final uri = Uri.parse('$_baseUrl?idtiposensor=$_rainfallSensorId');
      
      final response = await client.get(
        uri,
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
        },
      ).timeout(
        const Duration(seconds: 10),
      );

      if (response.statusCode == 200) {
        final jsonData = json.decode(response.body);
        
        // Response structure: { "TipoSensores": [ {...}, {...}, ... ] }
        if (jsonData is Map && jsonData.containsKey('TipoSensores')) {
          final sensorsJson = jsonData['TipoSensores'] as List;
          return sensorsJson
              .map((json) => SabSensorModel.fromJson(json as Map<String, dynamic>))
              .toList();
        }
        
        return [];
      } else {
        throw Exception('Failed to load SAB sensor data: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Error fetching SAB data: $e');
    }
  }
}
