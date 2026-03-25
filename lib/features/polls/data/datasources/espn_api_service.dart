import 'dart:convert';
import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;

import '../models/espn_models.dart';

/// Service to fetch sports data from ESPN public APIs.
///
/// Uses:
///   - Site API: `https://site.api.espn.com/apis/site/v2/sports/soccer/`
///   - Core API: `https://sports.core.api.espn.com/v2/sports/soccer/leagues`
class EspnApiService {
  static const String _siteBaseUrl =
      'https://site.api.espn.com/apis/site/v2/sports/soccer';
  static const String _coreLeaguesUrl =
      'https://sports.core.api.espn.com/v2/sports/soccer/leagues';

  // ---- Tuning ----
  static const Duration _kDefaultTimeout = Duration(seconds: 15);
  static const Duration _kScheduleTimeout = Duration(seconds: 20);

  /// Month (1-based) from which a new soccer season is considered to have started.
  /// Seasons beginning in August are labelled by their start year.
  static const int _kSeasonStartMonth = 8;

  /// Minimum number of events from the current season before the previous season
  /// is also fetched to fill in data.
  static const int _kMinEventsThreshold = 5;

  final http.Client _client;

  EspnApiService({http.Client? client}) : _client = client ?? http.Client();

  // ────────────────────────────────────────────────────────────────────────────
  // Core API - Leagues
  // ────────────────────────────────────────────────────────────────────────────

  /// Fetches the list of all available soccer leagues from the ESPN Core API.
  ///
  /// Merges dynamic leagues with the [EspnLeague.popularLeagues] static list so
  /// that well-known leagues always have a human-readable name.
  /// Falls back to [EspnLeague.popularLeagues] on any error.
  Future<List<EspnLeague>> getLeagues({int limit = 200}) async {
    try {
      final uri = Uri.parse('$_coreLeaguesUrl?limit=$limit');
      final response = await _client.get(uri).timeout(_kDefaultTimeout);

      if (response.statusCode == 200) {
        final data = json.decode(response.body) as Map<String, dynamic>;
        final items = data['items'] as List<dynamic>? ?? [];

        // Build a slug → EspnLeague map from the static popular list so we can
        // preserve human-readable names.
        final popularMap = {
          for (final l in EspnLeague.popularLeagues) l.slug: l
        };

        final leagues = <EspnLeague>[];
        for (final item in items) {
          final itemMap = _asMap(item);
          // Items may contain full league data or just a $ref link.
          if (itemMap.containsKey('slug') || itemMap.containsKey('id')) {
            final league = EspnLeague.fromCoreApi(itemMap);
            if (league.slug.isNotEmpty) {
              leagues.add(popularMap[league.slug] ?? league);
            }
          } else if (itemMap.containsKey(r'$ref')) {
            final slug = EspnLeague.slugFromRef(itemMap[r'$ref'] as String? ?? '');
            if (slug != null && slug.isNotEmpty) {
              leagues.add(popularMap[slug] ?? EspnLeague(slug: slug, name: slug));
            }
          }
        }

        if (leagues.isNotEmpty) {
          // Sort: popular leagues first, then alphabetical by name.
          final popularSlugs =
              EspnLeague.popularLeagues.map((l) => l.slug).toList();
          leagues.sort((a, b) {
            final ai = popularSlugs.indexOf(a.slug);
            final bi = popularSlugs.indexOf(b.slug);
            if (ai >= 0 && bi >= 0) return ai.compareTo(bi);
            if (ai >= 0) return -1;
            if (bi >= 0) return 1;
            return a.name.compareTo(b.name);
          });
          return leagues;
        }
      }

      debugPrint('ESPN getLeagues fallback: status ${response.statusCode}');
    } catch (e) {
      debugPrint('ESPN getLeagues exception: $e');
    }

    return EspnLeague.popularLeagues;
  }

  // ────────────────────────────────────────────────────────────────────────────
  // Site API - League Data
  // ────────────────────────────────────────────────────────────────────────────

  /// Fetches the list of teams for a given [league] slug (e.g., 'esp.1').
  Future<List<EspnTeam>> getTeams(String league) async {
    final uri = Uri.parse('$_siteBaseUrl/$league/teams');
    try {
      final response = await _client.get(uri).timeout(_kDefaultTimeout);
      if (response.statusCode == 200) {
        final data = json.decode(response.body) as Map<String, dynamic>;
        final sports = data['sports'] as List<dynamic>?;
        if (sports == null || sports.isEmpty) return [];

        final leagues = (_asMap(sports.first))['leagues'] as List<dynamic>?;
        if (leagues == null || leagues.isEmpty) return [];

        final teams = (_asMap(leagues.first))['teams'] as List<dynamic>? ?? [];
        return teams
            .map((t) => EspnTeam.fromJson(_asMap(_asMap(t)['team'])))
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
  /// Returns the upcoming / in-progress / recently-finished events for the current week.
  Future<List<EspnEvent>> getScoreboard(String league) async {
    final uri = Uri.parse('$_siteBaseUrl/$league/scoreboard');
    try {
      final response = await _client.get(uri).timeout(_kDefaultTimeout);
      if (response.statusCode == 200) {
        final data = json.decode(response.body) as Map<String, dynamic>;
        final events = data['events'] as List<dynamic>? ?? [];
        return events
            .whereType<Map<String, dynamic>>()
            .map(EspnEvent.fromJson)
            .toList();
      }

      debugPrint('ESPN scoreboard error ${response.statusCode} for $league');
      return [];
    } catch (e) {
      debugPrint('ESPN getScoreboard exception: $e');
      return [];
    }
  }

  /// Fetches scoreboard events for a [league] on a specific day [date] (YYYYMMDD).
  Future<List<EspnEvent>> getScoreboardForDate(String league, String date) async {
    final uri = Uri.parse('$_siteBaseUrl/$league/scoreboard?dates=$date');
    try {
      final response = await _client.get(uri).timeout(_kDefaultTimeout);
      if (response.statusCode == 200) {
        final data = json.decode(response.body) as Map<String, dynamic>;
        final events = data['events'] as List<dynamic>? ?? [];
        return events
            .whereType<Map<String, dynamic>>()
            .map(EspnEvent.fromJson)
            .toList();
      }

      debugPrint('ESPN scoreboard($date) error ${response.statusCode} for $league');
      return [];
    } catch (e) {
      debugPrint('ESPN getScoreboardForDate exception: $e');
      return [];
    }
  }

  /// Fetches scoreboard events across a range of weeks for [league].
  ///
  /// This is useful for incremental backfill (past results / future fixtures).
  Future<List<EspnEvent>> getScoreboardRange(
    String league, {
    required DateTime startDate,
    required int weekCount,
    int stepDays = 7,
  }) async {
    final seen = <String>{};
    final all = <EspnEvent>[];

    for (int i = 0; i < weekCount; i++) {
      final d = startDate.add(Duration(days: stepDays * i));
      final dateStr = _formatDate(d);
      final events = await getScoreboardForDate(league, dateStr);
      for (final e in events) {
        if (e.id.isNotEmpty && seen.add(e.id)) all.add(e);
      }
    }

    return all;
  }

  /// Like [getScoreboardRange] but fetches weeks in parallel batches for speed.
  ///
  /// IMPORTANT:
  /// - keep [concurrency] low (2-3) to avoid timeouts / rate-limits.
  /// - this method is best used with paging in UI (load more).
  Future<List<EspnEvent>> getScoreboardRangeParallel(
    String league, {
    required DateTime startDate,
    required int weekCount,
    int stepDays = 7,
    int concurrency = 3,
  }) async {
    final seen = <String>{};
    final all = <EspnEvent>[];

    for (int batch = 0; batch < weekCount; batch += concurrency) {
      final batchCount = (weekCount - batch).clamp(1, concurrency);

      final futures = List.generate(batchCount, (i) async {
        final d = startDate.add(Duration(days: stepDays * (batch + i)));
        try {
          return await getScoreboardForDate(league, _formatDate(d));
        } catch (_) {
          return <EspnEvent>[];
        }
      });

      final results = await Future.wait(futures);
      for (final events in results) {
        for (final e in events) {
          if (e.id.isNotEmpty && seen.add(e.id)) all.add(e);
        }
      }
    }

    return all;
  }

  // ────────────────────────────────────────────────────────────────────────────
  // Match Details
  // ────────────────────────────────────────────────────────────────────────────

  /// Fetches full match detail including timeline for a given [eventId] in [league].
  Future<EspnMatchDetail?> getMatchDetail(String league, String eventId) async {
    final uri = Uri.parse('$_siteBaseUrl/$league/summary?event=$eventId');
    try {
      final response = await _client.get(uri).timeout(_kDefaultTimeout);
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

  // ────────────────────────────────────────────────────────────────────────────
  // Team Detail (Schedule / Standings / Roster)
  // ────────────────────────────────────────────────────────────────────────────

  /// Fetches the schedule (past + upcoming) for [teamId] in [league].
  ///
  /// ESPN responses vary by league/endpoint. This method tries:
  /// 1) `/teams/{id}/schedule` (no season param) - usually the most stable.
  /// 2) Fallback to `?season=` current and previous season if results are too few.
  Future<List<EspnEvent>> getTeamSchedule(String league, String teamId) async {
    final events = <EspnEvent>[];
    final seen = <String>{};

    Future<void> _fetchUri(Uri uri) async {
      try {
        final response = await _client.get(uri).timeout(_kScheduleTimeout);

        if (response.statusCode != 200) {
          debugPrint('ESPN getTeamSchedule error ${response.statusCode} for $uri');
          return;
        }

        final data = json.decode(response.body) as Map<String, dynamic>;
        final raw = _extractScheduleEvents(data);

        for (final e in raw) {
          if (e is Map<String, dynamic>) {
            final ev = EspnEvent.fromJson(e);
            if (ev.id.isNotEmpty && seen.add(ev.id)) {
              events.add(ev);
            }
          }
        }
      } catch (e) {
        debugPrint('ESPN getTeamSchedule exception for $uri: $e');
      }
    }

    // 1) Try without season param first
    await _fetchUri(Uri.parse('$_siteBaseUrl/$league/teams/$teamId/schedule'));

    // 2) Fallback with season guessing only if too few events
    if (events.length < _kMinEventsThreshold) {
      final now = DateTime.now();
      final seasonYear = now.month >= _kSeasonStartMonth ? now.year : now.year - 1;

      await _fetchUri(Uri.parse('$_siteBaseUrl/$league/teams/$teamId/schedule?season=$seasonYear'));

      if (events.length < _kMinEventsThreshold) {
        await _fetchUri(Uri.parse('$_siteBaseUrl/$league/teams/$teamId/schedule?season=${seasonYear - 1}'));
      }
    }

    // Ensure deterministic ordering for UI filters (past/upcoming)
    events.sort((a, b) => a.date.compareTo(b.date));
    return events;
  }

  /// Fetches league standings for [league].
  Future<EspnStandings?> getStandings(String league) async {
    final uri = Uri.parse('$_siteBaseUrl/$league/standings');
    try {
      final response = await _client.get(uri).timeout(_kDefaultTimeout);
      if (response.statusCode == 200) {
        final data = json.decode(response.body) as Map<String, dynamic>;
        return EspnStandings.fromJson(data);
      }

      debugPrint('ESPN getStandings error ${response.statusCode} for $league');
      return null;
    } catch (e) {
      debugPrint('ESPN getStandings exception: $e');
      return null;
    }
  }

  /// Fetches the roster for [teamId] in [league].
  Future<EspnRoster?> getTeamRoster(String league, String teamId) async {
    final uri = Uri.parse('$_siteBaseUrl/$league/teams/$teamId/roster');
    try {
      final response = await _client.get(uri).timeout(_kDefaultTimeout);
      if (response.statusCode == 200) {
        final data = json.decode(response.body) as Map<String, dynamic>;
        return EspnRoster.fromJson(data);
      }

      debugPrint('ESPN getTeamRoster error ${response.statusCode} for $league/$teamId');
      return null;
    } catch (e) {
      debugPrint('ESPN getTeamRoster exception: $e');
      return null;
    }
  }

  // ────────────────────────────────────────────────────────────────────────────
  // Helpers
  // ────────────────────────────────────────────────────────────────────────────

  static Map<String, dynamic> _asMap(dynamic v) =>
      v is Map<String, dynamic> ? v : const <String, dynamic>{};

  /// Extract schedule events from a `teams/{id}/schedule` response, tolerant to shape changes.
  ///
  /// Known patterns:
  /// - Root: `{ "events": [...] }`
  /// - Wrapped: `{ "requestedSeason": { "events": [...] } }`
  /// - Wrapped: `{ "season": { "events": [...] } }`
  /// - Sports: `{ "sports":[{"leagues":[{"events":[...]}]}] }`
  static List<dynamic> _extractScheduleEvents(Map<String, dynamic> data) {
    final rootEvents = data['events'];
    if (rootEvents is List) return rootEvents;

    final requestedSeason = data['requestedSeason'];
    if (requestedSeason is Map<String, dynamic>) {
      final ev = requestedSeason['events'];
      if (ev is List) return ev;
    }

    final season = data['season'];
    if (season is Map<String, dynamic>) {
      final ev = season['events'];
      if (ev is List) return ev;
    }

    final sports = data['sports'];
    if (sports is List && sports.isNotEmpty) {
      final s0 = sports.first;
      if (s0 is Map<String, dynamic>) {
        final leagues = s0['leagues'];
        if (leagues is List && leagues.isNotEmpty) {
          final l0 = leagues.first;
          if (l0 is Map<String, dynamic>) {
            final ev = l0['events'];
            if (ev is List) return ev;
          }
        }
      }
    }

    return const [];
  }

  /// Formats a [DateTime] as `YYYYMMDD` for the ESPN scoreboard date parameter.
  static String _formatDate(DateTime date) {
    final y = date.year.toString().padLeft(4, '0');
    final m = date.month.toString().padLeft(2, '0');
    final d = date.day.toString().padLeft(2, '0');
    return '$y$m$d';
  }
}