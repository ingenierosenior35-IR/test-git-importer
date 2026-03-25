import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import '../../../../core/constants/colors.dart';
import '../../data/models/tournament_model.dart';
import '../../data/repositories/tournaments_firestore_repository.dart';
import '../../../teams/data/models/team_model.dart';
import '../../../teams/data/repositories/teams_firestore_repository.dart';

class TournamentDetailScreen extends StatefulWidget {
  const TournamentDetailScreen({Key? key}) : super(key: key);

  @override
  State<TournamentDetailScreen> createState() => _TournamentDetailScreenState();
}

class _TournamentDetailScreenState extends State<TournamentDetailScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  late Tournament tournament;
  List<TournamentEnrolledTeam> enrolledTeams = [];
  List<TournamentMatch> tournamentMatches = [];
  bool _isLoading = false;
  String? _currentUserId;
  bool _userTeamEnrolled = false;

  final _repository = TournamentsFirestoreRepository();
  final _teamsRepository = TeamsFirestoreRepository();

  bool get _isAdmin => tournament.createdBy == _currentUserId;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
    tournament = Get.arguments as Tournament;
    _currentUserId = FirebaseAuth.instance.currentUser?.uid;
    _loadData();
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  Future<void> _loadData() async {
    if (!mounted) return;
    setState(() => _isLoading = true);
    try {
      final teamsResult = await _repository.getEnrolledTeams(tournament.id);
      final matchesResult = await _repository.getTournamentMatches(tournament.id);
      final refreshed = await _repository.getTournament(tournament.id);

      if (mounted) {
        setState(() {
          enrolledTeams = teamsResult;
          tournamentMatches = matchesResult;
          if (refreshed != null) tournament = refreshed;
          _userTeamEnrolled = _currentUserId != null &&
              teamsResult.any((t) => t.ownerUserId == _currentUserId);
          _isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  // ── Admin actions ──────────────────────────────────

  Future<void> _openTournament() async {
    try {
      await _repository.updateTournamentStatus(
          tournament.id, TournamentStatus.open);
      await _loadData();
      Get.snackbar('Éxito', 'Torneo abierto para inscripciones',
          backgroundColor: AppColors.kGreen.withOpacity(0.8),
          colorText: AppColors.kWhite);
    } catch (e) {
      Get.snackbar('Error', e.toString(),
          backgroundColor: AppColors.kRed.withOpacity(0.8),
          colorText: AppColors.kWhite);
    }
  }

  Future<void> _generateBracket() async {
    if (enrolledTeams.length < 2) {
      Get.snackbar('Error', 'Se necesitan al menos 2 equipos inscritos.',
          backgroundColor: AppColors.kRed.withOpacity(0.8),
          colorText: AppColors.kWhite);
      return;
    }
    if (tournament.format != TournamentFormat.knockout) {
      Get.snackbar('Info',
          'La generación automática solo aplica al formato Eliminación.',
          backgroundColor: AppColors.kOrange.withOpacity(0.8),
          colorText: AppColors.kWhite);
      return;
    }
    try {
      setState(() => _isLoading = true);
      await _repository.generateBracket(tournament);
      await _loadData();
      Get.snackbar('Éxito', 'Bracket generado. Torneo iniciado.',
          backgroundColor: AppColors.kGreen.withOpacity(0.8),
          colorText: AppColors.kWhite);
    } catch (e) {
      if (mounted) setState(() => _isLoading = false);
      Get.snackbar('Error', e.toString(),
          backgroundColor: AppColors.kRed.withOpacity(0.8),
          colorText: AppColors.kWhite);
    }
  }

  /// Starts a non-knockout tournament (league / groups+KO) without generating
  /// a bracket automatically. Simply moves status → started.
  Future<void> _startTournament() async {
    if (enrolledTeams.length < 2) {
      Get.snackbar('Error', 'Se necesitan al menos 2 equipos inscritos.',
          backgroundColor: AppColors.kRed.withOpacity(0.8),
          colorText: AppColors.kWhite);
      return;
    }
    try {
      setState(() => _isLoading = true);
      await _repository.updateTournamentStatus(
          tournament.id, TournamentStatus.started,
          currentRound: 1);
      await _loadData();
      Get.snackbar('Éxito', 'Torneo iniciado.',
          backgroundColor: AppColors.kGreen.withOpacity(0.8),
          colorText: AppColors.kWhite);
    } catch (e) {
      if (mounted) setState(() => _isLoading = false);
      Get.snackbar('Error', e.toString(),
          backgroundColor: AppColors.kRed.withOpacity(0.8),
          colorText: AppColors.kWhite);
    }
  }

  /// Returns true when the current user (admin) can trigger the start/bracket
  /// action. True only when the user is the tournament creator AND the
  /// tournament status is draft, open, or upcoming (i.e. not yet started).
  bool get _isStartable =>
      _isAdmin &&
      (tournament.status == TournamentStatus.draft ||
          tournament.status == TournamentStatus.open ||
          tournament.status == TournamentStatus.upcoming);

  void _editTournament() {
    Get.toNamed('/tournament_form_screen', arguments: tournament)
        ?.then((_) => _loadData());
  }

  void _deleteTournament() {
    Get.dialog(
      AlertDialog(
        backgroundColor: AppColors.kDarkCard,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Text('Eliminar Torneo',
            style: TextStyle(color: AppColors.kWhite, fontWeight: FontWeight.bold)),
        content: Text(
          '¿Estás seguro de que deseas eliminar "${tournament.name}"?',
          style: const TextStyle(color: AppColors.kGrey),
        ),
        actions: [
          TextButton(
            onPressed: () => Get.back(),
            child: const Text('Cancelar', style: TextStyle(color: AppColors.kGrey)),
          ),
          TextButton(
            onPressed: () async {
              Get.back();
              await _repository.deleteTournament(tournament.id);
              Get.back();
              Get.snackbar('Éxito', 'Torneo eliminado',
                  backgroundColor: AppColors.kGreen.withOpacity(0.8),
                  colorText: AppColors.kWhite);
            },
            child: const Text('Eliminar',
                style: TextStyle(color: AppColors.kRed, fontWeight: FontWeight.bold)),
          ),
        ],
      ),
    );
  }

  void _removeTeam(TournamentEnrolledTeam team) {
    Get.dialog(
      AlertDialog(
        backgroundColor: AppColors.kDarkCard,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Text('Quitar equipo',
            style: TextStyle(color: AppColors.kWhite, fontWeight: FontWeight.bold)),
        content: Text(
          '¿Quitar a "${team.teamName}" del torneo?',
          style: const TextStyle(color: AppColors.kGrey),
        ),
        actions: [
          TextButton(
            onPressed: () => Get.back(),
            child: const Text('Cancelar', style: TextStyle(color: AppColors.kGrey)),
          ),
          TextButton(
            onPressed: () async {
              Get.back();
              try {
                await _repository.leaveOrRemoveTeam(tournament.id, team.teamId);
                await _loadData();
                Get.snackbar('Éxito', 'Equipo eliminado del torneo',
                    backgroundColor: AppColors.kGreen.withOpacity(0.8),
                    colorText: AppColors.kWhite);
              } catch (e) {
                Get.snackbar('Error', e.toString(),
                    backgroundColor: AppColors.kRed.withOpacity(0.8),
                    colorText: AppColors.kWhite);
              }
            },
            child: const Text('Quitar',
                style: TextStyle(color: AppColors.kRed, fontWeight: FontWeight.bold)),
          ),
        ],
      ),
    );
  }

  // ── Join tournament ────────────────────────────────

  Future<void> _showJoinDialog() async {
    final uid = _currentUserId;
    if (uid == null) {
      Get.snackbar('Error', 'Debes iniciar sesión.',
          backgroundColor: AppColors.kRed.withOpacity(0.8),
          colorText: AppColors.kWhite);
      return;
    }
    if (!tournament.canJoin) {
      Get.snackbar('No disponible', 'Este torneo no esta abierto para inscripciones.',
          backgroundColor: AppColors.kOrange.withOpacity(0.8),
          colorText: AppColors.kWhite);
      return;
    }

    final userTeams = await _teamsRepository.getTeamsForUser(uid);

    if (userTeams.isEmpty) {
      final create = await Get.dialog<bool>(
        AlertDialog(
          backgroundColor: AppColors.kDarkCard,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          title: const Text('Sin equipos',
              style: TextStyle(color: AppColors.kWhite, fontWeight: FontWeight.bold)),
          content: const Text(
            'No tienes ningún equipo creado. ¿Deseas crear uno ahora?',
            style: TextStyle(color: AppColors.kGrey),
          ),
          actions: [
            TextButton(
                onPressed: () => Get.back(result: false),
                child: const Text('Cancelar', style: TextStyle(color: AppColors.kGrey))),
            TextButton(
                onPressed: () => Get.back(result: true),
                child: const Text('Crear equipo',
                    style: TextStyle(color: AppColors.kYellowAccent, fontWeight: FontWeight.bold))),
          ],
        ),
      );
      if (create == true) {
        await Get.toNamed('/create_team_screen');
        await _showJoinDialog();
      }
      return;
    }

    final selectedTeam = await Get.dialog<Team>(
      AlertDialog(
        backgroundColor: AppColors.kDarkCard,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Text('Seleccionar equipo',
            style: TextStyle(color: AppColors.kWhite, fontWeight: FontWeight.bold)),
        content: SizedBox(
          width: double.maxFinite,
          child: ListView.builder(
            shrinkWrap: true,
            itemCount: userTeams.length,
            itemBuilder: (context, index) {
              final team = userTeams[index];
              final alreadyEnrolled = enrolledTeams.any((e) => e.teamId == team.id);
              return ListTile(
                leading: CircleAvatar(
                  backgroundColor: AppColors.kYellowAccent.withOpacity(0.2),
                  child: Text(
                    team.name.isNotEmpty ? team.name[0].toUpperCase() : 'T',
                    style: const TextStyle(color: AppColors.kYellowAccent),
                  ),
                ),
                title: Text(team.name,
                    style: TextStyle(
                        color: alreadyEnrolled ? AppColors.kGrey : AppColors.kWhite)),
                subtitle: alreadyEnrolled
                    ? const Text('Ya inscrito',
                        style: TextStyle(color: AppColors.kGrey, fontSize: 12))
                    : null,
                enabled: !alreadyEnrolled,
                onTap: alreadyEnrolled ? null : () => Get.back(result: team),
              );
            },
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Get.back(),
            child: const Text('Cancelar', style: TextStyle(color: AppColors.kGrey)),
          ),
        ],
      ),
    );

    if (selectedTeam == null) return;

    try {
      setState(() => _isLoading = true);
      await _repository.joinTournament(
        tournamentId: tournament.id,
        teamId: selectedTeam.id,
        teamName: selectedTeam.name,
        ownerUserId: uid,
        logoUrl: selectedTeam.logoUrl,
      );
      await _loadData();
      Get.snackbar('¡Éxito!', 'Te uniste al torneo con "${selectedTeam.name}"',
          backgroundColor: AppColors.kGreen.withOpacity(0.8),
          colorText: AppColors.kWhite);
    } catch (e) {
      if (mounted) setState(() => _isLoading = false);
      Get.snackbar('Error', e.toString(),
          backgroundColor: AppColors.kRed.withOpacity(0.8),
          colorText: AppColors.kWhite);
    }
  }

  // ── Match result entry ─────────────────────────────

  void _enterMatchResult(TournamentMatch match) {
    final homeController = TextEditingController(
        text: match.homeScore != null ? '${match.homeScore}' : '');
    final awayController = TextEditingController(
        text: match.awayScore != null ? '${match.awayScore}' : '');

    Get.dialog(
      AlertDialog(
        backgroundColor: AppColors.kDarkCard,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Text('Registrar resultado',
            style: TextStyle(color: AppColors.kWhite, fontWeight: FontWeight.bold)),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              '${match.effectiveHomeTeamName} vs ${match.effectiveAwayTeamName}',
              style: const TextStyle(color: AppColors.kGrey, fontSize: 13),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: Column(
                    children: [
                      Text(match.effectiveHomeTeamName,
                          style: const TextStyle(color: AppColors.kWhite, fontSize: 12),
                          textAlign: TextAlign.center),
                      const SizedBox(height: 8),
                      TextField(
                        controller: homeController,
                        keyboardType: TextInputType.number,
                        textAlign: TextAlign.center,
                        style: const TextStyle(color: AppColors.kWhite, fontSize: 28),
                        decoration: InputDecoration(
                          filled: true,
                          fillColor: AppColors.kDarkBackground,
                          border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12),
                              borderSide: BorderSide.none),
                        ),
                      ),
                    ],
                  ),
                ),
                const Padding(
                    padding: EdgeInsets.symmetric(horizontal: 12),
                    child: Text('-',
                        style: TextStyle(
                            color: AppColors.kGrey,
                            fontSize: 24,
                            fontWeight: FontWeight.bold))),
                Expanded(
                  child: Column(
                    children: [
                      Text(match.effectiveAwayTeamName,
                          style: const TextStyle(color: AppColors.kWhite, fontSize: 12),
                          textAlign: TextAlign.center),
                      const SizedBox(height: 8),
                      TextField(
                        controller: awayController,
                        keyboardType: TextInputType.number,
                        textAlign: TextAlign.center,
                        style: const TextStyle(color: AppColors.kWhite, fontSize: 28),
                        decoration: InputDecoration(
                          filled: true,
                          fillColor: AppColors.kDarkBackground,
                          border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12),
                              borderSide: BorderSide.none),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ],
        ),
        actions: [
          TextButton(
              onPressed: () => Get.back(),
              child: const Text('Cancelar', style: TextStyle(color: AppColors.kGrey))),
          TextButton(
            onPressed: () async {
              final home = int.tryParse(homeController.text.trim());
              final away = int.tryParse(awayController.text.trim());
              if (home == null || away == null) {
                Get.snackbar('Error', 'Ingresa goles válidos.',
                    backgroundColor: AppColors.kRed.withOpacity(0.8),
                    colorText: AppColors.kWhite);
                return;
              }
              // En empate, el equipo local avanza (regla simplificada; ajustar para penales si se requiere).
              final winnerId = home > away
                  ? (match.homeTeamId ?? '')
                  : home < away
                      ? (match.awayTeamId ?? '')
                      : (match.homeTeamId ?? '');
              Get.back();
              try {
                setState(() => _isLoading = true);
                await _repository.updateMatchResult(
                  tournamentId: tournament.id,
                  matchId: match.id,
                  homeScore: home,
                  awayScore: away,
                  winnerTeamId: winnerId,
                );
                await _loadData();
                Get.snackbar('Resultado guardado', '$home - $away',
                    backgroundColor: AppColors.kGreen.withOpacity(0.8),
                    colorText: AppColors.kWhite);
              } catch (e) {
                if (mounted) setState(() => _isLoading = false);
                Get.snackbar('Error', e.toString(),
                    backgroundColor: AppColors.kRed.withOpacity(0.8),
                    colorText: AppColors.kWhite);
              }
            },
            child: const Text('Guardar',
                style: TextStyle(
                    color: AppColors.kYellowAccent, fontWeight: FontWeight.bold)),
          ),
        ],
      ),
    );
  }

  void _shareCode() {
    if (tournament.joinCode != null) {
      Clipboard.setData(ClipboardData(text: tournament.joinCode!));
      Get.snackbar('Código copiado',
          'El código "${tournament.joinCode}" ha sido copiado al portapapeles',
          backgroundColor: AppColors.kYellowAccent.withOpacity(0.2),
          colorText: AppColors.kWhite,
          icon: const Icon(Icons.check_circle, color: AppColors.kYellowAccent));
    }
  }

  // ── Build ──────────────────────────────────────────

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
        title: Text(tournament.name,
            style: const TextStyle(
                color: AppColors.kWhite, fontSize: 18, fontWeight: FontWeight.bold)),
        actions: [
          if (_isAdmin) ...[
            IconButton(
              icon: const Icon(Icons.edit_outlined, color: AppColors.kYellowAccent),
              onPressed: _editTournament,
            ),
            IconButton(
              icon: const Icon(Icons.delete_outline, color: AppColors.kRed),
              onPressed: _deleteTournament,
            ),
          ],
        ],
        bottom: TabBar(
          controller: _tabController,
          indicatorColor: AppColors.kYellowAccent,
          labelColor: AppColors.kYellowAccent,
          unselectedLabelColor: AppColors.kGrey,
          labelStyle: const TextStyle(fontWeight: FontWeight.bold, fontSize: 12),
          tabs: const [
            Tab(text: 'EQUIPOS'),
            Tab(text: 'PARTIDOS'),
            Tab(text: 'INFO'),
          ],
        ),
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator(color: AppColors.kYellowAccent))
          : TabBarView(
              controller: _tabController,
              children: [
                _buildTeamsTab(),
                _buildMatchesTab(),
                _buildInfoTab(),
              ],
            ),
    );
  }

  // ── Teams tab ─────────────────────────────────────

  Widget _buildTeamsTab() {
    return RefreshIndicator(
      onRefresh: _loadData,
      color: AppColors.kYellowAccent,
      child: ListView(
        padding: const EdgeInsets.all(20),
        children: [
          if (_isAdmin) ...[
            if (tournament.status == TournamentStatus.draft ||
                tournament.status == TournamentStatus.upcoming) ...[
              _adminButton(
                label: 'Abrir inscripciones',
                icon: Icons.lock_open,
                color: AppColors.kYellowAccent,
                onTap: _openTournament,
              ),
              const SizedBox(height: 12),
            ],
            if (_isStartable) ...[
              if (enrolledTeams.length < 2) ...[
                _adminButton(
                  label: tournament.format == TournamentFormat.knockout
                      ? 'Generar bracket e iniciar (mínimo 2 equipos)'
                      : 'Iniciar torneo (mínimo 2 equipos)',
                  icon: tournament.format == TournamentFormat.knockout
                      ? Icons.account_tree_outlined
                      : Icons.play_circle_outline,
                  color: AppColors.kGreen,
                  onTap: null,
                ),
                const SizedBox(height: 12),
              ] else ...[
                _adminButton(
                  label: tournament.format == TournamentFormat.knockout
                      ? 'Generar bracket e iniciar torneo'
                      : 'Iniciar torneo',
                  icon: tournament.format == TournamentFormat.knockout
                      ? Icons.account_tree_outlined
                      : Icons.play_circle_outline,
                  color: AppColors.kGreen,
                  onTap: tournament.format == TournamentFormat.knockout
                      ? _generateBracket
                      : _startTournament,
                ),
                const SizedBox(height: 12),
              ],
            ],
          ],
          if (!_isAdmin && tournament.canJoin && !_userTeamEnrolled) ...[
            SizedBox(
              width: double.infinity,
              height: 52,
              child: ElevatedButton.icon(
                onPressed: _showJoinDialog,
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.kYellowAccent,
                  foregroundColor: AppColors.kBlack,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  elevation: 0,
                ),
                icon: const Icon(Icons.login),
                label: const Text('Unir mi equipo',
                    style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold)),
              ),
            ),
            const SizedBox(height: 16),
          ],
          if (_userTeamEnrolled && !_isAdmin)
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              decoration: BoxDecoration(
                color: AppColors.kGreen.withOpacity(0.1),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: AppColors.kGreen.withOpacity(0.4), width: 1),
              ),
              child: Row(
                children: const [
                  Icon(Icons.check_circle, color: AppColors.kGreen, size: 20),
                  SizedBox(width: 8),
                  Text('Tu equipo está inscrito',
                      style: TextStyle(color: AppColors.kGreen, fontWeight: FontWeight.w600)),
                ],
              ),
            ),
          const SizedBox(height: 16),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Equipos (${enrolledTeams.length}/${tournament.maxTeams})',
                style: const TextStyle(
                    color: AppColors.kWhite, fontSize: 16, fontWeight: FontWeight.bold),
              ),
              if (_isAdmin &&
                  (tournament.status == TournamentStatus.open ||
                      tournament.status == TournamentStatus.upcoming))
                TextButton.icon(
                  onPressed: _showJoinDialog,
                  icon: const Icon(Icons.add, size: 16, color: AppColors.kYellowAccent),
                  label: const Text('Añadir', style: TextStyle(color: AppColors.kYellowAccent)),
                ),
            ],
          ),
          const SizedBox(height: 12),
          if (enrolledTeams.isEmpty)
            Center(
              child: Padding(
                padding: const EdgeInsets.symmetric(vertical: 40),
                child: Column(
                  children: [
                    Icon(Icons.group_outlined,
                        size: 64, color: AppColors.kGrey.withOpacity(0.3)),
                    const SizedBox(height: 12),
                    const Text('Ningún equipo inscrito aún',
                        style: TextStyle(color: AppColors.kGrey, fontSize: 15)),
                  ],
                ),
              ),
            )
          else
            ...enrolledTeams.asMap().entries.map((entry) {
              return _buildTeamCard(entry.value, entry.key + 1);
            }),
        ],
      ),
    );
  }

  Widget _buildTeamCard(TournamentEnrolledTeam team, int position) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
          color: AppColors.kDarkCard, borderRadius: BorderRadius.circular(14)),
      child: Row(
        children: [
          Container(
            width: 32,
            height: 32,
            decoration: BoxDecoration(
              color: AppColors.kYellowAccent.withOpacity(0.15),
              shape: BoxShape.circle,
            ),
            child: Center(
              child: Text('$position',
                  style: const TextStyle(
                      color: AppColors.kYellowAccent, fontWeight: FontWeight.bold)),
            ),
          ),
          const SizedBox(width: 12),
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: AppColors.kYellowAccent.withOpacity(0.15),
              borderRadius: BorderRadius.circular(10),
            ),
            child: _teamInitial(team.teamName),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(team.teamName,
                    style: const TextStyle(
                        color: AppColors.kWhite, fontWeight: FontWeight.w600)),
                Text(DateFormat('dd/MM/yyyy').format(team.joinedAt),
                    style: const TextStyle(color: AppColors.kGrey, fontSize: 11)),
              ],
            ),
          ),
          if (_isAdmin &&
              (tournament.status == TournamentStatus.open ||
                  tournament.status == TournamentStatus.draft ||
                  tournament.status == TournamentStatus.upcoming))
            IconButton(
              icon: const Icon(Icons.remove_circle_outline,
                  color: AppColors.kRed, size: 20),
              onPressed: () => _removeTeam(team),
            ),
        ],
      ),
    );
  }

  Widget _teamInitial(String name) {
    return Center(
      child: Text(
        name.isNotEmpty ? name[0].toUpperCase() : 'T',
        style: const TextStyle(
            color: AppColors.kYellowAccent, fontWeight: FontWeight.bold),
      ),
    );
  }

  // ── Matches tab ───────────────────────────────────

  Widget _buildMatchesTab() {
    if (tournamentMatches.isEmpty) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(32),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.sports_soccer,
                  size: 80, color: AppColors.kGrey.withOpacity(0.3)),
              const SizedBox(height: 16),
              const Text('No hay partidos generados',
                  style: TextStyle(color: AppColors.kGrey, fontSize: 16)),
              if (_isAdmin &&
                  enrolledTeams.length >= 2 &&
                  _isStartable) ...[
                const SizedBox(height: 20),
                ElevatedButton.icon(
                  onPressed: tournament.format == TournamentFormat.knockout
                      ? _generateBracket
                      : _startTournament,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.kYellowAccent,
                    foregroundColor: AppColors.kBlack,
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12)),
                  ),
                  icon: Icon(tournament.format == TournamentFormat.knockout
                      ? Icons.account_tree_outlined
                      : Icons.play_circle_outline),
                  label: Text(
                    tournament.format == TournamentFormat.knockout
                        ? 'Generar bracket'
                        : 'Iniciar torneo',
                    style: const TextStyle(fontWeight: FontWeight.bold),
                  ),
                ),
              ],
            ],
          ),
        ),
      );
    }

    final rounds = <int, List<TournamentMatch>>{};
    for (final m in tournamentMatches) {
      rounds.putIfAbsent(m.round, () => []).add(m);
    }
    final sortedRounds = rounds.keys.toList()..sort();

    return RefreshIndicator(
      onRefresh: _loadData,
      color: AppColors.kYellowAccent,
      child: ListView(
        padding: const EdgeInsets.all(20),
        children: [
          for (final round in sortedRounds) ...[
            Padding(
              padding: const EdgeInsets.only(bottom: 12, top: 4),
              child: Text(
                _roundLabel(round, sortedRounds.length),
                style: const TextStyle(
                    color: AppColors.kYellowAccent,
                    fontSize: 15,
                    fontWeight: FontWeight.bold),
              ),
            ),
            ...rounds[round]!.map(_buildTournamentMatchCard),
            const SizedBox(height: 8),
          ],
        ],
      ),
    );
  }

  String _roundLabel(int round, int totalRounds) {
    final remaining = totalRounds - round + 1;
    if (remaining == 1) return 'Final';
    if (remaining == 2) return 'Semifinales';
    if (remaining == 3) return 'Cuartos de final';
    return 'Ronda $round';
  }

  Widget _buildTournamentMatchCard(TournamentMatch match) {
    final isBye = match.isBye;
    final isFinished = match.isFinished;
    final canEdit = _isAdmin && !isBye;

    Color statusColor;
    String statusText;
    if (isBye) {
      statusColor = AppColors.kGrey;
      statusText = 'BYE';
    } else if (isFinished) {
      statusColor = AppColors.kBlue;
      statusText = 'FINALIZADO';
    } else {
      statusColor = AppColors.kYellowAccent;
      statusText = 'PENDIENTE';
    }

    return GestureDetector(
      onTap: canEdit && !isFinished ? () => _enterMatchResult(match) : null,
      child: Container(
        margin: const EdgeInsets.only(bottom: 12),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: AppColors.kDarkCard,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: statusColor.withOpacity(0.25), width: 1),
        ),
        child: Column(
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                  decoration: BoxDecoration(
                      color: statusColor.withOpacity(0.15),
                      borderRadius: BorderRadius.circular(8)),
                  child: Text(statusText,
                      style: TextStyle(
                          color: statusColor,
                          fontSize: 10,
                          fontWeight: FontWeight.bold)),
                ),
                if (canEdit && !isFinished)
                  const Icon(Icons.edit_outlined, size: 16, color: AppColors.kGrey),
                if (_isAdmin && isFinished && !isBye)
                  GestureDetector(
                    onTap: () => _enterMatchResult(match),
                    child: const Text('Editar',
                        style: TextStyle(color: AppColors.kGrey, fontSize: 11)),
                  ),
              ],
            ),
            const SizedBox(height: 14),
            Row(
              children: [
                Expanded(
                  child: Column(
                    children: [
                      _teamAvatarWidget(match.homeTeamName),
                      const SizedBox(height: 6),
                      Text(
                        match.effectiveHomeTeamName,
                        style: TextStyle(
                          color: match.winnerTeamId == match.homeTeamId && isFinished
                              ? AppColors.kYellowAccent
                              : AppColors.kWhite,
                          fontSize: 13,
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
                  padding: const EdgeInsets.symmetric(horizontal: 12),
                  child: isFinished && !isBye
                      ? Text('${match.homeScore} - ${match.awayScore}',
                          style: const TextStyle(
                              color: AppColors.kWhite,
                              fontSize: 22,
                              fontWeight: FontWeight.bold))
                      : const Text('VS',
                          style: TextStyle(
                              color: AppColors.kGrey,
                              fontSize: 18,
                              fontWeight: FontWeight.bold)),
                ),
                Expanded(
                  child: Column(
                    children: [
                      _teamAvatarWidget(match.awayTeamName),
                      const SizedBox(height: 6),
                      Text(
                        match.effectiveAwayTeamName,
                        style: TextStyle(
                          color: match.winnerTeamId == match.awayTeamId && isFinished
                              ? AppColors.kYellowAccent
                              : AppColors.kWhite,
                          fontSize: 13,
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
          ],
        ),
      ),
    );
  }

  Widget _teamAvatarWidget(String? name) {
    final initial = (name != null && name.isNotEmpty) ? name[0].toUpperCase() : 'T';
    return Container(
      width: 44,
      height: 44,
      decoration: BoxDecoration(
        color: AppColors.kYellowAccent.withOpacity(0.15),
        borderRadius: BorderRadius.circular(10),
      ),
      child: Center(
        child: Text(initial,
            style: const TextStyle(
                color: AppColors.kYellowAccent,
                fontWeight: FontWeight.bold,
                fontSize: 18)),
      ),
    );
  }

  // ── Info tab ──────────────────────────────────────

  Widget _buildInfoTab() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildHeaderCard(),
          const SizedBox(height: 16),
          _buildInfoCard('Fechas', [
            _infoRow(Icons.calendar_today, 'Inicio',
                DateFormat('dd/MM/yyyy').format(tournament.startDate)),
            if (tournament.endDate != null) ...[
              const SizedBox(height: 8),
              _infoRow(Icons.event, 'Fin',
                  DateFormat('dd/MM/yyyy').format(tournament.endDate!)),
            ],
          ]),
          const SizedBox(height: 16),
          _buildInfoCard('Detalles', [
            _infoRow(Icons.sports_soccer, 'Deporte', tournament.sport),
            const SizedBox(height: 8),
            _infoRow(Icons.people, 'Equipos',
                '${tournament.currentTeams}/${tournament.maxTeams}'),
            if (tournament.location != null) ...[
              const SizedBox(height: 8),
              _infoRow(Icons.location_on, 'Lugar', tournament.location!),
            ],
          ]),
          if (tournament.format == TournamentFormat.league) ...[
            const SizedBox(height: 16),
            _buildInfoCard('Puntuacion', [
              _infoRow(Icons.emoji_events, 'Victoria',
                  '${tournament.pointsForWin} pts'),
              const SizedBox(height: 8),
              _infoRow(Icons.remove_circle_outline, 'Empate',
                  '${tournament.pointsForDraw} pts'),
              const SizedBox(height: 8),
              _infoRow(Icons.close, 'Derrota',
                  '${tournament.pointsForLoss} pts'),
            ]),
          ],
          if (tournament.joinCode != null) ...[
            const SizedBox(height: 16),
            SizedBox(
              width: double.infinity,
              height: 52,
              child: OutlinedButton.icon(
                onPressed: _shareCode,
                style: OutlinedButton.styleFrom(
                  foregroundColor: AppColors.kYellowAccent,
                  side: const BorderSide(color: AppColors.kYellowAccent),
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12)),
                ),
                icon: const Icon(Icons.share),
                label: Text('Código: ${tournament.joinCode}',
                    style: const TextStyle(fontWeight: FontWeight.bold)),
              ),
            ),
          ],
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
            color: _getStatusColor(tournament.status).withOpacity(0.3), width: 1),
      ),
      child: Column(
        children: [
          Container(
            width: 80,
            height: 80,
            decoration: BoxDecoration(
              color: AppColors.kYellowAccent.withOpacity(0.15),
              borderRadius: BorderRadius.circular(16),
            ),
            child: tournament.logoUrl != null
                ? ClipRRect(
                    borderRadius: BorderRadius.circular(16),
                    child: Image.network(tournament.logoUrl!,
                        fit: BoxFit.cover,
                        errorBuilder: (_, __, ___) => const Icon(Icons.emoji_events,
                            color: AppColors.kYellowAccent, size: 40)))
                : const Icon(Icons.emoji_events,
                    color: AppColors.kYellowAccent, size: 40),
          ),
          const SizedBox(height: 16),
          Text(tournament.name,
              style: const TextStyle(
                  color: AppColors.kWhite, fontSize: 20, fontWeight: FontWeight.bold),
              textAlign: TextAlign.center),
          if (tournament.description != null) ...[
            const SizedBox(height: 8),
            Text(tournament.description!,
                style: const TextStyle(color: AppColors.kGrey, fontSize: 14),
                textAlign: TextAlign.center),
          ],
          const SizedBox(height: 16),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              _pill(_getStatusText(tournament.status), _getStatusColor(tournament.status)),
              const SizedBox(width: 8),
              _pill(_getFormatText(tournament.format), AppColors.kGrey),
            ],
          ),
        ],
      ),
    );
  }

  Widget _pill(String label, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
          color: color.withOpacity(0.15), borderRadius: BorderRadius.circular(8)),
      child: Text(label,
          style:
              TextStyle(color: color, fontSize: 11, fontWeight: FontWeight.bold)),
    );
  }

  Widget _buildInfoCard(String title, List<Widget> children) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
          color: AppColors.kDarkCard, borderRadius: BorderRadius.circular(16)),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(title,
              style: const TextStyle(
                  color: AppColors.kWhite, fontSize: 15, fontWeight: FontWeight.bold)),
          const SizedBox(height: 12),
          ...children,
        ],
      ),
    );
  }

  Widget _infoRow(IconData icon, String label, String value) {
    return Row(
      children: [
        Icon(icon, size: 18, color: AppColors.kYellowAccent),
        const SizedBox(width: 10),
        Text(label, style: const TextStyle(color: AppColors.kGrey, fontSize: 13)),
        const Spacer(),
        Text(value,
            style: const TextStyle(
                color: AppColors.kWhite, fontSize: 13, fontWeight: FontWeight.w600)),
      ],
    );
  }

  Widget _adminButton({
    required String label,
    required IconData icon,
    required Color color,
    VoidCallback? onTap,
  }) {
    return SizedBox(
      width: double.infinity,
      height: 52,
      child: ElevatedButton.icon(
        onPressed: onTap,
        style: ElevatedButton.styleFrom(
          backgroundColor: color,
          foregroundColor: AppColors.kBlack,
          disabledBackgroundColor: AppColors.kGrey.withOpacity(0.3),
          disabledForegroundColor: AppColors.kGrey,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          elevation: 0,
        ),
        icon: Icon(icon),
        label: Text(label,
            style: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold)),
      ),
    );
  }

  // ── Status helpers ────────────────────────────────

  String _getStatusText(TournamentStatus status) {
    switch (status) {
      case TournamentStatus.draft:
        return 'BORRADOR';
      case TournamentStatus.open:
      case TournamentStatus.upcoming:
        return 'ABIERTO';
      case TournamentStatus.started:
      case TournamentStatus.ongoing:
        return 'EN CURSO';
      case TournamentStatus.finished:
      case TournamentStatus.completed:
        return 'FINALIZADO';
      case TournamentStatus.cancelled:
        return 'CANCELADO';
    }
  }

  Color _getStatusColor(TournamentStatus status) {
    switch (status) {
      case TournamentStatus.draft:
        return AppColors.kGrey;
      case TournamentStatus.open:
      case TournamentStatus.upcoming:
        return AppColors.kYellowAccent;
      case TournamentStatus.started:
      case TournamentStatus.ongoing:
        return AppColors.kGreen;
      case TournamentStatus.finished:
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
