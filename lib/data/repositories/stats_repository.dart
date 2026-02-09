import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';
import '../models/player_stats.dart';

class StatsRepository {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  CollectionReference get _statsCollection => _firestore.collection('player_stats');

  Future<void> savePlayerStats({
    required String matchId,
    required String playerId,
    required PlayerStats stats,
  }) async {
    try {
      await _statsCollection.doc('${matchId}_$playerId').set({
        ...stats.toJson(),
        'matchId': matchId,
        'playerId': playerId,
        'createdAt': FieldValue.serverTimestamp(),
      });
    } catch (e) {
      debugPrint('Error saving player stats: $e');
      rethrow;
    }
  }

  Future<PlayerStats?> getPlayerStatsForMatch(String matchId, String playerId) async {
    try {
      final doc = await _statsCollection.doc('${matchId}_$playerId').get();
      if (doc.exists) {
        final data = doc.data() as Map<String, dynamic>;
        return PlayerStats.fromJson(data);
      }
      return null;
    } catch (e) {
      debugPrint('Error getting player stats for match: $e');
      return null;
    }
  }

  Future<List<PlayerStats>> getAllPlayerStatsForMatch(String matchId) async {
    try {
      final querySnapshot = await _statsCollection
          .where('matchId', isEqualTo: matchId)
          .get();

      return querySnapshot.docs
          .map((doc) => PlayerStats.fromJson(doc.data() as Map<String, dynamic>))
          .toList();
    } catch (e) {
      debugPrint('Error getting all player stats for match: $e');
      return [];
    }
  }

  Future<List<PlayerStats>> getPlayerStatsHistory(String playerId) async {
    try {
      final querySnapshot = await _statsCollection
          .where('playerId', isEqualTo: playerId)
          .orderBy('createdAt', descending: true)
          .get();

      return querySnapshot.docs
          .map((doc) => PlayerStats.fromJson(doc.data() as Map<String, dynamic>))
          .toList();
    } catch (e) {
      debugPrint('Error getting player stats history: $e');
      return [];
    }
  }

  Future<Map<String, dynamic>> getAggregatedStats(String playerId) async {
    try {
      final stats = await getPlayerStatsHistory(playerId);
      
      if (stats.isEmpty) {
        return {};
      }

      double totalDistance = 0;
      double totalMaxSpeed = 0;
      int totalSprints = 0;
      int totalTouches = 0;
      int totalPasses = 0;
      int totalPassesCompleted = 0;
      int totalAssists = 0;
      int totalTackles = 0;
      int totalInterceptions = 0;
      double totalImpactScore = 0;

      for (final stat in stats) {
        totalDistance += stat.physical.distanceM;
        totalMaxSpeed = totalMaxSpeed > stat.physical.maxSpeedKmh 
            ? totalMaxSpeed 
            : stat.physical.maxSpeedKmh;
        totalSprints += stat.physical.sprintCount;
        totalTouches += stat.ballInteraction.touches;
        totalPasses += stat.passing.passesAttempted;
        totalPassesCompleted += stat.passing.passesCompleted;
        totalAssists += stat.passing.assists;
        totalTackles += stat.defensive.tackles;
        totalInterceptions += stat.defensive.interceptions;
        totalImpactScore += stat.advanced.impactScore;
      }

      final matchCount = stats.length;
      final avgPassAccuracy = totalPasses > 0 
          ? (totalPassesCompleted / totalPasses) * 100 
          : 0.0;

      return {
        'totalMatches': matchCount,
        'totalDistance': totalDistance,
        'avgDistance': totalDistance / matchCount,
        'maxSpeed': totalMaxSpeed,
        'totalSprints': totalSprints,
        'avgSprints': totalSprints / matchCount,
        'totalTouches': totalTouches,
        'avgTouches': totalTouches / matchCount,
        'totalPasses': totalPasses,
        'totalPassesCompleted': totalPassesCompleted,
        'avgPassAccuracy': avgPassAccuracy,
        'totalAssists': totalAssists,
        'totalTackles': totalTackles,
        'totalInterceptions': totalInterceptions,
        'avgImpactScore': totalImpactScore / matchCount,
      };
    } catch (e) {
      debugPrint('Error getting aggregated stats: $e');
      return {};
    }
  }
}
