import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';
import 'dart:math';
import '../models/match.dart';

class MatchRepository {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  CollectionReference get _matchesCollection => _firestore.collection('matches');

  Future<void> updateMatchStatus(String matchId, MatchStatus status) async {
  try {
    await _matchesCollection.doc(matchId).update({
      'status': status.name,
    });
  } catch (e) {
    debugPrint('Error updating match status: $e');
    rethrow;
  }
}

  Future<String> createMatch({
    required String name,
    required DateTime dateTime,
    required String venue,
    required String createdBy,
    List<String>? initialPlayers,
  }) async {
    try {
      final inviteCode = _generateInviteCode();
      final match = Match(
        id: '',
        name: name,
        dateTime: dateTime,
        venue: venue,
        playerIds: initialPlayers ?? [createdBy],
        confirmations: {createdBy: true},
        status: MatchStatus.pending,
        inviteCode: inviteCode,
        createdBy: createdBy,
        createdAt: DateTime.now(),
      );

      final docRef = await _matchesCollection.add(match.toMap());
      return docRef.id;
    } catch (e) {
      debugPrint('Error creating match: $e');
      rethrow;
    }
  }

  Future<Match?> getMatch(String matchId) async {
    try {
      final doc = await _matchesCollection.doc(matchId).get();
      if (doc.exists) {
        return Match.fromMap(doc.data() as Map<String, dynamic>, doc.id);
      }
      return null;
    } catch (e) {
      debugPrint('Error getting match: $e');
      return null;
    }
  }

  Future<List<Match>> getUserMatches(String userId) async {
    try {
      final querySnapshot = await _matchesCollection
          .where('playerIds', arrayContains: userId)
          .orderBy('dateTime', descending: true)
          .get();

      return querySnapshot.docs
          .map((doc) => Match.fromMap(doc.data() as Map<String, dynamic>, doc.id))
          .toList();
    } catch (e) {
      debugPrint('Error getting user matches: $e');
      return [];
    }
  }

  Future<void> updateMatch(String matchId, Map<String, dynamic> updates) async {
    try {
      await _matchesCollection.doc(matchId).update(updates);
    } catch (e) {
      debugPrint('Error updating match: $e');
      rethrow;
    }
  }

  Future<void> deleteMatch(String matchId) async {
    try {
      await _matchesCollection.doc(matchId).delete();
    } catch (e) {
      debugPrint('Error deleting match: $e');
      rethrow;
    }
  }

  Future<void> confirmAttendance(String matchId, String userId, bool confirmed) async {
    try {
      await _matchesCollection.doc(matchId).update({
        'confirmations.$userId': confirmed,
      });
    } catch (e) {
      debugPrint('Error confirming attendance: $e');
      rethrow;
    }
  }

  Future<Match?> joinMatchByCode(String inviteCode, String userId) async {
    try {
      final querySnapshot = await _matchesCollection
          .where('inviteCode', isEqualTo: inviteCode)
          .limit(1)
          .get();

      if (querySnapshot.docs.isEmpty) {
        return null;
      }

      final matchDoc = querySnapshot.docs.first;
      final match = Match.fromMap(matchDoc.data() as Map<String, dynamic>, matchDoc.id);

      if (!match.playerIds.contains(userId)) {
        await _matchesCollection.doc(matchDoc.id).update({
          'playerIds': FieldValue.arrayUnion([userId]),
          'confirmations.$userId': false,
        });

        return match.copyWith(
          playerIds: [...match.playerIds, userId],
          confirmations: {...match.confirmations, userId: false},
        );
      }

      return match;
    } catch (e) {
      debugPrint('Error joining match by code: $e');
      return null;
    }
  }

  Future<void> updateMatchVideo(String matchId, String videoUrl) async {
    try {
      await _matchesCollection.doc(matchId).update({
        'videoUrl': videoUrl,
        'status': MatchStatus.processing.name,
      });
    } catch (e) {
      debugPrint('Error updating match video: $e');
      rethrow;
    }
  }

  String _generateInviteCode() {
    const chars = 'ABCDEFGHJKLMNPQRSTUVWXYZ23456789';
    final random = Random();
    return String.fromCharCodes(
      Iterable.generate(6, (_) => chars.codeUnitAt(random.nextInt(chars.length))),
    );
  }
}
