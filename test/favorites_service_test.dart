import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:Rival/features/football/services/favorites_service.dart';

void main() {
  setUp(() {
    SharedPreferences.setMockInitialValues({});
  });

  group('FavoritesService', () {
    test('getFavorites returns empty set initially', () async {
      final favorites = await FavoritesService.getFavorites();
      expect(favorites, isEmpty);
    });

    test('toggleFavorite adds a team and returns true', () async {
      final added = await FavoritesService.toggleFavorite('86');
      expect(added, isTrue);
      final favorites = await FavoritesService.getFavorites();
      expect(favorites, contains('86'));
    });

    test('toggleFavorite removes a team on second call and returns false', () async {
      await FavoritesService.toggleFavorite('86');
      final removed = await FavoritesService.toggleFavorite('86');
      expect(removed, isFalse);
      final favorites = await FavoritesService.getFavorites();
      expect(favorites, isNot(contains('86')));
    });

    test('isFavorite returns false for unknown team', () async {
      final result = await FavoritesService.isFavorite('999');
      expect(result, isFalse);
    });

    test('isFavorite returns true after adding', () async {
      await FavoritesService.toggleFavorite('42');
      final result = await FavoritesService.isFavorite('42');
      expect(result, isTrue);
    });

    test('isFavorite returns false after removing', () async {
      await FavoritesService.toggleFavorite('42');
      await FavoritesService.toggleFavorite('42');
      final result = await FavoritesService.isFavorite('42');
      expect(result, isFalse);
    });

    test('multiple favorites can be stored', () async {
      await FavoritesService.toggleFavorite('1');
      await FavoritesService.toggleFavorite('2');
      await FavoritesService.toggleFavorite('3');
      final favorites = await FavoritesService.getFavorites();
      expect(favorites, containsAll(['1', '2', '3']));
      expect(favorites.length, 3);
    });

    test('removing one favorite does not affect others', () async {
      await FavoritesService.toggleFavorite('1');
      await FavoritesService.toggleFavorite('2');
      await FavoritesService.toggleFavorite('1'); // remove
      final favorites = await FavoritesService.getFavorites();
      expect(favorites, isNot(contains('1')));
      expect(favorites, contains('2'));
    });
  });
}
