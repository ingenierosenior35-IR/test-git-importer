import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import '../models/espn_models.dart';

/// Service to fetch sports data from ESPN public APIs.
///
/// Uses:
///   - `http://site.api.espn.com/apis/site/v2/sports/soccer/:league/teams`
///   - `http://site.api.espn.com/apis/site/v2/sports/soccer/:league/scoreboard`
class EspnApiService {
  static const String _siteBaseUrl =
      'http://site.api.espn.com/apis/site/v2/sports/soccer';

  final http.Client _client;

  EspnApiService({http.Client? client}) : _client = client ?? http.Client();

  /// Fetches the list of teams for a given [league] slug (e.g., 'esp.1').
  Future<List<EspnTeam>> getTeams(String league) async {
    final uri = Uri.parse('$_siteBaseUrl/$league/teams');
    try {
      final response = await _client.get(uri).timeout(const Duration(seconds: 15));
      if (response.statusCode == 200) {
        final data = json.decode(response.body) as Map<String, dynamic>;
        final sports = data['sports'] as List<dynamic>?;
        if (sports == null || sports.isEmpty) return [];
        final leagues = (sports.first as Map<String, dynamic>)['leagues'] as List<dynamic>?;
        if (leagues == null || leagues.isEmpty) return [];
        final teams = (leagues.first as Map<String, dynamic>)['teams'] as List<dynamic>? ?? [];
        return teams
            .map((t) => EspnTeam.fromJson((t as Map<String, dynamic>)['team'] as Map<String, dynamic>))
            .toList();
      }
      debugPrint('ESPN teams error ${response.statusCode} for $league');
      return [];
    } catch (e) {
      debugPrint('ESPN getTeams exception: $e');
      return [];
    }
  }

  /// Fetches current scoreboard events for a [league] slug.
  ///
  /// Returns the upcoming / in-progress / recently-finished events.
  Future<List<EspnEvent>> getScoreboard(String league) async {
    final uri = Uri.parse('$_siteBaseUrl/$league/scoreboard');
    try {
      final response = await _client.get(uri).timeout(const Duration(seconds: 15));
      if (response.statusCode == 200) {
        final data = json.decode(response.body) as Map<String, dynamic>;
        final events = data['events'] as List<dynamic>? ?? [];
        return events.map((e) => EspnEvent.fromJson(e as Map<String, dynamic>)).toList();
      }
      debugPrint('ESPN scoreboard error ${response.statusCode} for $league');
      return [];
    } catch (e) {
      debugPrint('ESPN getScoreboard exception: $e');
      return [];
    }
  }

  /// Fetches full match detail including timeline for a given [eventId] in [league].
  Future<EspnMatchDetail?> getMatchDetail(String league, String eventId) async {
    final uri = Uri.parse('$_siteBaseUrl/$league/summary?event=$eventId');
    try {
      final response = await _client.get(uri).timeout(const Duration(seconds: 15));
      if (response.statusCode == 200) {
        final data = json.decode(response.body) as Map<String, dynamic>;
        return EspnMatchDetail.fromJson(data);
      }
      debugPrint('ESPN getMatchDetail error ${response.statusCode} for $league/$eventId');
      return null;
    } catch (e) {
      debugPrint('ESPN getMatchDetail exception: $e');
      return null;
    }
  }

  /// Fetches play-by-play timeline events for a given [eventId] in [league].
  Future<List<EspnPlay>> getTimeline(String league, String eventId) async {
    final detail = await getMatchDetail(league, eventId);
    return detail?.timeline ?? [];
  }
}
