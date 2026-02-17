class Fixture {
  final String id;
  final String homeTeam;
  final String awayTeam;
  final String homeTeamLogo;
  final String awayTeamLogo;
  final DateTime dateTime;
  final String? homeScore;
  final String? awayScore;
  final String competition;
  final String status; // 'scheduled', 'live', 'finished'
  final String venue;

  Fixture({
    required this.id,
    required this.homeTeam,
    required this.awayTeam,
    this.homeTeamLogo = '',
    this.awayTeamLogo = '',
    required this.dateTime,
    this.homeScore,
    this.awayScore,
    required this.competition,
    required this.status,
    required this.venue,
  });

  factory Fixture.fromJson(Map<String, dynamic> json) {
    return Fixture(
      id: json['id'] as String,
      homeTeam: json['homeTeam'] as String,
      awayTeam: json['awayTeam'] as String,
      homeTeamLogo: json['homeTeamLogo'] as String? ?? '',
      awayTeamLogo: json['awayTeamLogo'] as String? ?? '',
      dateTime: DateTime.parse(json['dateTime'] as String),
      homeScore: json['homeScore'] as String?,
      awayScore: json['awayScore'] as String?,
      competition: json['competition'] as String,
      status: json['status'] as String,
      venue: json['venue'] as String,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'homeTeam': homeTeam,
      'awayTeam': awayTeam,
      'homeTeamLogo': homeTeamLogo,
      'awayTeamLogo': awayTeamLogo,
      'dateTime': dateTime.toIso8601String(),
      'homeScore': homeScore,
      'awayScore': awayScore,
      'competition': competition,
      'status': status,
      'venue': venue,
    };
  }

  bool get isFinished => status == 'finished';
  bool get isLive => status == 'live';
  bool get isScheduled => status == 'scheduled';
}
