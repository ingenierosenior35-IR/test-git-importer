import 'dart:convert';
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

  final http.Client _client;

  EspnApiService({http.Client? client}) : _client = client ?? http.Client();

  /// Fetches the list of all available soccer leagues from the ESPN Core API.
  ///
  /// Merges dynamic leagues with the [EspnLeague.popularLeagues] static list so
  /// that well-known leagues always have a human-readable name.  Falls back to
  /// [EspnLeague.popularLeagues] on any error.
  Future<List<EspnLeague>> getLeagues({int limit = 200}) async {
    try {
      final uri = Uri.parse('$_coreLeaguesUrl?limit=$limit');
      final response =
          await _client.get(uri).timeout(const Duration(seconds: 15));
      if (response.statusCode == 200) {
        final data = json.decode(response.body) as Map<String, dynamic>;
        final items = data['items'] as List<dynamic>? ?? [];

        // Build a slug → EspnLeague map from the static popular list so we
        // can preserve human-readable names.
        final popularMap = {
          for (final l in EspnLeague.popularLeagues) l.slug: l
        };

        final leagues = <EspnLeague>[];
        for (final item in items) {
          final itemMap = item as Map<String, dynamic>;
          // Items may contain full league data or just a \$ref link.
          if (itemMap.containsKey('slug') || itemMap.containsKey('id')) {
            final league = EspnLeague.fromCoreApi(itemMap);
            if (league.slug.isNotEmpty) {
              leagues.add(popularMap[league.slug] ?? league);
            }
          } else if (itemMap.containsKey('\$ref')) {
            final slug =
                EspnLeague.slugFromRef(itemMap['\$ref'] as String? ?? '');
            if (slug != null && slug.isNotEmpty) {
              leagues.add(
                  popularMap[slug] ?? EspnLeague(slug: slug, name: slug));
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
      debugPrint(
          'ESPN getLeagues fallback: status ${response.statusCode}');
    } catch (e) {
      debugPrint('ESPN getLeagues exception: $e');
    }
    return EspnLeague.popularLeagues;
  }

  /// Fetches the list of teams for a given [league] slug (e.g., 'esp.1').
  Future<List<EspnTeam>> getTeams(String league) async {
    final uri = Uri.parse('$_siteBaseUrl/$league/teams');
    try {
      final response =
          await _client.get(uri).timeout(const Duration(seconds: 15));
      if (response.statusCode == 200) {
        final data = json.decode(response.body) as Map<String, dynamic>;
        final sports = data['sports'] as List<dynamic>?;
        if (sports == null || sports.isEmpty) return [];
        final leagues = (sports.first as Map<String, dynamic>)['leagues']
            as List<dynamic>?;
        if (leagues == null || leagues.isEmpty) return [];
        final teams =
            (leagues.first as Map<String, dynamic>)['teams'] as List<dynamic>? ??
                [];
        return teams
            .map((t) => EspnTeam.fromJson(
                (t as Map<String, dynamic>)['team'] as Map<String, dynamic>))
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
  /// Returns the upcoming / in-progress / recently-finished events for the
  /// current week.
  Future<List<EspnEvent>> getScoreboard(String league) async {
    final uri = Uri.parse('$_siteBaseUrl/$league/scoreboard');
    try {
      final response =
          await _client.get(uri).timeout(const Duration(seconds: 15));
      if (response.statusCode == 200) {
        final data = json.decode(response.body) as Map<String, dynamic>;
        final events = data['events'] as List<dynamic>? ?? [];
        return events
            .map((e) => EspnEvent.fromJson(e as Map<String, dynamic>))
            .toList();
      }
      debugPrint('ESPN scoreboard error ${response.statusCode} for $league');
      return [];
    } catch (e) {
      debugPrint('ESPN getScoreboard exception: $e');
      return [];
    }
  }

  /// Fetches scoreboard events for a [league] on the week containing [date].
  ///
  /// [date] must be formatted as `YYYYMMDD`.
  Future<List<EspnEvent>> getScoreboardForDate(
      String league, String date) async {
    final uri =
        Uri.parse('$_siteBaseUrl/$league/scoreboard?dates=$date');
    try {
      final response =
          await _client.get(uri).timeout(const Duration(seconds: 15));
      if (response.statusCode == 200) {
        final data = json.decode(response.body) as Map<String, dynamic>;
        final events = data['events'] as List<dynamic>? ?? [];
        return events
            .map((e) => EspnEvent.fromJson(e as Map<String, dynamic>))
            .toList();
      }
      debugPrint(
          'ESPN scoreboard($date) error ${response.statusCode} for $league');
      return [];
    } catch (e) {
      debugPrint('ESPN getScoreboardForDate exception: $e');
      return [];
    }
  }

  /// Fetches scoreboard events across a range of weeks for [league].
  ///
  /// Starting from [startDate] and going back [weekCount] weeks (for past
  /// results) or forward [weekCount] weeks (for fixtures).  Each week step is
  /// [stepDays] days (default 7).
  ///
  /// [startDate] is the anchor date; positive [stepDays] goes into the future,
  /// negative goes into the past.
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
        if (seen.add(e.id)) all.add(e);
      }
    }
    return all;
  }

  /// Fetches full match detail including timeline for a given [eventId] in [league].
  Future<EspnMatchDetail?> getMatchDetail(
      String league, String eventId) async {
    final uri =
        Uri.parse('$_siteBaseUrl/$league/summary?event=$eventId');
    try {
      final response =
          await _client.get(uri).timeout(const Duration(seconds: 15));
      if (response.statusCode == 200) {
        final data = json.decode(response.body) as Map<String, dynamic>;
        return EspnMatchDetail.fromJson(data);
      }
      debugPrint(
          'ESPN getMatchDetail error ${response.statusCode} for $league/$eventId');
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

  /// Month (1-based) from which a new soccer season is considered to have
  /// started. Seasons beginning in August are labelled by their start year.
  static const int _kSeasonStartMonth = 8;

  /// Minimum number of events from the current season before the previous
  /// season is also fetched to fill in data.
  static const int _kMinEventsThreshold = 5;

  /// Fetches the schedule (past + upcoming) for [teamId] in [league].
  ///
  /// Queries the current season first; if fewer than [_kMinEventsThreshold]
  /// events are returned, also fetches the previous season and merges results.
  Future<List<EspnEvent>> getTeamSchedule(
      String league, String teamId) async {
    final now = DateTime.now();
    // Soccer seasons span two calendar years; pick the season start year.
    final seasonYear =
        now.month >= _kSeasonStartMonth ? now.year : now.year - 1;
    final events = <EspnEvent>[];
    final seen = <String>{};

    Future<void> _fetchSeason(int year) async {
      final uri = Uri.parse(
          '$_siteBaseUrl/$league/teams/$teamId/schedule?season=$year');
      try {
        final response =
            await _client.get(uri).timeout(const Duration(seconds: 20));
        if (response.statusCode == 200) {
          final data = json.decode(response.body) as Map<String, dynamic>;
          final raw = data['events'] as List<dynamic>? ?? [];
          for (final e in raw) {
            final ev = EspnEvent.fromJson(e as Map<String, dynamic>);
            if (seen.add(ev.id)) events.add(ev);
          }
        } else {
          debugPrint(
              'ESPN getTeamSchedule($year) error ${response.statusCode} for $league/$teamId');
        }
      } catch (e) {
        debugPrint('ESPN getTeamSchedule($year) exception: $e');
      }
    }

    // Current season
    await _fetchSeason(seasonYear);
    // If the current season returned very few results, also fetch previous.
    if (events.length < _kMinEventsThreshold) {
      await _fetchSeason(seasonYear - 1);
    }
    return events;
  }

  /// Fetches league standings for [league].
  Future<EspnStandings?> getStandings(String league) async {
    final uri = Uri.parse('$_siteBaseUrl/$league/standings');
    try {
      final response =
          await _client.get(uri).timeout(const Duration(seconds: 15));
      if (response.statusCode == 200) {
        final data = json.decode(response.body) as Map<String, dynamic>;
        return EspnStandings.fromJson(data);
      }
      debugPrint(
          'ESPN getStandings error ${response.statusCode} for $league');
      return null;
    } catch (e) {
      debugPrint('ESPN getStandings exception: $e');
      return null;
    }
  }

  /// Fetches the roster for [teamId] in [league].
  Future<EspnRoster?> getTeamRoster(String league, String teamId) async {
    final uri =
        Uri.parse('$_siteBaseUrl/$league/teams/$teamId/roster');
    try {
      final response =
          await _client.get(uri).timeout(const Duration(seconds: 15));
      if (response.statusCode == 200) {
        final data = json.decode(response.body) as Map<String, dynamic>;
        return EspnRoster.fromJson(data);
      }
      debugPrint(
          'ESPN getTeamRoster error ${response.statusCode} for $league/$teamId');
      return null;
    } catch (e) {
      debugPrint('ESPN getTeamRoster exception: $e');
      return null;
    }
  }

  /// Formats a [DateTime] as `YYYYMMDD` for the ESPN scoreboard date parameter.
  static String _formatDate(DateTime date) {
    final y = date.year.toString().padLeft(4, '0');
    final m = date.month.toString().padLeft(2, '0');
    final d = date.day.toString().padLeft(2, '0');
    return '$y$m$d';
  }
}
