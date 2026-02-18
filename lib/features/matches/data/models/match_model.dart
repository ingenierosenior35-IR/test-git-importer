enum MatchType {
  local, // Between friends
  versus, // Between registered teams
}

enum MatchStatus {
  upcoming,
  ongoing,
  completed,
  cancelled,
}

class Match {
  final String id;
  final String name;
  final DateTime dateTime;
  final String? venue;
  final MatchType matchType;
  final MatchStatus status;
  final String? homeTeamId;
  final String? awayTeamId;
  final int? homeScore;
  final int? awayScore;
  final String? reservationId;
  final String createdBy;
  final DateTime createdAt;
  final List<String> playerIds;
  final String? mvpPlayerId;
  final String? videoUrl;
  final String? videoThumbnail;
  final String? tournamentId; // Link to tournament if part of one

  Match({
    required this.id,
    required this.name,
    required this.dateTime,
    this.venue,
    required this.matchType,
    required this.status,
    this.homeTeamId,
    this.awayTeamId,
    this.homeScore,
    this.awayScore,
    this.reservationId,
    required this.createdBy,
    required this.createdAt,
    this.playerIds = const [],
    this.mvpPlayerId,
    this.videoUrl,
    this.videoThumbnail,
    this.tournamentId,
  });

  bool get hasScore => homeScore != null && awayScore != null;
  bool get isVersus => matchType == MatchType.versus;
  bool get hasTeams => homeTeamId != null || awayTeamId != null;

  Match copyWith({
    String? id,
    String? name,
    DateTime? dateTime,
    String? venue,
    MatchType? matchType,
    MatchStatus? status,
    String? homeTeamId,
    String? awayTeamId,
    int? homeScore,
    int? awayScore,
    String? reservationId,
    String? createdBy,
    DateTime? createdAt,
    List<String>? playerIds,
    String? mvpPlayerId,
    String? videoUrl,
    String? videoThumbnail,
    String? tournamentId,
  }) {
    return Match(
      id: id ?? this.id,
      name: name ?? this.name,
      dateTime: dateTime ?? this.dateTime,
      venue: venue ?? this.venue,
      matchType: matchType ?? this.matchType,
      status: status ?? this.status,
      homeTeamId: homeTeamId ?? this.homeTeamId,
      awayTeamId: awayTeamId ?? this.awayTeamId,
      homeScore: homeScore ?? this.homeScore,
      awayScore: awayScore ?? this.awayScore,
      reservationId: reservationId ?? this.reservationId,
      createdBy: createdBy ?? this.createdBy,
      createdAt: createdAt ?? this.createdAt,
      playerIds: playerIds ?? this.playerIds,
      mvpPlayerId: mvpPlayerId ?? this.mvpPlayerId,
      videoUrl: videoUrl ?? this.videoUrl,
      videoThumbnail: videoThumbnail ?? this.videoThumbnail,
      tournamentId: tournamentId ?? this.tournamentId,
    );
  }
}

enum MatchEventType {
  goal,
  yellowCard,
  redCard,
  substitution,
  penalty,
  ownGoal,
}

class MatchEvent {
  final String id;
  final String matchId;
  final MatchEventType type;
  final int minute;
  final String? playerId;
  final String? playerName;
  final String? teamId;
  final String? description;
  final String? relatedPlayerId; // For substitutions or assists

  MatchEvent({
    required this.id,
    required this.matchId,
    required this.type,
    required this.minute,
    this.playerId,
    this.playerName,
    this.teamId,
    this.description,
    this.relatedPlayerId,
  });

  String get eventIcon {
    switch (type) {
      case MatchEventType.goal:
        return '⚽';
      case MatchEventType.yellowCard:
        return '🟨';
      case MatchEventType.redCard:
        return '🟥';
      case MatchEventType.substitution:
        return '🔄';
      case MatchEventType.penalty:
        return '⚽(P)';
      case MatchEventType.ownGoal:
        return '⚽(OG)';
    }
  }
}
