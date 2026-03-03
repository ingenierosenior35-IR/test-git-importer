import 'package:flutter_test/flutter_test.dart';
import 'package:Rival/features/polls/data/models/espn_models.dart';

void main() {
  group('EspnTeam.fromJson', () {
    test('parses all fields correctly', () {
      final json = {
        'id': '86',
        'name': 'Real Madrid',
        'abbreviation': 'RM',
        'displayName': 'Real Madrid CF',
        'logos': [
          {'href': 'https://example.com/logo.png'}
        ],
      };
      final team = EspnTeam.fromJson(json);
      expect(team.id, '86');
      expect(team.name, 'Real Madrid');
      expect(team.abbreviation, 'RM');
      expect(team.displayName, 'Real Madrid CF');
      expect(team.logoUrl, 'https://example.com/logo.png');
    });

    test('handles missing logos gracefully', () {
      final json = {
        'id': '1',
        'name': 'Team',
        'abbreviation': 'TM',
        'displayName': 'Team FC',
      };
      final team = EspnTeam.fromJson(json);
      expect(team.logoUrl, isNull);
    });

    test('handles missing optional fields with defaults', () {
      final team = EspnTeam.fromJson({});
      expect(team.id, '');
      expect(team.name, '');
      expect(team.abbreviation, '');
    });
  });

  group('EspnEvent.fromJson', () {
    test('parses home and away teams with scores', () {
      final json = {
        'id': '401234',
        'name': 'Real Madrid vs Barcelona',
        'shortName': 'RM vs BAR',
        'date': '2024-03-10T20:00:00Z',
        'status': {
          'type': {'state': 'post'}
        },
        'competitions': [
          {
            'competitors': [
              {
                'homeAway': 'home',
                'score': '2',
                'team': {
                  'id': '86',
                  'name': 'Real Madrid',
                  'abbreviation': 'RM',
                  'displayName': 'Real Madrid CF',
                }
              },
              {
                'homeAway': 'away',
                'score': '1',
                'team': {
                  'id': '83',
                  'name': 'Barcelona',
                  'abbreviation': 'BAR',
                  'displayName': 'FC Barcelona',
                }
              },
            ]
          }
        ],
      };
      final event = EspnEvent.fromJson(json);
      expect(event.id, '401234');
      expect(event.status, 'post');
      expect(event.homeTeam.name, 'Real Madrid');
      expect(event.awayTeam.name, 'Barcelona');
      expect(event.homeScore, '2');
      expect(event.awayScore, '1');
      expect(event.isFinished, isTrue);
    });

    test('isScheduled returns true for pre status', () {
      final json = {
        'id': '1',
        'name': 'A vs B',
        'date': '2024-06-01T10:00:00Z',
        'status': {
          'type': {'state': 'pre'}
        },
        'competitions': [],
      };
      final event = EspnEvent.fromJson(json);
      expect(event.isScheduled, isTrue);
      expect(event.isLive, isFalse);
      expect(event.isFinished, isFalse);
    });
  });

  group('EspnPlay.fromJson', () {
    test('parses goal event correctly', () {
      final json = {
        'id': 'play-1',
        'clock': {'value': 23, 'displayValue': "23'"},
        'text': 'Goal - Benzema',
        'team': {'id': '86'},
        'type': {'id': 'goal', 'text': 'Goal'},
      };
      final play = EspnPlay.fromJson(json);
      expect(play.id, 'play-1');
      expect(play.clock, 23);
      expect(play.text, 'Goal - Benzema');
      expect(play.teamId, '86');
      expect(play.type, 'goal');
    });

    test('parses yellow-card event', () {
      final json = {
        'id': 'play-2',
        'clock': {'value': 45},
        'text': 'Yellow Card - Alaba',
        'team': {'id': '86'},
        'type': {'id': 'yellow-card'},
      };
      final play = EspnPlay.fromJson(json);
      expect(play.type, 'yellow-card');
      expect(play.clock, 45);
    });

    test('handles missing clock value gracefully', () {
      final play = EspnPlay.fromJson({'id': 'x', 'text': 'event'});
      expect(play.clock, 0);
      expect(play.type, 'event');
      expect(play.teamId, isNull);
    });

    test('toJson round-trips correctly', () {
      final play = const EspnPlay(
        id: '1',
        clock: 30,
        text: 'Test',
        teamId: '86',
        type: 'goal',
      );
      final json = play.toJson();
      expect(json['id'], '1');
      expect(json['clock'], 30);
      expect(json['type'], 'goal');
      expect(json['teamId'], '86');
    });
  });

  group('EspnMatchDetail.fromJson', () {
    test('parses summary endpoint response', () {
      final json = {
        'header': {
          'id': 'match-1',
          'name': 'Real Madrid vs Barcelona',
          'competitions': [
            {
              'status': {
                'type': {'state': 'post'}
              },
              'competitors': [
                {
                  'homeAway': 'home',
                  'score': '2',
                  'team': {
                    'id': '86',
                    'name': 'Real Madrid',
                    'abbreviation': 'RM',
                    'displayName': 'Real Madrid CF',
                  }
                },
                {
                  'homeAway': 'away',
                  'score': '1',
                  'team': {
                    'id': '83',
                    'name': 'Barcelona',
                    'abbreviation': 'BAR',
                    'displayName': 'FC Barcelona',
                  }
                },
              ]
            }
          ]
        },
        'keyEvents': [
          {
            'id': 'e1',
            'clock': {'value': 23},
            'text': 'Goal - Benzema',
            'team': {'id': '86'},
            'type': {'id': 'goal'},
          }
        ],
      };
      final detail = EspnMatchDetail.fromJson(json);
      expect(detail.event.id, 'match-1');
      expect(detail.event.status, 'post');
      expect(detail.timeline.length, 1);
      expect(detail.timeline.first.type, 'goal');
      expect(detail.timeline.first.clock, 23);
    });

    test('handles empty keyEvents', () {
      final json = {
        'header': {
          'id': 'match-2',
          'competitions': [],
        },
      };
      final detail = EspnMatchDetail.fromJson(json);
      expect(detail.timeline, isEmpty);
    });
  });
}
