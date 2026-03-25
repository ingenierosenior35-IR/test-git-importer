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
    test('2 teams – 1 normal match, no byes', () {
      final teams = [_team('t1', 'A'), _team('t2', 'B')];
      final matches = TournamentsFirestoreRepository.buildBracketRound1(teams);
      expect(matches.length, 1);
      expect(matches[0].homeTeamId, 't1');
      expect(matches[0].awayTeamId, 't2');
      expect(matches[0].isBye, isFalse);
      expect(matches[0].status, 'scheduled');
    });

    test('4 teams – 2 normal matches, no byes', () {
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

    test('3 teams – 1 normal match + 1 bye for last team', () {
      // 3 teams: (t1 vs t2), t3 = bye
      final teams = [_team('t1', 'A'), _team('t2', 'B'), _team('t3', 'C')];
      final matches = TournamentsFirestoreRepository.buildBracketRound1(teams);
      expect(matches.length, 2);
      expect(matches[0].isBye, isFalse);
      expect(matches[0].homeTeamId, 't1');
      expect(matches[0].awayTeamId, 't2');
      expect(matches[1].isBye, isTrue);
      expect(matches[1].homeTeamId, 't3');
      expect(matches[1].awayTeamId, isNull);
      expect(matches[1].status, 'bye');
      expect(matches[1].winnerTeamId, 't3');
      expect(matches[1].effectiveWinnerId, 't3');
    });

    test('5 teams – 2 normal matches + 1 bye (last team)', () {
      // 5 teams: (t1,t2), (t3,t4), t5=bye
      final teams = List.generate(5, (i) => _team('t${i + 1}', 'Team ${i + 1}'));
      final matches = TournamentsFirestoreRepository.buildBracketRound1(teams);
      expect(matches.length, 3);
      expect(matches[0].isBye, isFalse);
      expect(matches[1].isBye, isFalse);
      expect(matches[2].isBye, isTrue);
      expect(matches[2].homeTeamId, 't5');
    });

    test('6 teams – 3 normal matches, no byes', () {
      final teams = List.generate(6, (i) => _team('t${i + 1}', 'Team ${i + 1}'));
      final matches = TournamentsFirestoreRepository.buildBracketRound1(teams);
      expect(matches.length, 3);
      expect(matches.every((m) => !m.isBye), isTrue);
    });

    test('7 teams – 3 normal matches + 1 bye for last team', () {
      final teams = List.generate(7, (i) => _team('t${i + 1}', 'Team ${i + 1}'));
      final matches = TournamentsFirestoreRepository.buildBracketRound1(teams);
      expect(matches.length, 4);
      final byes = matches.where((m) => m.isBye).toList();
      expect(byes.length, 1);
      expect(byes[0].homeTeamId, 't7');
    });

    test('8 teams – 4 normal matches, no byes', () {
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

    test('round advancement: 3 winners from 5-team round 1 → 2 matches in round 2',
        () {
      // Simulate winners from a 5-team round 1: 2 normal + 1 bye = 3 advancing
      final roundOneWinners = [
        _team('w1', 'Winner1'),
        _team('w2', 'Winner2'),
        _team('t5', 'Team5'),
      ];
      final r2 =
          TournamentsFirestoreRepository.buildBracketRound(roundOneWinners, round: 2);
      // 3 teams: (w1,w2), t5=bye
      expect(r2.length, 2);
      expect(r2[0].isBye, isFalse);
      expect(r2[1].isBye, isTrue);
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
