import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:Rival/core/constants/colors.dart';
import 'package:Rival/data/models/player_stats.dart';

class MatchAnalysisController extends GetxController {
  final isLoading = false.obs;
  final Rx<PlayerStats?> playerStats = Rx<PlayerStats?>(null);
  String? matchId;

  @override
  void onInit() {
    super.onInit();
    final args = Get.arguments as Map<String, dynamic>?;
    if (args != null && args.containsKey('matchId')) {
      matchId = args['matchId'] as String;
      loadAnalysis();
    }
  }

  Future<void> loadAnalysis() async {
    try {
      isLoading.value = true;
      
      // TODO: Load actual player stats from repository
      // For now, using mock data
      await Future.delayed(const Duration(seconds: 1));
      
      playerStats.value = PlayerStats(
        playerId: 'player1',
        matchId: matchId ?? '',
        timestamp: DateTime.now(),
        physical: PhysicalStats(
          totalDistanceKm: 8.5,
          sprintDistanceM: 650,
          topSpeedKmh: 28.3,
          avgSpeedKmh: 12.5,
          sprintsCount: 42,
          accelerationsCount: 35,
          decelerationsCount: 38,
          minutesPlayed: 90,
        ),
        positioning: PositioningStats(
          avgPositionX: 0.55,
          avgPositionY: 0.45,
          fieldCoveragePercent: 65,
          heatmapZones: {},
          offensiveThirdPercent: 40,
          defensiveThirdPercent: 35,
          middleThirdPercent: 25,
        ),
        ballInteraction: BallInteractionStats(
          touches: 68,
          possessionPercent: 12.5,
          ballRecoveries: 8,
          ballLosses: 12,
        ),
        passing: PassingStats(
          passesAttempted: 45,
          passesCompleted: 38,
          passingAccuracyPercent: 84.4,
          keyPasses: 3,
          assists: 1,
          preAssists: 2,
        ),
        defensive: DefensiveStats(
          tacklesAttempted: 7,
          tacklesWon: 5,
          interceptions: 4,
          pressures: 12,
          duelsWon: 9,
          duelsLost: 6,
          blocks: 2,
        ),
        fatigue: FatigueStats(
          fatigueIndex: 72,
          consistencyIndex: 85,
          speedDropPercent: 15,
        ),
        estimatedBiometrics: EstimatedBiometrics(
          heightCm: 178,
          weightKg: 75,
          strideLengthM: 1.85,
          cadence: 165,
          jumpHeightCm: 45,
          confidenceScore: 0.82,
        ),
        advanced: AdvancedStats(
          impactScore: 7.8,
          offensiveIndex: 8.2,
          defensiveIndex: 7.4,
          versatilityIndex: 8.0,
        ),
      );
    } catch (e) {
      Get.snackbar('Error', 'No se pudo cargar el análisis');
    } finally {
      isLoading.value = false;
    }
  }
}

class MatchAnalysisScreen extends StatelessWidget {
  const MatchAnalysisScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final controller = Get.put(MatchAnalysisController());

    return Scaffold(
      backgroundColor: AppColors.kDarkBackground,
      appBar: AppBar(
        backgroundColor: AppColors.kDarkBackground,
        title: const Text(
          'Análisis del Partido',
          style: TextStyle(
            color: AppColors.kWhite,
            fontSize: 20,
            fontWeight: FontWeight.bold,
          ),
        ),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_rounded, color: AppColors.kWhite),
          onPressed: () => Get.back(),
        ),
      ),
      body: Obx(() {
        if (controller.isLoading.value) {
          return const Center(
            child: CircularProgressIndicator(
              color: AppColors.kYellowAccent,
            ),
          );
        }

        final stats = controller.playerStats.value;
        if (stats == null) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(
                  Icons.analytics_outlined,
                  size: 64,
                  color: AppColors.kGrey,
                ),
                const SizedBox(height: 16),
                Text(
                  'No hay datos de análisis',
                  style: TextStyle(
                    fontSize: 18,
                    color: AppColors.kGrey,
                  ),
                ),
              ],
            ),
          );
        }

        return SingleChildScrollView(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildImpactScoreCard(stats),
              const SizedBox(height: 20),
              _buildPhysicalStatsSection(stats.physical),
              const SizedBox(height: 20),
              _buildPassingStatsSection(stats.passing),
              const SizedBox(height: 20),
              _buildDefensiveStatsSection(stats.defensive),
              const SizedBox(height: 20),
              _buildAdvancedMetricsSection(stats.advanced),
            ],
          ),
        );
      }),
    );
  }

  Widget _buildImpactScoreCard(PlayerStats stats) {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            AppColors.kYellowAccent,
            AppColors.kYellowAccent.withOpacity(0.7),
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        children: [
          const Text(
            'Puntuación de Impacto',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w600,
              color: AppColors.kBlack,
            ),
          ),
          const SizedBox(height: 12),
          Text(
            stats.advanced.impactScore.toStringAsFixed(1),
            style: const TextStyle(
              fontSize: 48,
              fontWeight: FontWeight.bold,
              color: AppColors.kBlack,
            ),
          ),
          const SizedBox(height: 8),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              _buildMiniStat('Ofensiva', stats.advanced.offensiveIndex.toStringAsFixed(1)),
              _buildMiniStat('Defensiva', stats.advanced.defensiveIndex.toStringAsFixed(1)),
              _buildMiniStat('Versatilidad', stats.advanced.versatilityIndex.toStringAsFixed(1)),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildMiniStat(String label, String value) {
    return Column(
      children: [
        Text(
          value,
          style: const TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
            color: AppColors.kBlack,
          ),
        ),
        Text(
          label,
          style: const TextStyle(
            fontSize: 11,
            color: AppColors.kBlack,
          ),
        ),
      ],
    );
  }

  Widget _buildPhysicalStatsSection(PhysicalStats stats) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppColors.kDarkCard,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(Icons.directions_run_rounded, color: AppColors.kYellowAccent, size: 24),
              const SizedBox(width: 12),
              const Text(
                'Métricas Físicas',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: AppColors.kWhite,
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),
          _buildStatRow('Distancia Total', '${stats.totalDistanceKm.toStringAsFixed(1)} km'),
          const SizedBox(height: 12),
          _buildStatRow('Distancia Sprint', '${stats.sprintDistanceM} m'),
          const SizedBox(height: 12),
          _buildStatRow('Velocidad Máxima', '${stats.topSpeedKmh.toStringAsFixed(1)} km/h'),
          const SizedBox(height: 12),
          _buildStatRow('Sprints', '${stats.sprintsCount}'),
          const SizedBox(height: 12),
          _buildStatRow('Aceleraciones', '${stats.accelerationsCount}'),
          const SizedBox(height: 12),
          _buildStatRow('Minutos Jugados', '${stats.minutesPlayed}\''),
        ],
      ),
    );
  }

  Widget _buildPassingStatsSection(PassingStats stats) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppColors.kDarkCard,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(Icons.sports_soccer_rounded, color: AppColors.kYellowAccent, size: 24),
              const SizedBox(width: 12),
              const Text(
                'Pases y Juego',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: AppColors.kWhite,
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),
          _buildStatRow('Pases Completados', '${stats.passesCompleted}/${stats.passesAttempted}'),
          const SizedBox(height: 12),
          _buildProgressBar('Precisión', stats.passingAccuracyPercent / 100),
          const SizedBox(height: 12),
          _buildStatRow('Pases Clave', '${stats.keyPasses}'),
          const SizedBox(height: 12),
          _buildStatRow('Asistencias', '${stats.assists}'),
          const SizedBox(height: 12),
          _buildStatRow('Pre-Asistencias', '${stats.preAssists}'),
        ],
      ),
    );
  }

  Widget _buildDefensiveStatsSection(DefensiveStats stats) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppColors.kDarkCard,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(Icons.shield_rounded, color: AppColors.kYellowAccent, size: 24),
              const SizedBox(width: 12),
              const Text(
                'Métricas Defensivas',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: AppColors.kWhite,
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),
          _buildStatRow('Entradas Ganadas', '${stats.tacklesWon}/${stats.tacklesAttempted}'),
          const SizedBox(height: 12),
          _buildStatRow('Intercepciones', '${stats.interceptions}'),
          const SizedBox(height: 12),
          _buildStatRow('Presiones', '${stats.pressures}'),
          const SizedBox(height: 12),
          _buildStatRow('Duelos Ganados', '${stats.duelsWon}/${stats.duelsWon + stats.duelsLost}'),
          const SizedBox(height: 12),
          _buildStatRow('Bloqueos', '${stats.blocks}'),
        ],
      ),
    );
  }

  Widget _buildAdvancedMetricsSection(AdvancedStats stats) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppColors.kDarkCard,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(Icons.insights_rounded, color: AppColors.kYellowAccent, size: 24),
              const SizedBox(width: 12),
              const Text(
                'Métricas Avanzadas',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: AppColors.kWhite,
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),
          _buildProgressBar('Índice Ofensivo', stats.offensiveIndex / 10),
          const SizedBox(height: 16),
          _buildProgressBar('Índice Defensivo', stats.defensiveIndex / 10),
          const SizedBox(height: 16),
          _buildProgressBar('Índice de Versatilidad', stats.versatilityIndex / 10),
        ],
      ),
    );
  }

  Widget _buildStatRow(String label, String value) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: const TextStyle(
            fontSize: 14,
            color: AppColors.kGrey,
          ),
        ),
        Text(
          value,
          style: const TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.bold,
            color: AppColors.kWhite,
          ),
        ),
      ],
    );
  }

  Widget _buildProgressBar(String label, double value) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              label,
              style: const TextStyle(
                fontSize: 14,
                color: AppColors.kGrey,
              ),
            ),
            Text(
              '${(value * 100).toStringAsFixed(0)}%',
              style: const TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.bold,
                color: AppColors.kWhite,
              ),
            ),
          ],
        ),
        const SizedBox(height: 8),
        LinearProgressIndicator(
          value: value,
          backgroundColor: AppColors.kDarkSurface,
          valueColor: const AlwaysStoppedAnimation<Color>(AppColors.kYellowAccent),
          minHeight: 8,
          borderRadius: BorderRadius.circular(4),
        ),
      ],
    );
  }
}
