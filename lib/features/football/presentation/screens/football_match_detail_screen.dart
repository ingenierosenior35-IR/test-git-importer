import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:Rival/core/constants/colors.dart';
import 'package:Rival/features/polls/data/models/espn_models.dart';
import 'package:Rival/features/polls/data/datasources/espn_api_service.dart';

class FootballMatchDetailScreen extends StatefulWidget {
  final EspnEvent event;
  final String leagueSlug;

  const FootballMatchDetailScreen({
    Key? key,
    required this.event,
    required this.leagueSlug,
  }) : super(key: key);

  @override
  State<FootballMatchDetailScreen> createState() => _FootballMatchDetailScreenState();
}

class _FootballMatchDetailScreenState extends State<FootballMatchDetailScreen>
    with SingleTickerProviderStateMixin {
  final _service = EspnApiService();
  EspnMatchDetail? _detail;
  bool _loading = true;
  bool _hasError = false;
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
    _loadDetail();
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  Future<void> _loadDetail() async {
    setState(() {
      _loading = true;
      _hasError = false;
    });
    try {
      final detail = await _service.getMatchDetail(widget.leagueSlug, widget.event.id);
      if (mounted) {
        setState(() {
          _detail = detail;
          _loading = false;
        });
      }
    } catch (e) {
      debugPrint('FootballMatchDetailScreen error: $e');
      if (mounted) {
        setState(() {
          _hasError = true;
          _loading = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final event = _detail?.event ?? widget.event;
    return Scaffold(
      backgroundColor: AppColors.kDarkBackground,
      appBar: AppBar(
        backgroundColor: AppColors.kDarkBackground,
        title: Text(
          event.shortName,
          style: const TextStyle(color: AppColors.kWhite, fontWeight: FontWeight.bold),
          overflow: TextOverflow.ellipsis,
        ),
        iconTheme: const IconThemeData(color: AppColors.kWhite),
        bottom: TabBar(
          controller: _tabController,
          indicatorColor: AppColors.kYellowAccent,
          labelColor: AppColors.kYellowAccent,
          unselectedLabelColor: AppColors.kGrey,
          labelStyle: const TextStyle(fontWeight: FontWeight.bold, fontSize: 12),
          tabs: const [
            Tab(text: 'TIMELINE'),
            Tab(text: 'ESTADÍSTICAS'),
            Tab(text: 'ALINEACIONES'),
          ],
        ),
      ),
      body: Column(
        children: [
          _buildMatchHeader(event),
          if (_loading)
            const Expanded(
              child: Center(
                child: CircularProgressIndicator(color: AppColors.kYellowAccent),
              ),
            )
          else if (_hasError)
            Expanded(child: _buildErrorSection())
          else
            Expanded(
              child: TabBarView(
                controller: _tabController,
                children: [
                  _buildTimeline(),
                  _buildStats(),
                  _buildLineups(event),
                ],
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildMatchHeader(EspnEvent event) {
    return Container(
      color: AppColors.kDarkCard,
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 20),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              Expanded(
                child: Column(
                  children: [
                    if (event.homeTeam.logoUrl != null &&
                        event.homeTeam.logoUrl!.isNotEmpty)
                      CachedNetworkImage(
                        imageUrl: event.homeTeam.logoUrl!,
                        width: 48,
                        height: 48,
                        errorWidget: (_, __, ___) => const Icon(
                          Icons.sports_soccer,
                          color: AppColors.kYellowAccent,
                          size: 36,
                        ),
                      )
                    else
                      const Icon(Icons.sports_soccer,
                          color: AppColors.kYellowAccent, size: 36),
                    const SizedBox(height: 6),
                    Text(
                      event.homeTeam.displayName,
                      textAlign: TextAlign.center,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                          color: AppColors.kWhite,
                          fontSize: 13,
                          fontWeight: FontWeight.bold),
                    ),
                  ],
                ),
              ),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 12),
                child: Column(
                  children: [
                    Text(
                      event.homeScore != null && event.awayScore != null
                          ? '${event.homeScore} - ${event.awayScore}'
                          : 'vs',
                      style: const TextStyle(
                          color: AppColors.kYellowAccent,
                          fontSize: 32,
                          fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 4),
                    _StatusBadge(status: event.status),
                  ],
                ),
              ),
              Expanded(
                child: Column(
                  children: [
                    if (event.awayTeam.logoUrl != null &&
                        event.awayTeam.logoUrl!.isNotEmpty)
                      CachedNetworkImage(
                        imageUrl: event.awayTeam.logoUrl!,
                        width: 48,
                        height: 48,
                        errorWidget: (_, __, ___) => const Icon(
                          Icons.sports_soccer,
                          color: AppColors.kYellowAccent,
                          size: 36,
                        ),
                      )
                    else
                      const Icon(Icons.sports_soccer,
                          color: AppColors.kYellowAccent, size: 36),
                    const SizedBox(height: 6),
                    Text(
                      event.awayTeam.displayName,
                      textAlign: TextAlign.center,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                          color: AppColors.kWhite,
                          fontSize: 13,
                          fontWeight: FontWeight.bold),
                    ),
                  ],
                ),
              ),
            ],
          ),
          if (event.venue != null && event.venue!.isNotEmpty) ...[
            const SizedBox(height: 10),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(Icons.stadium_outlined,
                    color: AppColors.kGreyLight, size: 14),
                const SizedBox(width: 4),
                Flexible(
                  child: Text(
                    event.venue!,
                    style: const TextStyle(
                        color: AppColors.kGreyLight, fontSize: 12),
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ],
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildErrorSection() {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Text('No se pudieron cargar los detalles del partido',
              style: TextStyle(color: AppColors.kGreyLight),
              textAlign: TextAlign.center),
          const SizedBox(height: 12),
          ElevatedButton(
            onPressed: _loadDetail,
            style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.kYellowAccent),
            child: const Text('Reintentar',
                style: TextStyle(color: AppColors.kBlack)),
          ),
        ],
      ),
    );
  }

  Widget _buildTimeline() {
    final timeline = _detail?.timeline ?? [];
    if (timeline.isEmpty) {
      return const Center(
        child: Text('No hay eventos disponibles',
            style: TextStyle(color: AppColors.kGreyLight)),
      );
    }

    // Group plays by minute (integer division by 60 seconds → minutes)
    final byMinute = <int, List<EspnPlay>>{};
    for (final play in timeline) {
      // ESPN keyEvents use minutes directly (0-90+), while some play APIs
      // return clock in seconds (0-5400+). Values above 130 are treated as
      // seconds since no match has over 130 regular minutes.
      final minute = play.clock > 130 ? play.clock ~/ 60 : play.clock;
      byMinute.putIfAbsent(minute, () => []).add(play);
    }
    final sortedMinutes = byMinute.keys.toList()..sort();
    final event = _detail?.event ?? widget.event;

    return ListView.builder(
      padding: const EdgeInsets.all(12),
      itemCount: sortedMinutes.length,
      itemBuilder: (context, index) {
        final minute = sortedMinutes[index];
        final plays = byMinute[minute]!;
        return Column(
          children: plays
              .map((play) => _PlayTile(
                    play: play,
                    minute: minute,
                    homeTeamId: event.homeTeam.id,
                    awayTeamId: event.awayTeam.id,
                  ))
              .toList(),
        );
      },
    );
  }

  Widget _buildStats() {
    final stats = _detail?.stats ?? [];
    if (stats.isEmpty) {
      return const Center(
        child: Text('Estadísticas no disponibles',
            style: TextStyle(color: AppColors.kGreyLight)),
      );
    }
    final event = _detail?.event ?? widget.event;
    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        // Header row
        Row(
          children: [
            Expanded(
              child: Text(
                event.homeTeam.abbreviation,
                textAlign: TextAlign.center,
                style: const TextStyle(
                    color: AppColors.kYellowAccent,
                    fontWeight: FontWeight.bold),
              ),
            ),
            const Expanded(
              flex: 2,
              child: SizedBox(),
            ),
            Expanded(
              child: Text(
                event.awayTeam.abbreviation,
                textAlign: TextAlign.center,
                style: const TextStyle(
                    color: AppColors.kYellowAccent,
                    fontWeight: FontWeight.bold),
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        ...stats.map((stat) => _StatRow(stat: stat)).toList(),
      ],
    );
  }

  Widget _buildLineups(EspnEvent event) {
    final homeLineup = _detail?.homeLineup ?? [];
    final awayLineup = _detail?.awayLineup ?? [];

    if (homeLineup.isEmpty && awayLineup.isEmpty) {
      return const Center(
        child: Text('Alineaciones no disponibles',
            style: TextStyle(color: AppColors.kGreyLight)),
      );
    }

    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Expanded(
          child: _LineupColumn(
            teamName: event.homeTeam.abbreviation,
            players: homeLineup,
            isHome: true,
          ),
        ),
        Container(width: 1, color: AppColors.kDarkSurface),
        Expanded(
          child: _LineupColumn(
            teamName: event.awayTeam.abbreviation,
            players: awayLineup,
            isHome: false,
          ),
        ),
      ],
    );
  }
}

class _StatusBadge extends StatelessWidget {
  final String status;
  const _StatusBadge({required this.status});

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
        label = 'FINALIZADO';
        break;
      default:
        color = AppColors.kGreyLight;
        label = 'PRÓXIMO';
    }
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
      decoration: BoxDecoration(
        color: color.withOpacity(0.15),
        borderRadius: BorderRadius.circular(6),
        border: Border.all(color: color),
      ),
      child: Text(label,
          style: TextStyle(
              color: color, fontSize: 10, fontWeight: FontWeight.bold)),
    );
  }
}

class _StatRow extends StatelessWidget {
  final EspnStatItem stat;
  const _StatRow({required this.stat});

  @override
  Widget build(BuildContext context) {
    double? homeVal;
    double? awayVal;
    try {
      homeVal = double.parse(stat.homeValue.replaceAll('%', ''));
      awayVal = double.parse(stat.awayValue.replaceAll('%', ''));
    } catch (_) {}

    final total = (homeVal ?? 0) + (awayVal ?? 0);
    final homeFrac = total > 0 ? (homeVal ?? 0) / total : 0.5;

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(stat.homeValue,
                  style: const TextStyle(
                      color: AppColors.kWhite, fontWeight: FontWeight.bold)),
              Expanded(
                child: Text(
                  stat.label,
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                      color: AppColors.kGreyLight, fontSize: 12),
                ),
              ),
              Text(stat.awayValue,
                  style: const TextStyle(
                      color: AppColors.kWhite, fontWeight: FontWeight.bold)),
            ],
          ),
          const SizedBox(height: 4),
          ClipRRect(
            borderRadius: BorderRadius.circular(4),
            child: Row(
              children: [
                Expanded(
                  // Ensure flex is at least 1 to avoid a zero-flex Expanded error.
                  flex: ((homeFrac * 100).round()).clamp(1, 99),
                  child: Container(
                      height: 4, color: AppColors.kYellowAccent),
                ),
                Expanded(
                  flex: (((1 - homeFrac) * 100).round()).clamp(1, 99),
                  child: Container(height: 4, color: AppColors.kGrey),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _PlayTile extends StatelessWidget {
  final EspnPlay play;
  final int minute;
  final String homeTeamId;
  final String awayTeamId;

  const _PlayTile({
    required this.play,
    required this.minute,
    required this.homeTeamId,
    required this.awayTeamId,
  });

  @override
  Widget build(BuildContext context) {
    final isHome = play.teamId == homeTeamId;
    final icon = _iconForType(play.type);

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 5),
      child: Row(
        children: [
          if (isHome) ...[
            SizedBox(
              width: 36,
              child: Text(
                "$minute'",
                style: const TextStyle(
                    color: AppColors.kYellowAccent,
                    fontWeight: FontWeight.bold,
                    fontSize: 12),
                textAlign: TextAlign.center,
              ),
            ),
            const SizedBox(width: 6),
            Text(icon, style: const TextStyle(fontSize: 16)),
            const SizedBox(width: 6),
            Expanded(
              child: Text(play.text,
                  style: const TextStyle(
                      color: AppColors.kWhite, fontSize: 12)),
            ),
          ] else ...[
            Expanded(
              child: Text(play.text,
                  textAlign: TextAlign.end,
                  style: const TextStyle(
                      color: AppColors.kWhite, fontSize: 12)),
            ),
            const SizedBox(width: 6),
            Text(icon, style: const TextStyle(fontSize: 16)),
            const SizedBox(width: 6),
            SizedBox(
              width: 36,
              child: Text(
                "$minute'",
                style: const TextStyle(
                    color: AppColors.kYellowAccent,
                    fontWeight: FontWeight.bold,
                    fontSize: 12),
                textAlign: TextAlign.center,
              ),
            ),
          ],
        ],
      ),
    );
  }

  String _iconForType(String type) {
    switch (type) {
      case 'goal':
        return '⚽';
      case 'yellow-card':
        return '🟨';
      case 'red-card':
        return '🟥';
      case 'substitution':
        return '🔄';
      case 'penalty-scored':
        return '⚽🎯';
      case 'penalty-missed':
        return '❌';
      case 'own-goal':
        return '⚽🔁';
      case 'var':
        return '📺';
      default:
        return '•';
    }
  }
}

class _LineupColumn extends StatelessWidget {
  final String teamName;
  final List<EspnLineupPlayer> players;
  final bool isHome;

  const _LineupColumn({
    required this.teamName,
    required this.players,
    required this.isHome,
  });

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.all(8),
      children: [
        Container(
          padding: const EdgeInsets.symmetric(vertical: 8),
          child: Text(
            teamName,
            textAlign: TextAlign.center,
            style: const TextStyle(
                color: AppColors.kYellowAccent,
                fontWeight: FontWeight.bold,
                fontSize: 13),
          ),
        ),
        ...players.map((p) => Padding(
              padding: const EdgeInsets.symmetric(vertical: 3),
              child: Row(
                children: [
                  if (p.number != null)
                    SizedBox(
                      width: 24,
                      child: Text(
                        p.number!,
                        style: const TextStyle(
                            color: AppColors.kGreyLight, fontSize: 11),
                        textAlign: TextAlign.center,
                      ),
                    ),
                  const SizedBox(width: 4),
                  Expanded(
                    child: Text(
                      p.name,
                      style: const TextStyle(
                          color: AppColors.kWhite, fontSize: 12),
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                  if (p.position != null)
                    Text(
                      p.position!,
                      style: const TextStyle(
                          color: AppColors.kGrey, fontSize: 10),
                    ),
                ],
              ),
            )),
      ],
    );
  }
}
