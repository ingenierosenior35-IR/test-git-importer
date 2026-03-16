import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:Rival/core/constants/colors.dart';
import 'package:Rival/features/polls/data/models/espn_models.dart';
import 'package:Rival/features/polls/data/datasources/espn_api_service.dart';
import 'football_match_detail_screen.dart';
import 'football_team_detail_screen.dart';

/// Unified league detail screen: Results / Upcoming / Equipos / Tabla in one place.
class FootballLeagueDetailScreen extends StatefulWidget {
  final EspnLeague league;

  const FootballLeagueDetailScreen({Key? key, required this.league})
      : super(key: key);

  @override
  State<FootballLeagueDetailScreen> createState() =>
      _FootballLeagueDetailScreenState();
}

class _FootballLeagueDetailScreenState
    extends State<FootballLeagueDetailScreen>
    with SingleTickerProviderStateMixin {
  final _service = EspnApiService();
  late TabController _tabController;

  // Results (past)
  List<EspnEvent> _results = [];
  bool _loadingResults = true;

  // Upcoming (future)
  List<EspnEvent> _upcoming = [];
  bool _loadingUpcoming = true;

  /// Month (1-based) from which a soccer season is considered to have started.
  /// NOTE: This assumes Northern Hemisphere leagues (Aug-Jun). For Southern
  /// Hemisphere or differently structured leagues the results may be incomplete.
  static const int _kSeasonStartMonth = 8;
  static const int _kMaxWeeksBack = 50;
  static const int _kMaxWeeksAhead = 40;

  // Teams
  List<EspnTeam> _teams = [];
  bool _loadingTeams = true;

  // Standings
  EspnStandings? _standings;
  bool _loadingStandings = true;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 4, vsync: this);
    _loadResults();
    _loadUpcoming();
    _loadTeams();
    _loadStandings();
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  // ─── Results ─────────────────────────────────────────────────────────────

  Future<void> _loadResults() async {
    setState(() {
      _loadingResults = true;
      _results = [];
    });
    final now = DateTime.now();
    final seasonStartYear = now.month >= _kSeasonStartMonth ? now.year : now.year - 1;
    final seasonStart = DateTime(seasonStartYear, _kSeasonStartMonth, 1);
    final weeksBack = (now.difference(seasonStart).inDays / 7).ceil().clamp(1, _kMaxWeeksBack);
    final events = await _service.getScoreboardRangeParallel(
      widget.league.slug,
      startDate: seasonStart,
      weekCount: weeksBack,
      stepDays: 7,
    );
    if (mounted) {
      setState(() {
        _results = events
            .where((e) => e.isFinished || e.isLive)
            .toList()
          ..sort((a, b) => b.date.compareTo(a.date));
        _loadingResults = false;
      });
    }
  }

  // ─── Upcoming ────────────────────────────────────────────────────────────

  Future<void> _loadUpcoming() async {
    setState(() {
      _loadingUpcoming = true;
      _upcoming = [];
    });
    final now = DateTime.now();
    final seasonStartYear = now.month >= _kSeasonStartMonth ? now.year : now.year - 1;
    final seasonEnd = DateTime(seasonStartYear + 1, 6, 1);
    final weeksAhead = (seasonEnd.difference(now).inDays / 7).ceil().clamp(1, _kMaxWeeksAhead);
    final events = await _service.getScoreboardRangeParallel(
      widget.league.slug,
      startDate: now,
      weekCount: weeksAhead,
      stepDays: 7,
    );
    if (mounted) {
      setState(() {
        _upcoming = events
            .where((e) => e.isScheduled)
            .toList()
          ..sort((a, b) => a.date.compareTo(b.date));
        _loadingUpcoming = false;
      });
    }
  }

  // ─── Teams ───────────────────────────────────────────────────────────────

  Future<void> _loadTeams() async {
    setState(() => _loadingTeams = true);
    final teams = await _service.getTeams(widget.league.slug);
    if (mounted) {
      setState(() {
        _teams = teams;
        _loadingTeams = false;
      });
    }
  }

  // ─── Standings ───────────────────────────────────────────────────────────

  Future<void> _loadStandings() async {
    setState(() => _loadingStandings = true);
    final standings = await _service.getStandings(widget.league.slug);
    if (mounted) {
      setState(() {
        _standings = standings;
        _loadingStandings = false;
      });
    }
  }

  // ─── Build ───────────────────────────────────────────────────────────────

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.kDarkBackground,
      appBar: AppBar(
        backgroundColor: AppColors.kDarkBackground,
        title: Text(
          widget.league.name,
          style: const TextStyle(
              color: AppColors.kWhite, fontWeight: FontWeight.bold),
          overflow: TextOverflow.ellipsis,
        ),
        iconTheme: const IconThemeData(color: AppColors.kWhite),
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
            Tab(text: 'EQUIPOS'),
            Tab(text: 'TABLA'),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          _buildResults(),
          _buildUpcoming(),
          _buildTeams(),
          _buildStandings(),
        ],
      ),
    );
  }

  // ─── Results Tab ─────────────────────────────────────────────────────────

  Widget _buildResults() {
    if (_loadingResults) {
      return const Center(
          child: CircularProgressIndicator(color: AppColors.kYellowAccent));
    }
    if (_results.isEmpty) {
      return _buildEmptyWithRetry(
          'No hay resultados disponibles', _loadResults);
    }
    return RefreshIndicator(
      color: AppColors.kYellowAccent,
      onRefresh: _loadResults,
      child: ListView.builder(
        padding: const EdgeInsets.all(12),
        itemCount: _results.length,
        itemBuilder: (context, index) => _MatchCard(
          event: _results[index],
          onTap: () => _openMatchDetail(_results[index]),
        ),
      ),
    );
  }

  // ─── Upcoming Tab ────────────────────────────────────────────────────────

  Widget _buildUpcoming() {
    if (_loadingUpcoming) {
      return const Center(
          child: CircularProgressIndicator(color: AppColors.kYellowAccent));
    }
    if (_upcoming.isEmpty) {
      return _buildEmptyWithRetry(
          'No hay próximos partidos', _loadUpcoming);
    }
    return RefreshIndicator(
      color: AppColors.kYellowAccent,
      onRefresh: _loadUpcoming,
      child: ListView.builder(
        padding: const EdgeInsets.all(12),
        itemCount: _upcoming.length,
        itemBuilder: (context, index) => _FixtureCard(
          event: _upcoming[index],
          onTap: () => _openMatchDetail(_upcoming[index]),
        ),
      ),
    );
  }

  // ─── Teams Tab ───────────────────────────────────────────────────────────

  Widget _buildTeams() {
    if (_loadingTeams) {
      return const Center(
          child: CircularProgressIndicator(color: AppColors.kYellowAccent));
    }
    if (_teams.isEmpty) {
      return _buildEmptyWithRetry('No hay equipos disponibles', _loadTeams);
    }
    return RefreshIndicator(
      color: AppColors.kYellowAccent,
      onRefresh: _loadTeams,
      child: GridView.builder(
        padding: const EdgeInsets.all(12),
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 3,
          crossAxisSpacing: 8,
          mainAxisSpacing: 8,
          childAspectRatio: 0.85,
        ),
        itemCount: _teams.length,
        itemBuilder: (context, index) {
          final team = _teams[index];
          return _TeamCard(
            team: team,
            onTap: () => Navigator.push(
              context,
              MaterialPageRoute(
                builder: (_) => FootballTeamDetailScreen(
                  team: team,
                  leagueSlug: widget.league.slug,
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  // ─── Standings Tab ───────────────────────────────────────────────────────

  Widget _buildStandings() {
    if (_loadingStandings) {
      return const Center(
          child: CircularProgressIndicator(color: AppColors.kYellowAccent));
    }
    if (_standings == null || _standings!.entries.isEmpty) {
      return _buildEmptyWithRetry('Tabla no disponible', _loadStandings);
    }
    final entries = _standings!.entries;
    const kRankW = 28.0;
    const kLogoW = 32.0;
    const kNumW = 28.0;
    const kPtsW = 32.0;

    return RefreshIndicator(
      color: AppColors.kYellowAccent,
      onRefresh: _loadStandings,
      child: ListView(
        padding: const EdgeInsets.all(12),
        children: [
          // Header row
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
            child: Row(
              children: [
                SizedBox(
                    width: kRankW,
                    child: const Text('#',
                        style: TextStyle(
                            color: AppColors.kGrey,
                            fontSize: 11,
                            fontWeight: FontWeight.bold),
                        textAlign: TextAlign.center)),
                SizedBox(width: kLogoW),
                const Expanded(
                    child: Text('Equipo',
                        style: TextStyle(
                            color: AppColors.kGrey,
                            fontSize: 11,
                            fontWeight: FontWeight.bold))),
                SizedBox(
                    width: kNumW,
                    child: const Text('PJ',
                        style: TextStyle(color: AppColors.kGrey, fontSize: 11),
                        textAlign: TextAlign.center)),
                SizedBox(
                    width: kNumW,
                    child: const Text('G',
                        style: TextStyle(color: AppColors.kGrey, fontSize: 11),
                        textAlign: TextAlign.center)),
                SizedBox(
                    width: kNumW,
                    child: const Text('E',
                        style: TextStyle(color: AppColors.kGrey, fontSize: 11),
                        textAlign: TextAlign.center)),
                SizedBox(
                    width: kNumW,
                    child: const Text('P',
                        style: TextStyle(color: AppColors.kGrey, fontSize: 11),
                        textAlign: TextAlign.center)),
                SizedBox(
                    width: kNumW,
                    child: const Text('DG',
                        style: TextStyle(color: AppColors.kGrey, fontSize: 11),
                        textAlign: TextAlign.center)),
                SizedBox(
                    width: kPtsW,
                    child: const Text('PTS',
                        style: TextStyle(
                            color: AppColors.kYellowAccent,
                            fontSize: 11,
                            fontWeight: FontWeight.bold),
                        textAlign: TextAlign.center)),
              ],
            ),
          ),
          const Divider(color: AppColors.kDarkSurface),
          ...List.generate(entries.length, (i) {
            final e = entries[i];
            return Container(
              margin: const EdgeInsets.symmetric(vertical: 2),
              padding:
                  const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
              decoration: BoxDecoration(
                color: AppColors.kDarkCard,
                borderRadius: BorderRadius.circular(8),
              ),
              child: Row(
                children: [
                  SizedBox(
                    width: kRankW,
                    child: Text(
                      '${i + 1}',
                      textAlign: TextAlign.center,
                      style: const TextStyle(
                          color: AppColors.kGreyLight,
                          fontSize: 12,
                          fontWeight: FontWeight.bold),
                    ),
                  ),
                  SizedBox(
                    width: kLogoW,
                    height: kLogoW,
                    child: e.teamLogo != null && e.teamLogo!.isNotEmpty
                        ? CachedNetworkImage(
                            imageUrl: e.teamLogo!,
                            errorWidget: (_, __, ___) => const Icon(
                              Icons.sports_soccer,
                              color: AppColors.kGrey,
                              size: 18,
                            ),
                          )
                        : const Icon(Icons.sports_soccer,
                            color: AppColors.kGrey, size: 18),
                  ),
                  const SizedBox(width: 6),
                  Expanded(
                    child: Text(
                      e.teamName,
                      style: const TextStyle(
                          color: AppColors.kWhite, fontSize: 12),
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                  _numCell(e.played, kNumW),
                  _numCell(e.won, kNumW),
                  _numCell(e.drawn, kNumW),
                  _numCell(e.lost, kNumW),
                  _numCell(e.goalDifference, kNumW,
                      signed: true),
                  SizedBox(
                    width: kPtsW,
                    child: Text(
                      '${e.points}',
                      textAlign: TextAlign.center,
                      style: const TextStyle(
                          color: AppColors.kYellowAccent,
                          fontSize: 13,
                          fontWeight: FontWeight.bold),
                    ),
                  ),
                ],
              ),
            );
          }),
        ],
      ),
    );
  }

  // ─── Helpers ─────────────────────────────────────────────────────────────

  void _openMatchDetail(EspnEvent event) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => FootballMatchDetailScreen(
          event: event,
          leagueSlug: widget.league.slug,
        ),
      ),
    );
  }

  Widget _numCell(int value, double width, {bool signed = false}) {
    final text = signed && value > 0 ? '+$value' : '$value';
    return SizedBox(
      width: width,
      child: Text(
        text,
        textAlign: TextAlign.center,
        style: const TextStyle(color: AppColors.kGreyLight, fontSize: 12),
      ),
    );
  }

  Widget _buildEmptyWithRetry(String message, VoidCallback onRetry) {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(message,
              style: const TextStyle(color: AppColors.kGreyLight),
              textAlign: TextAlign.center),
          const SizedBox(height: 12),
          OutlinedButton(
            onPressed: onRetry,
            style: OutlinedButton.styleFrom(
                side: const BorderSide(color: AppColors.kYellowAccent)),
            child: const Text('Reintentar',
                style: TextStyle(color: AppColors.kYellowAccent)),
          ),
        ],
      ),
    );
  }
}

// ─── Match card (finished result) ─────────────────────────────────────────

class _MatchCard extends StatelessWidget {
  final EspnEvent event;
  final VoidCallback onTap;

  const _MatchCard({required this.event, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return Card(
      color: AppColors.kDarkCard,
      margin: const EdgeInsets.symmetric(vertical: 6),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
          child: Column(
            children: [
              Row(
                children: [
                  _TeamLogoName(
                      team: event.homeTeam,
                      align: CrossAxisAlignment.end),
                  Expanded(
                    flex: 2,
                    child: Column(
                      children: [
                        Text(
                          event.homeScore != null && event.awayScore != null
                              ? '${event.homeScore} - ${event.awayScore}'
                              : 'vs',
                          style: const TextStyle(
                            color: AppColors.kYellowAccent,
                            fontWeight: FontWeight.bold,
                            fontSize: 18,
                          ),
                          textAlign: TextAlign.center,
                        ),
                        const SizedBox(height: 4),
                        _StatusChip(status: event.status),
                        const SizedBox(height: 4),
                        Text(
                          _formatDate(event.date),
                          style: const TextStyle(
                              color: AppColors.kGreyLight, fontSize: 10),
                          textAlign: TextAlign.center,
                        ),
                      ],
                    ),
                  ),
                  _TeamLogoName(
                      team: event.awayTeam,
                      align: CrossAxisAlignment.start),
                ],
              ),
              if (event.venue != null && event.venue!.isNotEmpty)
                Padding(
                  padding: const EdgeInsets.only(top: 6),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Icon(Icons.stadium_outlined,
                          color: AppColors.kGreyLight, size: 12),
                      const SizedBox(width: 4),
                      Flexible(
                        child: Text(
                          event.venue!,
                          style: const TextStyle(
                              color: AppColors.kGreyLight, fontSize: 11),
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ],
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }

  String _formatDate(DateTime date) {
    final local = date.toLocal();
    final months = [
      'ene', 'feb', 'mar', 'abr', 'may', 'jun',
      'jul', 'ago', 'sep', 'oct', 'nov', 'dic'
    ];
    return '${local.day} ${months[local.month - 1]} ${local.year}  '
        '${local.hour.toString().padLeft(2, '0')}:${local.minute.toString().padLeft(2, '0')}';
  }
}

// ─── Fixture card (upcoming) ──────────────────────────────────────────────

class _FixtureCard extends StatelessWidget {
  final EspnEvent event;
  final VoidCallback onTap;

  const _FixtureCard({required this.event, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return Card(
      color: AppColors.kDarkCard,
      margin: const EdgeInsets.symmetric(vertical: 6),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
          child: Column(
            children: [
              Row(
                children: [
                  _TeamLogoName(
                      team: event.homeTeam,
                      align: CrossAxisAlignment.end),
                  Expanded(
                    flex: 2,
                    child: Column(
                      children: [
                        if (event.isLive)
                          Container(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 6, vertical: 2),
                            decoration: BoxDecoration(
                              color: Colors.green.withOpacity(0.2),
                              borderRadius: BorderRadius.circular(4),
                              border: Border.all(color: Colors.green),
                            ),
                            child: const Text('EN VIVO',
                                style: TextStyle(
                                    color: Colors.green,
                                    fontSize: 10,
                                    fontWeight: FontWeight.bold)),
                          )
                        else
                          const Text('vs',
                              style: TextStyle(
                                  color: AppColors.kYellowAccent,
                                  fontWeight: FontWeight.bold,
                                  fontSize: 16)),
                        const SizedBox(height: 4),
                        Text(
                          _formatDate(event.date),
                          style: const TextStyle(
                              color: AppColors.kGreyLight, fontSize: 11),
                          textAlign: TextAlign.center,
                        ),
                      ],
                    ),
                  ),
                  _TeamLogoName(
                      team: event.awayTeam,
                      align: CrossAxisAlignment.start),
                ],
              ),
              if (event.venue != null && event.venue!.isNotEmpty)
                Padding(
                  padding: const EdgeInsets.only(top: 6),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Icon(Icons.stadium_outlined,
                          color: AppColors.kGreyLight, size: 12),
                      const SizedBox(width: 4),
                      Flexible(
                        child: Text(
                          event.venue!,
                          style: const TextStyle(
                              color: AppColors.kGreyLight, fontSize: 11),
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ],
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }

  String _formatDate(DateTime date) {
    final local = date.toLocal();
    final days = ['Lun', 'Mar', 'Mié', 'Jue', 'Vie', 'Sáb', 'Dom'];
    final months = [
      'ene', 'feb', 'mar', 'abr', 'may', 'jun',
      'jul', 'ago', 'sep', 'oct', 'nov', 'dic'
    ];
    return '${days[local.weekday - 1]} ${local.day} ${months[local.month - 1]}  '
        '${local.hour.toString().padLeft(2, '0')}:${local.minute.toString().padLeft(2, '0')}';
  }
}

// ─── Team card ───────────────────────────────────────────────────────────

class _TeamCard extends StatelessWidget {
  final EspnTeam team;
  final VoidCallback onTap;

  const _TeamCard({required this.team, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Card(
        color: AppColors.kDarkCard,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        child: Padding(
          padding: const EdgeInsets.all(8),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              if (team.logoUrl != null && team.logoUrl!.isNotEmpty)
                CachedNetworkImage(
                  imageUrl: team.logoUrl!,
                  width: 40,
                  height: 40,
                  errorWidget: (_, __, ___) => const Icon(
                    Icons.sports_soccer,
                    color: AppColors.kYellowAccent,
                    size: 32,
                  ),
                )
              else
                const Icon(Icons.sports_soccer,
                    color: AppColors.kYellowAccent, size: 32),
              const SizedBox(height: 6),
              Text(
                team.displayName,
                textAlign: TextAlign.center,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(color: AppColors.kWhite, fontSize: 11),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// ─── Shared widgets ──────────────────────────────────────────────────────

class _TeamLogoName extends StatelessWidget {
  final EspnTeam team;
  final CrossAxisAlignment align;

  const _TeamLogoName({required this.team, required this.align});

  @override
  Widget build(BuildContext context) {
    return Expanded(
      flex: 3,
      child: Column(
        crossAxisAlignment: align,
        children: [
          if (team.logoUrl != null && team.logoUrl!.isNotEmpty)
            CachedNetworkImage(
              imageUrl: team.logoUrl!,
              width: 32,
              height: 32,
              errorWidget: (_, __, ___) => const Icon(
                Icons.sports_soccer,
                color: AppColors.kYellowAccent,
                size: 24,
              ),
            )
          else
            const Icon(Icons.sports_soccer,
                color: AppColors.kYellowAccent, size: 24),
          const SizedBox(height: 4),
          Text(
            team.displayName,
            textAlign:
                align == CrossAxisAlignment.end ? TextAlign.end : TextAlign.start,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
            style: const TextStyle(color: AppColors.kWhite, fontSize: 12),
          ),
        ],
      ),
    );
  }
}

class _StatusChip extends StatelessWidget {
  final String status;

  const _StatusChip({required this.status});

  @override
  Widget build(BuildContext context) {
    Color color;
    String label;
    switch (status) {
      case 'in':
        color = Colors.green;
        label = 'EN VIVO';
        break;
      case 'post':
        color = AppColors.kGrey;
        label = 'FIN';
        break;
      default:
        color = AppColors.kGreyLight;
        label = 'PRÓX';
    }
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
      decoration: BoxDecoration(
        color: color.withOpacity(0.2),
        borderRadius: BorderRadius.circular(4),
        border: Border.all(color: color, width: 1),
      ),
      child: Text(label,
          style: TextStyle(
              color: color, fontSize: 10, fontWeight: FontWeight.bold)),
    );
  }
}
