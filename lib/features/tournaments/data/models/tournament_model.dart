enum TournamentFormat {
  league, // Round-robin (todos contra todos)
  knockout, // Single elimination
  groupsAndKnockout, // Groups + knockout
}

enum TournamentStatus {
  upcoming,
  ongoing,
  completed,
  cancelled,
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
      pointsForWin: pointsForWin ?? this.pointsForWin,
      pointsForDraw: pointsForDraw ?? this.pointsForDraw,
      pointsForLoss: pointsForLoss ?? this.pointsForLoss,
      joinCode: joinCode ?? this.joinCode,
      isPublic: isPublic ?? this.isPublic,
    );
  }

  bool get isActive => status == TournamentStatus.ongoing;
  bool get isCompleted => status == TournamentStatus.completed;
  bool get canJoin => isPublic && currentTeams < maxTeams && 
                      (status == TournamentStatus.upcoming || status == TournamentStatus.ongoing);
}

class TournamentTeam {
  final String tournamentId;
  final String teamId;
  final DateTime joinedAt;
  final int? groupNumber; // For group stage tournaments
  final int? seed; // For seeded tournaments

  const TournamentTeam({
    required this.tournamentId,
    required this.teamId,
    required this.joinedAt,
    this.groupNumber,
    this.seed,
  });
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
