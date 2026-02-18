import '../models/tournament_model.dart';
import '../../../teams/data/datasources/teams_mock_data.dart';

class TournamentsMockData {
  static final List<Tournament> _tournaments = [
    Tournament(
      id: 'tournament1',
      name: 'Liga de Verano 2024',
      description: 'Torneo de fútbol amateur de verano',
      format: TournamentFormat.league,
      status: TournamentStatus.ongoing,
      startDate: DateTime(2024, 6, 1),
      endDate: DateTime(2024, 8, 31),
      sport: 'Fútbol',
      maxTeams: 8,
      currentTeams: 6,
      location: 'Madrid',
      createdBy: 'user1',
      createdAt: DateTime(2024, 5, 1),
      pointsForWin: 3,
      pointsForDraw: 1,
      pointsForLoss: 0,
      joinCode: 'SUMMER24',
      isPublic: true,
    ),
    Tournament(
      id: 'tournament2',
      name: 'Copa Primavera',
      description: 'Torneo eliminatorio de primavera',
      format: TournamentFormat.knockout,
      status: TournamentStatus.upcoming,
      startDate: DateTime(2024, 9, 1),
      endDate: DateTime(2024, 9, 30),
      sport: 'Fútbol',
      maxTeams: 16,
      currentTeams: 12,
      location: 'Barcelona',
      createdBy: 'user1',
      createdAt: DateTime(2024, 7, 15),
      joinCode: 'SPRING24',
      isPublic: true,
    ),
    Tournament(
      id: 'tournament3',
      name: 'Champions Amateur',
      description: 'Fase de grupos + eliminatorias',
      format: TournamentFormat.groupsAndKnockout,
      status: TournamentStatus.ongoing,
      startDate: DateTime(2024, 3, 1),
      endDate: DateTime(2024, 6, 30),
      sport: 'Fútbol',
      maxTeams: 16,
      currentTeams: 16,
      location: 'Valencia',
      createdBy: 'user2',
      createdAt: DateTime(2024, 2, 1),
      joinCode: 'CHAMP24',
      isPublic: true,
    ),
    Tournament(
      id: 'tournament4',
      name: 'Torneo Invierno',
      description: 'Liga de invierno completada',
      format: TournamentFormat.league,
      status: TournamentStatus.completed,
      startDate: DateTime(2023, 12, 1),
      endDate: DateTime(2024, 2, 28),
      sport: 'Fútbol',
      maxTeams: 10,
      currentTeams: 10,
      location: 'Sevilla',
      createdBy: 'user1',
      createdAt: DateTime(2023, 11, 1),
      isPublic: true,
    ),
  ];

  static final Map<String, List<TournamentTeam>> _tournamentTeams = {
    'tournament1': [
      TournamentTeam(
        tournamentId: 'tournament1',
        teamId: 'team1',
        joinedAt: DateTime(2024, 5, 15),
      ),
      TournamentTeam(
        tournamentId: 'tournament1',
        teamId: 'team2',
        joinedAt: DateTime(2024, 5, 16),
      ),
      TournamentTeam(
        tournamentId: 'tournament1',
        teamId: 'team3',
        joinedAt: DateTime(2024, 5, 17),
      ),
      TournamentTeam(
        tournamentId: 'tournament1',
        teamId: 'team4',
        joinedAt: DateTime(2024, 5, 18),
      ),
      TournamentTeam(
        tournamentId: 'tournament1',
        teamId: 'team5',
        joinedAt: DateTime(2024, 5, 19),
      ),
      TournamentTeam(
        tournamentId: 'tournament1',
        teamId: 'team6',
        joinedAt: DateTime(2024, 5, 20),
      ),
    ],
  };

  static List<Tournament> getAllTournaments() {
    return List.from(_tournaments);
  }

  static List<Tournament> getActiveTournaments() {
    return _tournaments
        .where((t) => t.status == TournamentStatus.ongoing)
        .toList();
  }

  static List<Tournament> getUpcomingTournaments() {
    return _tournaments
        .where((t) => t.status == TournamentStatus.upcoming)
        .toList();
  }

  static List<Tournament> getCompletedTournaments() {
    return _tournaments
        .where((t) => t.status == TournamentStatus.completed)
        .toList();
  }

  static Tournament? getTournamentById(String id) {
    try {
      return _tournaments.firstWhere((t) => t.id == id);
    } catch (e) {
      return null;
    }
  }

  static void addTournament(Tournament tournament) {
    _tournaments.add(tournament);
  }

  static void updateTournament(Tournament tournament) {
    final index = _tournaments.indexWhere((t) => t.id == tournament.id);
    if (index != -1) {
      _tournaments[index] = tournament;
    }
  }

  static void deleteTournament(String id) {
    _tournaments.removeWhere((t) => t.id == id);
    _tournamentTeams.remove(id);
  }

  static List<TournamentTeam> getTeamsByTournamentId(String tournamentId) {
    return _tournamentTeams[tournamentId] ?? [];
  }

  static void addTeamToTournament(TournamentTeam tournamentTeam) {
    if (!_tournamentTeams.containsKey(tournamentTeam.tournamentId)) {
      _tournamentTeams[tournamentTeam.tournamentId] = [];
    }
    _tournamentTeams[tournamentTeam.tournamentId]!.add(tournamentTeam);
    
    // Update tournament's current team count
    final tournament = getTournamentById(tournamentTeam.tournamentId);
    if (tournament != null) {
      updateTournament(tournament.copyWith(
        currentTeams: tournament.currentTeams + 1,
      ));
    }
  }

  static void removeTeamFromTournament(String tournamentId, String teamId) {
    _tournamentTeams[tournamentId]
        ?.removeWhere((tt) => tt.teamId == teamId);
    
    // Update tournament's current team count
    final tournament = getTournamentById(tournamentId);
    if (tournament != null && tournament.currentTeams > 0) {
      updateTournament(tournament.copyWith(
        currentTeams: tournament.currentTeams - 1,
      ));
    }
  }

  static List<StandingsRow> getStandingsByTournamentId(String tournamentId) {
    // Mock standings data for tournament1
    if (tournamentId == 'tournament1') {
      final teams = TeamsMockData.getAllTeams();
      return [
        StandingsRow(
          teamId: 'team1',
          teamName: teams.isNotEmpty ? teams[0].name : 'FC Barcelona',
          teamLogoUrl: teams.isNotEmpty ? teams[0].logoUrl : null,
          position: 1,
          matchesPlayed: 10,
          wins: 8,
          draws: 1,
          losses: 1,
          goalsFor: 25,
          goalsAgainst: 8,
          goalDifference: 17,
          points: 25,
        ),
        StandingsRow(
          teamId: 'team2',
          teamName: teams.length > 1 ? teams[1].name : 'Real Madrid',
          teamLogoUrl: teams.length > 1 ? teams[1].logoUrl : null,
          position: 2,
          matchesPlayed: 10,
          wins: 7,
          draws: 2,
          losses: 1,
          goalsFor: 22,
          goalsAgainst: 10,
          goalDifference: 12,
          points: 23,
        ),
        StandingsRow(
          teamId: 'team3',
          teamName: teams.length > 2 ? teams[2].name : 'Atlético Madrid',
          teamLogoUrl: teams.length > 2 ? teams[2].logoUrl : null,
          position: 3,
          matchesPlayed: 10,
          wins: 6,
          draws: 3,
          losses: 1,
          goalsFor: 20,
          goalsAgainst: 12,
          goalDifference: 8,
          points: 21,
        ),
        StandingsRow(
          teamId: 'team4',
          teamName: teams.length > 3 ? teams[3].name : 'Valencia CF',
          teamLogoUrl: teams.length > 3 ? teams[3].logoUrl : null,
          position: 4,
          matchesPlayed: 10,
          wins: 5,
          draws: 2,
          losses: 3,
          goalsFor: 18,
          goalsAgainst: 14,
          goalDifference: 4,
          points: 17,
        ),
        StandingsRow(
          teamId: 'team5',
          teamName: teams.length > 4 ? teams[4].name : 'Sevilla FC',
          teamLogoUrl: teams.length > 4 ? teams[4].logoUrl : null,
          position: 5,
          matchesPlayed: 10,
          wins: 3,
          draws: 4,
          losses: 3,
          goalsFor: 15,
          goalsAgainst: 16,
          goalDifference: -1,
          points: 13,
        ),
        StandingsRow(
          teamId: 'team6',
          teamName: teams.length > 5 ? teams[5].name : 'Athletic Bilbao',
          teamLogoUrl: teams.length > 5 ? teams[5].logoUrl : null,
          position: 6,
          matchesPlayed: 10,
          wins: 1,
          draws: 2,
          losses: 7,
          goalsFor: 8,
          goalsAgainst: 23,
          goalDifference: -15,
          points: 5,
        ),
      ];
    }
    
    return [];
  }
}
