import 'package:get/get.dart';
import 'package:share_plus/share_plus.dart';
import 'package:Rival/data/models/match.dart';
import 'package:Rival/data/repositories/match_repository.dart';
import 'package:Rival/features/weather/domain/entities/weather_condition.dart';
import 'package:Rival/features/weather/domain/repositories/weather_repository.dart';
import 'package:Rival/features/weather/data/datasources/sab_remote_data_source.dart';
import 'package:Rival/features/weather/data/repositories/weather_repository_impl.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

class MatchDetailController extends GetxController {
  final MatchRepository _matchRepository = MatchRepository();
  late final WeatherRepository _weatherRepository;

  final isLoading = false.obs;
  final match = Rx<Match?>(null);
  final weatherCondition = Rx<WeatherCondition?>(null);

  String? matchId;

  @override
  void onInit() {
    super.onInit();
    _initializeWeatherRepository();
    
    // Get matchId from arguments
    final args = Get.arguments as Map<String, dynamic>?;
    if (args != null && args.containsKey('matchId')) {
      matchId = args['matchId'] as String;
      loadMatchDetails();
    }
  }

  Future<void> _initializeWeatherRepository() async {
    final prefs = await SharedPreferences.getInstance();
    _weatherRepository = WeatherRepositoryImpl(
      remoteDataSource: SabRemoteDataSourceImpl(client: http.Client()),
      sharedPreferences: prefs,
    );
  }

  Future<void> loadMatchDetails() async {
    if (matchId == null) return;

    try {
      isLoading.value = true;
      
      // Load match details
      final matchData = await _matchRepository.getMatch(matchId!);
      match.value = matchData;

      // Load weather condition if location is available
      if (matchData.venueLatitude != null && matchData.venueLongitude != null) {
        await loadWeatherCondition(
          matchData.venueLatitude!,
          matchData.venueLongitude!,
        );
      }
    } catch (e) {
      Get.snackbar('Error', 'No se pudo cargar el partido');
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> loadWeatherCondition(double latitude, double longitude) async {
    try {
      final result = await _weatherRepository.getWeatherCondition(
        latitude: latitude,
        longitude: longitude,
      );

      result.fold(
        (failure) {
          // Weather unavailable, that's okay
          weatherCondition.value = null;
        },
        (condition) {
          weatherCondition.value = condition;
        },
      );
    } catch (e) {
      // Weather service failed, continue without it
      weatherCondition.value = null;
    }
  }

  void shareMatch() {
    final matchData = match.value;
    if (matchData == null) return;

    final text = '''
🏆 ${matchData.name}
📅 ${matchData.dateTime.toString()}
📍 ${matchData.venue}
${matchData.competition != null ? '🏅 ${matchData.competition}' : ''}

¡Únete al partido con el código: ${matchData.inviteCode}!
    ''';

    Share.share(text);
  }

  void shareInvite() {
    final matchData = match.value;
    if (matchData == null) return;

    final text = '''
🎮 ¡Te invito a jugar!

${matchData.name}
📅 ${matchData.dateTime.toString()}
📍 ${matchData.venue}

Código de invitación: ${matchData.inviteCode}
    ''';

    Share.share(text);
  }

  void editMatch() {
    // Navigate to edit screen
    Get.toNamed('/edit_match', arguments: {'match': match.value});
  }

  Future<void> cancelMatch() async {
    try {
      final matchData = match.value;
      if (matchData == null) return;

      // Show confirmation dialog
      final confirmed = await Get.dialog<bool>(
        AlertDialog(
          backgroundColor: const Color(0xFF252D32),
          title: const Text(
            'Cancelar partido',
            style: TextStyle(color: Colors.white),
          ),
          content: const Text(
            '¿Estás seguro de que quieres cancelar este partido?',
            style: TextStyle(color: Colors.white70),
          ),
          actions: [
            TextButton(
              onPressed: () => Get.back(result: false),
              child: const Text('No'),
            ),
            TextButton(
              onPressed: () => Get.back(result: true),
              child: const Text(
                'Sí, cancelar',
                style: TextStyle(color: Colors.red),
              ),
            ),
          ],
        ),
      );

      if (confirmed == true) {
        await _matchRepository.updateMatchStatus(
          matchData.id,
          MatchStatus.cancelled,
        );
        Get.back();
        Get.snackbar('Éxito', 'Partido cancelado');
      }
    } catch (e) {
      Get.snackbar('Error', 'No se pudo cancelar el partido');
    }
  }

  void handleVideo() {
    final matchData = match.value;
    if (matchData == null) return;

    if (matchData.videoUrl != null) {
      // Navigate to video player
      Get.toNamed('/video_player', arguments: {'videoUrl': matchData.videoUrl});
    } else {
      // Navigate to video upload
      Get.toNamed('/video_upload', arguments: {'matchId': matchData.id});
    }
  }

  void viewAnalysis() {
    final matchData = match.value;
    if (matchData == null) return;

    Get.toNamed('/match_analysis', arguments: {'matchId': matchData.id});
  }
}
