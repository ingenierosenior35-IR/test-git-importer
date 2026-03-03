import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:Rival/core/constants/colors.dart';
import 'package:Rival/features/polls/data/models/espn_models.dart';
import 'package:Rival/features/polls/data/datasources/espn_api_service.dart';
import '../../services/favorites_service.dart';

class FootballFavoritesScreen extends StatefulWidget {
  const FootballFavoritesScreen({Key? key}) : super(key: key);

  @override
  State<FootballFavoritesScreen> createState() => _FootballFavoritesScreenState();
}

class _FootballFavoritesScreenState extends State<FootballFavoritesScreen> {
  final _service = EspnApiService();
  List<EspnTeam> _favoriteTeams = [];
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _loadFavorites();
  }

  Future<void> _loadFavorites() async {
    setState(() => _loading = true);
    try {
      final favoriteIds = await FavoritesService.getFavorites();
      if (favoriteIds.isEmpty) {
        if (mounted) setState(() => _loading = false);
        return;
      }
      final found = await _fetchTeamsForIds(favoriteIds);
      if (mounted) {
        setState(() {
          _favoriteTeams = found;
          _loading = false;
        });
      }
    } catch (e) {
      debugPrint('FootballFavoritesScreen error: $e');
      if (mounted) setState(() => _loading = false);
    }
  }

  /// Searches popular leagues to find teams matching [ids].
  Future<List<EspnTeam>> _fetchTeamsForIds(Set<String> ids) async {
    const slugs = ['esp.1', 'eng.1', 'ger.1', 'ita.1', 'fra.1', 'usa.1'];
    final found = <EspnTeam>[];
    final remaining = Set<String>.from(ids);
    for (final slug in slugs) {
      if (remaining.isEmpty) break;
      final teams = await _service.getTeams(slug);
      for (final team in teams) {
        if (remaining.remove(team.id)) {
          found.add(team);
        }
      }
    }
    return found;
  }

  Future<void> _unfavorite(String teamId) async {
    await FavoritesService.toggleFavorite(teamId);
    if (mounted) {
      setState(() => _favoriteTeams.removeWhere((t) => t.id == teamId));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.kDarkBackground,
      appBar: AppBar(
        backgroundColor: AppColors.kDarkBackground,
        title: const Text(
          'Equipos Favoritos',
          style: TextStyle(color: AppColors.kWhite, fontWeight: FontWeight.bold),
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
    if (_favoriteTeams.isEmpty) {
      return const Center(
        child: Padding(
          padding: EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(Icons.star_border, color: AppColors.kGreyLight, size: 64),
              SizedBox(height: 16),
              Text(
                'No tienes equipos favoritos',
                style: TextStyle(
                    color: AppColors.kWhite,
                    fontSize: 18,
                    fontWeight: FontWeight.w600),
              ),
              SizedBox(height: 8),
              Text(
                'Añade favoritos desde la pantalla de ligas, entrando en un equipo y pulsando la estrella.',
                textAlign: TextAlign.center,
                style: TextStyle(color: AppColors.kGreyLight, fontSize: 14),
              ),
            ],
          ),
        ),
      );
    }
    return GridView.builder(
      padding: const EdgeInsets.all(16),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        crossAxisSpacing: 12,
        mainAxisSpacing: 12,
        childAspectRatio: 0.85,
      ),
      itemCount: _favoriteTeams.length,
      itemBuilder: (context, index) {
        final team = _favoriteTeams[index];
        return _TeamCard(team: team, onUnfavorite: () => _unfavorite(team.id));
      },
    );
  }
}

class _TeamCard extends StatelessWidget {
  final EspnTeam team;
  final VoidCallback onUnfavorite;

  const _TeamCard({required this.team, required this.onUnfavorite});

  @override
  Widget build(BuildContext context) {
    return Card(
      color: AppColors.kDarkCard,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            if (team.logoUrl != null && team.logoUrl!.isNotEmpty)
              CachedNetworkImage(
                imageUrl: team.logoUrl!,
                height: 60,
                width: 60,
                errorWidget: (_, __, ___) => const Icon(
                  Icons.sports_soccer,
                  color: AppColors.kYellowAccent,
                  size: 48,
                ),
              )
            else
              const Icon(Icons.sports_soccer, color: AppColors.kYellowAccent, size: 48),
            const SizedBox(height: 8),
            Text(
              team.displayName,
              textAlign: TextAlign.center,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(
                  color: AppColors.kWhite,
                  fontWeight: FontWeight.w600,
                  fontSize: 13),
            ),
            const SizedBox(height: 8),
            IconButton(
              icon: const Icon(Icons.star, color: AppColors.kYellowAccent),
              tooltip: 'Quitar de favoritos',
              onPressed: onUnfavorite,
            ),
          ],
        ),
      ),
    );
  }
}
