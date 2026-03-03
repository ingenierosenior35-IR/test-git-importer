import 'dart:math';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';
import '../models/poll_model.dart';

/// Repository for persisting and retrieving [Poll] documents in Firestore.
class PollsFirebaseRepository {
  final FirebaseFirestore _firestore;

  PollsFirebaseRepository({FirebaseFirestore? firestore})
      : _firestore = firestore ?? FirebaseFirestore.instance;

  CollectionReference<Map<String, dynamic>> get _pollsRef =>
      _firestore.collection('polls');

  /// Saves [poll] to Firestore. Returns the document id.
  Future<String> createPoll(Poll poll) async {
    try {
      final data = poll.toJson();
      // Use server timestamp for createdAt
      data['createdAt'] = FieldValue.serverTimestamp();
      if (poll.id.isEmpty) {
        final doc = await _pollsRef.add(data);
        return doc.id;
      } else {
        await _pollsRef.doc(poll.id).set(data);
        return poll.id;
      }
    } catch (e) {
      debugPrint('PollsFirebaseRepository.createPoll error: $e');
      rethrow;
    }
  }

  /// Returns all polls where [userId] is the creator or a participant.
  Future<List<Poll>> getPollsForUser(String userId) async {
    try {
      final results = await Future.wait([
        _pollsRef.where('creatorId', isEqualTo: userId).get(),
        _pollsRef.where('participantIds', arrayContains: userId).get(),
      ]);

      final docs = <String, QueryDocumentSnapshot<Map<String, dynamic>>>{};
      for (final snapshot in results) {
        for (final doc in snapshot.docs) {
          docs[doc.id] = doc;
        }
      }

      return docs.values.map(_docToPoll).whereType<Poll>().toList()
        ..sort((a, b) => b.createdAt.compareTo(a.createdAt));
    } catch (e) {
      debugPrint('PollsFirebaseRepository.getPollsForUser error: $e');
      return [];
    }
  }

  /// Fetches a single poll by [id].
  Future<Poll?> getPollById(String id) async {
    try {
      final doc = await _pollsRef.doc(id).get();
      if (!doc.exists) return null;
      return _docSnapshotToPoll(doc);
    } catch (e) {
      debugPrint('PollsFirebaseRepository.getPollById error: $e');
      return null;
    }
  }

  /// Adds [userId] to the participants list of poll [pollId].
  Future<void> joinPoll({required String pollId, required String userId}) async {
    await _pollsRef.doc(pollId).update({
      'participantIds': FieldValue.arrayUnion([userId]),
    });
  }

  /// Fetches poll by join code. Returns null if not found.
  Future<Poll?> getPollByJoinCode(String joinCode) async {
    try {
      final snapshot = await _pollsRef
          .where('joinCode', isEqualTo: joinCode.toUpperCase())
          .limit(1)
          .get();
      if (snapshot.docs.isEmpty) return null;
      return _docToPoll(snapshot.docs.first);
    } catch (e) {
      debugPrint('PollsFirebaseRepository.getPollByJoinCode error: $e');
      return null;
    }
  }

  Poll? _docToPoll(QueryDocumentSnapshot<Map<String, dynamic>> doc) {
    try {
      final data = Map<String, dynamic>.from(doc.data());
      return _normalizeAndParse(doc.id, data);
    } catch (e) {
      debugPrint('PollsFirebaseRepository._docToPoll error: $e');
      return null;
    }
  }

  Poll? _docSnapshotToPoll(DocumentSnapshot<Map<String, dynamic>> doc) {
    try {
      final raw = doc.data();
      if (raw == null) return null;
      final data = Map<String, dynamic>.from(raw);
      return _normalizeAndParse(doc.id, data);
    } catch (e) {
      debugPrint('PollsFirebaseRepository._docSnapshotToPoll error: $e');
      return null;
    }
  }

  Poll? _normalizeAndParse(String docId, Map<String, dynamic> data) {
    try {
      data['id'] = docId;
      // Convert Firestore Timestamp to ISO string
      final createdAt = data['createdAt'];
      if (createdAt is Timestamp) {
        data['createdAt'] = createdAt.toDate().toIso8601String();
      } else if (createdAt == null) {
        data['createdAt'] = DateTime.now().toIso8601String();
      }
      if (data['participantIds'] == null) {
        data['participantIds'] = <String>[];
      }
      if (data['fixtures'] == null) {
        data['fixtures'] = <dynamic>[];
      }
      return Poll.fromJson(data);
    } catch (e) {
      debugPrint('PollsFirebaseRepository._normalizeAndParse error: $e');
      return null;
    }
  }

  /// Saves a prediction for a fixture inside a poll.
  Future<void> savePrediction({
    required String pollId,
    required String userId,
    required String userName,
    required String fixtureId,
    required String homeScore,
    required String awayScore,
  }) async {
    final predRef = _pollsRef
        .doc(pollId)
        .collection('predictions')
        .doc('${userId}_$fixtureId');
    await predRef.set({
      'pollId': pollId,
      'userId': userId,
      'userName': userName,
      'fixtureId': fixtureId,
      'homeTeamPrediction': homeScore,
      'awayTeamPrediction': awayScore,
      'predictedAt': FieldValue.serverTimestamp(),
    }, SetOptions(merge: true));
  }

  /// Returns all predictions for a given poll.
  Future<List<Map<String, dynamic>>> getPredictions(String pollId) async {
    try {
      final snapshot =
          await _pollsRef.doc(pollId).collection('predictions').get();
      return snapshot.docs.map((d) => d.data()).toList();
    } catch (e) {
      debugPrint('PollsFirebaseRepository.getPredictions error: $e');
      return [];
    }
  }

  /// Generates a random 6-character uppercase alphanumeric code.
  static String generateJoinCode() {
    const chars = 'ABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789';
    final rand = Random.secure();
    return List.generate(6, (_) => chars[rand.nextInt(chars.length)]).join();
  }
}
