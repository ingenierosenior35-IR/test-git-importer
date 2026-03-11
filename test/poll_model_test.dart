import 'package:flutter_test/flutter_test.dart';
import 'package:Rival/features/polls/data/models/poll_model.dart';
import 'package:Rival/features/polls/data/models/espn_models.dart';

void main() {
  group('Poll.fromJson', () {
    test('parses all required fields correctly', () {
      final json = {
        'id': 'poll-1',
        'name': 'La Liga 2024',
        'description': 'Polla de La Liga',
        'creatorId': 'user-123',
        'creatorName': 'Juan Pérez',
        'createdAt': '2024-01-15T10:00:00.000Z',
        'participantIds': ['user-123', 'user-456'],
        'status': 'active',
        'fixtures': <dynamic>[],
      };
      final poll = Poll.fromJson(json);
      expect(poll.id, 'poll-1');
      expect(poll.name, 'La Liga 2024');
      expect(poll.description, 'Polla de La Liga');
      expect(poll.creatorId, 'user-123');
      expect(poll.creatorName, 'Juan Pérez');
      expect(poll.createdAt, DateTime.parse('2024-01-15T10:00:00.000Z'));
      expect(poll.participantIds, ['user-123', 'user-456']);
      expect(poll.status, 'active');
      expect(poll.isActive, isTrue);
      expect(poll.isFinished, isFalse);
      expect(poll.participantCount, 2);
    });

    test('isActive and isFinished reflect status correctly', () {
      final activeJson = {
        'id': '1',
        'name': 'Test',
        'description': '',
        'creatorId': 'u1',
        'creatorName': 'User',
        'createdAt': '2024-01-01T00:00:00.000Z',
        'participantIds': ['u1'],
        'status': 'active',
        'fixtures': <dynamic>[],
      };
      final finishedJson = Map<String, dynamic>.from(activeJson)
        ..['id'] = '2'
        ..['status'] = 'finished';

      final active = Poll.fromJson(activeJson);
      final finished = Poll.fromJson(finishedJson);

      expect(active.isActive, isTrue);
      expect(active.isFinished, isFalse);
      expect(finished.isActive, isFalse);
      expect(finished.isFinished, isTrue);
    });

    test('parses optional fields when present', () {
      final json = {
        'id': 'poll-2',
        'name': 'Copa Lib',
        'description': 'Polla copa',
        'creatorId': 'u1',
        'creatorName': 'U1',
        'createdAt': '2024-03-01T12:00:00.000Z',
        'participantIds': ['u1'],
        'status': 'active',
        'leagueSlug': 'conmebol.libertadores',
        'leagueName': 'Copa Libertadores',
        'joinCode': 'ABC123',
        'fixtures': <dynamic>[],
      };
      final poll = Poll.fromJson(json);
      expect(poll.leagueSlug, 'conmebol.libertadores');
      expect(poll.leagueName, 'Copa Libertadores');
      expect(poll.joinCode, 'ABC123');
    });

    test('parses fixtures embedded in poll', () {
      final fixtureJson = {
        'id': 'ev1',
        'name': 'A vs B',
        'date': '2024-04-01T20:00:00Z',
        'status': {'type': {'state': 'pre'}},
        'competitions': [],
      };
      final json = {
        'id': 'poll-3',
        'name': 'Test poll',
        'description': '',
        'creatorId': 'u1',
        'creatorName': 'U1',
        'createdAt': '2024-01-01T00:00:00.000Z',
        'participantIds': ['u1'],
        'status': 'active',
        'fixtures': [fixtureJson],
      };
      final poll = Poll.fromJson(json);
      expect(poll.fixtures.length, 1);
      expect(poll.fixtures.first.id, 'ev1');
      expect(poll.fixtures.first.isScheduled, isTrue);
    });

    test('toJson round-trips correctly', () {
      final original = Poll(
        id: 'poll-rt',
        name: 'Round Trip',
        description: 'Test',
        creatorId: 'u1',
        creatorName: 'User 1',
        createdAt: DateTime.parse('2024-06-01T00:00:00.000Z'),
        participantIds: ['u1', 'u2'],
        status: 'active',
        leagueSlug: 'esp.1',
        leagueName: 'LALIGA',
        joinCode: 'XY9Z88',
        fixtures: const [],
      );
      final json = original.toJson();
      expect(json['id'], 'poll-rt');
      expect(json['name'], 'Round Trip');
      expect(json['creatorId'], 'u1');
      expect(json['status'], 'active');
      expect(json['participantIds'], ['u1', 'u2']);
      expect(json['leagueSlug'], 'esp.1');
      expect(json['joinCode'], 'XY9Z88');
    });
  });

  group('PollStanding.fromJson', () {
    test('parses all fields correctly', () {
      final json = {
        'userId': 'u1',
        'userName': 'Player One',
        'points': 15,
        'correctPredictions': 5,
        'totalPredictions': 8,
      };
      final standing = PollStanding.fromJson(json);
      expect(standing.userId, 'u1');
      expect(standing.userName, 'Player One');
      expect(standing.points, 15);
      expect(standing.correctPredictions, 5);
      expect(standing.totalPredictions, 8);
    });
  });
}
