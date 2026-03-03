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

  /// Curated list of popular leagues available via ESPN API
  static const List<EspnLeague> popularLeagues = [
    EspnLeague(slug: 'esp.1', name: 'LALIGA (España)'),
    EspnLeague(slug: 'eng.1', name: 'Premier League (Inglaterra)'),
    EspnLeague(slug: 'ger.1', name: 'Bundesliga (Alemania)'),
    EspnLeague(slug: 'ita.1', name: 'Serie A (Italia)'),
    EspnLeague(slug: 'fra.1', name: 'Ligue 1 (Francia)'),
    EspnLeague(slug: 'usa.1', name: 'MLS (Estados Unidos)'),
    EspnLeague(slug: 'uefa.champions', name: 'UEFA Champions League'),
    EspnLeague(slug: 'conmebol.libertadores', name: 'Copa Libertadores'),
    EspnLeague(slug: 'conmebol.america', name: 'Copa América'),
    EspnLeague(slug: 'fifa.world', name: 'FIFA World Cup'),
    EspnLeague(slug: 'mex.1', name: 'Liga MX (México)'),
    EspnLeague(slug: 'col.1', name: 'Liga Colombiana'),
    EspnLeague(slug: 'arg.1', name: 'Liga Argentina'),
    EspnLeague(slug: 'bra.1', name: 'Brasileirão'),
    EspnLeague(slug: 'ned.1', name: 'Eredivisie (Países Bajos)'),
    EspnLeague(slug: 'por.1', name: 'Primeira Liga (Portugal)'),
  ];
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
