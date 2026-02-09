import 'package:cloud_firestore/cloud_firestore.dart';

enum VideoStatus {
  uploading,
  processing,
  ready,
  failed,
}

class Video {
  final String id;
  final String matchId;
  final String url;
  final VideoStatus status;
  final double? progress;
  final DateTime uploadedAt;
  final String uploadedBy;

  Video({
    required this.id,
    required this.matchId,
    required this.url,
    required this.status,
    this.progress,
    required this.uploadedAt,
    required this.uploadedBy,
  });

  factory Video.fromMap(Map<String, dynamic> map, String id) {
    return Video(
      id: id,
      matchId: map['matchId'] as String,
      url: map['url'] as String,
      status: VideoStatus.values.firstWhere(
        (e) => e.name == map['status'],
        orElse: () => VideoStatus.uploading,
      ),
      progress: map['progress'] as double?,
      uploadedAt: (map['uploadedAt'] as Timestamp).toDate(),
      uploadedBy: map['uploadedBy'] as String,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'matchId': matchId,
      'url': url,
      'status': status.name,
      'progress': progress,
      'uploadedAt': Timestamp.fromDate(uploadedAt),
      'uploadedBy': uploadedBy,
    };
  }

  Video copyWith({
    String? id,
    String? matchId,
    String? url,
    VideoStatus? status,
    double? progress,
    DateTime? uploadedAt,
    String? uploadedBy,
  }) {
    return Video(
      id: id ?? this.id,
      matchId: matchId ?? this.matchId,
      url: url ?? this.url,
      status: status ?? this.status,
      progress: progress ?? this.progress,
      uploadedAt: uploadedAt ?? this.uploadedAt,
      uploadedBy: uploadedBy ?? this.uploadedBy,
    );
  }
}
