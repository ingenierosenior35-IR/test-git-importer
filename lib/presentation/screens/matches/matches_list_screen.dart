import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../core/constants/colors.dart';
import '../../../core/constants/strings.dart';
import '../../controllers/matches_controller.dart';
import '../../../data/models/match.dart';
import 'package:intl/intl.dart';

class MatchesListScreen extends StatelessWidget {
  const MatchesListScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final controller = Get.put(MatchesController());

    return Scaffold(
      backgroundColor: AppColors.kDarkBackground,
      body: SafeArea(
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.all(20.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    AppStrings.matches,
                    style: const TextStyle(
                      fontSize: 28,
                      fontWeight: FontWeight.bold,
                      color: AppColors.kWhite,
                    ),
                  ),
                  const SizedBox(height: 16),
                  SizedBox(
                    height: 40,
                    child: Obx(() => ListView(
                      scrollDirection: Axis.horizontal,
                      children: [
                        _buildFilterChip('Todos', null, controller),
                        const SizedBox(width: 8),
                        _buildFilterChip('Pendientes', MatchStatus.pending, controller),
                        const SizedBox(width: 8),
                        _buildFilterChip('Completados', MatchStatus.completed, controller),
                        const SizedBox(width: 8),
                        _buildFilterChip('Procesando', MatchStatus.processing, controller),
                      ],
                    )),
                  ),
                ],
              ),
            ),
            Expanded(
              child: Obx(() {
                if (controller.isLoading.value) {
                  return const Center(
                    child: CircularProgressIndicator(
                      color: AppColors.kYellowAccent,
                    ),
                  );
                }

                if (controller.filteredMatches.isEmpty) {
                  return Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.sports_soccer_outlined,
                          size: 64,
                          color: AppColors.kGrey,
                        ),
                        const SizedBox(height: 16),
                        Text(
                          'No hay partidos',
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
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  itemCount: controller.filteredMatches.length,
                  separatorBuilder: (context, index) => const SizedBox(height: 12),
                  itemBuilder: (context, index) {
                    final match = controller.filteredMatches[index];
                    return _buildMatchCard(match, controller);
                  },
                );
              }),
            ),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: controller.navigateToCreateMatch,
        backgroundColor: AppColors.kYellowAccent,
        foregroundColor: AppColors.kBlack,
        icon: const Icon(Icons.add_rounded),
        label: Text(
          AppStrings.createMatch,
          style: const TextStyle(fontWeight: FontWeight.bold),
        ),
      ),
    );
  }

  Widget _buildFilterChip(String label, MatchStatus? status, MatchesController controller) {
    final isSelected = controller.selectedStatus.value == status;
    
    return GestureDetector(
      onTap: () => controller.setFilter(status),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        decoration: BoxDecoration(
          color: isSelected ? AppColors.kYellowAccent : AppColors.kDarkCard,
          borderRadius: BorderRadius.circular(20),
        ),
        child: Text(
          label,
          style: TextStyle(
            color: isSelected ? AppColors.kBlack : AppColors.kWhite,
            fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
          ),
        ),
      ),
    );
  }

  Widget _buildMatchCard(Match match, MatchesController controller) {
    return InkWell(
      onTap: () => controller.navigateToMatchDetail(match.id),
      borderRadius: BorderRadius.circular(16),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: AppColors.kDarkCard,
          borderRadius: BorderRadius.circular(16),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Expanded(
                  child: Text(
                    match.name,
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: AppColors.kWhite,
                    ),
                  ),
                ),
                _buildStatusBadge(match.status),
              ],
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                Icon(
                  Icons.location_on_rounded,
                  color: AppColors.kGrey,
                  size: 16,
                ),
                const SizedBox(width: 8),
                Text(
                  match.venue,
                  style: TextStyle(
                    fontSize: 14,
                    color: AppColors.kGrey,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Row(
              children: [
                Icon(
                  Icons.calendar_today_rounded,
                  color: AppColors.kGrey,
                  size: 16,
                ),
                const SizedBox(width: 8),
                Text(
                  DateFormat('dd MMM yyyy, HH:mm', 'es').format(match.dateTime),
                  style: TextStyle(
                    fontSize: 14,
                    color: AppColors.kGrey,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Row(
              children: [
                Icon(
                  Icons.people_rounded,
                  color: AppColors.kGrey,
                  size: 16,
                ),
                const SizedBox(width: 8),
                Text(
                  '${match.playerIds.length} jugadores',
                  style: TextStyle(
                    fontSize: 14,
                    color: AppColors.kGrey,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStatusBadge(MatchStatus status) {
    Color color;
    String text;

    switch (status) {
      case MatchStatus.pending:
        color = AppColors.kYellowAccent;
        text = 'Pendiente';
        break;
      case MatchStatus.completed:
        color = AppColors.kGreen;
        text = 'Completado';
        break;
      case MatchStatus.processing:
        color = Colors.orange;
        text = 'Procesando';
        break;
      case MatchStatus.cancelled:
        color = AppColors.kRed;
        text = 'Cancelado';
        break;
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: color.withOpacity(0.2),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Text(
        text,
        style: TextStyle(
          fontSize: 12,
          fontWeight: FontWeight.bold,
          color: color,
        ),
      ),
    );
  }
}
