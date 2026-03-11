/// ESPN API data models for leagues, teams, and events
class EspnLeague {
  final String slug;
  final String name;
  final String? logoUrl;

  const EspnLeague({
    required this.slug,
    required this.name,
    this.logoUrl,
  });

  /// Curated list of popular leagues available via ESPN API (used as fallback).
  static const List<EspnLeague> popularLeagues = [
    EspnLeague(slug: 'esp.1', name: 'LALIGA (España)'),
    EspnLeague(slug: 'eng.1', name: 'Premier League (Inglaterra)'),
    EspnLeague(slug: 'ger.1', name: 'Bundesliga (Alemania)'),
    EspnLeague(slug: 'ita.1', name: 'Serie A (Italia)'),
    EspnLeague(slug: 'fra.1', name: 'Ligue 1 (Francia)'),
    EspnLeague(slug: 'usa.1', name: 'MLS (Estados Unidos)'),
    EspnLeague(slug: 'uefa.champions', name: 'UEFA Champions League'),
    EspnLeague(slug: 'uefa.europa', name: 'UEFA Europa League'),
    EspnLeague(slug: 'conmebol.libertadores', name: 'Copa Libertadores'),
    EspnLeague(slug: 'conmebol.sudamericana', name: 'Copa Sudamericana'),
    EspnLeague(slug: 'conmebol.america', name: 'Copa América'),
    EspnLeague(slug: 'fifa.world', name: 'FIFA World Cup'),
    EspnLeague(slug: 'mex.1', name: 'Liga MX (México)'),
    EspnLeague(slug: 'col.1', name: 'Liga Colombiana'),
    EspnLeague(slug: 'arg.1', name: 'Liga Argentina'),
    EspnLeague(slug: 'bra.1', name: 'Brasileirão'),
    EspnLeague(slug: 'ned.1', name: 'Eredivisie (Países Bajos)'),
    EspnLeague(slug: 'por.1', name: 'Primeira Liga (Portugal)'),
    EspnLeague(slug: 'sco.1', name: 'Scottish Premiership'),
    EspnLeague(slug: 'tur.1', name: 'Süper Lig (Turquía)'),
    EspnLeague(slug: 'rus.1', name: 'Premier League (Rusia)'),
    EspnLeague(slug: 'gre.1', name: 'Super League (Grecia)'),
    EspnLeague(slug: 'chi.1', name: 'Primera División (Chile)'),
    EspnLeague(slug: 'per.1', name: 'Liga 1 (Perú)'),
    EspnLeague(slug: 'uru.1', name: 'Primera División (Uruguay)'),
    EspnLeague(slug: 'ecu.1', name: 'LigaPro (Ecuador)'),
    EspnLeague(slug: 'ven.1', name: 'Liga FUTVE (Venezuela)'),
    EspnLeague(slug: 'bol.1', name: 'División Profesional (Bolivia)'),
    EspnLeague(slug: 'par.1', name: 'División Profesional (Paraguay)'),
  ];

  /// Creates an [EspnLeague] from a Core API item that may include 'slug' and 'name' fields.
  factory EspnLeague.fromCoreApi(Map<String, dynamic> json) {
    final slug = json['slug']?.toString() ?? json['id']?.toString() ?? '';
    final name = json['name']?.toString() ??
        json['shortName']?.toString() ??
        json['abbreviation']?.toString() ??
        slug;
    final logos = json['logos'] as List<dynamic>?;
    final logoUrl = logos != null && logos.isNotEmpty
        ? logos.first['href']?.toString()
        : null;
    return EspnLeague(slug: slug, name: name, logoUrl: logoUrl);
  }

  /// Extracts a league slug from a Core API \$ref URL such as
  /// `https://sports.core.api.espn.com/v2/sports/soccer/leagues/esp.1`.
  static String? slugFromRef(String ref) {
    final uri = Uri.tryParse(ref);
    if (uri == null) return null;
    final segments = uri.pathSegments;
    if (segments.isEmpty) return null;
    final slug = segments.last.split('?').first;
    return slug.isEmpty ? null : slug;
  }
}

class EspnTeam {
  final String id;
  final String name;
  final String abbreviation;
  final String displayName;
  final String? logoUrl;

  const EspnTeam({
    required this.id,
    required this.name,
    required this.abbreviation,
    required this.displayName,
    this.logoUrl,
  });

  factory EspnTeam.fromJson(Map<String, dynamic> json) {
    final logos = json['logos'] as List<dynamic>?;
    return EspnTeam(
      id: json['id']?.toString() ?? '',
      name: json['name']?.toString() ?? '',
      abbreviation: json['abbreviation']?.toString() ?? '',
      displayName: json['displayName']?.toString() ?? json['name']?.toString() ?? '',
      logoUrl: logos != null && logos.isNotEmpty
          ? logos.first['href']?.toString()
          : null,
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'name': name,
        'abbreviation': abbreviation,
        'displayName': displayName,
        'logoUrl': logoUrl,
      };
}

class EspnEvent {
  final String id;
  final String name;
  final String shortName;
  final DateTime date;
  final String status; // 'pre', 'in', 'post'
  final EspnTeam homeTeam;
  final EspnTeam awayTeam;
  final String? homeScore;
  final String? awayScore;
  final String? venue;
  final String? week;

  const EspnEvent({
    required this.id,
    required this.name,
    required this.shortName,
    required this.date,
    required this.status,
    required this.homeTeam,
    required this.awayTeam,
    this.homeScore,
    this.awayScore,
    this.venue,
    this.week,
  });

  factory EspnEvent.fromJson(Map<String, dynamic> json) {
    final competitions = json['competitions'] as List<dynamic>? ?? [];
    final competition = competitions.isNotEmpty ? competitions.first as Map<String, dynamic> : <String, dynamic>{};

    final competitors = competition['competitors'] as List<dynamic>? ?? [];
    EspnTeam homeTeam = const EspnTeam(id: '', name: 'TBD', abbreviation: 'TBD', displayName: 'TBD');
    EspnTeam awayTeam = const EspnTeam(id: '', name: 'TBD', abbreviation: 'TBD', displayName: 'TBD');
    String? homeScore;
    String? awayScore;

    for (final comp in competitors) {
      final compMap = comp as Map<String, dynamic>;
      final teamMap = compMap['team'] as Map<String, dynamic>? ?? {};
      final team = EspnTeam.fromJson(teamMap);
      final score = compMap['score']?.toString();
      if (compMap['homeAway'] == 'home') {
        homeTeam = team;
        homeScore = score;
      } else {
        awayTeam = team;
        awayScore = score;
      }
    }

    final venueMap = competition['venue'] as Map<String, dynamic>?;
    final statusMap = json['status'] as Map<String, dynamic>?;
    final statusType = statusMap?['type'] as Map<String, dynamic>?;
    final statusStr = statusType?['state']?.toString() ?? 'pre';

    final weekMap = json['week'] as Map<String, dynamic>?;
    final weekNum = weekMap?['number']?.toString();

    return EspnEvent(
      id: json['id']?.toString() ?? '',
      name: json['name']?.toString() ?? '',
      shortName: json['shortName']?.toString() ?? json['name']?.toString() ?? '',
      date: DateTime.tryParse(json['date']?.toString() ?? '') ?? DateTime.now(),
      status: statusStr,
      homeTeam: homeTeam,
      awayTeam: awayTeam,
      homeScore: homeScore,
      awayScore: awayScore,
      venue: venueMap?['fullName']?.toString(),
      week: weekNum,
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'name': name,
        'shortName': shortName,
        'date': date.toIso8601String(),
        'status': status,
        'homeTeam': homeTeam.toJson(),
        'awayTeam': awayTeam.toJson(),
        'homeScore': homeScore,
        'awayScore': awayScore,
        'venue': venue,
        'week': week,
      };

  bool get isFinished => status == 'post';
  bool get isLive => status == 'in';
  bool get isScheduled => status == 'pre';
}

/// A single timeline play/event from a match
class EspnPlay {
  final String id;
  final int clock; // minute
  final String text; // description
  final String? teamId;
  final String type; // 'goal', 'yellow-card', 'red-card', 'substitution', etc.

  const EspnPlay({
    required this.id,
    required this.clock,
    required this.text,
    this.teamId,
    required this.type,
  });

  factory EspnPlay.fromJson(Map<String, dynamic> json) {
    final clockMap = json['clock'] as Map<String, dynamic>?;
    final teamMap = json['team'] as Map<String, dynamic>?;
    final typeMap = json['type'] as Map<String, dynamic>?;
    return EspnPlay(
      id: json['id']?.toString() ?? '',
      clock: (clockMap?['value'] as num?)?.toInt() ?? 0,
      text: json['text']?.toString() ?? '',
      teamId: teamMap?['id']?.toString(),
      type: typeMap?['id']?.toString() ?? 'event',
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'clock': clock,
        'text': text,
        'teamId': teamId,
        'type': type,
      };
}

/// A statistic entry (e.g. Possession, Shots on Target)
class EspnStatItem {
  final String label;
  final String homeValue;
  final String awayValue;

  const EspnStatItem({
    required this.label,
    required this.homeValue,
    required this.awayValue,
  });
}

/// A lineup player entry
class EspnLineupPlayer {
  final String name;
  final String? position;
  final String? number;

  const EspnLineupPlayer({
    required this.name,
    this.position,
    this.number,
  });

  factory EspnLineupPlayer.fromJson(Map<String, dynamic> json) {
    final athleteMap = json['athlete'] as Map<String, dynamic>? ?? json;
    final posMap = athleteMap['position'] as Map<String, dynamic>? ??
        json['position'] as Map<String, dynamic>?;
    return EspnLineupPlayer(
      name: athleteMap['displayName']?.toString() ??
          athleteMap['fullName']?.toString() ??
          athleteMap['name']?.toString() ??
          '',
      position: posMap?['abbreviation']?.toString() ??
          posMap?['name']?.toString(),
      number: athleteMap['jersey']?.toString() ??
          json['subbedIn']?.toString(),
    );
  }
}

/// Full match detail including timeline, stats and lineups
class EspnMatchDetail {
  final EspnEvent event;
  final List<EspnPlay> timeline;
  final String? homeTeamStats;
  final String? awayTeamStats;
  /// Parsed stat rows (e.g. possession, shots)
  final List<EspnStatItem> stats;
  /// Home-team starting lineup
  final List<EspnLineupPlayer> homeLineup;
  /// Away-team starting lineup
  final List<EspnLineupPlayer> awayLineup;
  /// Venue / stadium name
  final String? venue;

  const EspnMatchDetail({
    required this.event,
    required this.timeline,
    this.homeTeamStats,
    this.awayTeamStats,
    this.stats = const [],
    this.homeLineup = const [],
    this.awayLineup = const [],
    this.venue,
  });

  factory EspnMatchDetail.fromJson(Map<String, dynamic> json) {
    final header = json['header'] as Map<String, dynamic>?;
    final competitions = (header?['competitions'] as List<dynamic>?) ?? [];
    final competition = competitions.isNotEmpty
        ? competitions.first as Map<String, dynamic>
        : <String, dynamic>{};

    final competitors = competition['competitors'] as List<dynamic>? ?? [];
    EspnTeam homeTeam = const EspnTeam(id: '', name: 'TBD', abbreviation: 'TBD', displayName: 'TBD');
    EspnTeam awayTeam = const EspnTeam(id: '', name: 'TBD', abbreviation: 'TBD', displayName: 'TBD');
    String? homeScore;
    String? awayScore;
    String? homeStats;
    String? awayStats;
    final homeLineup = <EspnLineupPlayer>[];
    final awayLineup = <EspnLineupPlayer>[];

    for (final comp in competitors) {
      final compMap = comp as Map<String, dynamic>;
      final teamMap = compMap['team'] as Map<String, dynamic>? ?? {};
      final team = EspnTeam.fromJson(teamMap);
      final score = compMap['score']?.toString();
      final isHome = compMap['homeAway'] == 'home';
      if (isHome) {
        homeTeam = team;
        homeScore = score;
        homeStats = score != null ? '${team.displayName}: $score' : null;
      } else {
        awayTeam = team;
        awayScore = score;
        awayStats = score != null ? '${team.displayName}: $score' : null;
      }

      // Parse lineup from rosters node (present in summary response)
      final roster = compMap['roster'] as List<dynamic>?;
      if (roster != null) {
        final players = roster
            .map((p) =>
                EspnLineupPlayer.fromJson(p as Map<String, dynamic>))
            .toList();
        if (isHome) {
          homeLineup.addAll(players);
        } else {
          awayLineup.addAll(players);
        }
      }
    }

    final statusMap = competition['status'] as Map<String, dynamic>?;
    final statusType = statusMap?['type'] as Map<String, dynamic>?;
    final statusStr = statusType?['state']?.toString() ?? 'pre';

    // Venue
    final venueMap = competition['venue'] as Map<String, dynamic>?;
    final venueName = venueMap?['fullName']?.toString() ??
        venueMap?['name']?.toString();

    final event = EspnEvent(
      id: header?['id']?.toString() ?? '',
      name: header?['name']?.toString() ?? '',
      shortName: header?['shortName']?.toString() ?? header?['name']?.toString() ?? '',
      date: DateTime.tryParse(header?['gameDate']?.toString() ?? '') ?? DateTime.now(),
      status: statusStr,
      homeTeam: homeTeam,
      awayTeam: awayTeam,
      homeScore: homeScore,
      awayScore: awayScore,
      venue: venueName,
    );

    // Parse keyEvents / plays for timeline
    final keyEvents = json['keyEvents'] as List<dynamic>? ?? [];

    // Parse match statistics
    final stats = <EspnStatItem>[];
    final boxscoreMap = json['boxscore'] as Map<String, dynamic>?;
    if (boxscoreMap != null) {
      final teamStats =
          boxscoreMap['teamStats'] as List<dynamic>? ?? [];
      // teamStats is [ { stats: [{name, displayValue},...] }, ... ] for home/away
      if (teamStats.length >= 2) {
        final homeStatsList = (teamStats[0] as Map<String, dynamic>?)?['statistics']
            as List<dynamic>?;
        final awayStatsList = (teamStats[1] as Map<String, dynamic>?)?['statistics']
            as List<dynamic>?;
        if (homeStatsList != null && awayStatsList != null) {
          final homeMap = {
            for (final s in homeStatsList)
              (s as Map<String, dynamic>)['name']?.toString() ?? '':
                  s['displayValue']?.toString() ?? ''
          };
          final awayMap = {
            for (final s in awayStatsList)
              (s as Map<String, dynamic>)['name']?.toString() ?? '':
                  s['displayValue']?.toString() ?? ''
          };
          for (final key in homeMap.keys) {
            if (awayMap.containsKey(key) && key.isNotEmpty) {
              stats.add(EspnStatItem(
                label: (homeStatsList.firstWhere((s) =>
                    (s as Map<String, dynamic>)['name'] == key,
                    orElse: () => <String, dynamic>{}) as Map<String, dynamic>)['label']
                        ?.toString() ??
                    key,
                homeValue: homeMap[key]!,
                awayValue: awayMap[key]!,
              ));
            }
          }
        }
      }
    }

    return EspnMatchDetail(
      event: event,
      timeline: keyEvents
          .map((e) => EspnPlay.fromJson(e as Map<String, dynamic>))
          .toList(),
      homeTeamStats: homeStats,
      awayTeamStats: awayStats,
      stats: stats,
      homeLineup: homeLineup,
      awayLineup: awayLineup,
      venue: venueName,
    );
  }
}

// ─── Standings ───────────────────────────────────────────────────────────────

class EspnStandingEntry {
  final String teamId;
  final String teamName;
  final String? teamLogo;
  final int rank;
  final int played;
  final int won;
  final int drawn;
  final int lost;
  final int goalsFor;
  final int goalsAgainst;
  final int points;

  const EspnStandingEntry({
    required this.teamId,
    required this.teamName,
    this.teamLogo,
    required this.rank,
    required this.played,
    required this.won,
    required this.drawn,
    required this.lost,
    required this.goalsFor,
    required this.goalsAgainst,
    required this.points,
  });

  int get goalDifference => goalsFor - goalsAgainst;

  factory EspnStandingEntry.fromJson(
      Map<String, dynamic> json, int position) {
    final teamMap = json['team'] as Map<String, dynamic>? ?? {};
    final logos = teamMap['logos'] as List<dynamic>?;
    final statsRaw = json['stats'] as List<dynamic>? ?? [];
    final statsMap = {
      for (final s in statsRaw)
        (s as Map<String, dynamic>)['name']?.toString() ?? '':
            s['value']
    };

    int _v(String key) =>
        (statsMap[key] as num?)?.toInt() ?? 0;

    return EspnStandingEntry(
      teamId: teamMap['id']?.toString() ?? '',
      teamName: teamMap['displayName']?.toString() ??
          teamMap['name']?.toString() ?? '',
      teamLogo: logos != null && logos.isNotEmpty
          ? logos.first['href']?.toString()
          : null,
      rank: (json['rank'] as num?)?.toInt() ?? position,
      played: _v('gamesPlayed'),
      won: _v('wins'),
      drawn: _v('ties'),
      lost: _v('losses'),
      goalsFor: _v('pointsFor'),
      goalsAgainst: _v('pointsAgainst'),
      points: _v('points'),
    );
  }
}

class EspnStandings {
  final String name;
  final List<EspnStandingEntry> entries;

  const EspnStandings({required this.name, required this.entries});

  factory EspnStandings.fromJson(Map<String, dynamic> json) {
    final children = json['children'] as List<dynamic>? ?? [];
    final allEntries = <EspnStandingEntry>[];

    // Some leagues return standings nested under children groups
    if (children.isNotEmpty) {
      for (final child in children) {
        final childMap = child as Map<String, dynamic>;
        final standings =
            childMap['standings'] as Map<String, dynamic>? ?? {};
        final entries = standings['entries'] as List<dynamic>? ?? [];
        int pos = 1;
        for (final e in entries) {
          allEntries.add(EspnStandingEntry.fromJson(
              e as Map<String, dynamic>, pos++));
        }
      }
    } else {
      // Flat structure
      final standings = json['standings'] as Map<String, dynamic>? ?? {};
      final entries = standings['entries'] as List<dynamic>? ?? [];
      int pos = 1;
      for (final e in entries) {
        allEntries
            .add(EspnStandingEntry.fromJson(e as Map<String, dynamic>, pos++));
      }
    }

    // Sort by points desc, then goal difference desc
    allEntries.sort((a, b) {
      final byPts = b.points.compareTo(a.points);
      if (byPts != 0) return byPts;
      return b.goalDifference.compareTo(a.goalDifference);
    });

    return EspnStandings(
      name: json['name']?.toString() ?? '',
      entries: allEntries,
    );
  }
}

// ─── Roster ──────────────────────────────────────────────────────────────────

class EspnPlayer {
  final String id;
  final String name;
  final String? number;
  final String? position;
  final String? nationality;
  final String? photoUrl;

  const EspnPlayer({
    required this.id,
    required this.name,
    this.number,
    this.position,
    this.nationality,
    this.photoUrl,
  });

  factory EspnPlayer.fromJson(Map<String, dynamic> json) {
    final athleteMap = json['athlete'] as Map<String, dynamic>? ?? json;
    final posMap = athleteMap['position'] as Map<String, dynamic>? ??
        json['position'] as Map<String, dynamic>?;
    final flagMap = athleteMap['flag'] as Map<String, dynamic>?;
    return EspnPlayer(
      id: athleteMap['id']?.toString() ?? '',
      name: athleteMap['displayName']?.toString() ??
          athleteMap['fullName']?.toString() ??
          athleteMap['name']?.toString() ??
          '',
      number: athleteMap['jersey']?.toString(),
      position: posMap?['abbreviation']?.toString() ??
          posMap?['name']?.toString(),
      nationality: flagMap?['alt']?.toString() ??
          athleteMap['citizenship']?.toString(),
      photoUrl: athleteMap['headshot']?.toString() ??
          (athleteMap['headshot'] as Map<String, dynamic>?)?['href']
              ?.toString(),
    );
  }
}

class EspnRoster {
  final List<EspnPlayer> players;

  const EspnRoster({required this.players});

  factory EspnRoster.fromJson(Map<String, dynamic> json) {
    final athletes = json['athletes'] as List<dynamic>? ?? [];
    final players = <EspnPlayer>[];
    for (final group in athletes) {
      final groupMap = group as Map<String, dynamic>;
      final items = groupMap['items'] as List<dynamic>? ?? [];
      players.addAll(
          items.map((p) => EspnPlayer.fromJson(p as Map<String, dynamic>)));
    }
    return EspnRoster(players: players);
  }
}
