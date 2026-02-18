import '../models/match_model.dart';

class MatchesMockData {
  static final List<Match> _matches = [];
  static final List<MatchEvent> _matchEvents = [];

  static void initialize() {
    if (_matches.isEmpty) {
      _initializeMatches();
      _initializeMatchEvents();
    }
  }

  static void _initializeMatches() {
    final now = DateTime.now();
    
    _matches.addAll([
      // Upcoming matches
      Match(
        id: 'match1',
        name: 'Partido de Amigos',
        dateTime: now.add(const Duration(days: 3)),
        venue: 'Cancha Central',
        matchType: MatchType.local,
        status: MatchStatus.upcoming,
        createdBy: 'user1',
        createdAt: now.subtract(const Duration(days: 5)),
        playerIds: ['player1', 'player2', 'player3', 'player4'],
      ),
      Match(
        id: 'match2',
        name: 'Tigres vs Halcones',
        dateTime: now.add(const Duration(days: 7)),
        venue: 'Polideportivo Norte',
        matchType: MatchType.versus,
        status: MatchStatus.upcoming,
        homeTeamId: 'team1',
        awayTeamId: 'team2',
        reservationId: 'RES1001',
        createdBy: 'user1',
        createdAt: now.subtract(const Duration(days: 10)),
      ),
      Match(
        id: 'match3',
        name: 'Clásico del Barrio',
        dateTime: now.add(const Duration(days: 14)),
        venue: 'Arena Deportiva Sur',
        matchType: MatchType.versus,
        status: MatchStatus.upcoming,
        homeTeamId: 'team1',
        awayTeamId: 'team3',
        createdBy: 'user2',
        createdAt: now.subtract(const Duration(days: 2)),
      ),
      // Completed matches
      Match(
        id: 'match4',
        name: 'Tigres vs Halcones',
        dateTime: now.subtract(const Duration(days: 7)),
        venue: 'Cancha Deportiva Central',
        matchType: MatchType.versus,
        status: MatchStatus.completed,
        homeTeamId: 'team1',
        awayTeamId: 'team2',
        homeScore: 3,
        awayScore: 2,
        reservationId: 'RES1000',
        createdBy: 'user1',
        createdAt: now.subtract(const Duration(days: 14)),
        mvpPlayerId: 'player5',
        videoThumbnail: 'https://via.placeholder.com/640x360',
      ),
      Match(
        id: 'match5',
        name: 'Partido Relámpago',
        dateTime: now.subtract(const Duration(days: 2)),
        venue: 'Sport Center 5',
        matchType: MatchType.local,
        status: MatchStatus.completed,
        homeScore: 2,
        awayScore: 2,
        createdBy: 'user2',
        createdAt: now.subtract(const Duration(days: 5)),
        playerIds: ['player1', 'player2', 'player6', 'player7'],
      ),
    ]);
  }

  static void _initializeMatchEvents() {
    // Events for match4 (completed match with score 3-2)
    _matchEvents.addAll([
      MatchEvent(
        id: 'event1',
        matchId: 'match4',
        type: MatchEventType.goal,
        minute: 15,
        playerId: 'player5',
        playerName: 'Luis Martínez',
        teamId: 'team1',
        description: 'Gol de Luis Martínez',
      ),
      MatchEvent(
        id: 'event2',
        matchId: 'match4',
        type: MatchEventType.goal,
        minute: 23,
        playerId: 'player6',
        playerName: 'Roberto Díaz',
        teamId: 'team2',
        description: 'Gol de Roberto Díaz',
      ),
      MatchEvent(
        id: 'event3',
        matchId: 'match4',
        type: MatchEventType.yellowCard,
        minute: 34,
        playerId: 'player3',
        playerName: 'Miguel López',
        teamId: 'team1',
        description: 'Tarjeta amarilla a Miguel López',
      ),
      MatchEvent(
        id: 'event4',
        matchId: 'match4',
        type: MatchEventType.goal,
        minute: 42,
        playerId: 'player1',
        playerName: 'Carlos García',
        teamId: 'team1',
        description: 'Gol de Carlos García',
      ),
      MatchEvent(
        id: 'event5',
        matchId: 'match4',
        type: MatchEventType.goal,
        minute: 58,
        playerId: 'player10',
        playerName: 'David Ramírez',
        teamId: 'team2',
        description: 'Gol de David Ramírez',
      ),
      MatchEvent(
        id: 'event6',
        matchId: 'match4',
        type: MatchEventType.substitution,
        minute: 65,
        playerId: 'player2',
        playerName: 'Juan Pérez',
        teamId: 'team1',
        description: 'Entra Juan Pérez',
      ),
      MatchEvent(
        id: 'event7',
        matchId: 'match4',
        type: MatchEventType.goal,
        minute: 78,
        playerId: 'player5',
        playerName: 'Luis Martínez',
        teamId: 'team1',
        description: 'Gol de Luis Martínez',
      ),
      MatchEvent(
        id: 'event8',
        matchId: 'match4',
        type: MatchEventType.yellowCard,
        minute: 85,
        playerId: 'player8',
        playerName: 'Alberto Gómez',
        teamId: 'team2',
        description: 'Tarjeta amarilla a Alberto Gómez',
      ),
    ]);
  }

  static List<Match> getAllMatches() {
    initialize();
    return List.unmodifiable(_matches);
  }

  static List<Match> getUpcomingMatches() {
    initialize();
    return _matches
        .where((match) => match.status == MatchStatus.upcoming)
        .toList()
      ..sort((a, b) => a.dateTime.compareTo(b.dateTime));
  }

  static List<Match> getCompletedMatches() {
    initialize();
    return _matches
        .where((match) => match.status == MatchStatus.completed)
        .toList()
      ..sort((a, b) => b.dateTime.compareTo(a.dateTime));
  }

  static Match? getMatchById(String id) {
    initialize();
    try {
      return _matches.firstWhere((match) => match.id == id);
    } catch (e) {
      return null;
    }
  }

  static List<MatchEvent> getMatchEvents(String matchId) {
    initialize();
    return _matchEvents
        .where((event) => event.matchId == matchId)
        .toList()
      ..sort((a, b) => a.minute.compareTo(b.minute));
  }

  static void addMatch(Match match) {
    initialize();
    _matches.add(match);
  }

  static void updateMatch(Match match) {
    initialize();
    final index = _matches.indexWhere((m) => m.id == match.id);
    if (index != -1) {
      _matches[index] = match;
    }
  }

  static void deleteMatch(String id) {
    initialize();
    _matches.removeWhere((match) => match.id == id);
    _matchEvents.removeWhere((event) => event.matchId == id);
  }

  static void addMatchEvent(MatchEvent event) {
    initialize();
    _matchEvents.add(event);
  }
}
