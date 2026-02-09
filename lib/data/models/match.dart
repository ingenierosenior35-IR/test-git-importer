import 'package:cloud_firestore/cloud_firestore.dart';

enum MatchStatus {
  pending,
  completed,
  processing,
  cancelled,
}

class Match {
  final String id;
  final String name;
  final DateTime dateTime;
  final String venue;
  final double? venueLatitude;
  final double? venueLongitude;
  final List<String> playerIds;
  final Map<String, bool> confirmations;
  final String? videoUrl;
  final MatchStatus status;
  final String inviteCode;
  final String createdBy;
  final DateTime createdAt;
  final String? competition; // League or tournament name
  final String? team1;
  final String? team2;

  Match({
    required this.id,
    required this.name,
    required this.dateTime,
    required this.venue,
    this.venueLatitude,
    this.venueLongitude,
    required this.playerIds,
    required this.confirmations,
    this.videoUrl,
    required this.status,
    required this.inviteCode,
    required this.createdBy,
    required this.createdAt,
    this.competition,
    this.team1,
    this.team2,
  });

  factory Match.fromMap(Map<String, dynamic> map, String id) {
    return Match(
      id: id,
      name: map['name'] as String,
      dateTime: (map['dateTime'] as Timestamp).toDate(),
      venue: map['venue'] as String,
      venueLatitude: map['venueLatitude'] as double?,
      venueLongitude: map['venueLongitude'] as double?,
      playerIds: List<String>.from(map['playerIds'] as List),
      confirmations: Map<String, bool>.from(map['confirmations'] as Map),
      videoUrl: map['videoUrl'] as String?,
      status: MatchStatus.values.firstWhere(
        (e) => e.name == map['status'],
        orElse: () => MatchStatus.pending,
      ),
      inviteCode: map['inviteCode'] as String,
      createdBy: map['createdBy'] as String,
      createdAt: (map['createdAt'] as Timestamp).toDate(),
      competition: map['competition'] as String?,
      team1: map['team1'] as String?,
      team2: map['team2'] as String?,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'name': name,
      'dateTime': Timestamp.fromDate(dateTime),
      'venue': venue,
      'venueLatitude': venueLatitude,
      'venueLongitude': venueLongitude,
      'playerIds': playerIds,
      'confirmations': confirmations,
      'videoUrl': videoUrl,
      'status': status.name,
      'inviteCode': inviteCode,
      'createdBy': createdBy,
      'createdAt': Timestamp.fromDate(createdAt),
      'competition': competition,
      'team1': team1,
      'team2': team2,
    };
  }

  Match copyWith({
    String? id,
    String? name,
    DateTime? dateTime,
    String? venue,
    double? venueLatitude,
    double? venueLongitude,
    List<String>? playerIds,
    Map<String, bool>? confirmations,
    String? videoUrl,
    MatchStatus? status,
    String? inviteCode,
    String? createdBy,
    DateTime? createdAt,
    String? competition,
    String? team1,
    String? team2,
  }) {
    return Match(
      id: id ?? this.id,
      name: name ?? this.name,
      dateTime: dateTime ?? this.dateTime,
      venue: venue ?? this.venue,
      venueLatitude: venueLatitude ?? this.venueLatitude,
      venueLongitude: venueLongitude ?? this.venueLongitude,
      playerIds: playerIds ?? this.playerIds,
      confirmations: confirmations ?? this.confirmations,
      videoUrl: videoUrl ?? this.videoUrl,
      status: status ?? this.status,
      inviteCode: inviteCode ?? this.inviteCode,
      createdBy: createdBy ?? this.createdBy,
      createdAt: createdAt ?? this.createdAt,
      competition: competition ?? this.competition,
      team1: team1 ?? this.team1,
      team2: team2 ?? this.team2,
    );
  }
}
