class Poll {
  final String id;
  final String name;
  final String description;
  final String creatorId;
  final String creatorName;
  final DateTime createdAt;
  final List<String> participantIds;
  final String status; // 'active', 'finished'
  final String? imageUrl;

  Poll({
    required this.id,
    required this.name,
    required this.description,
    required this.creatorId,
    required this.creatorName,
    required this.createdAt,
    required this.participantIds,
    required this.status,
    this.imageUrl,
  });

  factory Poll.fromJson(Map<String, dynamic> json) {
    return Poll(
      id: json['id'] as String,
      name: json['name'] as String,
      description: json['description'] as String,
      creatorId: json['creatorId'] as String,
      creatorName: json['creatorName'] as String,
      createdAt: DateTime.parse(json['createdAt'] as String),
      participantIds: List<String>.from(json['participantIds'] as List),
      status: json['status'] as String,
      imageUrl: json['imageUrl'] as String?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'description': description,
      'creatorId': creatorId,
      'creatorName': creatorName,
      'createdAt': createdAt.toIso8601String(),
      'participantIds': participantIds,
      'status': status,
      'imageUrl': imageUrl,
    };
  }

  bool get isActive => status == 'active';
  bool get isFinished => status == 'finished';
  int get participantCount => participantIds.length;
}

class PollPrediction {
  final String id;
  final String pollId;
  final String userId;
  final String userName;
  final String fixtureId;
  final String homeTeamPrediction;
  final String awayTeamPrediction;
  final DateTime predictedAt;
  final int? points;

  PollPrediction({
    required this.id,
    required this.pollId,
    required this.userId,
    required this.userName,
    required this.fixtureId,
    required this.homeTeamPrediction,
    required this.awayTeamPrediction,
    required this.predictedAt,
    this.points,
  });

  factory PollPrediction.fromJson(Map<String, dynamic> json) {
    return PollPrediction(
      id: json['id'] as String,
      pollId: json['pollId'] as String,
      userId: json['userId'] as String,
      userName: json['userName'] as String,
      fixtureId: json['fixtureId'] as String,
      homeTeamPrediction: json['homeTeamPrediction'] as String,
      awayTeamPrediction: json['awayTeamPrediction'] as String,
      predictedAt: DateTime.parse(json['predictedAt'] as String),
      points: json['points'] as int?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'pollId': pollId,
      'userId': userId,
      'userName': userName,
      'fixtureId': fixtureId,
      'homeTeamPrediction': homeTeamPrediction,
      'awayTeamPrediction': awayTeamPrediction,
      'predictedAt': predictedAt.toIso8601String(),
      'points': points,
    };
  }
}

class PollStanding {
  final String userId;
  final String userName;
  final int points;
  final int correctPredictions;
  final int totalPredictions;

  PollStanding({
    required this.userId,
    required this.userName,
    required this.points,
    required this.correctPredictions,
    required this.totalPredictions,
  });

  factory PollStanding.fromJson(Map<String, dynamic> json) {
    return PollStanding(
      userId: json['userId'] as String,
      userName: json['userName'] as String,
      points: json['points'] as int,
      correctPredictions: json['correctPredictions'] as int,
      totalPredictions: json['totalPredictions'] as int,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'userId': userId,
      'userName': userName,
      'points': points,
      'correctPredictions': correctPredictions,
      'totalPredictions': totalPredictions,
    };
  }
}
