import 'package:flutter/material.dart';
import 'package:Rival/core/constants/colors.dart';
import 'package:Rival/features/polls/data/models/espn_models.dart';
import 'package:Rival/features/polls/data/datasources/espn_api_service.dart';
import 'football_match_detail_screen.dart';

class FootballFixturesScreen extends StatefulWidget {
  final EspnLeague league;

  const FootballFixturesScreen({Key? key, required this.league}) : super(key: key);

  @override
  State<FootballFixturesScreen> createState() => _FootballFixturesScreenState();
}

class _FootballFixturesScreenState extends State<FootballFixturesScreen> {
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
      final allEvents = await _service.getScoreboard(widget.league.slug);
      if (mounted) {
        setState(() {
          _events = allEvents.where((e) => e.isScheduled).toList();
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.kDarkBackground,
      appBar: AppBar(
        backgroundColor: AppColors.kDarkBackground,
        title: Text(
          'Próximos partidos: ${widget.league.name}',
          style: const TextStyle(color: AppColors.kWhite, fontWeight: FontWeight.bold),
          overflow: TextOverflow.ellipsis,
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
            const Text('Error al cargar los próximos partidos',
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
                child: Column(
                  children: [
                    const Text('vs',
                        style: TextStyle(
                            color: AppColors.kYellowAccent,
                            fontWeight: FontWeight.bold,
                            fontSize: 16)),
                    const SizedBox(height: 4),
                    Text(
                      _formatDate(event.date),
                      style: const TextStyle(color: AppColors.kGreyLight, fontSize: 11),
                    ),
                  ],
                ),
              ),
              Expanded(
                child: Text(
                  event.awayTeam.displayName,
                  textAlign: TextAlign.start,
                  style: const TextStyle(color: AppColors.kWhite, fontSize: 14),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  String _formatDate(DateTime date) {
    return '${date.day}/${date.month} ${date.hour.toString().padLeft(2, '0')}:${date.minute.toString().padLeft(2, '0')}';
  }
}
