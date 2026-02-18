class Team {
  final String id;
  final String name;
  final String? logoUrl;
  final String sport;
  final String? description;
  final String creatorId;
  final DateTime createdAt;
  final List<String> playerIds;
  final String? inviteCode;

  Team({
    required this.id,
    required this.name,
    this.logoUrl,
    required this.sport,
    this.description,
    required this.creatorId,
    required this.createdAt,
    this.playerIds = const [],
    this.inviteCode,
  });

  String get inviteUrl => 'https://rival.app/invite/${inviteCode ?? id}';

  Team copyWith({
    String? id,
    String? name,
    String? logoUrl,
    String? sport,
    String? description,
    String? creatorId,
    DateTime? createdAt,
    List<String>? playerIds,
    String? inviteCode,
  }) {
    return Team(
      id: id ?? this.id,
      name: name ?? this.name,
      logoUrl: logoUrl ?? this.logoUrl,
      sport: sport ?? this.sport,
      description: description ?? this.description,
      creatorId: creatorId ?? this.creatorId,
      createdAt: createdAt ?? this.createdAt,
      playerIds: playerIds ?? this.playerIds,
      inviteCode: inviteCode ?? this.inviteCode,
    );
  }
}
