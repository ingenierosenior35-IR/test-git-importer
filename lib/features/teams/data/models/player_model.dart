class Player {
  final String id;
  final String name;
  final String? position;
  final int? jerseyNumber;
  final String? photoUrl;
  final List<String> sports;
  final PlayerStats? stats;
  final List<String> teamIds;

  Player({
    required this.id,
    required this.name,
    this.position,
    this.jerseyNumber,
    this.photoUrl,
    this.sports = const [],
    this.stats,
    this.teamIds = const [],
  });

  Player copyWith({
    String? id,
    String? name,
    String? position,
    int? jerseyNumber,
    String? photoUrl,
    List<String>? sports,
    PlayerStats? stats,
    List<String>? teamIds,
  }) {
    return Player(
      id: id ?? this.id,
      name: name ?? this.name,
      position: position ?? this.position,
      jerseyNumber: jerseyNumber ?? this.jerseyNumber,
      photoUrl: photoUrl ?? this.photoUrl,
      sports: sports ?? this.sports,
      stats: stats ?? this.stats,
      teamIds: teamIds ?? this.teamIds,
    );
  }
}

class PlayerStats {
  final int matchesPlayed;
  final int goals;
  final int assists;
  final int yellowCards;
  final int redCards;
  final double rating;

  PlayerStats({
    this.matchesPlayed = 0,
    this.goals = 0,
    this.assists = 0,
    this.yellowCards = 0,
    this.redCards = 0,
    this.rating = 0.0,
  });

  PlayerStats copyWith({
    int? matchesPlayed,
    int? goals,
    int? assists,
    int? yellowCards,
    int? redCards,
    double? rating,
  }) {
    return PlayerStats(
      matchesPlayed: matchesPlayed ?? this.matchesPlayed,
      goals: goals ?? this.goals,
      assists: assists ?? this.assists,
      yellowCards: yellowCards ?? this.yellowCards,
      redCards: redCards ?? this.redCards,
      rating: rating ?? this.rating,
    );
  }
}
