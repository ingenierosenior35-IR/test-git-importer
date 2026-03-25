import 'package:flutter_test/flutter_test.dart';
import 'package:Rival/features/tournaments/data/models/tournament_model.dart';
import 'package:Rival/features/tournaments/data/repositories/tournaments_firestore_repository.dart';

TournamentEnrolledTeam _team(String id, String name) => TournamentEnrolledTeam(
      teamId: id,
      teamName: name,
      ownerUserId: 'user-$id',
      joinedAt: DateTime(2024, 1, 1),
    );

void main() {
  group('TournamentsFirestoreRepository.buildBracketRound1', () {
    test('2 teams – 1 match, no byes', () {
      final teams = [_team('t1', 'A'), _team('t2', 'B')];
      final matches = TournamentsFirestoreRepository.buildBracketRound1(teams);
      expect(matches.length, 1);
      expect(matches[0].homeTeamId, 't1');
      expect(matches[0].awayTeamId, 't2');
      expect(matches[0].isBye, isFalse);
      expect(matches[0].status, 'scheduled');
    });

    test('4 teams – 2 matches, no byes', () {
      final teams = [
        _team('t1', 'A'),
        _team('t2', 'B'),
        _team('t3', 'C'),
        _team('t4', 'D'),
      ];
      final matches = TournamentsFirestoreRepository.buildBracketRound1(teams);
      expect(matches.length, 2);
      expect(matches.every((m) => !m.isBye), isTrue);
    });

    test('3 teams – 2 slots, 1 bye (slot 4 = 4 slots total for 3 teams → 1 bye)',
        () {
      // 3 teams → nextPow2 = 4 → slots = 4 → byeCount = 1
      // padded = [t1, t2, t3, null]
      // match0: t1 vs t2 (scheduled)
      // match1: t3 vs null (bye)
      final teams = [_team('t1', 'A'), _team('t2', 'B'), _team('t3', 'C')];
      final matches = TournamentsFirestoreRepository.buildBracketRound1(teams);
      expect(matches.length, 2);
      expect(matches[0].isBye, isFalse);
      expect(matches[1].isBye, isTrue);
      expect(matches[1].homeTeamId, 't3');
      expect(matches[1].awayTeamId, isNull);
      expect(matches[1].status, 'bye');
      expect(matches[1].winnerTeamId, 't3');
      expect(matches[1].effectiveWinnerId, 't3');
    });

    test('5 teams – 4 matches, 3 byes', () {
      // 5 teams → nextPow2 = 8 → 8 slots → byeCount = 3
      final teams = List.generate(5, (i) => _team('t${i + 1}', 'Team ${i + 1}'));
      final matches = TournamentsFirestoreRepository.buildBracketRound1(teams);
      expect(matches.length, 4);
      final byes = matches.where((m) => m.isBye).toList();
      expect(byes.length, 3);
    });

    test('8 teams – 4 matches, no byes', () {
      final teams = List.generate(8, (i) => _team('t${i + 1}', 'Team ${i + 1}'));
      final matches = TournamentsFirestoreRepository.buildBracketRound1(teams);
      expect(matches.length, 4);
      expect(matches.every((m) => !m.isBye), isTrue);
    });

    test('1 team – returns empty list', () {
      final matches =
          TournamentsFirestoreRepository.buildBracketRound1([_team('t1', 'A')]);
      expect(matches, isEmpty);
    });

    test('matchIndex is sequential starting at 0', () {
      final teams = List.generate(4, (i) => _team('t${i + 1}', 'T${i + 1}'));
      final matches = TournamentsFirestoreRepository.buildBracketRound1(teams);
      for (int i = 0; i < matches.length; i++) {
        expect(matches[i].matchIndex, i);
      }
    });

    test('round number is set correctly', () {
      final teams = [_team('t1', 'A'), _team('t2', 'B')];
      final r1 = TournamentsFirestoreRepository.buildBracketRound1(teams);
      final r2 = TournamentsFirestoreRepository.buildBracketRound(teams, round: 3);
      expect(r1[0].round, 1);
      expect(r2[0].round, 3);
    });

    test('team names are preserved in matches', () {
      final teams = [_team('t1', 'Real Madrid'), _team('t2', 'Barcelona')];
      final matches = TournamentsFirestoreRepository.buildBracketRound1(teams);
      expect(matches[0].homeTeamName, 'Real Madrid');
      expect(matches[0].awayTeamName, 'Barcelona');
    });

    test('effectiveHomeTeamName returns teamName or fallback', () {
      final m = TournamentMatch(
        id: '',
        round: 1,
        matchIndex: 0,
        homeTeamId: 'h1',
        homeTeamName: 'Home Team',
        status: 'scheduled',
      );
      expect(m.effectiveHomeTeamName, 'Home Team');

      final m2 = TournamentMatch(
        id: '',
        round: 1,
        matchIndex: 0,
        homeTeamId: 'h1',
        status: 'scheduled',
      );
      expect(m2.effectiveHomeTeamName, 'h1');

      final m3 = TournamentMatch(
        id: '',
        round: 1,
        matchIndex: 0,
        status: 'scheduled',
      );
      expect(m3.effectiveHomeTeamName, 'TBD');
    });

    test('effectiveAwayTeamName is BYE for bye matches', () {
      final m = TournamentMatch(
        id: '',
        round: 1,
        matchIndex: 0,
        homeTeamId: 't1',
        homeTeamName: 'Alpha',
        status: 'bye',
        winnerTeamId: 't1',
      );
      expect(m.effectiveAwayTeamName, 'BYE');
    });
  });

  group('TournamentStatus parsing', () {
    test('canJoin is true for open/draft/upcoming statuses', () {
      for (final status in [
        TournamentStatus.open,
        TournamentStatus.draft,
        TournamentStatus.upcoming,
      ]) {
        final t = Tournament(
          id: 'id',
          name: 'T',
          format: TournamentFormat.knockout,
          status: status,
          startDate: DateTime.now(),
          sport: 'Futbol',
          maxTeams: 8,
          currentTeams: 0,
          createdBy: 'u1',
          createdAt: DateTime.now(),
        );
        expect(t.canJoin, isTrue,
            reason: 'Expected canJoin=true for status $status');
      }
    });

    test('canJoin is false for started/finished/cancelled statuses', () {
      for (final status in [
        TournamentStatus.started,
        TournamentStatus.finished,
        TournamentStatus.cancelled,
        TournamentStatus.ongoing,
        TournamentStatus.completed,
      ]) {
        final t = Tournament(
          id: 'id',
          name: 'T',
          format: TournamentFormat.knockout,
          status: status,
          startDate: DateTime.now(),
          sport: 'Futbol',
          maxTeams: 8,
          currentTeams: 0,
          createdBy: 'u1',
          createdAt: DateTime.now(),
        );
        expect(t.canJoin, isFalse,
            reason: 'Expected canJoin=false for status $status');
      }
    });

    test('canJoin is false when maxTeams reached', () {
      final t = Tournament(
        id: 'id',
        name: 'T',
        format: TournamentFormat.knockout,
        status: TournamentStatus.open,
        startDate: DateTime.now(),
        sport: 'Futbol',
        maxTeams: 4,
        currentTeams: 4,
        createdBy: 'u1',
        createdAt: DateTime.now(),
      );
      expect(t.canJoin, isFalse);
    });
  });
}
