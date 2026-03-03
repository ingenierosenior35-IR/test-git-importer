import 'package:flutter/material.dart';
import 'package:Rival/core/constants/colors.dart';
import 'package:Rival/features/polls/data/models/espn_models.dart';
import 'football_results_screen.dart';
import 'football_fixtures_screen.dart';
import 'football_teams_screen.dart';
import 'football_favorites_screen.dart';

class FootballLeaguesScreen extends StatelessWidget {
  const FootballLeaguesScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.kDarkBackground,
      appBar: AppBar(
        backgroundColor: AppColors.kDarkBackground,
        title: const Text(
          'FÚTBOL - LIGAS',
          style: TextStyle(color: AppColors.kWhite, fontWeight: FontWeight.bold),
        ),
        iconTheme: const IconThemeData(color: AppColors.kWhite),
        actions: [
          IconButton(
            icon: const Icon(Icons.star, color: AppColors.kYellowAccent),
            tooltip: 'Mis Favoritos',
            onPressed: () => Navigator.push(
              context,
              MaterialPageRoute(
                  builder: (_) => const FootballFavoritesScreen()),
            ),
          ),
        ],
      ),
      body: ListView.builder(
        padding: const EdgeInsets.all(12),
        itemCount: EspnLeague.popularLeagues.length,
        itemBuilder: (context, index) {
          final league = EspnLeague.popularLeagues[index];
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
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
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
              ],
            ),
            const SizedBox(height: 8),
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                TextButton(
                  onPressed: () => Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => FootballTeamsScreen(league: league),
                    ),
                  ),
                  child: const Text(
                    'Equipos',
                    style: TextStyle(color: AppColors.kGreyLight),
                  ),
                ),
                TextButton(
                  onPressed: () => Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => FootballResultsScreen(league: league),
                    ),
                  ),
                  child: const Text(
                    'Resultados',
                    style: TextStyle(color: AppColors.kYellowAccent),
                  ),
                ),
                TextButton(
                  onPressed: () => Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => FootballFixturesScreen(league: league),
                    ),
                  ),
                  child: const Text(
                    'Próximos',
                    style: TextStyle(color: AppColors.kGreyLight),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
