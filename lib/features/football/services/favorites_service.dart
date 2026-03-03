import 'package:shared_preferences/shared_preferences.dart';

class FavoritesService {
  static const _key = 'favorite_teams';

  /// Returns the set of favorite team IDs.
  static Future<Set<String>> getFavorites() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getStringList(_key)?.toSet() ?? {};
  }

  /// Toggles a team as favorite.
  /// Returns true if added, false if removed.
  static Future<bool> toggleFavorite(String teamId) async {
    final prefs = await SharedPreferences.getInstance();
    final favorites = prefs.getStringList(_key)?.toSet() ?? {};
    final added = favorites.add(teamId);
    if (!added) {
      favorites.remove(teamId);
    }
    await prefs.setStringList(_key, favorites.toList());
    return added;
  }

  static Future<bool> isFavorite(String teamId) async {
    final favorites = await getFavorites();
    return favorites.contains(teamId);
  }
}
