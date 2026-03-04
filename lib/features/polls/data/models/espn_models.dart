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
    EspnLeague(slug: 'chl.1', name: 'Primera División (Chile)'),
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

/// Full match detail including timeline
class EspnMatchDetail {
  final EspnEvent event;
  final List<EspnPlay> timeline;
  final String? homeTeamStats;
  final String? awayTeamStats;

  const EspnMatchDetail({
    required this.event,
    required this.timeline,
    this.homeTeamStats,
    this.awayTeamStats,
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

    for (final comp in competitors) {
      final compMap = comp as Map<String, dynamic>;
      final teamMap = compMap['team'] as Map<String, dynamic>? ?? {};
      final team = EspnTeam.fromJson(teamMap);
      final score = compMap['score']?.toString();
      if (compMap['homeAway'] == 'home') {
        homeTeam = team;
        homeScore = score;
        homeStats = score != null ? '${team.displayName}: $score' : null;
      } else {
        awayTeam = team;
        awayScore = score;
        awayStats = score != null ? '${team.displayName}: $score' : null;
      }
    }

    final statusMap = competition['status'] as Map<String, dynamic>?;
    final statusType = statusMap?['type'] as Map<String, dynamic>?;
    final statusStr = statusType?['state']?.toString() ?? 'pre';

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
    );

    final keyEvents = json['keyEvents'] as List<dynamic>? ?? [];
    return EspnMatchDetail(
      event: event,
      timeline: keyEvents
          .map((e) => EspnPlay.fromJson(e as Map<String, dynamic>))
          .toList(),
      homeTeamStats: homeStats,
      awayTeamStats: awayStats,
    );
  }
}
