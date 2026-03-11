import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:Rival/core/constants/colors.dart';
import 'package:Rival/features/polls/data/models/espn_models.dart';
import '../../data/models/favorite_team_model.dart';
import '../../services/firestore_favorites_service.dart';
import 'football_team_detail_screen.dart';

class FootballFavoritesScreen extends StatelessWidget {
  const FootballFavoritesScreen({Key? key}) : super(key: key);

  /// Returns an [EspnLeague] with the human-readable name for the given [slug],
  /// falling back to the slug itself when not found in the popular list.
  EspnLeague _leagueForSlug(String slug) {
    return EspnLeague.popularLeagues.firstWhere(
      (l) => l.slug == slug,
      orElse: () => EspnLeague(slug: slug, name: slug),
    );
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
      body: StreamBuilder<List<FavoriteTeam>>(
        stream: FirestoreFavoritesService.watchFavorites(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(
                child:
                    CircularProgressIndicator(color: AppColors.kYellowAccent));
          }
          if (snapshot.hasError) {
            return Center(
              child: Text(
                'Error al cargar favoritos: ${snapshot.error}',
                style: const TextStyle(color: AppColors.kWhite),
                textAlign: TextAlign.center,
              ),
            );
          }
          final favorites = snapshot.data ?? [];
          if (favorites.isEmpty) {
            return const _EmptyFavorites();
          }
          return GridView.builder(
            padding: const EdgeInsets.all(16),
            gridDelegate:
                const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 2,
              crossAxisSpacing: 12,
              mainAxisSpacing: 12,
              childAspectRatio: 0.85,
            ),
            itemCount: favorites.length,
            itemBuilder: (context, index) {
              final fav = favorites[index];
              return _FavoriteTeamCard(
                favorite: fav,
                onUnfavorite: () => FirestoreFavoritesService.removeFavorite(
                    fav.league, fav.teamId),
                onViewFixtures: () => Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => FootballTeamDetailScreen(
                      team: EspnTeam(
                        id: fav.teamId,
                        name: fav.name,
                        abbreviation: fav.name.length > 3
                            ? fav.name.substring(0, 3).toUpperCase()
                            : fav.name.toUpperCase(),
                        displayName: fav.name,
                        logoUrl: fav.logoUrl,
                      ),
                      leagueSlug: fav.league,
                    ),
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }
}

class _EmptyFavorites extends StatelessWidget {
  const _EmptyFavorites();

  @override
  Widget build(BuildContext context) {
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
}

class _FavoriteTeamCard extends StatelessWidget {
  final FavoriteTeam favorite;
  final VoidCallback onUnfavorite;
  final VoidCallback onViewFixtures;

  const _FavoriteTeamCard({
    required this.favorite,
    required this.onUnfavorite,
    required this.onViewFixtures,
  });

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
            if (favorite.logoUrl != null && favorite.logoUrl!.isNotEmpty)
              CachedNetworkImage(
                imageUrl: favorite.logoUrl!,
                height: 52,
                width: 52,
                errorWidget: (_, __, ___) => const Icon(
                  Icons.sports_soccer,
                  color: AppColors.kYellowAccent,
                  size: 44,
                ),
              )
            else
              const Icon(Icons.sports_soccer,
                  color: AppColors.kYellowAccent, size: 44),
            const SizedBox(height: 6),
            Text(
              favorite.name,
              textAlign: TextAlign.center,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(
                  color: AppColors.kWhite,
                  fontWeight: FontWeight.w600,
                  fontSize: 12),
            ),
            const SizedBox(height: 4),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                IconButton(
                  constraints: const BoxConstraints(),
                  padding: const EdgeInsets.all(4),
                  icon: const Icon(Icons.calendar_month_outlined,
                      color: AppColors.kGreyLight, size: 18),
                  tooltip: 'Ver próximos partidos',
                  onPressed: onViewFixtures,
                ),
                IconButton(
                  constraints: const BoxConstraints(),
                  padding: const EdgeInsets.all(4),
                  icon: const Icon(Icons.star,
                      color: AppColors.kYellowAccent, size: 20),
                  tooltip: 'Quitar de favoritos',
                  onPressed: onUnfavorite,
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

