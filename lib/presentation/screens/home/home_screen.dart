import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../core/constants/colors.dart';
import '../../../core/constants/strings.dart';
import '../../controllers/home_controller.dart';
import 'widgets/player_card.dart';
import 'widgets/matches_agenda.dart';
import 'widgets/scoreboards_section.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final controller = Get.put(HomeController());

    return Scaffold(
      backgroundColor: AppColors.kDarkBackground,
      body: SafeArea(
        child: Obx(() {
          if (controller.isLoading.value) {
            return const Center(
              child: CircularProgressIndicator(
                color: AppColors.kYellowAccent,
              ),
            );
          }

          return RefreshIndicator(
            onRefresh: () async {
              await controller.loadMatches();
              await controller.loadUserData();
            },
            color: AppColors.kYellowAccent,
            backgroundColor: AppColors.kDarkCard,
            child: SingleChildScrollView(
              physics: const AlwaysScrollableScrollPhysics(),
              child: Padding(
                padding: const EdgeInsets.all(20.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Hola, ${controller.userName.value}',
                      style: const TextStyle(
                        fontSize: 28,
                        fontWeight: FontWeight.bold,
                        color: AppColors.kWhite,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Bienvenido a Rival',
                      style: TextStyle(
                        fontSize: 16,
                        color: AppColors.kGrey,
                      ),
                    ),
                    const SizedBox(height: 24),
                    PlayerCard(
                      userName: controller.userName.value,
                      photoUrl: controller.userPhotoUrl.value,
                      upcomingMatch: controller.upcomingMatches.isNotEmpty 
                          ? controller.upcomingMatches.first 
                          : null,
                    ),
                    const SizedBox(height: 24),
                    _buildQuickAccessSection(),
                    const SizedBox(height: 24),
                    ScoreboardsSection(),
                    const SizedBox(height: 24),
                    MatchesAgenda(
                      upcomingMatches: controller.upcomingMatches,
                      onMatchTap: (matchId) => controller.navigateToMatchDetail(matchId),
                    ),
                    const SizedBox(height: 24),
                    _buildCreateTournamentButton(controller),
                  ],
                ),
              ),
            ),
          );
        }),
      ),
    );
  }

  Widget _buildQuickAccessSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Acceso Rápido',
          style: const TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
            color: AppColors.kWhite,
          ),
        ),
        const SizedBox(height: 12),
        Row(
          children: [
            Expanded(
              child: _buildQuickAccessCard(
                icon: Icons.poll,
                title: 'Pollas',
                onTap: () => Get.toNamed('/polls_screen'),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: _buildQuickAccessCard(
                icon: Icons.sports_soccer,
                title: 'Fixtures',
                onTap: () => Get.toNamed('/fixtures_screen'),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: _buildQuickAccessCard(
                icon: Icons.wb_sunny,
                title: 'Clima',
                onTap: () => Get.toNamed('/weather_screen'),
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildQuickAccessCard({
    required IconData icon,
    required String title,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(16),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: AppColors.kDarkCard,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: AppColors.kYellowAccent.withOpacity(0.3),
            width: 1,
          ),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: AppColors.kYellowAccent.withOpacity(0.15),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(
                icon,
                color: AppColors.kYellowAccent,
                size: 28,
              ),
            ),
            const SizedBox(height: 12),
            Text(
              title,
              style: const TextStyle(
                color: AppColors.kWhite,
                fontSize: 14,
                fontWeight: FontWeight.w600,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCreateTournamentButton(HomeController controller) {
    return InkWell(
      onTap: controller.navigateToCreateTournament,
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [
              AppColors.kYellowAccent.withOpacity(0.8),
              AppColors.kYellowAccent,
            ],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          borderRadius: BorderRadius.circular(16),
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: AppColors.kBlack.withOpacity(0.2),
                borderRadius: BorderRadius.circular(12),
              ),
              child: const Icon(
                Icons.emoji_events_rounded,
                color: AppColors.kBlack,
                size: 28,
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    AppStrings.createTournament,
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: AppColors.kBlack,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'Organiza tu propio torneo',
                    style: const TextStyle(
                      fontSize: 14,
                      color: AppColors.kBlack,
                    ),
                  ),
                ],
              ),
            ),
            const Icon(
              Icons.arrow_forward_ios_rounded,
              color: AppColors.kBlack,
              size: 20,
            ),
          ],
        ),
      ),
    );
  }
}
