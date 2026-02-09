import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../core/constants/colors.dart';
import '../../../core/constants/strings.dart';
import '../../controllers/analysis_controller.dart';
import 'package:intl/intl.dart';

class MatchHistoryScreen extends StatelessWidget {
  const MatchHistoryScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final controller = Get.put(AnalysisController());

    return Scaffold(
      backgroundColor: AppColors.kDarkBackground,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(20.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                AppStrings.analysis,
                style: const TextStyle(
                  fontSize: 28,
                  fontWeight: FontWeight.bold,
                  color: AppColors.kWhite,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                'Revisa tu rendimiento y progreso',
                style: TextStyle(
                  fontSize: 16,
                  color: AppColors.kGrey,
                ),
              ),
              const SizedBox(height: 24),
              Obx(() {
                if (controller.aggregatedStats.isNotEmpty) {
                  return _buildStatsOverview(controller);
                }
                return const SizedBox.shrink();
              }),
              const SizedBox(height: 24),
              Text(
                AppStrings.matchHistory,
                style: const TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: AppColors.kWhite,
                ),
              ),
              const SizedBox(height: 12),
              Expanded(
                child: Obx(() {
                  if (controller.isLoading.value) {
                    return const Center(
                      child: CircularProgressIndicator(
                        color: AppColors.kYellowAccent,
                      ),
                    );
                  }

                  if (controller.matchHistory.isEmpty) {
                    return Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            Icons.analytics_outlined,
                            size: 64,
                            color: AppColors.kGrey,
                          ),
                          const SizedBox(height: 16),
                          Text(
                            'No hay partidos analizados',
                            style: TextStyle(
                              fontSize: 18,
                              color: AppColors.kGrey,
                            ),
                          ),
                        ],
                      ),
                    );
                  }

                  return ListView.separated(
                    itemCount: controller.matchHistory.length,
                    separatorBuilder: (context, index) => const SizedBox(height: 12),
                    itemBuilder: (context, index) {
                      final match = controller.matchHistory[index];
                      return InkWell(
                        onTap: () => controller.navigateToMatchDetail(match.id),
                        borderRadius: BorderRadius.circular(16),
                        child: Container(
                          padding: const EdgeInsets.all(16),
                          decoration: BoxDecoration(
                            color: AppColors.kDarkCard,
                            borderRadius: BorderRadius.circular(16),
                          ),
                          child: Row(
                            children: [
                              Container(
                                padding: const EdgeInsets.all(12),
                                decoration: BoxDecoration(
                                  color: AppColors.kYellowAccent.withOpacity(0.15),
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                child: const Icon(
                                  Icons.sports_soccer_rounded,
                                  color: AppColors.kYellowAccent,
                                  size: 24,
                                ),
                              ),
                              const SizedBox(width: 16),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      match.name,
                                      style: const TextStyle(
                                        fontSize: 16,
                                        fontWeight: FontWeight.w600,
                                        color: AppColors.kWhite,
                                      ),
                                    ),
                                    const SizedBox(height: 4),
                                    Text(
                                      DateFormat('dd MMM yyyy', 'es').format(match.dateTime),
                                      style: TextStyle(
                                        fontSize: 14,
                                        color: AppColors.kGrey,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              Icon(
                                Icons.arrow_forward_ios_rounded,
                                color: AppColors.kGrey,
                                size: 16,
                              ),
                            ],
                          ),
                        ),
                      );
                    },
                  );
                }),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildStatsOverview(AnalysisController controller) {
    final stats = controller.aggregatedStats;
    
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            AppColors.kDarkCard,
            AppColors.kDarkSurface,
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              _buildStatItem(
                'Partidos',
                stats['totalMatches']?.toString() ?? '0',
                Icons.sports_soccer_rounded,
              ),
              _buildStatItem(
                'Impacto',
                stats['avgImpactScore']?.toStringAsFixed(1) ?? '0.0',
                Icons.stars_rounded,
              ),
              _buildStatItem(
                'Asistencias',
                stats['totalAssists']?.toString() ?? '0',
                Icons.sports_handball_rounded,
              ),
            ],
          ),
          const SizedBox(height: 16),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              _buildStatItem(
                'Distancia',
                '${((stats['totalDistance'] ?? 0) / 1000).toStringAsFixed(1)} km',
                Icons.directions_run_rounded,
              ),
              _buildStatItem(
                'Precisión',
                '${stats['avgPassAccuracy']?.toStringAsFixed(0) ?? '0'}%',
                Icons.check_circle_rounded,
              ),
              _buildStatItem(
                'Tackles',
                stats['totalTackles']?.toString() ?? '0',
                Icons.shield_rounded,
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildStatItem(String label, String value, IconData icon) {
    return Column(
      children: [
        Icon(
          icon,
          color: AppColors.kYellowAccent,
          size: 24,
        ),
        const SizedBox(height: 8),
        Text(
          value,
          style: const TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
            color: AppColors.kWhite,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          label,
          style: TextStyle(
            fontSize: 12,
            color: AppColors.kGrey,
          ),
        ),
      ],
    );
  }
}
