import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../../core/constants/colors.dart';
import '../../data/models/team_model.dart';
import '../../data/datasources/teams_mock_data.dart';

class TeamsListScreen extends StatefulWidget {
  const TeamsListScreen({Key? key}) : super(key: key);

  @override
  State<TeamsListScreen> createState() => _TeamsListScreenState();
}

class _TeamsListScreenState extends State<TeamsListScreen> {
  List<Team> teams = [];

  @override
  void initState() {
    super.initState();
    _loadTeams();
  }

  void _loadTeams() {
    setState(() {
      teams = TeamsMockData.getAllTeams();
    });
  }

  void _createTeam() {
    Get.toNamed('/create_team_screen')?.then((_) => _loadTeams());
  }

  void _viewTeamDetail(Team team) {
    Get.toNamed('/team_detail_screen', arguments: team)?.then((_) => _loadTeams());
  }

  @override
  Widget build(BuildContext context) {
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
          'Equipos',
          style: TextStyle(
            color: AppColors.kWhite,
            fontSize: 20,
            fontWeight: FontWeight.bold,
          ),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.add_circle_outline, color: AppColors.kYellowAccent),
            onPressed: _createTeam,
          ),
        ],
      ),
      body: teams.isEmpty
          ? _buildEmptyState()
          : ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: teams.length,
              itemBuilder: (context, index) {
                return _buildTeamCard(teams[index]);
              },
            ),
      floatingActionButton: FloatingActionButton(
        onPressed: _createTeam,
        backgroundColor: AppColors.kYellowAccent,
        child: const Icon(Icons.add, color: AppColors.kBlack),
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.group_off,
            size: 80,
            color: AppColors.kGrey.withOpacity(0.5),
          ),
          const SizedBox(height: 16),
          Text(
            'No tienes equipos',
            style: TextStyle(
              color: AppColors.kGrey,
              fontSize: 18,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Crea tu primer equipo',
            style: TextStyle(
              color: AppColors.kGrey.withOpacity(0.7),
              fontSize: 14,
            ),
          ),
          const SizedBox(height: 24),
          ElevatedButton.icon(
            onPressed: _createTeam,
            icon: const Icon(Icons.add),
            label: const Text('Crear Equipo'),
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.kYellowAccent,
              foregroundColor: AppColors.kBlack,
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTeamCard(Team team) {
    final players = TeamsMockData.getPlayersByTeamId(team.id);
    
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        color: AppColors.kDarkCard,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: AppColors.kBlack.withOpacity(0.2),
            blurRadius: 8,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: () => _viewTeamDetail(team),
          borderRadius: BorderRadius.circular(16),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    // Team Logo/Icon
                    Container(
                      width: 60,
                      height: 60,
                      decoration: BoxDecoration(
                        color: AppColors.kYellowAccent.withOpacity(0.2),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: team.logoUrl != null
                          ? ClipRRect(
                              borderRadius: BorderRadius.circular(12),
                              child: Image.network(
                                team.logoUrl!,
                                fit: BoxFit.cover,
                                errorBuilder: (context, error, stackTrace) {
                                  return const Icon(Icons.shield, color: AppColors.kYellowAccent, size: 32);
                                },
                              ),
                            )
                          : const Icon(Icons.shield, color: AppColors.kYellowAccent, size: 32),
                    ),
                    const SizedBox(width: 16),
                    // Team Info
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            team.name,
                            style: const TextStyle(
                              color: AppColors.kWhite,
                              fontSize: 18,
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
                    const Icon(
                      Icons.arrow_forward_ios_rounded,
                      color: AppColors.kGrey,
                      size: 16,
                    ),
                  ],
                ),
                if (team.description != null) ...[
                  const SizedBox(height: 12),
                  Text(
                    team.description!,
                    style: TextStyle(
                      color: AppColors.kGreyLight,
                      fontSize: 14,
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
                const SizedBox(height: 12),
                Row(
                  children: [
                    Icon(Icons.people, size: 16, color: AppColors.kGrey),
                    const SizedBox(width: 4),
                    Text(
                      '${players.length} jugadores',
                      style: TextStyle(
                        color: AppColors.kGrey,
                        fontSize: 12,
                      ),
                    ),
                    const SizedBox(width: 16),
                    Icon(Icons.calendar_today, size: 16, color: AppColors.kGrey),
                    const SizedBox(width: 4),
                    Text(
                      'Creado ${_formatDate(team.createdAt)}',
                      style: TextStyle(
                        color: AppColors.kGrey,
                        fontSize: 12,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  String _formatDate(DateTime date) {
    final now = DateTime.now();
    final difference = now.difference(date);
    
    if (difference.inDays < 7) {
      return 'hace ${difference.inDays} días';
    } else if (difference.inDays < 30) {
      return 'hace ${(difference.inDays / 7).floor()} semanas';
    } else if (difference.inDays < 365) {
      return 'hace ${(difference.inDays / 30).floor()} meses';
    } else {
      return 'hace ${(difference.inDays / 365).floor()} años';
    }
  }
}
