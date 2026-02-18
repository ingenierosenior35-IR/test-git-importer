import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import '../../../../core/constants/colors.dart';
import '../../data/models/team_model.dart';
import '../../data/models/player_model.dart';
import '../../data/datasources/teams_mock_data.dart';

class TeamDetailScreen extends StatefulWidget {
  const TeamDetailScreen({Key? key}) : super(key: key);

  @override
  State<TeamDetailScreen> createState() => _TeamDetailScreenState();
}

class _TeamDetailScreenState extends State<TeamDetailScreen> {
  Team? team;
  List<Player> players = [];

  @override
  void initState() {
    super.initState();
    team = Get.arguments as Team?;
    if (team != null) {
      _loadPlayers();
    }
  }

  void _loadPlayers() {
    setState(() {
      players = TeamsMockData.getPlayersByTeamId(team!.id);
    });
  }

  void _editTeam() {
    Get.toNamed('/create_team_screen', arguments: team)?.then((_) {
      final updatedTeam = TeamsMockData.getTeamById(team!.id);
      if (updatedTeam != null) {
        setState(() {
          team = updatedTeam;
        });
      }
    });
  }

  void _copyToClipboard(String text, String label) {
    Clipboard.setData(ClipboardData(text: text));
    Get.snackbar(
      'Copiado',
      '$label copiado al portapapeles',
      backgroundColor: AppColors.kGreen.withOpacity(0.8),
      colorText: AppColors.kWhite,
      snackPosition: SnackPosition.BOTTOM,
      duration: const Duration(seconds: 2),
    );
  }

  void _removePlayer(Player player) {
    Get.defaultDialog(
      backgroundColor: AppColors.kDarkCard,
      title: 'Eliminar Jugador',
      titleStyle: const TextStyle(color: AppColors.kWhite),
      middleText: '¿Deseas eliminar a ${player.name} del equipo?',
      middleTextStyle: const TextStyle(color: AppColors.kGreyLight),
      textConfirm: 'Eliminar',
      textCancel: 'Cancelar',
      confirmTextColor: AppColors.kBlack,
      cancelTextColor: AppColors.kWhite,
      buttonColor: AppColors.kRed,
      onConfirm: () {
        final updatedPlayerIds = List<String>.from(team!.playerIds)
          ..remove(player.id);
        final updatedTeam = team!.copyWith(playerIds: updatedPlayerIds);
        TeamsMockData.updateTeam(updatedTeam);
        
        setState(() {
          team = updatedTeam;
          players.remove(player);
        });
        
        Get.back();
        Get.snackbar(
          'Éxito',
          'Jugador eliminado del equipo',
          backgroundColor: AppColors.kGreen.withOpacity(0.8),
          colorText: AppColors.kWhite,
          snackPosition: SnackPosition.BOTTOM,
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    if (team == null) {
      return Scaffold(
        backgroundColor: AppColors.kDarkBackground,
        appBar: AppBar(
          backgroundColor: AppColors.kDarkCard,
          leading: IconButton(
            icon: const Icon(Icons.arrow_back_ios_rounded, color: AppColors.kWhite),
            onPressed: () => Get.back(),
          ),
        ),
        body: const Center(
          child: Text(
            'Equipo no encontrado',
            style: TextStyle(color: AppColors.kWhite),
          ),
        ),
      );
    }

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
          'Detalles del Equipo',
          style: TextStyle(
            color: AppColors.kWhite,
            fontSize: 20,
            fontWeight: FontWeight.bold,
          ),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.edit, color: AppColors.kYellowAccent),
            onPressed: _editTeam,
          ),
        ],
      ),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildTeamHeader(),
            const SizedBox(height: 16),
            _buildInviteSection(),
            const SizedBox(height: 24),
            _buildPlayersSection(),
          ],
        ),
      ),
    );
  }

  Widget _buildTeamHeader() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: AppColors.kDarkCard,
        borderRadius: const BorderRadius.only(
          bottomLeft: Radius.circular(24),
          bottomRight: Radius.circular(24),
        ),
      ),
      child: Column(
        children: [
          Container(
            width: 100,
            height: 100,
            decoration: BoxDecoration(
              color: AppColors.kYellowAccent.withOpacity(0.2),
              borderRadius: BorderRadius.circular(20),
            ),
            child: team!.logoUrl != null
                ? ClipRRect(
                    borderRadius: BorderRadius.circular(20),
                    child: Image.network(
                      team!.logoUrl!,
                      fit: BoxFit.cover,
                      errorBuilder: (context, error, stackTrace) {
                        return const Icon(Icons.shield, color: AppColors.kYellowAccent, size: 50);
                      },
                    ),
                  )
                : const Icon(Icons.shield, color: AppColors.kYellowAccent, size: 50),
          ),
          const SizedBox(height: 16),
          Text(
            team!.name,
            style: const TextStyle(
              color: AppColors.kWhite,
              fontSize: 24,
              fontWeight: FontWeight.bold,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 8),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            decoration: BoxDecoration(
              color: AppColors.kYellowAccent.withOpacity(0.2),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Text(
              team!.sport,
              style: const TextStyle(
                color: AppColors.kYellowAccent,
                fontSize: 14,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
          if (team!.description != null) ...[
            const SizedBox(height: 16),
            Text(
              team!.description!,
              style: const TextStyle(
                color: AppColors.kGreyLight,
                fontSize: 14,
              ),
              textAlign: TextAlign.center,
            ),
          ],
          const SizedBox(height: 16),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              _buildStatItem(Icons.people, '${players.length}', 'Jugadores'),
              _buildStatItem(Icons.calendar_today, _formatDate(team!.createdAt), 'Creado'),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildStatItem(IconData icon, String value, String label) {
    return Column(
      children: [
        Icon(icon, color: AppColors.kYellowAccent, size: 24),
        const SizedBox(height: 4),
        Text(
          value,
          style: const TextStyle(
            color: AppColors.kWhite,
            fontSize: 16,
            fontWeight: FontWeight.bold,
          ),
        ),
        Text(
          label,
          style: TextStyle(
            color: AppColors.kGrey,
            fontSize: 12,
          ),
        ),
      ],
    );
  }

  Widget _buildInviteSection() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Invitar Jugadores',
            style: TextStyle(
              color: AppColors.kWhite,
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 12),
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: AppColors.kDarkCard,
              borderRadius: BorderRadius.circular(16),
            ),
            child: Column(
              children: [
                Row(
                  children: [
                    const Icon(Icons.key, color: AppColors.kYellowAccent, size: 20),
                    const SizedBox(width: 12),
                    const Text(
                      'Código de Invitación',
                      style: TextStyle(
                        color: AppColors.kGrey,
                        fontSize: 14,
                      ),
                    ),
                    const Spacer(),
                    Text(
                      team!.inviteCode ?? 'N/A',
                      style: const TextStyle(
                        color: AppColors.kWhite,
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        letterSpacing: 2,
                      ),
                    ),
                    const SizedBox(width: 8),
                    IconButton(
                      icon: const Icon(Icons.copy, color: AppColors.kYellowAccent, size: 20),
                      onPressed: () => _copyToClipboard(team!.inviteCode ?? '', 'Código'),
                    ),
                  ],
                ),
                const Divider(color: AppColors.kGrey, height: 24),
                Row(
                  children: [
                    const Icon(Icons.link, color: AppColors.kYellowAccent, size: 20),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            'Link de Invitación',
                            style: TextStyle(
                              color: AppColors.kGrey,
                              fontSize: 14,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            team!.inviteUrl,
                            style: TextStyle(
                              color: AppColors.kGreyLight,
                              fontSize: 12,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ],
                      ),
                    ),
                    IconButton(
                      icon: const Icon(Icons.copy, color: AppColors.kYellowAccent, size: 20),
                      onPressed: () => _copyToClipboard(team!.inviteUrl, 'Link'),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPlayersSection() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'Jugadores',
                style: TextStyle(
                  color: AppColors.kWhite,
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
              TextButton.icon(
                onPressed: () {
                  Get.snackbar(
                    'Próximamente',
                    'Función de agregar jugadores en desarrollo',
                    backgroundColor: AppColors.kOrange.withOpacity(0.8),
                    colorText: AppColors.kWhite,
                  );
                },
                icon: const Icon(Icons.person_add, color: AppColors.kYellowAccent, size: 20),
                label: const Text(
                  'Agregar',
                  style: TextStyle(color: AppColors.kYellowAccent),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          if (players.isEmpty)
            _buildEmptyPlayers()
          else
            ListView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: players.length,
              itemBuilder: (context, index) {
                return _buildPlayerCard(players[index]);
              },
            ),
          const SizedBox(height: 24),
        ],
      ),
    );
  }

  Widget _buildEmptyPlayers() {
    return Container(
      padding: const EdgeInsets.all(32),
      decoration: BoxDecoration(
        color: AppColors.kDarkCard,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        children: [
          Icon(
            Icons.people_outline,
            size: 60,
            color: AppColors.kGrey.withOpacity(0.5),
          ),
          const SizedBox(height: 16),
          Text(
            'No hay jugadores',
            style: TextStyle(
              color: AppColors.kGrey,
              fontSize: 16,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Invita jugadores usando el código o link',
            style: TextStyle(
              color: AppColors.kGrey.withOpacity(0.7),
              fontSize: 12,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildPlayerCard(Player player) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: AppColors.kDarkCard,
        borderRadius: BorderRadius.circular(16),
      ),
      child: ListTile(
        contentPadding: const EdgeInsets.all(12),
        onTap: () => Get.toNamed('/player_detail_screen', arguments: player),
        leading: CircleAvatar(
          radius: 28,
          backgroundColor: AppColors.kYellowAccent.withOpacity(0.2),
          child: player.photoUrl != null
              ? ClipOval(
                  child: Image.network(
                    player.photoUrl!,
                    fit: BoxFit.cover,
                    errorBuilder: (context, error, stackTrace) {
                      return Text(
                        player.name[0].toUpperCase(),
                        style: const TextStyle(
                          color: AppColors.kYellowAccent,
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                        ),
                      );
                    },
                  ),
                )
              : Text(
                  player.name[0].toUpperCase(),
                  style: const TextStyle(
                    color: AppColors.kYellowAccent,
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                ),
        ),
        title: Row(
          children: [
            Expanded(
              child: Text(
                player.name,
                style: const TextStyle(
                  color: AppColors.kWhite,
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
            if (player.jerseyNumber != null)
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: AppColors.kYellowAccent.withOpacity(0.2),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  '#${player.jerseyNumber}',
                  style: const TextStyle(
                    color: AppColors.kYellowAccent,
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
          ],
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 4),
            Text(
              player.position ?? 'Sin posición',
              style: TextStyle(
                color: AppColors.kGrey,
                fontSize: 14,
              ),
            ),
            if (player.stats != null) ...[
              const SizedBox(height: 8),
              Row(
                children: [
                  _buildPlayerStat('⚽', player.stats!.goals.toString()),
                  const SizedBox(width: 12),
                  _buildPlayerStat('🎯', player.stats!.assists.toString()),
                  const SizedBox(width: 12),
                  _buildPlayerStat('⭐', player.stats!.rating.toStringAsFixed(1)),
                ],
              ),
            ],
          ],
        ),
        trailing: IconButton(
          icon: const Icon(Icons.remove_circle_outline, color: AppColors.kRed),
          onPressed: () => _removePlayer(player),
        ),
      ),
    );
  }

  Widget _buildPlayerStat(String icon, String value) {
    return Row(
      children: [
        Text(icon, style: const TextStyle(fontSize: 14)),
        const SizedBox(width: 4),
        Text(
          value,
          style: const TextStyle(
            color: AppColors.kWhite,
            fontSize: 12,
            fontWeight: FontWeight.w600,
          ),
        ),
      ],
    );
  }

  String _formatDate(DateTime date) {
    final now = DateTime.now();
    final difference = now.difference(date);
    
    if (difference.inDays < 30) {
      return '${difference.inDays}d';
    } else if (difference.inDays < 365) {
      return '${(difference.inDays / 30).floor()}m';
    } else {
      return '${(difference.inDays / 365).floor()}a';
    }
  }
}
