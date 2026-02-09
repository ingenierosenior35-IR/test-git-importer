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
                    style: TextStyle(
                      fontSize: 14,
                      color: AppColors.kBlack.withOpacity(0.7),
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
