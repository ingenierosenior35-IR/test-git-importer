import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:Rival/core/constants/colors.dart';
import 'package:Rival/features/polls/data/models/espn_models.dart';
import 'package:Rival/features/polls/data/datasources/espn_api_service.dart';
import 'football_match_detail_screen.dart';

/// How many weeks ahead to load in the initial fetch.
const _kInitialWeeks = 4;
/// How many additional weeks to load per "load more" tap.
const _kMoreWeeks = 4;
/// Maximum weeks ahead to load (roughly 2 months).
const _kMaxWeeks = 12;

class FootballFixturesScreen extends StatefulWidget {
  final EspnLeague league;

  const FootballFixturesScreen({Key? key, required this.league})
      : super(key: key);

  @override
  State<FootballFixturesScreen> createState() => _FootballFixturesScreenState();
}

class _FootballFixturesScreenState extends State<FootballFixturesScreen> {
  final _service = EspnApiService();
  List<EspnEvent> _events = [];
  bool _loading = true;
  bool _hasError = false;
  bool _loadingMore = false;
  int _weeksLoaded = 0;

  @override
  void initState() {
    super.initState();
    _loadEvents();
  }

  Future<void> _loadEvents() async {
    setState(() {
      _loading = true;
      _hasError = false;
      _weeksLoaded = 0;
      _events = [];
    });
    try {
      final events = await _fetchUpcomingWeeks(_kInitialWeeks);
      if (mounted) {
        setState(() {
          _events = events;
          _weeksLoaded = _kInitialWeeks;
          _loading = false;
        });
      }
    } catch (e) {
      debugPrint('FootballFixturesScreen error: $e');
      if (mounted) {
        setState(() {
          _hasError = true;
          _loading = false;
        });
      }
    }
  }

  Future<void> _loadMore() async {
    if (_loadingMore || _weeksLoaded >= _kMaxWeeks) return;
    setState(() => _loadingMore = true);
    try {
      final more = await _fetchUpcomingWeeks(
        _kMoreWeeks,
        offsetWeeks: _weeksLoaded,
      );
      if (mounted) {
        final seen = _events.map((e) => e.id).toSet();
        setState(() {
          _events.addAll(more.where((e) => !seen.contains(e.id)));
          _weeksLoaded += _kMoreWeeks;
          _loadingMore = false;
        });
      }
    } catch (e) {
      debugPrint('FootballFixturesScreen loadMore error: $e');
      if (mounted) setState(() => _loadingMore = false);
    }
  }

  /// Fetches [count] weeks of upcoming events starting at [offsetWeeks] from now.
  Future<List<EspnEvent>> _fetchUpcomingWeeks(int count,
      {int offsetWeeks = 0}) async {
    final now = DateTime.now();
    final start = now.add(Duration(days: offsetWeeks * 7));
    final raw = await _service.getScoreboardRange(
      widget.league.slug,
      startDate: start,
      weekCount: count,
      stepDays: 7,
    );
    return raw
        .where((e) => e.isScheduled || e.isLive)
        .toList()
      ..sort((a, b) => a.date.compareTo(b.date));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.kDarkBackground,
      appBar: AppBar(
        backgroundColor: AppColors.kDarkBackground,
        title: Text(
          'Próximos: ${widget.league.name}',
          style: const TextStyle(
              color: AppColors.kWhite, fontWeight: FontWeight.bold),
          overflow: TextOverflow.ellipsis,
        ),
        iconTheme: const IconThemeData(color: AppColors.kWhite),
      ),
      body: _buildBody(),
    );
  }

  Widget _buildBody() {
    if (_loading) {
      return const Center(
          child: CircularProgressIndicator(color: AppColors.kYellowAccent));
    }
    if (_hasError) {
      return Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text('Error al cargar los próximos partidos',
                style: TextStyle(color: AppColors.kWhite)),
            const SizedBox(height: 12),
            ElevatedButton(
              onPressed: _loadEvents,
              style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.kYellowAccent),
              child: const Text('Reintentar',
                  style: TextStyle(color: AppColors.kBlack)),
            ),
          ],
        ),
      );
    }
    if (_events.isEmpty) {
      return const Center(
        child: Text('No hay próximos partidos disponibles',
            style: TextStyle(color: AppColors.kGreyLight)),
      );
    }
    return ListView.builder(
      padding: const EdgeInsets.all(12),
      itemCount: _events.length + 1,
      itemBuilder: (context, index) {
        if (index == _events.length) {
          return _buildLoadMoreButton();
        }
        final event = _events[index];
        return _FixtureCard(
          event: event,
          onTap: () => Navigator.push(
            context,
            MaterialPageRoute(
              builder: (_) => FootballMatchDetailScreen(
                event: event,
                leagueSlug: widget.league.slug,
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildLoadMoreButton() {
    if (_weeksLoaded >= _kMaxWeeks) return const SizedBox.shrink();
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 16),
      child: Center(
        child: _loadingMore
            ? const CircularProgressIndicator(color: AppColors.kYellowAccent)
            : OutlinedButton(
                onPressed: _loadMore,
                style: OutlinedButton.styleFrom(
                  side: const BorderSide(color: AppColors.kYellowAccent),
                ),
                child: const Text('Cargar más',
                    style: TextStyle(color: AppColors.kYellowAccent)),
              ),
      ),
    );
  }
}

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
                  _TeamBlock(team: event.homeTeam, align: CrossAxisAlignment.end),
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
                  _TeamBlock(team: event.awayTeam, align: CrossAxisAlignment.start),
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
    final dayName = days[local.weekday - 1];
    final monthName = months[local.month - 1];
    return '$dayName ${local.day} $monthName  '
        '${local.hour.toString().padLeft(2, '0')}:${local.minute.toString().padLeft(2, '0')}';
  }
}

class _TeamBlock extends StatelessWidget {
  final EspnTeam team;
  final CrossAxisAlignment align;

  const _TeamBlock({required this.team, required this.align});

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
              width: 36,
              height: 36,
              errorWidget: (_, __, ___) => const Icon(
                Icons.sports_soccer,
                color: AppColors.kYellowAccent,
                size: 28,
              ),
            )
          else
            const Icon(Icons.sports_soccer,
                color: AppColors.kYellowAccent, size: 28),
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
