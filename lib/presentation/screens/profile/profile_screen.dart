import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:cached_network_image/cached_network_image.dart';
import '../../../core/constants/colors.dart';
import '../../../core/constants/strings.dart';
import '../../controllers/profile_controller.dart';

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final controller = Get.put(ProfileController());

    return Scaffold(
      backgroundColor: AppColors.kDarkBackground,
      body: SafeArea(
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.all(20.0),
            child: Obx(() {
              if (controller.isLoading.value && controller.userName.value.isEmpty) {
                return const Center(
                  child: CircularProgressIndicator(
                    color: AppColors.kYellowAccent,
                  ),
                );
              }

              return Column(
                children: [
                  _buildProfileHeader(controller),
                  const SizedBox(height: 24),
                  _buildRatingCard(controller),
                  const SizedBox(height: 24),
                  _buildStatsGrid(controller),
                  const SizedBox(height: 24),
                  _buildMenuOptions(controller),
                ],
              );
            }),
          ),
        ),
      ),
    );
  }

  Widget _buildProfileHeader(ProfileController controller) {
    return Column(
      children: [
        Stack(
          children: [
            Container(
              width: 100,
              height: 100,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                border: Border.all(
                  color: AppColors.kYellowAccent,
                  width: 3,
                ),
              ),
              child: ClipOval(
                child: controller.userPhotoUrl.value.isNotEmpty
                    ? CachedNetworkImage(
                        imageUrl: controller.userPhotoUrl.value,
                        fit: BoxFit.cover,
                        placeholder: (context, url) => const Icon(
                          Icons.person,
                          color: AppColors.kGrey,
                          size: 50,
                        ),
                        errorWidget: (context, url, error) => const Icon(
                          Icons.person,
                          color: AppColors.kGrey,
                          size: 50,
                        ),
                      )
                    : const Icon(
                        Icons.person,
                        color: AppColors.kGrey,
                        size: 50,
                      ),
              ),
            ),
            Positioned(
              bottom: 0,
              right: 0,
              child: InkWell(
                onTap: controller.updateProfilePhoto,
                child: Container(
                  padding: const EdgeInsets.all(6),
                  decoration: BoxDecoration(
                    color: AppColors.kYellowAccent,
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(
                    Icons.camera_alt_rounded,
                    color: AppColors.kBlack,
                    size: 16,
                  ),
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 16),
        Text(
          controller.userName.value,
          style: const TextStyle(
            fontSize: 24,
            fontWeight: FontWeight.bold,
            color: AppColors.kWhite,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          controller.userEmail.value,
          style: TextStyle(
            fontSize: 14,
            color: AppColors.kGrey,
          ),
        ),
      ],
    );
  }

  Widget _buildRatingCard(ProfileController controller) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            AppColors.kYellowAccent.withOpacity(0.3),
            AppColors.kYellowAccent.withOpacity(0.1),
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: AppColors.kYellowAccent.withOpacity(0.3),
          width: 1,
        ),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          Column(
            children: [
              Text(
                controller.overallRating.value.toStringAsFixed(1),
                style: const TextStyle(
                  fontSize: 40,
                  fontWeight: FontWeight.bold,
                  color: AppColors.kYellowAccent,
                ),
              ),
              Text(
                AppStrings.overallRating,
                style: TextStyle(
                  fontSize: 14,
                  color: AppColors.kWhite,
                ),
              ),
            ],
          ),
          Container(
            width: 1,
            height: 60,
            color: AppColors.kWhite.withOpacity(0.3),
          ),
          Column(
            children: [
              Text(
                controller.totalMatches.value.toString(),
                style: const TextStyle(
                  fontSize: 40,
                  fontWeight: FontWeight.bold,
                  color: AppColors.kWhite,
                ),
              ),
              Text(
                AppStrings.totalMatches,
                style: TextStyle(
                  fontSize: 14,
                  color: AppColors.kWhite,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildStatsGrid(ProfileController controller) {
    final stats = controller.aggregatedStats;
    
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppColors.kDarkCard,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            AppStrings.accumulatedStats,
            style: const TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: AppColors.kWhite,
            ),
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(
                child: _buildStatBox(
                  'Distancia Total',
                  stats.isNotEmpty 
                      ? '${((stats['totalDistance'] ?? 0) / 1000).toStringAsFixed(1)} km'
                      : '0 km',
                  Icons.directions_run_rounded,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _buildStatBox(
                  'Asistencias',
                  stats['totalAssists']?.toString() ?? '0',
                  Icons.sports_handball_rounded,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: _buildStatBox(
                  'Precisión',
                  stats.isNotEmpty 
                      ? '${stats['avgPassAccuracy']?.toStringAsFixed(0) ?? '0'}%'
                      : '0%',
                  Icons.check_circle_rounded,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _buildStatBox(
                  'Tackles',
                  stats['totalTackles']?.toString() ?? '0',
                  Icons.shield_rounded,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildStatBox(String label, String value, IconData icon) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.kDarkSurface,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        children: [
          Icon(
            icon,
            color: AppColors.kYellowAccent,
            size: 32,
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
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 12,
              color: AppColors.kGrey,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMenuOptions(ProfileController controller) {
    return Column(
      children: [
        _buildMenuItem(
          Icons.edit_rounded,
          AppStrings.editProfile,
          controller.navigateToEditProfile,
        ),
        const SizedBox(height: 12),
        _buildMenuItem(
          Icons.account_balance_wallet_rounded,
          'Billetera',
          () => Get.toNamed('/wallet_screen'),
        ),
        const SizedBox(height: 12),
        _buildMenuItem(
          Icons.settings_rounded,
          'Configuración',
          () {},
        ),
        const SizedBox(height: 12),
        _buildMenuItem(
          Icons.logout_rounded,
          'Cerrar Sesión',
          controller.signOut,
          isDestructive: true,
        ),
      ],
    );
  }

  Widget _buildMenuItem(IconData icon, String label, VoidCallback onTap, {bool isDestructive = false}) {
    return InkWell(
      onTap: onTap,
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
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: (isDestructive ? AppColors.kRed : AppColors.kYellowAccent).withOpacity(0.15),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Icon(
                icon,
                color: isDestructive ? AppColors.kRed : AppColors.kYellowAccent,
                size: 20,
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Text(
                label,
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w500,
                  color: isDestructive ? AppColors.kRed : AppColors.kWhite,
                ),
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
  }
}
