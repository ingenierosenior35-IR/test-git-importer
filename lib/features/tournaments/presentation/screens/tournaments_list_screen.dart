import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import '../../../../core/constants/colors.dart';
import '../../data/models/tournament_model.dart';
import '../../data/repositories/tournaments_firestore_repository.dart';

class TournamentsListScreen extends StatefulWidget {
  const TournamentsListScreen({Key? key}) : super(key: key);

  @override
  State<TournamentsListScreen> createState() => _TournamentsListScreenState();
}

class _TournamentsListScreenState extends State<TournamentsListScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  final _repository = TournamentsFirestoreRepository();
  List<Tournament> activeTournaments = [];
  List<Tournament> upcomingTournaments = [];
  List<Tournament> completedTournaments = [];
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
    _loadTournaments();
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  Future<void> _loadTournaments() async {
    setState(() => _loading = true);
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) {
      if (mounted) setState(() => _loading = false);
      return;
    }
    try {
      final mine = await _repository.getTournamentsForUser(user.uid);
      if (mounted) {
        setState(() {
          activeTournaments = mine
              .where((t) => t.status == TournamentStatus.ongoing)
              .toList();
          upcomingTournaments = mine
              .where((t) => t.status == TournamentStatus.upcoming)
              .toList();
          completedTournaments = mine
              .where((t) => t.status == TournamentStatus.completed)
              .toList();
          _loading = false;
        });
      }
    } catch (e) {
      if (mounted) setState(() => _loading = false);
    }
  }

  void _createTournament() {
    Get.toNamed('/tournament_form_screen')?.then((_) => _loadTournaments());
  }

  void _viewTournamentDetail(Tournament tournament) {
    Get.toNamed('/tournament_detail_screen', arguments: tournament)
        ?.then((_) => _loadTournaments());
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.kDarkBackground,
      appBar: AppBar(
        backgroundColor: AppColors.kDarkCard,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_rounded,
              color: AppColors.kWhite),
          onPressed: () => Get.back(),
        ),
        title: const Text(
          'Torneos',
          style: TextStyle(
            color: AppColors.kWhite,
            fontSize: 20,
            fontWeight: FontWeight.bold,
          ),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.add_circle_outline,
                color: AppColors.kYellowAccent),
            onPressed: _createTournament,
          ),
        ],
        bottom: TabBar(
          controller: _tabController,
          indicatorColor: AppColors.kYellowAccent,
          labelColor: AppColors.kYellowAccent,
          unselectedLabelColor: AppColors.kGrey,
          labelStyle: const TextStyle(fontWeight: FontWeight.bold, fontSize: 12),
          tabs: const [
            Tab(text: 'ACTIVOS'),
            Tab(text: 'PRÓXIMOS'),
            Tab(text: 'FINALIZADOS'),
          ],
        ),
      ),
      body: _loading
          ? const Center(
              child: CircularProgressIndicator(color: AppColors.kYellowAccent))
          : TabBarView(
        controller: _tabController,
        children: [
          _buildTournamentsList(activeTournaments, isEmpty: activeTournaments.isEmpty),
          _buildTournamentsList(upcomingTournaments, isEmpty: upcomingTournaments.isEmpty),
          _buildTournamentsList(completedTournaments, isEmpty: completedTournaments.isEmpty),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _createTournament,
        backgroundColor: AppColors.kYellowAccent,
        child: const Icon(Icons.add, color: AppColors.kBlack),
      ),
    );
  }

  Widget _buildTournamentsList(List<Tournament> tournaments, {required bool isEmpty}) {
    if (isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.emoji_events_outlined,
              size: 80,
              color: AppColors.kGrey.withOpacity(0.3),
            ),
            const SizedBox(height: 16),
            Text(
              'No hay torneos',
              style: TextStyle(
                color: AppColors.kGrey,
                fontSize: 16,
              ),
            ),
            const SizedBox(height: 8),
            TextButton(
              onPressed: _createTournament,
              child: const Text(
                'Crear torneo',
                style: TextStyle(
                  color: AppColors.kYellowAccent,
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ],
        ),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.all(20),
      itemCount: tournaments.length,
      itemBuilder: (context, index) {
        return _buildTournamentCard(tournaments[index]);
      },
    );
  }

  Widget _buildTournamentCard(Tournament tournament) {
    return GestureDetector(
      onTap: () => _viewTournamentDetail(tournament),
      child: Container(
        margin: const EdgeInsets.only(bottom: 16),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: AppColors.kDarkCard,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: _getStatusColor(tournament.status).withOpacity(0.3),
            width: 1,
          ),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  width: 60,
                  height: 60,
                  decoration: BoxDecoration(
                    color: AppColors.kYellowAccent.withOpacity(0.2),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: tournament.logoUrl != null
                      ? ClipRRect(
                          borderRadius: BorderRadius.circular(12),
                          child: Image.network(
                            tournament.logoUrl!,
                            fit: BoxFit.cover,
                            errorBuilder: (context, error, stackTrace) {
                              return const Icon(
                                Icons.emoji_events,
                                color: AppColors.kYellowAccent,
                                size: 32,
                              );
                            },
                          ),
                        )
                      : const Icon(
                          Icons.emoji_events,
                          color: AppColors.kYellowAccent,
                          size: 32,
                        ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        tournament.name,
                        style: const TextStyle(
                          color: AppColors.kWhite,
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: 4),
                      Row(
                        children: [
                          Container(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 8, vertical: 4),
                            decoration: BoxDecoration(
                              color: _getStatusColor(tournament.status)
                                  .withOpacity(0.2),
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Text(
                              _getStatusText(tournament.status),
                              style: TextStyle(
                                color: _getStatusColor(tournament.status),
                                fontSize: 10,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                          const SizedBox(width: 8),
                          Container(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 8, vertical: 4),
                            decoration: BoxDecoration(
                              color: AppColors.kGrey.withOpacity(0.2),
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Text(
                              _getFormatText(tournament.format),
                              style: const TextStyle(
                                color: AppColors.kGrey,
                                fontSize: 10,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                Icon(Icons.location_on, size: 14, color: AppColors.kGrey),
                const SizedBox(width: 4),
                Text(
                  tournament.location ?? 'Sin ubicación',
                  style: TextStyle(
                    color: AppColors.kGrey,
                    fontSize: 12,
                  ),
                ),
                const SizedBox(width: 16),
                Icon(Icons.calendar_today, size: 14, color: AppColors.kGrey),
                const SizedBox(width: 4),
                Text(
                  DateFormat('dd/MM/yyyy').format(tournament.startDate),
                  style: TextStyle(
                    color: AppColors.kGrey,
                    fontSize: 12,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(
                  child: Row(
                    children: [
                      Icon(Icons.people, size: 16, color: AppColors.kYellowAccent),
                      const SizedBox(width: 4),
                      Text(
                        '${tournament.currentTeams}/${tournament.maxTeams} equipos',
                        style: const TextStyle(
                          color: AppColors.kWhite,
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                ),
                if (tournament.canJoin)
                  Container(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 12, vertical: 6),
                    decoration: BoxDecoration(
                      color: AppColors.kYellowAccent.withOpacity(0.2),
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(
                        color: AppColors.kYellowAccent,
                        width: 1,
                      ),
                    ),
                    child: const Text(
                      'Unirse',
                      style: TextStyle(
                        color: AppColors.kYellowAccent,
                        fontSize: 11,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
              ],
            ),
          ],
        ),
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
}
