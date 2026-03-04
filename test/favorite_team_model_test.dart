import 'package:flutter_test/flutter_test.dart';
import 'package:Rival/features/football/data/models/favorite_team_model.dart';

void main() {
  group('FavoriteTeam.fromMap', () {
    test('parses all fields correctly', () {
      final map = {
        'league': 'esp.1',
        'teamId': '86',
        'name': 'Real Madrid CF',
        'logoUrl': 'https://example.com/logo.png',
      };
      final team = FavoriteTeam.fromMap(map);
      expect(team.league, 'esp.1');
      expect(team.teamId, '86');
      expect(team.name, 'Real Madrid CF');
      expect(team.logoUrl, 'https://example.com/logo.png');
    });

    test('handles missing optional logoUrl', () {
      final map = {
        'league': 'eng.1',
        'teamId': '360',
        'name': 'Arsenal',
      };
      final team = FavoriteTeam.fromMap(map);
      expect(team.logoUrl, isNull);
    });

    test('handles empty map with defaults', () {
      final team = FavoriteTeam.fromMap({});
      expect(team.league, '');
      expect(team.teamId, '');
      expect(team.name, '');
      expect(team.logoUrl, isNull);
    });
  });

  group('FavoriteTeam.docId', () {
    test('returns league_teamId', () {
      const team = FavoriteTeam(
        league: 'esp.1',
        teamId: '86',
        name: 'Real Madrid CF',
      );
      expect(team.docId, 'esp.1_86');
    });
  });

  group('FavoriteTeam.toMap', () {
    test('round-trips through toMap and fromMap', () {
      const team = FavoriteTeam(
        league: 'ger.1',
        teamId: '131',
        name: 'Bayern Munich',
        logoUrl: 'https://example.com/bayer.png',
      );
      final map = team.toMap();
      final restored = FavoriteTeam.fromMap(map);
      expect(restored.league, team.league);
      expect(restored.teamId, team.teamId);
      expect(restored.name, team.name);
      expect(restored.logoUrl, team.logoUrl);
    });
  });

  group('FavoriteTeam equality', () {
    test('two teams with same league+teamId are equal', () {
      const a = FavoriteTeam(league: 'esp.1', teamId: '86', name: 'A');
      const b = FavoriteTeam(league: 'esp.1', teamId: '86', name: 'B');
      expect(a, equals(b));
    });

    test('teams with different league are not equal', () {
      const a = FavoriteTeam(league: 'esp.1', teamId: '86', name: 'A');
      const b = FavoriteTeam(league: 'eng.1', teamId: '86', name: 'A');
      expect(a, isNot(equals(b)));
    });

    test('teams with different teamId are not equal', () {
      const a = FavoriteTeam(league: 'esp.1', teamId: '86', name: 'A');
      const b = FavoriteTeam(league: 'esp.1', teamId: '83', name: 'A');
      expect(a, isNot(equals(b)));
    });
  });
}
