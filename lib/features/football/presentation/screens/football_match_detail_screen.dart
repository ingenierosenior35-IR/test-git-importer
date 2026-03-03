import 'package:flutter/material.dart';
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

class _FootballMatchDetailScreenState extends State<FootballMatchDetailScreen> {
  final _service = EspnApiService();
  EspnMatchDetail? _detail;
  bool _loading = true;
  bool _hasError = false;

  @override
  void initState() {
    super.initState();
    _loadDetail();
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
      ),
      body: _buildBody(event),
    );
  }

  Widget _buildBody(EspnEvent event) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          _buildMatchHeader(event),
          const SizedBox(height: 24),
          if (_loading)
            const Center(child: CircularProgressIndicator(color: AppColors.kYellowAccent))
          else if (_hasError)
            _buildErrorSection()
          else
            _buildTimeline(),
        ],
      ),
    );
  }

  Widget _buildMatchHeader(EspnEvent event) {
    return Card(
      color: AppColors.kDarkCard,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: [
            Expanded(
              child: Text(
                event.homeTeam.displayName,
                textAlign: TextAlign.center,
                style: const TextStyle(
                    color: AppColors.kWhite, fontSize: 16, fontWeight: FontWeight.bold),
              ),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Text(
                event.homeScore != null && event.awayScore != null
                    ? '${event.homeScore} - ${event.awayScore}'
                    : 'vs',
                style: const TextStyle(
                    color: AppColors.kYellowAccent,
                    fontSize: 28,
                    fontWeight: FontWeight.bold),
              ),
            ),
            Expanded(
              child: Text(
                event.awayTeam.displayName,
                textAlign: TextAlign.center,
                style: const TextStyle(
                    color: AppColors.kWhite, fontSize: 16, fontWeight: FontWeight.bold),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildErrorSection() {
    return Column(
      children: [
        const Text('No se pudieron cargar los detalles del partido',
            style: TextStyle(color: AppColors.kGreyLight), textAlign: TextAlign.center),
        const SizedBox(height: 12),
        ElevatedButton(
          onPressed: _loadDetail,
          style: ElevatedButton.styleFrom(backgroundColor: AppColors.kYellowAccent),
          child: const Text('Reintentar', style: TextStyle(color: AppColors.kBlack)),
        ),
      ],
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
    final sorted = List<EspnPlay>.from(timeline)
      ..sort((a, b) => a.clock.compareTo(b.clock));

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Timeline',
          style: TextStyle(
              color: AppColors.kWhite, fontSize: 18, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 12),
        ...sorted.map((play) => _PlayTile(play: play)).toList(),
      ],
    );
  }
}

class _PlayTile extends StatelessWidget {
  final EspnPlay play;

  const _PlayTile({required this.play});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        children: [
          SizedBox(
            width: 40,
            child: Text(
              "${play.clock}'",
              style: const TextStyle(
                  color: AppColors.kYellowAccent,
                  fontWeight: FontWeight.bold,
                  fontSize: 13),
              textAlign: TextAlign.center,
            ),
          ),
          const SizedBox(width: 8),
          Text(_iconForType(play.type), style: const TextStyle(fontSize: 18)),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              play.text,
              style: const TextStyle(color: AppColors.kWhite, fontSize: 13),
            ),
          ),
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
      default:
        return '•';
    }
  }
}
