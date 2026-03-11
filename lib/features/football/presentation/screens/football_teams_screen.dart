import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:Rival/core/constants/colors.dart';
import 'package:Rival/features/polls/data/models/espn_models.dart';
import 'package:Rival/features/polls/data/datasources/espn_api_service.dart';
import '../../services/firestore_favorites_service.dart';
import 'football_team_detail_screen.dart';

/// Screen that lists teams for a given league and allows marking them as favorites.
class FootballTeamsScreen extends StatefulWidget {
  final EspnLeague league;

  const FootballTeamsScreen({Key? key, required this.league}) : super(key: key);

  @override
  State<FootballTeamsScreen> createState() => _FootballTeamsScreenState();
}

class _FootballTeamsScreenState extends State<FootballTeamsScreen> {
  final _service = EspnApiService();
  List<EspnTeam> _teams = [];
  Set<String> _favorites = {};
  bool _loading = true;
  bool _hasError = false;

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    setState(() {
      _loading = true;
      _hasError = false;
    });
    try {
      final results = await Future.wait([
        _service.getTeams(widget.league.slug),
        FirestoreFavoritesService.getFavoriteTeamIds(
            league: widget.league.slug),
      ]);
      if (mounted) {
        setState(() {
          _teams = results[0] as List<EspnTeam>;
          _favorites = results[1] as Set<String>;
          _loading = false;
        });
      }
    } catch (e) {
      debugPrint('FootballTeamsScreen error: $e');
      if (mounted) {
        setState(() {
          _hasError = true;
          _loading = false;
        });
      }
    }
  }

  Future<void> _toggleFavorite(EspnTeam team) async {
    final added = await FirestoreFavoritesService.toggleFavorite(
      league: widget.league.slug,
      teamId: team.id,
      name: team.displayName,
      logoUrl: team.logoUrl,
    );
    if (mounted) {
      setState(() {
        if (added) {
          _favorites.add(team.id);
        } else {
          _favorites.remove(team.id);
        }
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.kDarkBackground,
      appBar: AppBar(
        backgroundColor: AppColors.kDarkBackground,
        title: Text(
          'Equipos: ${widget.league.name}',
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
            const Text('Error al cargar los equipos',
                style: TextStyle(color: AppColors.kWhite)),
            const SizedBox(height: 12),
            ElevatedButton(
              onPressed: _loadData,
              style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.kYellowAccent),
              child: const Text('Reintentar',
                  style: TextStyle(color: AppColors.kBlack)),
            ),
          ],
        ),
      );
    }
    if (_teams.isEmpty) {
      return const Center(
        child: Text('No hay equipos disponibles',
            style: TextStyle(color: AppColors.kGreyLight)),
      );
    }
    return ListView.builder(
      padding: const EdgeInsets.all(12),
      itemCount: _teams.length,
      itemBuilder: (context, index) {
        final team = _teams[index];
        final isFav = _favorites.contains(team.id);
        return _TeamListTile(
          team: team,
          isFavorite: isFav,
          leagueSlug: widget.league.slug,
          onToggle: () => _toggleFavorite(team),
        );
      },
    );
  }
}

class _TeamListTile extends StatelessWidget {
  final EspnTeam team;
  final bool isFavorite;
  final String leagueSlug;
  final VoidCallback onToggle;

  const _TeamListTile(
      {required this.team, required this.isFavorite, required this.leagueSlug, required this.onToggle});

  @override
  Widget build(BuildContext context) {
    return Card(
      color: AppColors.kDarkCard,
      margin: const EdgeInsets.symmetric(vertical: 4),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      child: ListTile(
        leading: team.logoUrl != null && team.logoUrl!.isNotEmpty
            ? CachedNetworkImage(
                imageUrl: team.logoUrl!,
                width: 40,
                height: 40,
                errorWidget: (_, __, ___) => const Icon(
                  Icons.sports_soccer,
                  color: AppColors.kYellowAccent,
                ),
              )
            : const Icon(Icons.sports_soccer, color: AppColors.kYellowAccent),
        title: Text(
          team.displayName,
          style: const TextStyle(
              color: AppColors.kWhite,
              fontWeight: FontWeight.w600,
              fontSize: 14),
        ),
        subtitle: Text(
          team.abbreviation,
          style: const TextStyle(color: AppColors.kGreyLight, fontSize: 12),
        ),
        onTap: () => Navigator.push(
          context,
          MaterialPageRoute(
            builder: (_) => FootballTeamDetailScreen(
              team: team,
              leagueSlug: leagueSlug,
            ),
          ),
        ),
        trailing: IconButton(
          icon: Icon(
            isFavorite ? Icons.star : Icons.star_border,
            color: isFavorite ? AppColors.kYellowAccent : AppColors.kGrey,
          ),
          tooltip:
              isFavorite ? 'Quitar de favoritos' : 'Añadir a favoritos',
          onPressed: onToggle,
        ),
      ),
    );
  }
}

