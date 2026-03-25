import 'dart:math';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';
import '../models/tournament_model.dart';

/// Firestore repository for user-owned tournaments.
///
/// Firestore schema:
///   tournaments/{tournamentId}           – tournament document
///   tournaments/{tournamentId}/teams/{teamId}    – enrolled teams
///   tournaments/{tournamentId}/matches/{matchId} – bracket matches
class TournamentsFirestoreRepository {
  final FirebaseFirestore _firestore;

  TournamentsFirestoreRepository({FirebaseFirestore? firestore})
      : _firestore = firestore ?? FirebaseFirestore.instance;

  CollectionReference<Map<String, dynamic>> get _tournamentsRef =>
      _firestore.collection('tournaments');

  CollectionReference<Map<String, dynamic>> _teamsRef(String tournamentId) =>
      _tournamentsRef.doc(tournamentId).collection('teams');

  CollectionReference<Map<String, dynamic>> _matchesRef(String tournamentId) =>
      _tournamentsRef.doc(tournamentId).collection('matches');

  // ─────────────────────────────────────────────────────────────────────────
  // Tournament CRUD
  // ─────────────────────────────────────────────────────────────────────────

  /// Returns all tournaments created by [userId].
  Future<List<Tournament>> getTournamentsForUser(String userId) async {
    try {
      // Filter by createdBy only (no compound index needed); sort client-side.
      final snapshot = await _tournamentsRef
          .where('createdBy', isEqualTo: userId)
          .get();
      final result = snapshot.docs
          .map(_docToTournament)
          .whereType<Tournament>()
          .toList()
        ..sort((a, b) => b.createdAt.compareTo(a.createdAt));
      return result;
    } catch (e) {
      debugPrint('TournamentsFirestoreRepository.getTournamentsForUser error: $e');
      return [];
    }
  }

  /// Returns all public tournaments (sorted client-side, no composite index needed).
  Future<List<Tournament>> getPublicTournaments() async {
    try {
      final snapshot = await _tournamentsRef
          .where('isPublic', isEqualTo: true)
          .limit(50)
          .get();
      final result = snapshot.docs
          .map(_docToTournament)
          .whereType<Tournament>()
          .toList()
        ..sort((a, b) => b.createdAt.compareTo(a.createdAt));
      return result;
    } catch (e) {
      debugPrint('TournamentsFirestoreRepository.getPublicTournaments error: $e');
      return [];
    }
  }

  /// Fetches a single tournament by [tournamentId].
  Future<Tournament?> getTournament(String tournamentId) async {
    try {
      final doc = await _tournamentsRef.doc(tournamentId).get();
      if (!doc.exists) return null;
      return _docToTournament(doc);
    } catch (e) {
      debugPrint('TournamentsFirestoreRepository.getTournament error: $e');
      return null;
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

  /// Updates only the status (and optionally currentRound) of a tournament.
  Future<void> updateTournamentStatus(
      String tournamentId, TournamentStatus status,
      {int? currentRound}) async {
    final data = <String, dynamic>{'status': _statusName(status)};
    if (currentRound != null) data['currentRound'] = currentRound;
    await _tournamentsRef.doc(tournamentId).update(data);
  }

  /// Deletes a tournament by [tournamentId].
  Future<void> deleteTournament(String tournamentId) async {
    await _tournamentsRef.doc(tournamentId).delete();
  }

  // ─────────────────────────────────────────────────────────────────────────
  // Enrolled teams subcollection
  // ─────────────────────────────────────────────────────────────────────────

  /// Returns the list of teams enrolled in [tournamentId], ordered by join time.
  Future<List<TournamentEnrolledTeam>> getEnrolledTeams(
      String tournamentId) async {
    try {
      final snapshot = await _teamsRef(tournamentId)
          .orderBy('joinedAt', descending: false)
          .get();
      return snapshot.docs
          .map(_docToEnrolledTeam)
          .whereType<TournamentEnrolledTeam>()
          .toList();
    } catch (e) {
      debugPrint('TournamentsFirestoreRepository.getEnrolledTeams error: $e');
      return [];
    }
  }

  /// Returns true if [teamId] is already enrolled in [tournamentId].
  Future<bool> isTeamEnrolled(String tournamentId, String teamId) async {
    final doc = await _teamsRef(tournamentId).doc(teamId).get();
    return doc.exists;
  }

  /// Joins [team] to [tournamentId] atomically using a batch write.
  ///
  /// Validates:
  ///   - Tournament is in joinable state (draft/open/upcoming).
  ///   - Team is not already enrolled.
  ///   - maxTeams not exceeded.
  Future<void> joinTournament({
    required String tournamentId,
    required String teamId,
    required String teamName,
    required String ownerUserId,
    String? logoUrl,
  }) async {
    final tournamentDoc = _tournamentsRef.doc(tournamentId);
    final teamDoc = _teamsRef(tournamentId).doc(teamId);

    await _firestore.runTransaction((txn) async {
      final tSnap = await txn.get(tournamentDoc);
      if (!tSnap.exists) throw Exception('El torneo no existe.');

      final tournament = _docToTournament(tSnap);
      if (tournament == null) throw Exception('Error al leer el torneo.');
      if (!tournament.canJoin) {
        throw Exception('No se puede unir: el torneo ya inició o está lleno.');
      }

      final teamSnap = await txn.get(teamDoc);
      if (teamSnap.exists) throw Exception('El equipo ya está inscrito.');

      txn.set(teamDoc, {
        'teamId': teamId,
        'teamName': teamName,
        'ownerUserId': ownerUserId,
        'logoUrl': logoUrl,
        'joinedAt': FieldValue.serverTimestamp(),
      });

      txn.update(tournamentDoc, {
        'currentTeams': FieldValue.increment(1),
      });
    });
  }

  /// Removes a team from the tournament (admin-only; call after checking perms).
  Future<void> leaveOrRemoveTeam(
      String tournamentId, String teamId) async {
    final batch = _firestore.batch();
    batch.delete(_teamsRef(tournamentId).doc(teamId));
    batch.update(_tournamentsRef.doc(tournamentId), {
      'currentTeams': FieldValue.increment(-1),
    });
    await batch.commit();
  }

  // ─────────────────────────────────────────────────────────────────────────
  // Bracket / Matches subcollection
  // ─────────────────────────────────────────────────────────────────────────

  /// Returns all matches for [tournamentId] sorted by round then matchIndex.
  /// Sorting is done client-side to avoid a composite Firestore index.
  Future<List<TournamentMatch>> getTournamentMatches(
      String tournamentId) async {
    try {
      final snapshot = await _matchesRef(tournamentId).get();
      final result = snapshot.docs
          .map(_docToTournamentMatch)
          .whereType<TournamentMatch>()
          .toList()
        ..sort((a, b) {
          final roundCmp = a.round.compareTo(b.round);
          if (roundCmp != 0) return roundCmp;
          return a.matchIndex.compareTo(b.matchIndex);
        });
      return result;
    } catch (e) {
      debugPrint('TournamentsFirestoreRepository.getTournamentMatches error: $e');
      return [];
    }
  }

  /// Generates and persists a single-elimination bracket for [tournament].
  ///
  /// Requires at least 2 enrolled teams. Teams with a BYE advance automatically.
  /// Ordering is deterministic: teams are sorted by [joinedAt] ascending.
  ///
  /// Sets tournament status → started and currentRound → 1.
  Future<void> generateBracket(Tournament tournament) async {
    if (tournament.format != TournamentFormat.knockout) {
      throw Exception(
          'La generación automática de bracket solo aplica al formato eliminación.');
    }

    final enrolled = await getEnrolledTeams(tournament.id);
    if (enrolled.length < 2) {
      throw Exception(
          'Se necesitan al menos 2 equipos para generar el bracket.');
    }

    final matches = buildBracketRound1(enrolled);
    final batch = _firestore.batch();

    for (final m in matches) {
      final ref = _matchesRef(tournament.id).doc();
      batch.set(ref, _tournamentMatchToJson(m.copyWith(id: ref.id)));
    }

    // Mark tournament as started with round 1
    batch.update(_tournamentsRef.doc(tournament.id), {
      'status': _statusName(TournamentStatus.started),
      'currentRound': 1,
    });

    await batch.commit();
  }

  /// Records the result of a match and, if the entire round is now finished,
  /// automatically generates the next round (or marks the tournament as finished).
  Future<void> updateMatchResult({
    required String tournamentId,
    required String matchId,
    required int homeScore,
    required int awayScore,
    required String winnerTeamId,
    String winnerTeamName = '',
  }) async {
    final matchRef = _matchesRef(tournamentId).doc(matchId);
    await matchRef.update({
      'homeScore': homeScore,
      'awayScore': awayScore,
      'winnerTeamId': winnerTeamId,
      'status': 'finished',
    });

    // Check if all matches in the current round are finished to advance.
    await _advanceRoundIfComplete(tournamentId);
  }

  /// Checks whether the current round is fully finished; if so, generates the
  /// next round or marks the tournament as finished.
  Future<void> _advanceRoundIfComplete(String tournamentId) async {
    final tSnap = await _tournamentsRef.doc(tournamentId).get();
    if (!tSnap.exists) return;
    final tournament = _docToTournament(tSnap);
    if (tournament == null) return;
    if (tournament.currentRound < 1) return;

    final allMatches = await getTournamentMatches(tournamentId);
    final roundMatches =
        allMatches.where((m) => m.round == tournament.currentRound).toList();

    // All matches in the round must be finished (including byes which are auto-finished).
    final allFinished = roundMatches.isNotEmpty &&
        roundMatches.every((m) => m.isFinished);

    if (!allFinished) return;

    // Collect winners ordered by matchIndex.
    final winners = roundMatches
      ..sort((a, b) => a.matchIndex.compareTo(b.matchIndex));
    final winnerList = winners.map((m) {
      final id = m.effectiveWinnerId ?? '';
      final name = m.winnerTeamId == m.homeTeamId
          ? (m.homeTeamName ?? '')
          : (m.awayTeamName ?? '');
      return TournamentEnrolledTeam(
        teamId: id,
        teamName: name,
        ownerUserId: '',
        joinedAt: DateTime.now(),
      );
    }).toList();

    if (winnerList.length == 1) {
      // Tournament finished
      await _tournamentsRef.doc(tournamentId).update({
        'status': _statusName(TournamentStatus.finished),
      });
      return;
    }

    // Generate next round
    final nextRound = tournament.currentRound + 1;
    final nextMatches = buildBracketRound(winnerList, round: nextRound);
    final batch = _firestore.batch();
    for (final m in nextMatches) {
      final ref = _matchesRef(tournamentId).doc();
      batch.set(ref, _tournamentMatchToJson(m.copyWith(id: ref.id)));
    }
    batch.update(_tournamentsRef.doc(tournamentId), {
      'currentRound': nextRound,
    });
    await batch.commit();
  }

  // ─────────────────────────────────────────────────────────────────────────
  // Bracket algorithm (pure, testable)
  // ─────────────────────────────────────────────────────────────────────────

  /// Builds round-1 bracket matches for [enrolled] teams.
  ///
  /// If the count is not a power of 2, the top-seeded teams receive a BYE
  /// (i.e., they advance automatically without playing).
  ///
  /// [enrolled] should already be sorted by joinedAt ascending for determinism.
  static List<TournamentMatch> buildBracketRound1(
      List<TournamentEnrolledTeam> enrolled) {
    return buildBracketRound(enrolled, round: 1);
  }

  /// Builds bracket matches for [teams] in the given [round].
  static List<TournamentMatch> buildBracketRound(
      List<TournamentEnrolledTeam> teams,
      {required int round}) {
    final n = teams.length;
    if (n < 2) return [];

    // Next power of 2 >= n
    final slots = _nextPowerOf2(n);
    final byeCount = slots - n;

    // Create a seeded list padded with nulls (= byes) interleaved at the end.
    // The first [byeCount] positions get a BYE partner.
    final padded = List<TournamentEnrolledTeam?>.from(teams)
      ..addAll(List<TournamentEnrolledTeam?>.filled(byeCount, null));

    final matches = <TournamentMatch>[];
    for (int i = 0; i < padded.length; i += 2) {
      final home = padded[i];
      final away = padded[i + 1];
      final isBye = away == null;
      matches.add(TournamentMatch(
        id: '',
        round: round,
        matchIndex: i ~/ 2,
        homeTeamId: home?.teamId,
        awayTeamId: away?.teamId,
        homeTeamName: home?.teamName,
        awayTeamName: away?.teamName,
        status: isBye ? 'bye' : 'scheduled',
        winnerTeamId: isBye ? home?.teamId : null,
      ));
    }
    return matches;
  }

  static int _nextPowerOf2(int n) {
    if (n <= 1) return 1;
    var p = 1;
    while (p < n) {
      p <<= 1;
    }
    return p;
  }

  // ─────────────────────────────────────────────────────────────────────────
  // Serialisation helpers
  // ─────────────────────────────────────────────────────────────────────────

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
        currentRound: (data['currentRound'] as num?)?.toInt() ?? 0,
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

  TournamentEnrolledTeam? _docToEnrolledTeam(
      DocumentSnapshot<Map<String, dynamic>> doc) {
    try {
      final data = Map<String, dynamic>.from(doc.data() ?? {});
      final raw = data['joinedAt'];
      DateTime joinedAt;
      if (raw is Timestamp) {
        joinedAt = raw.toDate();
      } else if (raw is String) {
        joinedAt = DateTime.tryParse(raw) ?? DateTime.now();
      } else {
        joinedAt = DateTime.now();
      }
      return TournamentEnrolledTeam(
        teamId: data['teamId'] as String? ?? doc.id,
        teamName: data['teamName'] as String? ?? '',
        ownerUserId: data['ownerUserId'] as String? ?? '',
        joinedAt: joinedAt,
        logoUrl: data['logoUrl'] as String?,
      );
    } catch (e) {
      debugPrint('TournamentsFirestoreRepository._docToEnrolledTeam error: $e');
      return null;
    }
  }

  TournamentMatch? _docToTournamentMatch(
      DocumentSnapshot<Map<String, dynamic>> doc) {
    try {
      final data = Map<String, dynamic>.from(doc.data() ?? {});
      DateTime? scheduledAt;
      final raw = data['scheduledAt'];
      if (raw is Timestamp) {
        scheduledAt = raw.toDate();
      } else if (raw is String) {
        scheduledAt = DateTime.tryParse(raw);
      }
      return TournamentMatch(
        id: doc.id,
        round: (data['round'] as num?)?.toInt() ?? 1,
        matchIndex: (data['matchIndex'] as num?)?.toInt() ?? 0,
        homeTeamId: data['homeTeamId'] as String?,
        awayTeamId: data['awayTeamId'] as String?,
        homeTeamName: data['homeTeamName'] as String?,
        awayTeamName: data['awayTeamName'] as String?,
        homeScore: (data['homeScore'] as num?)?.toInt(),
        awayScore: (data['awayScore'] as num?)?.toInt(),
        scheduledAt: scheduledAt,
        status: data['status'] as String? ?? 'scheduled',
        winnerTeamId: data['winnerTeamId'] as String?,
      );
    } catch (e) {
      debugPrint(
          'TournamentsFirestoreRepository._docToTournamentMatch error: $e');
      return null;
    }
  }

  Map<String, dynamic> _tournamentToJson(Tournament t) => {
        'name': t.name,
        'description': t.description,
        'format': t.format.name,
        'status': _statusName(t.status),
        'startDate': Timestamp.fromDate(t.startDate),
        'endDate': t.endDate != null ? Timestamp.fromDate(t.endDate!) : null,
        'sport': t.sport,
        'maxTeams': t.maxTeams,
        'currentTeams': t.currentTeams,
        'logoUrl': t.logoUrl,
        'location': t.location,
        'createdBy': t.createdBy,
        if (t.id.isEmpty) 'createdAt': FieldValue.serverTimestamp(),
        'currentRound': t.currentRound,
        'pointsForWin': t.pointsForWin,
        'pointsForDraw': t.pointsForDraw,
        'pointsForLoss': t.pointsForLoss,
        'joinCode': t.joinCode,
        'isPublic': t.isPublic,
      };

  Map<String, dynamic> _tournamentMatchToJson(TournamentMatch m) => {
        'round': m.round,
        'matchIndex': m.matchIndex,
        'homeTeamId': m.homeTeamId,
        'awayTeamId': m.awayTeamId,
        'homeTeamName': m.homeTeamName,
        'awayTeamName': m.awayTeamName,
        'homeScore': m.homeScore,
        'awayScore': m.awayScore,
        'scheduledAt':
            m.scheduledAt != null ? Timestamp.fromDate(m.scheduledAt!) : null,
        'status': m.status,
        'winnerTeamId': m.winnerTeamId,
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
      case 'draft':
        return TournamentStatus.draft;
      case 'open':
        return TournamentStatus.open;
      case 'started':
        return TournamentStatus.started;
      case 'finished':
        return TournamentStatus.finished;
      case 'cancelled':
        return TournamentStatus.cancelled;
      // Legacy values
      case 'upcoming':
        return TournamentStatus.open;
      case 'ongoing':
        return TournamentStatus.started;
      case 'completed':
        return TournamentStatus.finished;
      default:
        return TournamentStatus.open;
    }
  }

  String _statusName(TournamentStatus s) {
    switch (s) {
      case TournamentStatus.draft:
        return 'draft';
      case TournamentStatus.open:
        return 'open';
      case TournamentStatus.started:
        return 'started';
      case TournamentStatus.finished:
        return 'finished';
      case TournamentStatus.cancelled:
        return 'cancelled';
      // Legacy – normalise to canonical names on write
      case TournamentStatus.upcoming:
        return 'open';
      case TournamentStatus.ongoing:
        return 'started';
      case TournamentStatus.completed:
        return 'finished';
    }
  }

  static String generateJoinCode() {
    const chars = 'ABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789';
    final rand = Random.secure();
    return List.generate(6, (_) => chars[rand.nextInt(chars.length)]).join();
  }
}
