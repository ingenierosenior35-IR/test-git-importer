enum TournamentFormat {
  league, // Round-robin (todos contra todos)
  knockout, // Single elimination
  groupsAndKnockout, // Groups + knockout
}

/// draft = not yet open; open = accepting teams; started = bracket generated / in progress;
/// finished = completed; cancelled = cancelled.
/// Legacy values (upcoming → open, ongoing → started, completed → finished) are
/// normalised on read in the repository.
enum TournamentStatus {
  draft,
  open,
  started,
  finished,
  cancelled,
  // Keep legacy aliases so existing Firestore docs still parse correctly.
  upcoming,
  ongoing,
  completed,
}

class Tournament {
  final String id;
  final String name;
  final String? description;
  final TournamentFormat format;
  final TournamentStatus status;
  final DateTime startDate;
  final DateTime? endDate;
  final String sport;
  final int maxTeams;
  final int currentTeams;
  final String? logoUrl;
  final String? location;
  final String createdBy;
  final DateTime createdAt;

  /// Current elimination round (1-based). 0 = bracket not yet generated.
  final int currentRound;

  // Scoring rules
  final int pointsForWin;
  final int pointsForDraw;
  final int pointsForLoss;

  // Registration
  final String? joinCode;
  final bool isPublic;

  const Tournament({
    required this.id,
    required this.name,
    this.description,
    required this.format,
    required this.status,
    required this.startDate,
    this.endDate,
    required this.sport,
    required this.maxTeams,
    this.currentTeams = 0,
    this.logoUrl,
    this.location,
    required this.createdBy,
    required this.createdAt,
    this.currentRound = 0,
    this.pointsForWin = 3,
    this.pointsForDraw = 1,
    this.pointsForLoss = 0,
    this.joinCode,
    this.isPublic = true,
  });

  Tournament copyWith({
    String? id,
    String? name,
    String? description,
    TournamentFormat? format,
    TournamentStatus? status,
    DateTime? startDate,
    DateTime? endDate,
    String? sport,
    int? maxTeams,
    int? currentTeams,
    String? logoUrl,
    String? location,
    String? createdBy,
    DateTime? createdAt,
    int? currentRound,
    int? pointsForWin,
    int? pointsForDraw,
    int? pointsForLoss,
    String? joinCode,
    bool? isPublic,
  }) {
    return Tournament(
      id: id ?? this.id,
      name: name ?? this.name,
      description: description ?? this.description,
      format: format ?? this.format,
      status: status ?? this.status,
      startDate: startDate ?? this.startDate,
      endDate: endDate ?? this.endDate,
      sport: sport ?? this.sport,
      maxTeams: maxTeams ?? this.maxTeams,
      currentTeams: currentTeams ?? this.currentTeams,
      logoUrl: logoUrl ?? this.logoUrl,
      location: location ?? this.location,
      createdBy: createdBy ?? this.createdBy,
      createdAt: createdAt ?? this.createdAt,
      currentRound: currentRound ?? this.currentRound,
      pointsForWin: pointsForWin ?? this.pointsForWin,
      pointsForDraw: pointsForDraw ?? this.pointsForDraw,
      pointsForLoss: pointsForLoss ?? this.pointsForLoss,
      joinCode: joinCode ?? this.joinCode,
      isPublic: isPublic ?? this.isPublic,
    );
  }

  bool get isActive =>
      status == TournamentStatus.started || status == TournamentStatus.ongoing;
  bool get isCompleted =>
      status == TournamentStatus.finished || status == TournamentStatus.completed;
  bool get canJoin =>
      currentTeams < maxTeams &&
      (status == TournamentStatus.open ||
          status == TournamentStatus.draft ||
          status == TournamentStatus.upcoming);
}

/// Represents a team enrolled in a tournament (subcollection: tournaments/{id}/teams/{teamId}).
class TournamentEnrolledTeam {
  final String teamId;
  final String teamName;
  final String ownerUserId;
  final DateTime joinedAt;
  final String? logoUrl;

  const TournamentEnrolledTeam({
    required this.teamId,
    required this.teamName,
    required this.ownerUserId,
    required this.joinedAt,
    this.logoUrl,
  });
}

/// Legacy model kept for backward compatibility with mock data.
class TournamentTeam {
  final String tournamentId;
  final String teamId;
  final DateTime joinedAt;
  final int? groupNumber;
  final int? seed;

  const TournamentTeam({
    required this.tournamentId,
    required this.teamId,
    required this.joinedAt,
    this.groupNumber,
    this.seed,
  });
}

/// A match within a tournament bracket (subcollection: tournaments/{id}/matches/{matchId}).
class TournamentMatch {
  final String id;
  final int round;
  final int matchIndex; // 0-based position within the round
  final String? homeTeamId;
  final String? awayTeamId;
  final String? homeTeamName;
  final String? awayTeamName;
  final int? homeScore;
  final int? awayScore;
  final DateTime? scheduledAt;

  /// 'scheduled' | 'live' | 'finished' | 'bye'
  final String status;
  final String? winnerTeamId;

  const TournamentMatch({
    required this.id,
    required this.round,
    required this.matchIndex,
    this.homeTeamId,
    this.awayTeamId,
    this.homeTeamName,
    this.awayTeamName,
    this.homeScore,
    this.awayScore,
    this.scheduledAt,
    this.status = 'scheduled',
    this.winnerTeamId,
  });

  /// A bye match has no away team; the home team advances automatically.
  bool get isBye => awayTeamId == null;
  bool get isFinished => status == 'finished' || status == 'bye';

  String? get effectiveWinnerId {
    if (isBye) return homeTeamId;
    return winnerTeamId;
  }

  String get effectiveHomeTeamName => homeTeamName ?? homeTeamId ?? 'TBD';
  String get effectiveAwayTeamName =>
      isBye ? 'BYE' : (awayTeamName ?? awayTeamId ?? 'TBD');

  TournamentMatch copyWith({
    String? id,
    int? round,
    int? matchIndex,
    String? homeTeamId,
    String? awayTeamId,
    String? homeTeamName,
    String? awayTeamName,
    int? homeScore,
    int? awayScore,
    DateTime? scheduledAt,
    String? status,
    String? winnerTeamId,
  }) {
    return TournamentMatch(
      id: id ?? this.id,
      round: round ?? this.round,
      matchIndex: matchIndex ?? this.matchIndex,
      homeTeamId: homeTeamId ?? this.homeTeamId,
      awayTeamId: awayTeamId ?? this.awayTeamId,
      homeTeamName: homeTeamName ?? this.homeTeamName,
      awayTeamName: awayTeamName ?? this.awayTeamName,
      homeScore: homeScore ?? this.homeScore,
      awayScore: awayScore ?? this.awayScore,
      scheduledAt: scheduledAt ?? this.scheduledAt,
      status: status ?? this.status,
      winnerTeamId: winnerTeamId ?? this.winnerTeamId,
    );
  }
}

class StandingsRow {
  final String teamId;
  final String teamName;
  final String? teamLogoUrl;
  final int position;
  final int matchesPlayed;
  final int wins;
  final int draws;
  final int losses;
  final int goalsFor;
  final int goalsAgainst;
  final int goalDifference;
  final int points;

  const StandingsRow({
    required this.teamId,
    required this.teamName,
    this.teamLogoUrl,
    required this.position,
    required this.matchesPlayed,
    required this.wins,
    required this.draws,
    required this.losses,
    required this.goalsFor,
    required this.goalsAgainst,
    required this.goalDifference,
    required this.points,
  });

  StandingsRow copyWith({
    String? teamId,
    String? teamName,
    String? teamLogoUrl,
    int? position,
    int? matchesPlayed,
    int? wins,
    int? draws,
    int? losses,
    int? goalsFor,
    int? goalsAgainst,
    int? goalDifference,
    int? points,
  }) {
    return StandingsRow(
      teamId: teamId ?? this.teamId,
      teamName: teamName ?? this.teamName,
      teamLogoUrl: teamLogoUrl ?? this.teamLogoUrl,
      position: position ?? this.position,
      matchesPlayed: matchesPlayed ?? this.matchesPlayed,
      wins: wins ?? this.wins,
      draws: draws ?? this.draws,
      losses: losses ?? this.losses,
      goalsFor: goalsFor ?? this.goalsFor,
      goalsAgainst: goalsAgainst ?? this.goalsAgainst,
      goalDifference: goalDifference ?? this.goalDifference,
      points: points ?? this.points,
    );
  }
}
