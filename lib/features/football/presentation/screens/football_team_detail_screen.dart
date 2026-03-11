import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:intl/intl.dart';
import 'package:Rival/core/constants/colors.dart';
import 'package:Rival/features/polls/data/models/espn_models.dart';
import 'package:Rival/features/polls/data/datasources/espn_api_service.dart';
import 'package:Rival/features/football/data/models/favorite_team_model.dart';
import 'package:Rival/features/football/services/firestore_favorites_service.dart';
import 'football_match_detail_screen.dart';

class FootballTeamDetailScreen extends StatefulWidget {
  final EspnTeam team;
  final String leagueSlug;

  const FootballTeamDetailScreen({
    Key? key,
    required this.team,
    required this.leagueSlug,
  }) : super(key: key);

  @override
  State<FootballTeamDetailScreen> createState() =>
      _FootballTeamDetailScreenState();
}

class _FootballTeamDetailScreenState extends State<FootballTeamDetailScreen>
    with SingleTickerProviderStateMixin {
  final _service = EspnApiService();
  late TabController _tabController;

  // Data
  List<EspnEvent> _schedule = [];
  EspnStandings? _standings;
  EspnRoster? _roster;

  bool _loadingSchedule = true;
  bool _loadingStandings = true;
  bool _loadingRoster = true;
  bool _isFavorite = false;

  late final DateFormat _dateFormat;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 4, vsync: this);
    _dateFormat = DateFormat('dd MMM yyyy', 'es');
    _loadAll();
    _checkFavorite();
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  Future<void> _loadAll() async {
    _loadSchedule();
    _loadStandings();
    _loadRoster();
  }

  Future<void> _checkFavorite() async {
    final fav = await FirestoreFavoritesService.isFavorite(
        widget.leagueSlug, widget.team.id);
    if (mounted) setState(() => _isFavorite = fav);
  }

  Future<void> _loadSchedule() async {
    setState(() => _loadingSchedule = true);
    try {
      final events =
          await _service.getTeamSchedule(widget.leagueSlug, widget.team.id);
      if (mounted) setState(() => _schedule = events);
    } catch (e) {
      debugPrint('TeamDetail schedule error: $e');
    } finally {
      if (mounted) setState(() => _loadingSchedule = false);
    }
  }

  Future<void> _loadStandings() async {
    setState(() => _loadingStandings = true);
    try {
      final standings = await _service.getStandings(widget.leagueSlug);
      if (mounted) setState(() => _standings = standings);
    } catch (e) {
      debugPrint('TeamDetail standings error: $e');
    } finally {
      if (mounted) setState(() => _loadingStandings = false);
    }
  }

  Future<void> _loadRoster() async {
    setState(() => _loadingRoster = true);
    try {
      final roster = await _service.getTeamRoster(
          widget.leagueSlug, widget.team.id);
      if (mounted) setState(() => _roster = roster);
    } catch (e) {
      debugPrint('TeamDetail roster error: $e');
    } finally {
      if (mounted) setState(() => _loadingRoster = false);
    }
  }

  Future<void> _toggleFavorite() async {
    final added = await FirestoreFavoritesService.toggleFavorite(
      league: widget.leagueSlug,
      teamId: widget.team.id,
      name: widget.team.displayName,
      logoUrl: widget.team.logoUrl,
    );
    if (mounted) setState(() => _isFavorite = added);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.kDarkBackground,
      appBar: AppBar(
        backgroundColor: AppColors.kDarkBackground,
        title: Text(
          widget.team.displayName,
          style: const TextStyle(
              color: AppColors.kWhite, fontWeight: FontWeight.bold),
          overflow: TextOverflow.ellipsis,
        ),
        iconTheme: const IconThemeData(color: AppColors.kWhite),
        actions: [
          IconButton(
            icon: Icon(
              _isFavorite ? Icons.star : Icons.star_border,
              color: AppColors.kYellowAccent,
            ),
            tooltip: _isFavorite ? 'Quitar de favoritos' : 'Agregar a favoritos',
            onPressed: _toggleFavorite,
          ),
        ],
        bottom: TabBar(
          controller: _tabController,
          indicatorColor: AppColors.kYellowAccent,
          labelColor: AppColors.kYellowAccent,
          unselectedLabelColor: AppColors.kGrey,
          isScrollable: true,
          labelStyle:
              const TextStyle(fontWeight: FontWeight.bold, fontSize: 12),
          tabs: const [
            Tab(text: 'RESULTADOS'),
            Tab(text: 'PRÓXIMOS'),
            Tab(text: 'TABLA'),
            Tab(text: 'PLANTILLA'),
          ],
        ),
      ),
      body: Column(
        children: [
          _buildTeamHeader(),
          Expanded(
            child: TabBarView(
              controller: _tabController,
              children: [
                _buildResults(),
                _buildUpcoming(),
                _buildStandings(),
                _buildRoster(),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTeamHeader() {
    return Container(
      color: AppColors.kDarkCard,
      padding: const EdgeInsets.all(20),
      child: Row(
        children: [
          if (widget.team.logoUrl != null && widget.team.logoUrl!.isNotEmpty)
            CachedNetworkImage(
              imageUrl: widget.team.logoUrl!,
              width: 64,
              height: 64,
              errorWidget: (_, __, ___) => const Icon(
                Icons.sports_soccer,
                color: AppColors.kYellowAccent,
                size: 48,
              ),
            )
          else
            const Icon(Icons.sports_soccer,
                color: AppColors.kYellowAccent, size: 48),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  widget.team.displayName,
                  style: const TextStyle(
                      color: AppColors.kWhite,
                      fontSize: 20,
                      fontWeight: FontWeight.bold),
                ),
                if (widget.team.abbreviation.isNotEmpty)
                  Text(
                    widget.team.abbreviation,
                    style: const TextStyle(
                        color: AppColors.kGreyLight, fontSize: 14),
                  ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // ─── Tab 1: Results ───────────────────────────────────────────────────────

  Widget _buildResults() {
    if (_loadingSchedule) {
      return const Center(
          child: CircularProgressIndicator(color: AppColors.kYellowAccent));
    }
    final past = _schedule
        .where((e) => e.isFinished)
        .toList()
      ..sort((a, b) => b.date.compareTo(a.date));
    if (past.isEmpty) {
      return const _EmptyState(message: 'No hay resultados disponibles');
    }
    return RefreshIndicator(
      color: AppColors.kYellowAccent,
      onRefresh: _loadSchedule,
      child: ListView.builder(
        padding: const EdgeInsets.all(12),
        itemCount: past.length,
        itemBuilder: (context, index) => _ScheduleCard(
          event: past[index],
          leagueSlug: widget.leagueSlug,
          dateFormat: _dateFormat,
        ),
      ),
    );
  }

  // ─── Tab 2: Upcoming ─────────────────────────────────────────────────────

  Widget _buildUpcoming() {
    if (_loadingSchedule) {
      return const Center(
          child: CircularProgressIndicator(color: AppColors.kYellowAccent));
    }
    final upcoming = _schedule
        .where((e) => e.isScheduled || e.isLive)
        .toList()
      ..sort((a, b) => a.date.compareTo(b.date));
    if (upcoming.isEmpty) {
      return const _EmptyState(message: 'No hay próximos partidos');
    }
    return RefreshIndicator(
      color: AppColors.kYellowAccent,
      onRefresh: _loadSchedule,
      child: ListView.builder(
        padding: const EdgeInsets.all(12),
        itemCount: upcoming.length,
        itemBuilder: (context, index) => _ScheduleCard(
          event: upcoming[index],
          leagueSlug: widget.leagueSlug,
          dateFormat: _dateFormat,
        ),
      ),
    );
  }

  // ─── Tab 3: Standings ────────────────────────────────────────────────────

  Widget _buildStandings() {
    if (_loadingStandings) {
      return const Center(
          child: CircularProgressIndicator(color: AppColors.kYellowAccent));
    }
    if (_standings == null || _standings!.entries.isEmpty) {
      return const _EmptyState(message: 'Tabla no disponible');
    }
    final entries = _standings!.entries;
    return RefreshIndicator(
      color: AppColors.kYellowAccent,
      onRefresh: _loadStandings,
      child: ListView.builder(
        padding: const EdgeInsets.fromLTRB(8, 12, 8, 12),
        itemCount: entries.length + 1,
        itemBuilder: (context, index) {
          if (index == 0) return _buildStandingsHeader();
          final entry = entries[index - 1];
          final isCurrentTeam = entry.teamId == widget.team.id;
          return _StandingRow(
            entry: entry,
            position: index,
            isHighlighted: isCurrentTeam,
          );
        },
      ),
    );
  }

  Widget _buildStandingsHeader() {
    const style =
        TextStyle(color: AppColors.kGreyLight, fontSize: 11, fontWeight: FontWeight.bold);
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6, horizontal: 4),
      child: Row(
        children: const [
          SizedBox(width: 28, child: Text('#', style: style, textAlign: TextAlign.center)),
          SizedBox(width: 32),
          Expanded(child: Text('EQUIPO', style: style)),
          SizedBox(width: 28, child: Text('PJ', style: style, textAlign: TextAlign.center)),
          SizedBox(width: 24, child: Text('G', style: style, textAlign: TextAlign.center)),
          SizedBox(width: 24, child: Text('E', style: style, textAlign: TextAlign.center)),
          SizedBox(width: 24, child: Text('P', style: style, textAlign: TextAlign.center)),
          SizedBox(width: 32, child: Text('DG', style: style, textAlign: TextAlign.center)),
          SizedBox(width: 32, child: Text('PTS', style: style, textAlign: TextAlign.center)),
        ],
      ),
    );
  }

  // ─── Tab 4: Roster ───────────────────────────────────────────────────────

  Widget _buildRoster() {
    if (_loadingRoster) {
      return const Center(
          child: CircularProgressIndicator(color: AppColors.kYellowAccent));
    }
    if (_roster == null || _roster!.players.isEmpty) {
      return const _EmptyState(message: 'Plantilla no disponible');
    }
    return RefreshIndicator(
      color: AppColors.kYellowAccent,
      onRefresh: _loadRoster,
      child: ListView.builder(
        padding: const EdgeInsets.all(12),
        itemCount: _roster!.players.length,
        itemBuilder: (context, index) {
          final player = _roster!.players[index];
          return _PlayerRow(player: player);
        },
      ),
    );
  }
}

// ─── Shared Widgets ──────────────────────────────────────────────────────────

class _EmptyState extends StatelessWidget {
  final String message;
  const _EmptyState({required this.message});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Text(message,
          style: const TextStyle(color: AppColors.kGreyLight, fontSize: 14)),
    );
  }
}

class _ScheduleCard extends StatelessWidget {
  final EspnEvent event;
  final String leagueSlug;
  final DateFormat dateFormat;

  const _ScheduleCard({
    required this.event,
    required this.leagueSlug,
    required this.dateFormat,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      color: AppColors.kDarkCard,
      margin: const EdgeInsets.symmetric(vertical: 5),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      child: InkWell(
        borderRadius: BorderRadius.circular(10),
        onTap: () => Navigator.push(
          context,
          MaterialPageRoute(
            builder: (_) => FootballMatchDetailScreen(
              event: event,
              leagueSlug: leagueSlug,
            ),
          ),
        ),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
          child: Row(
            children: [
              Expanded(
                child: Text(
                  event.homeTeam.displayName,
                  textAlign: TextAlign.end,
                  style: const TextStyle(color: AppColors.kWhite, fontSize: 12),
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 10),
                child: Column(
                  children: [
                    Text(
                      event.homeScore != null && event.awayScore != null
                          ? '${event.homeScore} - ${event.awayScore}'
                          : 'vs',
                      style: const TextStyle(
                          color: AppColors.kYellowAccent,
                          fontSize: 16,
                          fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      dateFormat.format(event.date.toLocal()),
                      style: const TextStyle(
                          color: AppColors.kGreyLight, fontSize: 10),
                    ),
                  ],
                ),
              ),
              Expanded(
                child: Text(
                  event.awayTeam.displayName,
                  textAlign: TextAlign.start,
                  style: const TextStyle(color: AppColors.kWhite, fontSize: 12),
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _StandingRow extends StatelessWidget {
  final EspnStandingEntry entry;
  final int position;
  final bool isHighlighted;

  const _StandingRow({
    required this.entry,
    required this.position,
    required this.isHighlighted,
  });

  @override
  Widget build(BuildContext context) {
    const style = TextStyle(color: AppColors.kWhite, fontSize: 12);
    const centerStyle =
        TextStyle(color: AppColors.kWhite, fontSize: 12);

    return Container(
      padding: const EdgeInsets.symmetric(vertical: 6, horizontal: 4),
      margin: const EdgeInsets.symmetric(vertical: 1),
      decoration: BoxDecoration(
        color: isHighlighted
            ? AppColors.kYellowAccent.withOpacity(0.12)
            : Colors.transparent,
        borderRadius: BorderRadius.circular(6),
        border: isHighlighted
            ? Border.all(color: AppColors.kYellowAccent.withOpacity(0.4))
            : null,
      ),
      child: Row(
        children: [
          SizedBox(
            width: 28,
            child: Text(
              '$position',
              textAlign: TextAlign.center,
              style: TextStyle(
                color: isHighlighted
                    ? AppColors.kYellowAccent
                    : AppColors.kGreyLight,
                fontSize: 12,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          SizedBox(
            width: 32,
            height: 24,
            child: entry.teamLogo != null && entry.teamLogo!.isNotEmpty
                ? CachedNetworkImage(
                    imageUrl: entry.teamLogo!,
                    errorWidget: (_, __, ___) => const Icon(
                      Icons.sports_soccer,
                      color: AppColors.kGrey,
                      size: 16,
                    ),
                  )
                : const Icon(Icons.sports_soccer,
                    color: AppColors.kGrey, size: 16),
          ),
          Expanded(
            child: Text(
              entry.teamName,
              style: style,
              overflow: TextOverflow.ellipsis,
            ),
          ),
          SizedBox(
              width: 28,
              child: Text('${entry.played}',
                  textAlign: TextAlign.center, style: centerStyle)),
          SizedBox(
              width: 24,
              child: Text('${entry.won}',
                  textAlign: TextAlign.center, style: centerStyle)),
          SizedBox(
              width: 24,
              child: Text('${entry.drawn}',
                  textAlign: TextAlign.center, style: centerStyle)),
          SizedBox(
              width: 24,
              child: Text('${entry.lost}',
                  textAlign: TextAlign.center, style: centerStyle)),
          SizedBox(
            width: 32,
            child: Text(
              '${entry.goalDifference >= 0 ? '+' : ''}${entry.goalDifference}',
              textAlign: TextAlign.center,
              style: TextStyle(
                color: entry.goalDifference > 0
                    ? Colors.green
                    : entry.goalDifference < 0
                        ? AppColors.kRed
                        : AppColors.kWhite,
                fontSize: 12,
              ),
            ),
          ),
          SizedBox(
            width: 32,
            child: Text(
              '${entry.points}',
              textAlign: TextAlign.center,
              style: TextStyle(
                color: isHighlighted
                    ? AppColors.kYellowAccent
                    : AppColors.kWhite,
                fontSize: 12,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _PlayerRow extends StatelessWidget {
  final EspnPlayer player;
  const _PlayerRow({required this.player});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 10),
      decoration: const BoxDecoration(
        border: Border(
          bottom: BorderSide(color: AppColors.kDarkSurface, width: 0.5),
        ),
      ),
      child: Row(
        children: [
          if (player.number != null)
            SizedBox(
              width: 32,
              child: Text(
                player.number!,
                textAlign: TextAlign.center,
                style: const TextStyle(
                    color: AppColors.kGreyLight,
                    fontSize: 13,
                    fontWeight: FontWeight.bold),
              ),
            ),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              player.name,
              style: const TextStyle(
                  color: AppColors.kWhite,
                  fontSize: 14,
                  fontWeight: FontWeight.w500),
            ),
          ),
          if (player.position != null)
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
              decoration: BoxDecoration(
                color: AppColors.kDarkSurface,
                borderRadius: BorderRadius.circular(6),
              ),
              child: Text(
                player.position!,
                style: const TextStyle(
                    color: AppColors.kGreyLight, fontSize: 11),
              ),
            ),
          if (player.nationality != null) ...[
            const SizedBox(width: 8),
            Text(
              player.nationality!,
              style: const TextStyle(
                  color: AppColors.kGrey, fontSize: 11),
            ),
          ],
        ],
      ),
    );
  }
}
