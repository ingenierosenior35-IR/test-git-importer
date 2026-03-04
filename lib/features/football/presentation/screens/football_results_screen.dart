import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:Rival/core/constants/colors.dart';
import 'package:Rival/features/polls/data/models/espn_models.dart';
import 'package:Rival/features/polls/data/datasources/espn_api_service.dart';
import 'football_match_detail_screen.dart';

/// Number of weeks to load on initial fetch (going back from today).
const _kInitialWeeks = 4;
/// Weeks per "load more" page.
const _kMoreWeeks = 4;
/// Maximum weeks back to load (≈2 years).
const _kMaxWeeks = 104;

class FootballResultsScreen extends StatefulWidget {
  final EspnLeague league;

  const FootballResultsScreen({Key? key, required this.league})
      : super(key: key);

  @override
  State<FootballResultsScreen> createState() => _FootballResultsScreenState();
}

class _FootballResultsScreenState extends State<FootballResultsScreen> {
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
      final events = await _fetchPastWeeks(_kInitialWeeks, offsetWeeks: 0);
      if (mounted) {
        setState(() {
          _events = events;
          _weeksLoaded = _kInitialWeeks;
          _loading = false;
        });
      }
    } catch (e) {
      debugPrint('FootballResultsScreen error: $e');
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
      final more = await _fetchPastWeeks(_kMoreWeeks, offsetWeeks: _weeksLoaded);
      if (mounted) {
        final seen = _events.map((e) => e.id).toSet();
        setState(() {
          _events.addAll(more.where((e) => !seen.contains(e.id)));
          _weeksLoaded += _kMoreWeeks;
          _loadingMore = false;
        });
      }
    } catch (e) {
      debugPrint('FootballResultsScreen loadMore error: $e');
      if (mounted) setState(() => _loadingMore = false);
    }
  }

  /// Fetches [count] weeks of past results starting at [offsetWeeks] ago.
  Future<List<EspnEvent>> _fetchPastWeeks(int count,
      {required int offsetWeeks}) async {
    final now = DateTime.now();
    // Start from [offsetWeeks] ago and go further back.
    final startAnchor = now.subtract(Duration(days: offsetWeeks * 7));
    final raw = await _service.getScoreboardRange(
      widget.league.slug,
      startDate: startAnchor,
      weekCount: count,
      stepDays: -7,
    );
    return raw
        .where((e) => e.isFinished || e.isLive)
        .toList()
      ..sort((a, b) => b.date.compareTo(a.date)); // newest first
  }

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
            const Text('Error al cargar los resultados',
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
        child: Text('No hay resultados disponibles',
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
        return _MatchCard(
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
            textAlign: align == CrossAxisAlignment.end
                ? TextAlign.end
                : TextAlign.start,
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

