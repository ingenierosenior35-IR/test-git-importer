import 'dart:convert';
import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';
import 'package:Rival/features/polls/data/datasources/espn_api_service.dart';
import 'package:Rival/features/polls/data/models/espn_models.dart';

http.Client _mockClient(Map<String, dynamic> body) {
  return MockClient((request) async {
    return http.Response(json.encode(body), 200);
  });
}

void main() {
  group('EspnApiService.getScoreboardForDate', () {
    test('returns events for the given date', () async {
      final mockBody = {
        'events': [
          {
            'id': '401234',
            'name': 'A vs B',
            'shortName': 'A vs B',
            'date': '2024-01-10T20:00:00Z',
            'status': {
              'type': {'state': 'post'}
            },
            'competitions': [],
          }
        ],
      };
      final service = EspnApiService(client: _mockClient(mockBody));
      final events = await service.getScoreboardForDate('esp.1', '20240110');
      expect(events.length, 1);
      expect(events.first.id, '401234');
      expect(events.first.isFinished, isTrue);
    });

    test('returns empty list on error response', () async {
      final service = EspnApiService(
        client: MockClient((_) async => http.Response('Error', 500)),
      );
      final events = await service.getScoreboardForDate('esp.1', '20240110');
      expect(events, isEmpty);
    });
  });

  group('EspnApiService.getLeagues', () {
    test('falls back to popularLeagues on non-200 response', () async {
      final service = EspnApiService(
        client: MockClient((_) async => http.Response('Error', 404)),
      );
      final leagues = await service.getLeagues();
      expect(leagues, isNotEmpty);
      expect(leagues, equals(EspnLeague.popularLeagues));
    });

    test('merges dynamic leagues with popular list', () async {
      final mockBody = {
        'count': 2,
        'items': [
          {'\$ref': 'https://sports.core.api.espn.com/v2/sports/soccer/leagues/esp.1'},
          {'\$ref': 'https://sports.core.api.espn.com/v2/sports/soccer/leagues/xyz.99'},
        ],
      };
      final service = EspnApiService(client: _mockClient(mockBody));
      final leagues = await service.getLeagues();
      expect(leagues, isNotEmpty);
      // esp.1 should get the human-readable name from popularLeagues
      final espLeague = leagues.firstWhere((l) => l.slug == 'esp.1',
          orElse: () => const EspnLeague(slug: '', name: ''));
      expect(espLeague.name, 'LALIGA (España)');
      // Unknown slug should be present with slug as name
      final unknownLeague = leagues.firstWhere((l) => l.slug == 'xyz.99',
          orElse: () => const EspnLeague(slug: '', name: ''));
      expect(unknownLeague.slug, 'xyz.99');
    });
  });

  group('EspnLeague.slugFromRef', () {
    test('extracts slug from a valid Core API ref URL', () {
      const ref =
          'https://sports.core.api.espn.com/v2/sports/soccer/leagues/esp.1';
      expect(EspnLeague.slugFromRef(ref), 'esp.1');
    });

    test('extracts slug even when ref has query parameters', () {
      const ref =
          'https://sports.core.api.espn.com/v2/sports/soccer/leagues/eng.1?lang=es&region=mx';
      expect(EspnLeague.slugFromRef(ref), 'eng.1');
    });

    test('returns null for empty string', () {
      expect(EspnLeague.slugFromRef(''), isNull);
    });
  });
}
