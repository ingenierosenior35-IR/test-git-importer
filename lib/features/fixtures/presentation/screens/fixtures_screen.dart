import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:Rival/core/constants/colors.dart';
import 'package:Rival/features/polls/data/models/espn_models.dart';
import 'package:Rival/features/polls/data/datasources/espn_api_service.dart';
import 'package:Rival/features/football/presentation/screens/football_league_detail_screen.dart';

class FixturesScreen extends StatefulWidget {
  const FixturesScreen({Key? key}) : super(key: key);

  @override
  State<FixturesScreen> createState() => _FixturesScreenState();
}

class _FixturesScreenState extends State<FixturesScreen> {
  final _service = EspnApiService();
  List<EspnLeague> _leagues = EspnLeague.popularLeagues;
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _loadLeagues();
  }

  Future<void> _loadLeagues() async {
    setState(() => _loading = true);
    final leagues = await _service.getLeagues();
    if (mounted) {
      setState(() {
        _leagues = leagues;
        _loading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.kDarkBackground,
      appBar: AppBar(
        backgroundColor: AppColors.kDarkBackground,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: AppColors.kWhite),
          onPressed: () => Get.back(),
        ),
        title: const Text(
          'FÚTBOL - LIGAS',
          style: TextStyle(
            color: AppColors.kWhite,
            fontWeight: FontWeight.bold,
          ),
        ),
        iconTheme: const IconThemeData(color: AppColors.kWhite),
        actions: [
          if (_loading)
            const Padding(
              padding: EdgeInsets.only(right: 12),
              child: Center(
                child: SizedBox(
                  width: 18,
                  height: 18,
                  child: CircularProgressIndicator(
                    color: AppColors.kYellowAccent,
                    strokeWidth: 2,
                  ),
                ),
              ),
            ),
        ],
      ),
      body: _loading && _leagues == EspnLeague.popularLeagues
          ? const Center(
              child: CircularProgressIndicator(color: AppColors.kYellowAccent),
            )
          : ListView.builder(
              padding: const EdgeInsets.all(12),
              itemCount: _leagues.length,
              itemBuilder: (context, index) {
                final league = _leagues[index];
                return _LeagueCard(league: league);
              },
            ),
    );
  }
}

class _LeagueCard extends StatelessWidget {
  final EspnLeague league;

  const _LeagueCard({required this.league});

  @override
  Widget build(BuildContext context) {
    return Card(
      color: AppColors.kDarkCard,
      margin: const EdgeInsets.symmetric(vertical: 6),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: InkWell(
        onTap: () => Navigator.push(
          context,
          MaterialPageRoute(
            builder: (_) => FootballLeagueDetailScreen(league: league),
          ),
        ),
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
          child: Row(
            children: [
              const Icon(Icons.sports_soccer, color: AppColors.kYellowAccent),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  league.name,
                  style: const TextStyle(
                    color: AppColors.kWhite,
                    fontWeight: FontWeight.w600,
                    fontSize: 15,
                  ),
                ),
              ),
              const Icon(Icons.chevron_right, color: AppColors.kGrey),
            ],
          ),
        ),
      ),
    );
  }
}

