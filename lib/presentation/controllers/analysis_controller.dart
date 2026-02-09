import 'package:get/get.dart';
import '../../services/auth_service.dart';
import '../../data/repositories/stats_repository.dart';
import '../../data/repositories/match_repository.dart';
import '../../data/services/ai_service.dart';
import '../../data/models/player_stats.dart';
import '../../data/models/match.dart';

class AnalysisController extends GetxController {
  final AuthService _authService = Get.find<AuthService>();
  final StatsRepository _statsRepository = StatsRepository();
  final MatchRepository _matchRepository = MatchRepository();
  final AIService _aiService = AIService();

  final isLoading = false.obs;
  final matchHistory = <Match>[].obs;
  final currentStats = Rx<PlayerStats?>(null);
  final currentAnalysis = Rx<MatchAnalysis?>(null);
  final aggregatedStats = <String, dynamic>{}.obs;

  @override
  void onInit() {
    super.onInit();
    loadMatchHistory();
    loadAggregatedStats();
  }

  Future<void> loadMatchHistory() async {
    try {
      isLoading.value = true;
      final user = _authService.currentUser;
      if (user != null) {
        final matches = await _matchRepository.getUserMatches(user.uid);
        matchHistory.value = matches
            .where((match) => match.status == MatchStatus.completed)
            .toList();
      }
    } catch (e) {
      Get.snackbar('Error', 'No se pudo cargar el historial de partidos');
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> loadMatchStats(String matchId) async {
    try {
      isLoading.value = true;
      final user = _authService.currentUser;
      if (user != null) {
        final stats = await _statsRepository.getPlayerStatsForMatch(matchId, user.uid);
        if (stats != null) {
          currentStats.value = stats;
          final analysis = await _aiService.analyzeMatch(stats);
          currentAnalysis.value = analysis;
        }
      }
    } catch (e) {
      Get.snackbar('Error', 'No se pudieron cargar las estadísticas');
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> loadAggregatedStats() async {
    try {
      final user = _authService.currentUser;
      if (user != null) {
        final stats = await _statsRepository.getAggregatedStats(user.uid);
        aggregatedStats.value = stats;
      }
    } catch (e) {
      Get.snackbar('Error', 'No se pudieron cargar las estadísticas acumuladas');
    }
  }

  void navigateToMatchDetail(String matchId) {
    loadMatchStats(matchId);
    Get.toNamed('/player_metrics', arguments: {'matchId': matchId});
  }
}
