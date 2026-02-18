import '../models/team_model.dart';
import '../models/player_model.dart';

class TeamsMockData {
  static final List<Team> _teams = [];
  static final List<Player> _players = [];

  static void initialize() {
    if (_teams.isEmpty) {
      _initializeTeams();
      _initializePlayers();
    }
  }

  static void _initializeTeams() {
    final now = DateTime.now();
    
    _teams.addAll([
      Team(
        id: 'team1',
        name: 'Los Tigres FC',
        logoUrl: null,
        sport: 'Fútbol',
        description: 'Equipo de amigos del barrio',
        creatorId: 'user1',
        createdAt: now.subtract(const Duration(days: 90)),
        playerIds: ['player1', 'player2', 'player3', 'player4', 'player5'],
        inviteCode: 'TIGRES2024',
      ),
      Team(
        id: 'team2',
        name: 'Halcones United',
        logoUrl: null,
        sport: 'Fútbol',
        description: 'Equipo competitivo',
        creatorId: 'user2',
        createdAt: now.subtract(const Duration(days: 60)),
        playerIds: ['player6', 'player7', 'player8', 'player9', 'player10'],
        inviteCode: 'HALCONES24',
      ),
      Team(
        id: 'team3',
        name: 'Águilas Rojas',
        logoUrl: null,
        sport: 'Fútbol',
        description: 'Equipo veterano',
        creatorId: 'user1',
        createdAt: now.subtract(const Duration(days: 120)),
        playerIds: ['player11', 'player12', 'player13'],
        inviteCode: 'AGUILAS2024',
      ),
    ]);
  }

  static void _initializePlayers() {
    _players.addAll([
      Player(
        id: 'player1',
        name: 'Carlos García',
        position: 'Delantero',
        jerseyNumber: 10,
        sports: ['Fútbol'],
        teamIds: ['team1'],
        stats: PlayerStats(
          matchesPlayed: 25,
          goals: 12,
          assists: 8,
          yellowCards: 2,
          redCards: 0,
          rating: 7.8,
        ),
      ),
      Player(
        id: 'player2',
        name: 'Juan Pérez',
        position: 'Mediocampista',
        jerseyNumber: 8,
        sports: ['Fútbol'],
        teamIds: ['team1'],
        stats: PlayerStats(
          matchesPlayed: 24,
          goals: 5,
          assists: 15,
          yellowCards: 3,
          redCards: 0,
          rating: 7.5,
        ),
      ),
      Player(
        id: 'player3',
        name: 'Miguel López',
        position: 'Defensa',
        jerseyNumber: 4,
        sports: ['Fútbol'],
        teamIds: ['team1'],
        stats: PlayerStats(
          matchesPlayed: 23,
          goals: 1,
          assists: 2,
          yellowCards: 5,
          redCards: 1,
          rating: 7.2,
        ),
      ),
      Player(
        id: 'player4',
        name: 'Pedro Sánchez',
        position: 'Portero',
        jerseyNumber: 1,
        sports: ['Fútbol'],
        teamIds: ['team1'],
        stats: PlayerStats(
          matchesPlayed: 25,
          goals: 0,
          assists: 0,
          yellowCards: 1,
          redCards: 0,
          rating: 7.6,
        ),
      ),
      Player(
        id: 'player5',
        name: 'Luis Martínez',
        position: 'Delantero',
        jerseyNumber: 9,
        sports: ['Fútbol'],
        teamIds: ['team1'],
        stats: PlayerStats(
          matchesPlayed: 22,
          goals: 18,
          assists: 4,
          yellowCards: 2,
          redCards: 0,
          rating: 8.1,
        ),
      ),
      // Team 2 players
      Player(
        id: 'player6',
        name: 'Roberto Díaz',
        position: 'Delantero',
        jerseyNumber: 11,
        sports: ['Fútbol'],
        teamIds: ['team2'],
        stats: PlayerStats(
          matchesPlayed: 20,
          goals: 15,
          assists: 6,
          yellowCards: 1,
          redCards: 0,
          rating: 7.9,
        ),
      ),
      Player(
        id: 'player7',
        name: 'Fernando Ruiz',
        position: 'Mediocampista',
        jerseyNumber: 6,
        sports: ['Fútbol'],
        teamIds: ['team2'],
        stats: PlayerStats(
          matchesPlayed: 19,
          goals: 4,
          assists: 10,
          yellowCards: 4,
          redCards: 0,
          rating: 7.4,
        ),
      ),
      Player(
        id: 'player8',
        name: 'Alberto Gómez',
        position: 'Defensa',
        jerseyNumber: 3,
        sports: ['Fútbol'],
        teamIds: ['team2'],
        stats: PlayerStats(
          matchesPlayed: 20,
          goals: 2,
          assists: 1,
          yellowCards: 6,
          redCards: 0,
          rating: 7.1,
        ),
      ),
      Player(
        id: 'player9',
        name: 'José Torres',
        position: 'Portero',
        jerseyNumber: 1,
        sports: ['Fútbol'],
        teamIds: ['team2'],
        stats: PlayerStats(
          matchesPlayed: 20,
          goals: 0,
          assists: 0,
          yellowCards: 0,
          redCards: 0,
          rating: 7.7,
        ),
      ),
      Player(
        id: 'player10',
        name: 'David Ramírez',
        position: 'Delantero',
        jerseyNumber: 7,
        sports: ['Fútbol'],
        teamIds: ['team2'],
        stats: PlayerStats(
          matchesPlayed: 18,
          goals: 11,
          assists: 7,
          yellowCards: 2,
          redCards: 0,
          rating: 7.8,
        ),
      ),
    ]);
  }

  static List<Team> getAllTeams() {
    initialize();
    return List.unmodifiable(_teams);
  }

  static List<Player> getAllPlayers() {
    initialize();
    return List.unmodifiable(_players);
  }

  static Team? getTeamById(String id) {
    initialize();
    try {
      return _teams.firstWhere((team) => team.id == id);
    } catch (e) {
      return null;
    }
  }

  static Player? getPlayerById(String id) {
    initialize();
    try {
      return _players.firstWhere((player) => player.id == id);
    } catch (e) {
      return null;
    }
  }

  static List<Player> getPlayersByTeamId(String teamId) {
    initialize();
    return _players.where((player) => player.teamIds.contains(teamId)).toList();
  }

  static void addTeam(Team team) {
    initialize();
    _teams.add(team);
  }

  static void updateTeam(Team team) {
    initialize();
    final index = _teams.indexWhere((t) => t.id == team.id);
    if (index != -1) {
      _teams[index] = team;
    }
  }

  static void deleteTeam(String id) {
    initialize();
    _teams.removeWhere((team) => team.id == id);
  }

  static void addPlayer(Player player) {
    initialize();
    _players.add(player);
  }

  static void updatePlayer(Player player) {
    initialize();
    final index = _players.indexWhere((p) => p.id == player.id);
    if (index != -1) {
      _players[index] = player;
    }
  }

  static void deletePlayer(String id) {
    initialize();
    _players.removeWhere((player) => player.id == id);
  }

  static String generateInviteCode(String teamName) {
    final cleanName = teamName.toUpperCase().replaceAll(' ', '');
    final year = DateTime.now().year;
    return '$cleanName$year';
  }
}
