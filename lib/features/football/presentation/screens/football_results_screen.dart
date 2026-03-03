import 'package:flutter/material.dart';
import 'package:Rival/core/constants/colors.dart';
import 'package:Rival/features/polls/data/models/espn_models.dart';
import 'package:Rival/features/polls/data/datasources/espn_api_service.dart';
import 'football_match_detail_screen.dart';

class FootballResultsScreen extends StatefulWidget {
  final EspnLeague league;

  const FootballResultsScreen({Key? key, required this.league}) : super(key: key);

  @override
  State<FootballResultsScreen> createState() => _FootballResultsScreenState();
}

class _FootballResultsScreenState extends State<FootballResultsScreen> {
  final _service = EspnApiService();
  List<EspnEvent> _events = [];
  bool _loading = true;
  bool _hasError = false;

  @override
  void initState() {
    super.initState();
    _loadEvents();
  }

  Future<void> _loadEvents() async {
    setState(() {
      _loading = true;
      _hasError = false;
    });
    try {
      final events = await _service.getScoreboard(widget.league.slug);
      if (mounted) {
        setState(() {
          _events = events;
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.kDarkBackground,
      appBar: AppBar(
        backgroundColor: AppColors.kDarkBackground,
        title: Text(
          widget.league.name,
          style: const TextStyle(color: AppColors.kWhite, fontWeight: FontWeight.bold),
        ),
        iconTheme: const IconThemeData(color: AppColors.kWhite),
      ),
      body: _buildBody(),
    );
  }

  Widget _buildBody() {
    if (_loading) {
      return const Center(child: CircularProgressIndicator(color: AppColors.kYellowAccent));
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
              style: ElevatedButton.styleFrom(backgroundColor: AppColors.kYellowAccent),
              child: const Text('Reintentar', style: TextStyle(color: AppColors.kBlack)),
            ),
          ],
        ),
      );
    }
    if (_events.isEmpty) {
      return const Center(
        child: Text('No hay partidos disponibles',
            style: TextStyle(color: AppColors.kGreyLight)),
      );
    }
    return ListView.builder(
      padding: const EdgeInsets.all(12),
      itemCount: _events.length,
      itemBuilder: (context, index) {
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
          child: Row(
            children: [
              Expanded(
                child: Text(
                  event.homeTeam.displayName,
                  textAlign: TextAlign.end,
                  style: const TextStyle(color: AppColors.kWhite, fontSize: 14),
                ),
              ),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 12),
                child: Text(
                  event.homeScore != null && event.awayScore != null
                      ? '${event.homeScore} - ${event.awayScore}'
                      : 'vs',
                  style: const TextStyle(
                    color: AppColors.kYellowAccent,
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                  ),
                ),
              ),
              Expanded(
                child: Text(
                  event.awayTeam.displayName,
                  textAlign: TextAlign.start,
                  style: const TextStyle(color: AppColors.kWhite, fontSize: 14),
                ),
              ),
              const SizedBox(width: 8),
              _StatusChip(status: event.status),
            ],
          ),
        ),
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
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: color.withOpacity(0.2),
        borderRadius: BorderRadius.circular(6),
        border: Border.all(color: color, width: 1),
      ),
      child: Text(label, style: TextStyle(color: color, fontSize: 11, fontWeight: FontWeight.bold)),
    );
  }
}
