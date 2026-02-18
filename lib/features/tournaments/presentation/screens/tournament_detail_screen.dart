import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import '../../../../core/constants/colors.dart';
import '../../data/models/tournament_model.dart';
import '../../data/datasources/tournaments_mock_data.dart';
import '../../../matches/data/models/match_model.dart';
import '../../../matches/data/datasources/matches_mock_data.dart';
import '../../../teams/data/datasources/teams_mock_data.dart';
import '../../../teams/data/models/team_model.dart';

class TournamentDetailScreen extends StatefulWidget {
  const TournamentDetailScreen({Key? key}) : super(key: key);

  @override
  State<TournamentDetailScreen> createState() => _TournamentDetailScreenState();
}

class _TournamentDetailScreenState extends State<TournamentDetailScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  late Tournament tournament;
  List<Match> tournamentMatches = [];
  List<StandingsRow> standings = [];
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
    tournament = Get.arguments as Tournament;
    _loadData();
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  void _loadData() {
    setState(() {
      tournamentMatches = _getTournamentMatches();
      standings = TournamentsMockData.getStandingsByTournamentId(tournament.id);
    });
  }

  List<Match> _getTournamentMatches() {
    final allMatches = MatchesMockData.getAllMatches();
    final tournamentTeams = TournamentsMockData.getTeamsByTournamentId(tournament.id);
    final teamIds = tournamentTeams.map((tt) => tt.teamId).toSet();
    
    return allMatches.where((match) {
      if (match.homeTeamId != null && match.awayTeamId != null) {
        return teamIds.contains(match.homeTeamId) || teamIds.contains(match.awayTeamId);
      }
      return false;
    }).toList()..sort((a, b) => a.dateTime.compareTo(b.dateTime));
  }

  void _editTournament() {
    Get.toNamed('/tournament_form_screen', arguments: tournament)?.then((_) {
      final updated = TournamentsMockData.getTournamentById(tournament.id);
      if (updated != null) {
        setState(() {
          tournament = updated;
        });
      }
    });
  }

  void _deleteTournament() {
    Get.dialog(
      AlertDialog(
        backgroundColor: AppColors.kDarkCard,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Text(
          'Eliminar Torneo',
          style: TextStyle(color: AppColors.kWhite, fontWeight: FontWeight.bold),
        ),
        content: Text(
          '¿Estás seguro de que deseas eliminar "${tournament.name}"?',
          style: const TextStyle(color: AppColors.kGrey),
        ),
        actions: [
          TextButton(
            onPressed: () => Get.back(),
            child: const Text(
              'Cancelar',
              style: TextStyle(color: AppColors.kGrey),
            ),
          ),
          TextButton(
            onPressed: () {
              TournamentsMockData.deleteTournament(tournament.id);
              Get.back();
              Get.back();
              Get.snackbar(
                'Éxito',
                'Torneo eliminado',
                backgroundColor: AppColors.kGreen.withOpacity(0.8),
                colorText: AppColors.kWhite,
              );
            },
            child: const Text(
              'Eliminar',
              style: TextStyle(color: AppColors.kRed, fontWeight: FontWeight.bold),
            ),
          ),
        ],
      ),
    );
  }

  void _joinTournament() {
    final codeController = TextEditingController();
    
    Get.dialog(
      AlertDialog(
        backgroundColor: AppColors.kDarkCard,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Text(
          'Unirse al Torneo',
          style: TextStyle(color: AppColors.kWhite, fontWeight: FontWeight.bold),
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Ingresa el código de tu equipo para unirte a "${tournament.name}"',
              style: const TextStyle(color: AppColors.kGrey, fontSize: 14),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: codeController,
              style: const TextStyle(color: AppColors.kWhite),
              decoration: InputDecoration(
                labelText: 'Código del equipo',
                labelStyle: const TextStyle(color: AppColors.kGrey),
                filled: true,
                fillColor: AppColors.kDarkBackground,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide.none,
                ),
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Get.back(),
            child: const Text(
              'Cancelar',
              style: TextStyle(color: AppColors.kGrey),
            ),
          ),
          TextButton(
            onPressed: () {
              Get.back();
              Get.snackbar(
                'Éxito',
                'Te has unido al torneo',
                backgroundColor: AppColors.kGreen.withOpacity(0.8),
                colorText: AppColors.kWhite,
              );
            },
            child: const Text(
              'Unirse',
              style: TextStyle(color: AppColors.kYellowAccent, fontWeight: FontWeight.bold),
            ),
          ),
        ],
      ),
    );
  }

  void _shareCode() {
    if (tournament.joinCode != null) {
      Clipboard.setData(ClipboardData(text: tournament.joinCode!));
      Get.snackbar(
        'Código copiado',
        'El código "${tournament.joinCode}" ha sido copiado al portapapeles',
        backgroundColor: AppColors.kYellowAccent.withOpacity(0.2),
        colorText: AppColors.kWhite,
        icon: const Icon(Icons.check_circle, color: AppColors.kYellowAccent),
      );
    }
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
        title: Text(
          tournament.name,
          style: const TextStyle(
            color: AppColors.kWhite,
            fontSize: 18,
            fontWeight: FontWeight.bold,
          ),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.edit_outlined, color: AppColors.kYellowAccent),
            onPressed: _editTournament,
          ),
          IconButton(
            icon: const Icon(Icons.delete_outline, color: AppColors.kRed),
            onPressed: _deleteTournament,
          ),
        ],
        bottom: TabBar(
          controller: _tabController,
          indicatorColor: AppColors.kYellowAccent,
          labelColor: AppColors.kYellowAccent,
          unselectedLabelColor: AppColors.kGrey,
          labelStyle: const TextStyle(fontWeight: FontWeight.bold, fontSize: 12),
          tabs: const [
            Tab(text: 'INFO'),
            Tab(text: 'PARTIDOS'),
            Tab(text: 'TABLA'),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          _buildInfoTab(),
          _buildMatchesTab(),
          _buildStandingsTab(),
        ],
      ),
    );
  }

  Widget _buildInfoTab() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildHeaderCard(),
          const SizedBox(height: 16),
          _buildInfoCard('Fechas', [
            _buildInfoRow(
              Icons.calendar_today,
              'Inicio',
              DateFormat('dd/MM/yyyy').format(tournament.startDate),
            ),
            if (tournament.endDate != null) ...[
              const SizedBox(height: 8),
              _buildInfoRow(
                Icons.event,
                'Fin',
                DateFormat('dd/MM/yyyy').format(tournament.endDate!),
              ),
            ],
          ]),
          const SizedBox(height: 16),
          _buildInfoCard('Ubicación', [
            _buildInfoRow(
              Icons.location_on,
              'Lugar',
              tournament.location ?? 'Sin ubicación',
            ),
          ]),
          const SizedBox(height: 16),
          _buildInfoCard('Detalles', [
            _buildInfoRow(
              Icons.sports_soccer,
              'Deporte',
              tournament.sport,
            ),
            const SizedBox(height: 8),
            _buildInfoRow(
              Icons.people,
              'Equipos',
              '${tournament.currentTeams}/${tournament.maxTeams}',
            ),
          ]),
          const SizedBox(height: 16),
          _buildInfoCard('Reglas de Puntuación', [
            _buildInfoRow(
              Icons.emoji_events,
              'Victoria',
              '${tournament.pointsForWin} puntos',
            ),
            const SizedBox(height: 8),
            _buildInfoRow(
              Icons.remove_circle_outline,
              'Empate',
              '${tournament.pointsForDraw} puntos',
            ),
            const SizedBox(height: 8),
            _buildInfoRow(
              Icons.close,
              'Derrota',
              '${tournament.pointsForLoss} puntos',
            ),
          ]),
          const SizedBox(height: 24),
          if (tournament.canJoin) ...[
            SizedBox(
              width: double.infinity,
              height: 56,
              child: ElevatedButton.icon(
                onPressed: _joinTournament,
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.kYellowAccent,
                  foregroundColor: AppColors.kBlack,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  elevation: 0,
                ),
                icon: const Icon(Icons.login),
                label: const Text(
                  'Unirse al Torneo',
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                ),
              ),
            ),
            const SizedBox(height: 12),
          ],
          if (tournament.joinCode != null)
            SizedBox(
              width: double.infinity,
              height: 56,
              child: OutlinedButton.icon(
                onPressed: _shareCode,
                style: OutlinedButton.styleFrom(
                  foregroundColor: AppColors.kYellowAccent,
                  side: const BorderSide(color: AppColors.kYellowAccent),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                icon: const Icon(Icons.share),
                label: Text(
                  'Compartir Código: ${tournament.joinCode}',
                  style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                ),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildHeaderCard() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppColors.kDarkCard,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: _getStatusColor(tournament.status).withOpacity(0.3),
          width: 1,
        ),
      ),
      child: Column(
        children: [
          Container(
            width: 80,
            height: 80,
            decoration: BoxDecoration(
              color: AppColors.kYellowAccent.withOpacity(0.2),
              borderRadius: BorderRadius.circular(16),
            ),
            child: tournament.logoUrl != null
                ? ClipRRect(
                    borderRadius: BorderRadius.circular(16),
                    child: Image.network(
                      tournament.logoUrl!,
                      fit: BoxFit.cover,
                      errorBuilder: (context, error, stackTrace) {
                        return const Icon(
                          Icons.emoji_events,
                          color: AppColors.kYellowAccent,
                          size: 40,
                        );
                      },
                    ),
                  )
                : const Icon(
                    Icons.emoji_events,
                    color: AppColors.kYellowAccent,
                    size: 40,
                  ),
          ),
          const SizedBox(height: 16),
          Text(
            tournament.name,
            style: const TextStyle(
              color: AppColors.kWhite,
              fontSize: 20,
              fontWeight: FontWeight.bold,
            ),
            textAlign: TextAlign.center,
          ),
          if (tournament.description != null) ...[
            const SizedBox(height: 8),
            Text(
              tournament.description!,
              style: const TextStyle(
                color: AppColors.kGrey,
                fontSize: 14,
              ),
              textAlign: TextAlign.center,
            ),
          ],
          const SizedBox(height: 16),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                decoration: BoxDecoration(
                  color: _getStatusColor(tournament.status).withOpacity(0.2),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  _getStatusText(tournament.status),
                  style: TextStyle(
                    color: _getStatusColor(tournament.status),
                    fontSize: 11,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              const SizedBox(width: 8),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                decoration: BoxDecoration(
                  color: AppColors.kGrey.withOpacity(0.2),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  _getFormatText(tournament.format),
                  style: const TextStyle(
                    color: AppColors.kGrey,
                    fontSize: 11,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildInfoCard(String title, List<Widget> children) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.kDarkCard,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: const TextStyle(
              color: AppColors.kWhite,
              fontSize: 16,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 12),
          ...children,
        ],
      ),
    );
  }

  Widget _buildInfoRow(IconData icon, String label, String value) {
    return Row(
      children: [
        Icon(icon, size: 20, color: AppColors.kYellowAccent),
        const SizedBox(width: 12),
        Text(
          label,
          style: const TextStyle(
            color: AppColors.kGrey,
            fontSize: 14,
          ),
        ),
        const Spacer(),
        Text(
          value,
          style: const TextStyle(
            color: AppColors.kWhite,
            fontSize: 14,
            fontWeight: FontWeight.w600,
          ),
        ),
      ],
    );
  }

  Widget _buildMatchesTab() {
    if (tournamentMatches.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.sports_soccer,
              size: 80,
              color: AppColors.kGrey.withOpacity(0.3),
            ),
            const SizedBox(height: 16),
            const Text(
              'No hay partidos',
              style: TextStyle(
                color: AppColors.kGrey,
                fontSize: 16,
              ),
            ),
          ],
        ),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.all(20),
      itemCount: tournamentMatches.length,
      itemBuilder: (context, index) {
        return _buildMatchCard(tournamentMatches[index]);
      },
    );
  }

  Widget _buildMatchCard(Match match) {
    final homeTeam = match.homeTeamId != null
        ? TeamsMockData.getTeamById(match.homeTeamId!)
        : null;
    final awayTeam = match.awayTeamId != null
        ? TeamsMockData.getTeamById(match.awayTeamId!)
        : null;

    return GestureDetector(
      onTap: () {
        Get.toNamed('/match_detail_screen', arguments: match);
      },
      child: Container(
        margin: const EdgeInsets.only(bottom: 16),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: AppColors.kDarkCard,
          borderRadius: BorderRadius.circular(16),
        ),
        child: Column(
          children: [
            Row(
              children: [
                Icon(
                  Icons.calendar_today,
                  size: 14,
                  color: AppColors.kGrey,
                ),
                const SizedBox(width: 4),
                Text(
                  DateFormat('dd/MM/yyyy - HH:mm').format(match.dateTime),
                  style: const TextStyle(
                    color: AppColors.kGrey,
                    fontSize: 12,
                  ),
                ),
                const Spacer(),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: _getMatchStatusColor(match.status).withOpacity(0.2),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(
                    _getMatchStatusText(match.status),
                    style: TextStyle(
                      color: _getMatchStatusColor(match.status),
                      fontSize: 10,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                Expanded(
                  child: Column(
                    children: [
                      _buildTeamAvatar(homeTeam),
                      const SizedBox(height: 8),
                      Text(
                        homeTeam?.name ?? 'Equipo Local',
                        style: const TextStyle(
                          color: AppColors.kWhite,
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                        ),
                        textAlign: TextAlign.center,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  child: match.status == MatchStatus.completed && match.hasScore
                      ? Column(
                          children: [
                            Row(
                              children: [
                                Text(
                                  '${match.homeScore}',
                                  style: const TextStyle(
                                    color: AppColors.kYellowAccent,
                                    fontSize: 28,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                const SizedBox(width: 12),
                                const Text(
                                  '-',
                                  style: TextStyle(
                                    color: AppColors.kGrey,
                                    fontSize: 24,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                const SizedBox(width: 12),
                                Text(
                                  '${match.awayScore}',
                                  style: const TextStyle(
                                    color: AppColors.kYellowAccent,
                                    fontSize: 28,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ],
                            ),
                          ],
                        )
                      : const Text(
                          'VS',
                          style: TextStyle(
                            color: AppColors.kGrey,
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                ),
                Expanded(
                  child: Column(
                    children: [
                      _buildTeamAvatar(awayTeam),
                      const SizedBox(height: 8),
                      Text(
                        awayTeam?.name ?? 'Equipo Visitante',
                        style: const TextStyle(
                          color: AppColors.kWhite,
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                        ),
                        textAlign: TextAlign.center,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                  ),
                ),
              ],
            ),
            if (match.venue != null) ...[
              const SizedBox(height: 12),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.location_on, size: 14, color: AppColors.kGrey),
                  const SizedBox(width: 4),
                  Text(
                    match.venue!,
                    style: const TextStyle(
                      color: AppColors.kGrey,
                      fontSize: 12,
                    ),
                  ),
                ],
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildTeamAvatar(Team? team) {
    return Container(
      width: 60,
      height: 60,
      decoration: BoxDecoration(
        color: AppColors.kYellowAccent.withOpacity(0.2),
        borderRadius: BorderRadius.circular(12),
      ),
      child: team?.logoUrl != null
          ? ClipRRect(
              borderRadius: BorderRadius.circular(12),
              child: Image.network(
                team!.logoUrl!,
                fit: BoxFit.cover,
                errorBuilder: (context, error, stackTrace) {
                  return Center(
                    child: Text(
                      team.name[0].toUpperCase(),
                      style: const TextStyle(
                        color: AppColors.kYellowAccent,
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  );
                },
              ),
            )
          : Center(
              child: Text(
                team?.name[0].toUpperCase() ?? 'T',
                style: const TextStyle(
                  color: AppColors.kYellowAccent,
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
    );
  }

  Widget _buildStandingsTab() {
    if (standings.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.table_chart,
              size: 80,
              color: AppColors.kGrey.withOpacity(0.3),
            ),
            const SizedBox(height: 16),
            const Text(
              'No hay tabla de posiciones',
              style: TextStyle(
                color: AppColors.kGrey,
                fontSize: 16,
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
          const Text(
            'Tabla de Posiciones',
            style: TextStyle(
              color: AppColors.kWhite,
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 16),
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: DataTable(
              headingRowColor: MaterialStateProperty.all(
                AppColors.kDarkCard,
              ),
              dataRowColor: MaterialStateProperty.resolveWith((states) {
                return AppColors.kDarkCard;
              }),
              border: TableBorder.all(
                color: AppColors.kGrey.withOpacity(0.2),
                borderRadius: BorderRadius.circular(12),
              ),
              headingTextStyle: const TextStyle(
                color: AppColors.kYellowAccent,
                fontWeight: FontWeight.bold,
                fontSize: 12,
              ),
              dataTextStyle: const TextStyle(
                color: AppColors.kWhite,
                fontSize: 12,
              ),
              columns: const [
                DataColumn(label: Text('Pos')),
                DataColumn(label: Text('Equipo')),
                DataColumn(label: Text('PJ')),
                DataColumn(label: Text('G')),
                DataColumn(label: Text('E')),
                DataColumn(label: Text('P')),
                DataColumn(label: Text('GF')),
                DataColumn(label: Text('GC')),
                DataColumn(label: Text('DG')),
                DataColumn(label: Text('Pts')),
              ],
              rows: standings.map((row) {
                final isTopThree = row.position <= 3;
                return DataRow(
                  color: MaterialStateProperty.all(
                    isTopThree
                        ? AppColors.kYellowAccent.withOpacity(0.05)
                        : AppColors.kDarkCard,
                  ),
                  cells: [
                    DataCell(
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 8,
                          vertical: 4,
                        ),
                        decoration: BoxDecoration(
                          color: isTopThree
                              ? AppColors.kYellowAccent.withOpacity(0.2)
                              : Colors.transparent,
                          borderRadius: BorderRadius.circular(8),
                          border: isTopThree
                              ? Border.all(
                                  color: AppColors.kYellowAccent.withOpacity(0.5),
                                  width: 1,
                                )
                              : null,
                        ),
                        child: Text(
                          '${row.position}',
                          style: TextStyle(
                            color: isTopThree
                                ? AppColors.kYellowAccent
                                : AppColors.kWhite,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ),
                    DataCell(
                      Row(
                        children: [
                          Container(
                            width: 24,
                            height: 24,
                            decoration: BoxDecoration(
                              color: AppColors.kYellowAccent.withOpacity(0.2),
                              borderRadius: BorderRadius.circular(6),
                            ),
                            child: row.teamLogoUrl != null
                                ? ClipRRect(
                                    borderRadius: BorderRadius.circular(6),
                                    child: Image.network(
                                      row.teamLogoUrl!,
                                      fit: BoxFit.cover,
                                      errorBuilder: (context, error, stackTrace) {
                                        return Center(
                                          child: Text(
                                            row.teamName[0].toUpperCase(),
                                            style: const TextStyle(
                                              color: AppColors.kYellowAccent,
                                              fontSize: 10,
                                              fontWeight: FontWeight.bold,
                                            ),
                                          ),
                                        );
                                      },
                                    ),
                                  )
                                : Center(
                                    child: Text(
                                      row.teamName[0].toUpperCase(),
                                      style: const TextStyle(
                                        color: AppColors.kYellowAccent,
                                        fontSize: 10,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                  ),
                          ),
                          const SizedBox(width: 8),
                          Text(row.teamName),
                        ],
                      ),
                    ),
                    DataCell(Text('${row.matchesPlayed}')),
                    DataCell(Text('${row.wins}')),
                    DataCell(Text('${row.draws}')),
                    DataCell(Text('${row.losses}')),
                    DataCell(Text('${row.goalsFor}')),
                    DataCell(Text('${row.goalsAgainst}')),
                    DataCell(
                      Text(
                        '${row.goalDifference >= 0 ? '+' : ''}${row.goalDifference}',
                        style: TextStyle(
                          color: row.goalDifference > 0
                              ? AppColors.kGreen
                              : row.goalDifference < 0
                                  ? AppColors.kRed
                                  : AppColors.kWhite,
                        ),
                      ),
                    ),
                    DataCell(
                      Text(
                        '${row.points}',
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          color: AppColors.kYellowAccent,
                        ),
                      ),
                    ),
                  ],
                );
              }).toList(),
            ),
          ),
        ],
      ),
    );
  }

  String _getStatusText(TournamentStatus status) {
    switch (status) {
      case TournamentStatus.upcoming:
        return 'PRÓXIMO';
      case TournamentStatus.ongoing:
        return 'EN CURSO';
      case TournamentStatus.completed:
        return 'FINALIZADO';
      case TournamentStatus.cancelled:
        return 'CANCELADO';
    }
  }

  Color _getStatusColor(TournamentStatus status) {
    switch (status) {
      case TournamentStatus.upcoming:
        return AppColors.kYellowAccent;
      case TournamentStatus.ongoing:
        return AppColors.kGreen;
      case TournamentStatus.completed:
        return AppColors.kBlue;
      case TournamentStatus.cancelled:
        return AppColors.kRed;
    }
  }

  String _getFormatText(TournamentFormat format) {
    switch (format) {
      case TournamentFormat.league:
        return 'Liga';
      case TournamentFormat.knockout:
        return 'Eliminación';
      case TournamentFormat.groupsAndKnockout:
        return 'Grupos + KO';
    }
  }

  String _getMatchStatusText(MatchStatus status) {
    switch (status) {
      case MatchStatus.upcoming:
        return 'PRÓXIMO';
      case MatchStatus.ongoing:
        return 'EN CURSO';
      case MatchStatus.completed:
        return 'FINALIZADO';
      case MatchStatus.cancelled:
        return 'CANCELADO';
    }
  }

  Color _getMatchStatusColor(MatchStatus status) {
    switch (status) {
      case MatchStatus.upcoming:
        return AppColors.kYellowAccent;
      case MatchStatus.ongoing:
        return AppColors.kGreen;
      case MatchStatus.completed:
        return AppColors.kBlue;
      case MatchStatus.cancelled:
        return AppColors.kRed;
    }
  }
}
