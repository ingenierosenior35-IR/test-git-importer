import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../../core/constants/colors.dart';
import '../../data/models/player_model.dart';

class PlayerDetailScreen extends StatelessWidget {
  const PlayerDetailScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final Player player = Get.arguments as Player;
    // Teams are now in Firestore; player.teamIds stores IDs but we can't sync-lookup
    final List teams = [];  // Will be empty until Firestore async fetch is added

    return Scaffold(
      backgroundColor: AppColors.kDarkBackground,
      appBar: AppBar(
        backgroundColor: AppColors.kDarkCard,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_rounded, color: AppColors.kWhite),
          onPressed: () => Get.back(),
        ),
        title: const Text(
          'Perfil del Jugador',
          style: TextStyle(
            color: AppColors.kWhite,
            fontSize: 20,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Player Header
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    AppColors.kDarkCard,
                    AppColors.kDarkBackground,
                  ],
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                ),
              ),
              child: Column(
                children: [
                  Container(
                    width: 100,
                    height: 100,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      border: Border.all(color: AppColors.kYellowAccent, width: 3),
                    ),
                    child: player.photoUrl != null
                        ? ClipOval(
                            child: Image.network(
                              player.photoUrl!,
                              fit: BoxFit.cover,
                              errorBuilder: (context, error, stackTrace) {
                                return const Icon(Icons.person, size: 50, color: AppColors.kGrey);
                              },
                            ),
                          )
                        : const Icon(Icons.person, size: 50, color: AppColors.kGrey),
                  ),
                  const SizedBox(height: 16),
                  Text(
                    player.name,
                    style: const TextStyle(
                      color: AppColors.kWhite,
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 8),
                  if (player.position != null)
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                      decoration: BoxDecoration(
                        color: AppColors.kYellowAccent.withOpacity(0.2),
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Text(
                        player.position!,
                        style: const TextStyle(
                          color: AppColors.kYellowAccent,
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  if (player.jerseyNumber != null) ...[
                    const SizedBox(height: 12),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.numbers, size: 16, color: AppColors.kGrey),
                        const SizedBox(width: 8),
                        Text(
                          'Número ${player.jerseyNumber}',
                          style: TextStyle(
                            color: AppColors.kGrey,
                            fontSize: 14,
                          ),
                        ),
                      ],
                    ),
                  ],
                ],
              ),
            ),
            
            // Sports
            if (player.sports.isNotEmpty) ...[
              const SizedBox(height: 24),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Deportes',
                      style: TextStyle(
                        color: AppColors.kWhite,
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 12),
                    Wrap(
                      spacing: 8,
                      runSpacing: 8,
                      children: player.sports.map((sport) {
                        return Container(
                          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                          decoration: BoxDecoration(
                            color: AppColors.kDarkCard,
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Text(
                            sport,
                            style: const TextStyle(
                              color: AppColors.kWhite,
                              fontSize: 14,
                            ),
                          ),
                        );
                      }).toList(),
                    ),
                  ],
                ),
              ),
            ],

            // Statistics
            if (player.stats != null) ...[
              const SizedBox(height: 24),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Estadísticas',
                      style: TextStyle(
                        color: AppColors.kWhite,
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 16),
                    Container(
                      padding: const EdgeInsets.all(20),
                      decoration: BoxDecoration(
                        color: AppColors.kDarkCard,
                        borderRadius: BorderRadius.circular(16),
                      ),
                      child: Column(
                        children: [
                          _buildStatRow('Partidos Jugados', player.stats!.matchesPlayed.toString(), Icons.sports_soccer),
                          const Divider(color: AppColors.kDarkSurface, height: 24),
                          _buildStatRow('Goles', player.stats!.goals.toString(), Icons.sports_score),
                          const Divider(color: AppColors.kDarkSurface, height: 24),
                          _buildStatRow('Asistencias', player.stats!.assists.toString(), Icons.assist_walker),
                          const Divider(color: AppColors.kDarkSurface, height: 24),
                          _buildStatRow('Tarjetas Amarillas', player.stats!.yellowCards.toString(), Icons.square, color: Colors.yellow),
                          const Divider(color: AppColors.kDarkSurface, height: 24),
                          _buildStatRow('Tarjetas Rojas', player.stats!.redCards.toString(), Icons.square, color: Colors.red),
                          const Divider(color: AppColors.kDarkSurface, height: 24),
                          _buildStatRow('Calificación', player.stats!.rating.toStringAsFixed(1), Icons.star, color: AppColors.kYellowAccent),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ],

            // Teams
            if (teams.isNotEmpty) ...[
              const SizedBox(height: 24),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Equipos',
                      style: TextStyle(
                        color: AppColors.kWhite,
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 12),
                    ...teams.map((team) {
                      return Container(
                        margin: const EdgeInsets.only(bottom: 12),
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: AppColors.kDarkCard,
                          borderRadius: BorderRadius.circular(16),
                        ),
                        child: Row(
                          children: [
                            Icon(Icons.shield, color: AppColors.kYellowAccent, size: 32),
                            const SizedBox(width: 16),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    team!.name,
                                    style: const TextStyle(
                                      color: AppColors.kWhite,
                                      fontSize: 16,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                  const SizedBox(height: 4),
                                  Text(
                                    team.sport,
                                    style: TextStyle(
                                      color: AppColors.kGrey,
                                      fontSize: 14,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      );
                    }).toList(),
                  ],
                ),
              ),
            ],
            
            const SizedBox(height: 32),
          ],
        ),
      ),
    );
  }

  Widget _buildStatRow(String label, String value, IconData icon, {Color? color}) {
    return Row(
      children: [
        Icon(icon, color: color ?? AppColors.kYellowAccent, size: 20),
        const SizedBox(width: 12),
        Expanded(
          child: Text(
            label,
            style: const TextStyle(
              color: AppColors.kWhite,
              fontSize: 15,
            ),
          ),
        ),
        Text(
          value,
          style: TextStyle(
            color: color ?? AppColors.kYellowAccent,
            fontSize: 18,
            fontWeight: FontWeight.bold,
          ),
        ),
      ],
    );
  }
}
