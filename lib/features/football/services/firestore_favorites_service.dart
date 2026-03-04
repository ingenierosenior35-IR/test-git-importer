import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';
import '../data/models/favorite_team_model.dart';

/// Firestore-backed service for managing a user's favourite soccer teams.
///
/// Schema: `users/{uid}/favorite_teams/{league}_{teamId}`
///
/// Each document contains: league, teamId, name, logoUrl, createdAt.
///
/// For unauthenticated users all write operations are no-ops and reads return
/// empty results.
class FirestoreFavoritesService {
  static const _subcollection = 'favorite_teams';

  static FirebaseFirestore get _db => FirebaseFirestore.instance;

  static String? get _uid => FirebaseAuth.instance.currentUser?.uid;

  static CollectionReference<Map<String, dynamic>>? get _col {
    final uid = _uid;
    if (uid == null) return null;
    return _db
        .collection('users')
        .doc(uid)
        .collection(_subcollection)
        .withConverter(
          fromFirestore: (s, _) => s.data() ?? {},
          toFirestore: (d, _) => d,
        );
  }

  /// Returns a real-time stream of the current user's favourite teams.
  ///
  /// The stream reacts to Firebase Auth state changes: when the user signs in
  /// it starts streaming from Firestore, and when the user signs out it emits
  /// an empty list.
  static Stream<List<FavoriteTeam>> watchFavorites() {
    return FirebaseAuth.instance.authStateChanges().asyncExpand((user) {
      if (user == null) return Stream.value(<FavoriteTeam>[]);
      return _db
          .collection('users')
          .doc(user.uid)
          .collection(_subcollection)
          .orderBy('createdAt', descending: true)
          .snapshots()
          .map((snap) => snap.docs
              .map((d) =>
                  FavoriteTeam.fromMap(d.data() as Map<String, dynamic>? ?? {}))
              .toList());
    });
  }

  /// Returns the current snapshot of the user's favourite teams.
  static Future<List<FavoriteTeam>> getFavorites() async {
    final col = _col;
    if (col == null) return [];
    try {
      final snap = await col.get();
      return snap.docs.map((d) => FavoriteTeam.fromMap(d.data())).toList();
    } catch (e) {
      debugPrint('FirestoreFavoritesService.getFavorites error: $e');
      return [];
    }
  }

  /// Returns the set of `teamId` values that the user has favourited,
  /// optionally filtered to a single [league].
  static Future<Set<String>> getFavoriteTeamIds({String? league}) async {
    final all = await getFavorites();
    return all
        .where((f) => league == null || f.league == league)
        .map((f) => f.teamId)
        .toSet();
  }

  /// Adds [team] to the user's favourites.
  ///
  /// Returns `true` on success, `false` if the user is not signed in or an
  /// error occurs.
  static Future<bool> addFavorite(FavoriteTeam team) async {
    final col = _col;
    if (col == null) return false;
    try {
      await col.doc(team.docId).set({
        ...team.toMap(),
        'createdAt': FieldValue.serverTimestamp(),
      });
      return true;
    } catch (e) {
      debugPrint('FirestoreFavoritesService.addFavorite error: $e');
      return false;
    }
  }

  /// Removes [league]+[teamId] from the user's favourites.
  ///
  /// Returns `true` on success or if the document did not exist.
  static Future<bool> removeFavorite(String league, String teamId) async {
    final col = _col;
    if (col == null) return false;
    try {
      await col.doc('${league}_$teamId').delete();
      return true;
    } catch (e) {
      debugPrint('FirestoreFavoritesService.removeFavorite error: $e');
      return false;
    }
  }

  /// Returns whether the given [league]+[teamId] combination is a favourite.
  static Future<bool> isFavorite(String league, String teamId) async {
    final col = _col;
    if (col == null) return false;
    try {
      final doc = await col.doc('${league}_$teamId').get();
      return doc.exists;
    } catch (e) {
      debugPrint('FirestoreFavoritesService.isFavorite error: $e');
      return false;
    }
  }

  /// Toggles the favourite status for the given team.
  ///
  /// Returns `true` if the team was added, `false` if it was removed.
  static Future<bool> toggleFavorite({
    required String league,
    required String teamId,
    required String name,
    String? logoUrl,
  }) async {
    final currently = await isFavorite(league, teamId);
    if (currently) {
      await removeFavorite(league, teamId);
      return false;
    } else {
      await addFavorite(FavoriteTeam(
        league: league,
        teamId: teamId,
        name: name,
        logoUrl: logoUrl,
      ));
      return true;
    }
  }
}
