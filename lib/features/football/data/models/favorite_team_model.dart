import 'package:cloud_firestore/cloud_firestore.dart';

/// Represents a team that the current user has marked as a favourite.
///
/// Persisted in Firestore under `users/{uid}/favorite_teams/{league}_{teamId}`.
class FavoriteTeam {
  final String league;
  final String teamId;
  final String name;
  final String? logoUrl;

  const FavoriteTeam({
    required this.league,
    required this.teamId,
    required this.name,
    this.logoUrl,
  });

  /// The Firestore document ID for this favourite: `{league}_{teamId}`.
  String get docId => '${league}_$teamId';

  /// Creates a [FavoriteTeam] from a Firestore [DocumentSnapshot].
  factory FavoriteTeam.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>? ?? {};
    return FavoriteTeam(
      league: data['league'] as String? ?? '',
      teamId: data['teamId'] as String? ?? '',
      name: data['name'] as String? ?? '',
      logoUrl: data['logoUrl'] as String?,
    );
  }

  /// Creates a [FavoriteTeam] from a plain [Map] (useful for testing).
  factory FavoriteTeam.fromMap(Map<String, dynamic> data) {
    return FavoriteTeam(
      league: data['league'] as String? ?? '',
      teamId: data['teamId'] as String? ?? '',
      name: data['name'] as String? ?? '',
      logoUrl: data['logoUrl'] as String?,
    );
  }

  Map<String, dynamic> toMap() => {
        'league': league,
        'teamId': teamId,
        'name': name,
        'logoUrl': logoUrl,
      };

  @override
  bool operator ==(Object other) =>
      other is FavoriteTeam &&
      other.league == league &&
      other.teamId == teamId;

  @override
  int get hashCode => Object.hash(league, teamId);
}
