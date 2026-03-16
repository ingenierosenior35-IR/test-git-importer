import 'dart:math';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';
import '../models/team_model.dart';

/// Firestore repository for user-owned teams.
class TeamsFirestoreRepository {
  final FirebaseFirestore _firestore;

  TeamsFirestoreRepository({FirebaseFirestore? firestore})
      : _firestore = firestore ?? FirebaseFirestore.instance;

  CollectionReference<Map<String, dynamic>> get _teamsRef =>
      _firestore.collection('teams');

  /// Returns all teams created by [userId].
  Future<List<Team>> getTeamsForUser(String userId) async {
    try {
      final snapshot = await _teamsRef
          .where('creatorId', isEqualTo: userId)
          .orderBy('createdAt', descending: true)
          .get();
      return snapshot.docs.map(_docToTeam).whereType<Team>().toList();
    } catch (e) {
      debugPrint('TeamsFirestoreRepository.getTeamsForUser error: $e');
      return [];
    }
  }

  /// Returns all teams (for selection in create match, etc.).
  Future<List<Team>> getAllTeamsForUser(String userId) =>
      getTeamsForUser(userId);

  /// Saves [team] to Firestore. Returns the document id.
  Future<String> saveTeam(Team team) async {
    try {
      final data = _teamToJson(team);
      if (team.id.isEmpty) {
        final doc = await _teamsRef.add(data);
        return doc.id;
      } else {
        await _teamsRef.doc(team.id).set(data, SetOptions(merge: true));
        return team.id;
      }
    } catch (e) {
      debugPrint('TeamsFirestoreRepository.saveTeam error: $e');
      rethrow;
    }
  }

  /// Deletes a team by [teamId].
  Future<void> deleteTeam(String teamId) async {
    await _teamsRef.doc(teamId).delete();
  }

  Team? _docToTeam(DocumentSnapshot<Map<String, dynamic>> doc) {
    try {
      final data = Map<String, dynamic>.from(doc.data() ?? {});
      data['id'] = doc.id;
      final createdAtRaw = data['createdAt'];
      if (createdAtRaw is Timestamp) {
        data['createdAt'] = createdAtRaw.toDate().toIso8601String();
      } else if (createdAtRaw == null) {
        data['createdAt'] = DateTime.now().toIso8601String();
      }
      return Team(
        id: data['id'] as String,
        name: data['name'] as String? ?? '',
        logoUrl: data['logoUrl'] as String?,
        sport: data['sport'] as String? ?? 'Fútbol',
        description: data['description'] as String?,
        creatorId: data['creatorId'] as String? ?? '',
        createdAt: DateTime.parse(data['createdAt'] as String),
        playerIds: List<String>.from(data['playerIds'] as List? ?? []),
        inviteCode: data['inviteCode'] as String?,
      );
    } catch (e) {
      debugPrint('TeamsFirestoreRepository._docToTeam error: $e');
      return null;
    }
  }

  Map<String, dynamic> _teamToJson(Team team) => {
        'name': team.name,
        'logoUrl': team.logoUrl,
        'sport': team.sport,
        'description': team.description,
        'creatorId': team.creatorId,
        // Only set createdAt on creation; preserve existing value on updates.
        if (team.id.isEmpty) 'createdAt': FieldValue.serverTimestamp(),
        'playerIds': team.playerIds,
        'inviteCode': team.inviteCode,
      };

  /// Generates a random 6-character uppercase invite code based on [baseName].
  static String generateInviteCode(String baseName) {
    const chars = 'ABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789';
    final rand = Random.secure();
    final suffix = List.generate(4, (_) => chars[rand.nextInt(chars.length)]).join();
    final prefix = baseName.replaceAll(RegExp(r'[^A-Za-z0-9]'), '')
        .toUpperCase()
        .padRight(2, 'X')
        .substring(0, 2);
    return '$prefix$suffix';
  }
}
