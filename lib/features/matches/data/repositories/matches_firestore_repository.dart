import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';
import '../models/match_model.dart';

/// Firestore repository for user-owned matches.
class MatchesFirestoreRepository {
  final FirebaseFirestore _firestore;

  MatchesFirestoreRepository({FirebaseFirestore? firestore})
      : _firestore = firestore ?? FirebaseFirestore.instance;

  CollectionReference<Map<String, dynamic>> get _matchesRef =>
      _firestore.collection('matches');

  /// Returns all matches created by [userId].
  Future<List<Match>> getMatchesForUser(String userId) async {
    try {
      final snapshot = await _matchesRef
          .where('createdBy', isEqualTo: userId)
          .orderBy('dateTime', descending: true)
          .get();
      return snapshot.docs.map(_docToMatch).whereType<Match>().toList();
    } catch (e) {
      debugPrint('MatchesFirestoreRepository.getMatchesForUser error: $e');
      return [];
    }
  }

  /// Saves [match] to Firestore. Returns the document id.
  Future<String> saveMatch(Match match) async {
    try {
      final data = _matchToJson(match);
      if (match.id.isEmpty) {
        final doc = await _matchesRef.add(data);
        return doc.id;
      } else {
        await _matchesRef.doc(match.id).set(data, SetOptions(merge: true));
        return match.id;
      }
    } catch (e) {
      debugPrint('MatchesFirestoreRepository.saveMatch error: $e');
      rethrow;
    }
  }

  /// Deletes a match by [matchId].
  Future<void> deleteMatch(String matchId) async {
    await _matchesRef.doc(matchId).delete();
  }

  Match? _docToMatch(DocumentSnapshot<Map<String, dynamic>> doc) {
    try {
      final data = Map<String, dynamic>.from(doc.data() ?? {});
      data['id'] = doc.id;
      final dateTimeRaw = data['dateTime'];
      if (dateTimeRaw is Timestamp) {
        data['dateTime'] = dateTimeRaw.toDate().toIso8601String();
      }
      final createdAtRaw = data['createdAt'];
      if (createdAtRaw is Timestamp) {
        data['createdAt'] = createdAtRaw.toDate().toIso8601String();
      }
      return Match(
        id: data['id'] as String,
        name: data['name'] as String? ?? '',
        dateTime: DateTime.parse(data['dateTime'] as String),
        venue: data['venue'] as String?,
        matchType: _parseMatchType(data['matchType'] as String?),
        status: _parseMatchStatus(data['status'] as String?),
        homeTeamId: data['homeTeamId'] as String?,
        awayTeamId: data['awayTeamId'] as String?,
        homeScore: data['homeScore'] as int?,
        awayScore: data['awayScore'] as int?,
        reservationId: data['reservationId'] as String?,
        createdBy: data['createdBy'] as String? ?? '',
        createdAt: DateTime.parse(data['createdAt'] as String),
        playerIds: List<String>.from(data['playerIds'] as List? ?? []),
        tournamentId: data['tournamentId'] as String?,
      );
    } catch (e) {
      debugPrint('MatchesFirestoreRepository._docToMatch error: $e');
      return null;
    }
  }

  Map<String, dynamic> _matchToJson(Match match) => {
        'name': match.name,
        'dateTime': Timestamp.fromDate(match.dateTime),
        'venue': match.venue,
        'matchType': match.matchType.name,
        'status': match.status.name,
        'homeTeamId': match.homeTeamId,
        'awayTeamId': match.awayTeamId,
        'homeScore': match.homeScore,
        'awayScore': match.awayScore,
        'reservationId': match.reservationId,
        'createdBy': match.createdBy,
        // Only set createdAt on creation; preserve existing value on updates.
        if (match.id.isEmpty) 'createdAt': FieldValue.serverTimestamp(),
        'playerIds': match.playerIds,
        'tournamentId': match.tournamentId,
      };

  MatchType _parseMatchType(String? s) {
    switch (s) {
      case 'versus':
        return MatchType.versus;
      default:
        return MatchType.local;
    }
  }

  MatchStatus _parseMatchStatus(String? s) {
    switch (s) {
      case 'completed':
        return MatchStatus.completed;
      case 'ongoing':
        return MatchStatus.ongoing;
      case 'cancelled':
        return MatchStatus.cancelled;
      default:
        return MatchStatus.upcoming;
    }
  }
}
