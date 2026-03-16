import 'dart:math';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';
import '../models/tournament_model.dart';

/// Firestore repository for user-owned tournaments.
class TournamentsFirestoreRepository {
  final FirebaseFirestore _firestore;

  TournamentsFirestoreRepository({FirebaseFirestore? firestore})
      : _firestore = firestore ?? FirebaseFirestore.instance;

  CollectionReference<Map<String, dynamic>> get _tournamentsRef =>
      _firestore.collection('tournaments');

  /// Returns all tournaments created by [userId].
  Future<List<Tournament>> getTournamentsForUser(String userId) async {
    try {
      final snapshot = await _tournamentsRef
          .where('createdBy', isEqualTo: userId)
          .orderBy('createdAt', descending: true)
          .get();
      return snapshot.docs.map(_docToTournament).whereType<Tournament>().toList();
    } catch (e) {
      debugPrint('TournamentsFirestoreRepository.getTournamentsForUser error: $e');
      return [];
    }
  }

  /// Returns all public tournaments.
  Future<List<Tournament>> getPublicTournaments() async {
    try {
      final snapshot = await _tournamentsRef
          .where('isPublic', isEqualTo: true)
          .orderBy('createdAt', descending: true)
          .limit(50)
          .get();
      return snapshot.docs.map(_docToTournament).whereType<Tournament>().toList();
    } catch (e) {
      debugPrint('TournamentsFirestoreRepository.getPublicTournaments error: $e');
      return [];
    }
  }

  /// Saves [tournament] to Firestore. Returns the document id.
  Future<String> saveTournament(Tournament tournament) async {
    try {
      final data = _tournamentToJson(tournament);
      if (tournament.id.isEmpty) {
        final doc = await _tournamentsRef.add(data);
        return doc.id;
      } else {
        await _tournamentsRef.doc(tournament.id).set(data, SetOptions(merge: true));
        return tournament.id;
      }
    } catch (e) {
      debugPrint('TournamentsFirestoreRepository.saveTournament error: $e');
      rethrow;
    }
  }

  /// Deletes a tournament by [tournamentId].
  Future<void> deleteTournament(String tournamentId) async {
    await _tournamentsRef.doc(tournamentId).delete();
  }

  Tournament? _docToTournament(DocumentSnapshot<Map<String, dynamic>> doc) {
    try {
      final data = Map<String, dynamic>.from(doc.data() ?? {});
      data['id'] = doc.id;

      DateTime _ts(String key, DateTime fallback) {
        final raw = data[key];
        if (raw is Timestamp) return raw.toDate();
        if (raw is String) return DateTime.tryParse(raw) ?? fallback;
        return fallback;
      }

      return Tournament(
        id: data['id'] as String,
        name: data['name'] as String? ?? '',
        description: data['description'] as String?,
        format: _parseFormat(data['format'] as String?),
        status: _parseStatus(data['status'] as String?),
        startDate: _ts('startDate', DateTime.now()),
        endDate: data['endDate'] != null ? _ts('endDate', DateTime.now()) : null,
        sport: data['sport'] as String? ?? 'Fútbol',
        maxTeams: (data['maxTeams'] as num?)?.toInt() ?? 8,
        currentTeams: (data['currentTeams'] as num?)?.toInt() ?? 0,
        logoUrl: data['logoUrl'] as String?,
        location: data['location'] as String?,
        createdBy: data['createdBy'] as String? ?? '',
        createdAt: _ts('createdAt', DateTime.now()),
        pointsForWin: (data['pointsForWin'] as num?)?.toInt() ?? 3,
        pointsForDraw: (data['pointsForDraw'] as num?)?.toInt() ?? 1,
        pointsForLoss: (data['pointsForLoss'] as num?)?.toInt() ?? 0,
        joinCode: data['joinCode'] as String?,
        isPublic: data['isPublic'] as bool? ?? true,
      );
    } catch (e) {
      debugPrint('TournamentsFirestoreRepository._docToTournament error: $e');
      return null;
    }
  }

  Map<String, dynamic> _tournamentToJson(Tournament t) => {
        'name': t.name,
        'description': t.description,
        'format': t.format.name,
        'status': t.status.name,
        'startDate': Timestamp.fromDate(t.startDate),
        'endDate': t.endDate != null ? Timestamp.fromDate(t.endDate!) : null,
        'sport': t.sport,
        'maxTeams': t.maxTeams,
        'currentTeams': t.currentTeams,
        'logoUrl': t.logoUrl,
        'location': t.location,
        'createdBy': t.createdBy,
        // Only set createdAt on creation; preserve existing value on updates.
        if (t.id.isEmpty) 'createdAt': FieldValue.serverTimestamp(),
        'pointsForWin': t.pointsForWin,
        'pointsForDraw': t.pointsForDraw,
        'pointsForLoss': t.pointsForLoss,
        'joinCode': t.joinCode,
        'isPublic': t.isPublic,
      };

  TournamentFormat _parseFormat(String? s) {
    switch (s) {
      case 'knockout':
        return TournamentFormat.knockout;
      case 'groupsAndKnockout':
        return TournamentFormat.groupsAndKnockout;
      default:
        return TournamentFormat.league;
    }
  }

  TournamentStatus _parseStatus(String? s) {
    switch (s) {
      case 'ongoing':
        return TournamentStatus.ongoing;
      case 'completed':
        return TournamentStatus.completed;
      case 'cancelled':
        return TournamentStatus.cancelled;
      default:
        return TournamentStatus.upcoming;
    }
  }

  static String generateJoinCode() {
    const chars = 'ABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789';
    final rand = Random.secure();
    return List.generate(6, (_) => chars[rand.nextInt(chars.length)]).join();
  }
}
