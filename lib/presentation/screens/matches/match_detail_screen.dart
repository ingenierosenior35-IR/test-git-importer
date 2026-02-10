import 'package:Rival/presentation/controllers/match_detail_controller.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:Rival/core/constants/colors.dart';
import 'package:Rival/data/models/match.dart';
import 'package:Rival/features/weather/domain/entities/weather_condition.dart';
import 'package:Rival/core/utils/map_launcher.dart';

class MatchDetailScreen extends StatelessWidget {
  const MatchDetailScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final controller = Get.put(MatchDetailController());

    return Scaffold(
      backgroundColor: AppColors.kDarkBackground,
      body: Obx(() {
        if (controller.isLoading.value) {
          return const Center(
            child: CircularProgressIndicator(
              color: AppColors.kYellowAccent,
            ),
          );
        }

        final match = controller.match.value;
        if (match == null) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(
                  Icons.error_outline,
                  size: 64,
                  color: AppColors.kGrey,
                ),
                const SizedBox(height: 16),
                Text(
                  'Partido no encontrado',
                  style: TextStyle(
                    fontSize: 18,
                    color: AppColors.kGrey,
                  ),
                ),
              ],
            ),
          );
        }

        return CustomScrollView(
          slivers: [
            _buildAppBar(match, controller),
            SliverToBoxAdapter(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildBasicInfo(match),
                  const SizedBox(height: 16),
                  _buildWeatherCard(match, controller),
                  const SizedBox(height: 16),
                  _buildPlayersSection(match, controller),
                  const SizedBox(height: 16),
                  _buildActionsSection(match, controller),
                  const SizedBox(height: 16),
                  if (match.videoUrl != null) _buildVideoSection(match),
                  const SizedBox(height: 32),
                ],
              ),
            ),
          ],
        );
      }),
    );
  }

  Widget _buildAppBar(Match match, MatchDetailController controller) {
    return SliverAppBar(
      expandedHeight: 120,
      floating: false,
      pinned: true,
      backgroundColor: AppColors.kDarkBackground,
      leading: IconButton(
        icon: const Icon(Icons.arrow_back_rounded, color: AppColors.kWhite),
        onPressed: () => Get.back(),
      ),
      actions: [
        IconButton(
          icon: const Icon(Icons.share_rounded, color: AppColors.kWhite),
          onPressed: () => controller.shareMatch(),
        ),
        PopupMenuButton<String>(
          icon: const Icon(Icons.more_vert_rounded, color: AppColors.kWhite),
          color: AppColors.kDarkCard,
          itemBuilder: (context) => [
            const PopupMenuItem(
              value: 'edit',
              child: Row(
                children: [
                  Icon(Icons.edit_rounded, color: AppColors.kWhite, size: 20),
                  SizedBox(width: 12),
                  Text('Editar', style: TextStyle(color: AppColors.kWhite)),
                ],
              ),
            ),
            const PopupMenuItem(
              value: 'cancel',
              child: Row(
                children: [
                  Icon(Icons.cancel_rounded, color: AppColors.kRed, size: 20),
                  SizedBox(width: 12),
                  Text('Cancelar partido', style: TextStyle(color: AppColors.kRed)),
                ],
              ),
            ),
          ],
          onSelected: (value) {
            if (value == 'edit') {
              controller.editMatch();
            } else if (value == 'cancel') {
              controller.cancelMatch();
            }
          },
        ),
      ],
      flexibleSpace: FlexibleSpaceBar(
        title: Text(
          match.name,
          style: const TextStyle(
            color: AppColors.kWhite,
            fontSize: 20,
            fontWeight: FontWeight.bold,
          ),
        ),
        titlePadding: const EdgeInsets.only(left: 56, bottom: 16, right: 100),
      ),
    );
  }

  Widget _buildBasicInfo(Match match) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 20),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppColors.kDarkCard,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (match.competition != null) ...[
            Row(
              children: [
                const Icon(Icons.emoji_events_rounded, color: AppColors.kYellowAccent, size: 20),
                const SizedBox(width: 8),
                Text(
                  match.competition!,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: AppColors.kYellowAccent,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
          ],
          if (match.team1 != null && match.team2 != null) ...[
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: Column(
                    children: [
                      Container(
                        width: 60,
                        height: 60,
                        decoration: BoxDecoration(
                          color: AppColors.kDarkSurface,
                          shape: BoxShape.circle,
                        ),
                        child: const Icon(
                          Icons.shield_rounded,
                          color: AppColors.kYellowAccent,
                          size: 32,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        match.team1!,
                        textAlign: TextAlign.center,
                        style: const TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.bold,
                          color: AppColors.kWhite,
                        ),
                      ),
                    ],
                  ),
                ),
                const Text(
                  'VS',
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: AppColors.kGrey,
                  ),
                ),
                Expanded(
                  child: Column(
                    children: [
                      Container(
                        width: 60,
                        height: 60,
                        decoration: BoxDecoration(
                          color: AppColors.kDarkSurface,
                          shape: BoxShape.circle,
                        ),
                        child: const Icon(
                          Icons.shield_rounded,
                          color: AppColors.kWhite,
                          size: 32,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        match.team2!,
                        textAlign: TextAlign.center,
                        style: const TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.bold,
                          color: AppColors.kWhite,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 20),
            const Divider(color: AppColors.kDarkSurface, height: 1),
            const SizedBox(height: 20),
          ],
          Row(
            children: [
              const Icon(Icons.calendar_today_rounded, color: AppColors.kGrey, size: 20),
              const SizedBox(width: 12),
              Text(
                DateFormat('EEEE, dd MMMM yyyy', 'es').format(match.dateTime),
                style: const TextStyle(
                  fontSize: 15,
                  color: AppColors.kWhite,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              const Icon(Icons.access_time_rounded, color: AppColors.kGrey, size: 20),
              const SizedBox(width: 12),
              Text(
                DateFormat('HH:mm').format(match.dateTime),
                style: const TextStyle(
                  fontSize: 15,
                  color: AppColors.kWhite,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildWeatherCard(Match match, MatchDetailController controller) {
    if (match.venueLatitude == null || match.venueLongitude == null) {
      // No location data, show basic venue info
      return Container(
        margin: const EdgeInsets.symmetric(horizontal: 20),
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: AppColors.kDarkCard,
          borderRadius: BorderRadius.circular(16),
        ),
        child: Row(
          children: [
            const Icon(Icons.location_on_rounded, color: AppColors.kGrey, size: 24),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                match.venue,
                style: const TextStyle(
                  fontSize: 16,
                  color: AppColors.kWhite,
                ),
              ),
            ),
          ],
        ),
      );
    }

    return Obx(() {
      final weatherCondition = controller.weatherCondition.value;

      return Container(
        margin: const EdgeInsets.symmetric(horizontal: 20),
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
                const Icon(Icons.location_on_rounded, color: AppColors.kYellowAccent, size: 24),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    match.venue,
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: AppColors.kWhite,
                    ),
                  ),
                ),
                ElevatedButton.icon(
                  onPressed: () => MapLauncher.openMapWithDirections(
                    latitude: match.venueLatitude!,
                    longitude: match.venueLongitude!,
                    locationName: match.venue,
                  ),
                  icon: const Icon(Icons.directions_rounded, size: 16),
                  label: const Text('Cómo llegar'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.kYellowAccent,
                    foregroundColor: AppColors.kBlack,
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                ),
              ],
            ),
            if (weatherCondition != null) ...[
              const SizedBox(height: 16),
              const Divider(color: AppColors.kDarkSurface, height: 1),
              const SizedBox(height: 16),
              Row(
                children: [
                  _getWeatherIcon(weatherCondition.fieldCondition),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          weatherCondition.description,
                          style: const TextStyle(
                            fontSize: 15,
                            fontWeight: FontWeight.w600,
                            color: AppColors.kWhite,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          '${weatherCondition.rainfallMm.toStringAsFixed(1)} mm acumulado',
                          style: const TextStyle(
                            fontSize: 13,
                            color: AppColors.kGrey,
                          ),
                        ),
                        Text(
                          'Estación: ${weatherCondition.stationName} (${weatherCondition.distanceKm.toStringAsFixed(1)} km)',
                          style: const TextStyle(
                            fontSize: 12,
                            color: AppColors.kGreyLight,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ],
          ],
        ),
      );
    });
  }

  Widget _getWeatherIcon(FieldCondition condition) {
    IconData icon;
    Color color;

    switch (condition) {
      case FieldCondition.excellent:
        icon = Icons.wb_sunny_rounded;
        color = AppColors.kYellowAccent;
        break;
      case FieldCondition.good:
        icon = Icons.cloud_outlined;
        color = AppColors.kGreen;
        break;
      case FieldCondition.fair:
        icon = Icons.wb_cloudy_rounded;
        color = Colors.orange;
        break;
      case FieldCondition.poor:
        icon = Icons.water_drop_rounded;
        color = Colors.blue;
        break;
      case FieldCondition.unplayable:
        icon = Icons.thunderstorm_rounded;
        color = AppColors.kRed;
        break;
    }

    return Icon(icon, color: color, size: 32);
  }

  Widget _buildPlayersSection(Match match, MatchDetailController controller) {
    final acceptedPlayers = match.confirmations.entries
        .where((e) => e.value == true)
        .length;
    final pendingPlayers = match.confirmations.entries
        .where((e) => e.value == false)
        .length;

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 20),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppColors.kDarkCard,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Jugadores',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: AppColors.kWhite,
            ),
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(
                child: _buildPlayerStat(
                  'Confirmados',
                  acceptedPlayers.toString(),
                  AppColors.kGreen,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _buildPlayerStat(
                  'Pendientes',
                  pendingPlayers.toString(),
                  AppColors.kYellowAccent,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _buildPlayerStat(
                  'Total',
                  match.playerIds.length.toString(),
                  AppColors.kWhite,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildPlayerStat(String label, String value, Color color) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: AppColors.kDarkSurface,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        children: [
          Text(
            value,
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: color,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            label,
            style: const TextStyle(
              fontSize: 12,
              color: AppColors.kGrey,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildActionsSection(Match match, MatchDetailController controller) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 20),
      child: Column(
        children: [
          _buildActionButton(
            icon: Icons.share_rounded,
            label: 'Compartir invitación',
            onTap: () => controller.shareInvite(),
          ),
          const SizedBox(height: 12),
          _buildActionButton(
            icon: Icons.videocam_rounded,
            label: match.videoUrl != null ? 'Ver video' : 'Subir video',
            onTap: () => controller.handleVideo(),
          ),
          const SizedBox(height: 12),
          if (match.videoUrl != null)
            _buildActionButton(
              icon: Icons.analytics_rounded,
              label: 'Ver análisis',
              onTap: () => controller.viewAnalysis(),
            ),
        ],
      ),
    );
  }

  Widget _buildActionButton({
    required IconData icon,
    required String label,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(16),
      child: Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: AppColors.kDarkCard,
          borderRadius: BorderRadius.circular(16),
        ),
        child: Row(
          children: [
            Icon(icon, color: AppColors.kYellowAccent, size: 24),
            const SizedBox(width: 16),
            Expanded(
              child: Text(
                label,
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: AppColors.kWhite,
                ),
              ),
            ),
            const Icon(Icons.arrow_forward_ios_rounded, color: AppColors.kGrey, size: 16),
          ],
        ),
      ),
    );
  }

  Widget _buildVideoSection(Match match) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 20),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppColors.kDarkCard,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Video',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: AppColors.kWhite,
            ),
          ),
          const SizedBox(height: 12),
          Container(
            height: 200,
            decoration: BoxDecoration(
              color: AppColors.kDarkSurface,
              borderRadius: BorderRadius.circular(12),
            ),
            child: const Center(
              child: Icon(
                Icons.play_circle_outline_rounded,
                color: AppColors.kYellowAccent,
                size: 64,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
