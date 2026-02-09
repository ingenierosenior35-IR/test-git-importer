import 'dart:io';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/foundation.dart';
import '../models/video.dart';

class VideoRepository {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseStorage _storage = FirebaseStorage.instance;

  CollectionReference get _videosCollection => _firestore.collection('videos');

  Future<String> uploadVideo({
    required File videoFile,
    required String matchId,
    required String uploadedBy,
    required Function(double) onProgress,
  }) async {
    try {
      final fileName = '${matchId}_${DateTime.now().millisecondsSinceEpoch}.mp4';
      final ref = _storage.ref().child('match_videos/$fileName');

      final uploadTask = ref.putFile(videoFile);

      uploadTask.snapshotEvents.listen((taskSnapshot) {
        final progress = taskSnapshot.bytesTransferred / taskSnapshot.totalBytes;
        onProgress(progress);
      });

      await uploadTask;
      final downloadUrl = await ref.getDownloadURL();

      final video = Video(
        id: '',
        matchId: matchId,
        url: downloadUrl,
        status: VideoStatus.processing,
        progress: 1.0,
        uploadedAt: DateTime.now(),
        uploadedBy: uploadedBy,
      );

      final docRef = await _videosCollection.add(video.toMap());
      return docRef.id;
    } catch (e) {
      debugPrint('Error uploading video: $e');
      rethrow;
    }
  }

  Future<Video?> getVideo(String videoId) async {
    try {
      final doc = await _videosCollection.doc(videoId).get();
      if (doc.exists) {
        return Video.fromMap(doc.data() as Map<String, dynamic>, doc.id);
      }
      return null;
    } catch (e) {
      debugPrint('Error getting video: $e');
      return null;
    }
  }

  Future<List<Video>> getMatchVideos(String matchId) async {
    try {
      final querySnapshot = await _videosCollection
          .where('matchId', isEqualTo: matchId)
          .orderBy('uploadedAt', descending: true)
          .get();

      return querySnapshot.docs
          .map((doc) => Video.fromMap(doc.data() as Map<String, dynamic>, doc.id))
          .toList();
    } catch (e) {
      debugPrint('Error getting match videos: $e');
      return [];
    }
  }

  Future<List<Video>> getUserVideos(String userId) async {
    try {
      final querySnapshot = await _videosCollection
          .where('uploadedBy', isEqualTo: userId)
          .orderBy('uploadedAt', descending: true)
          .get();

      return querySnapshot.docs
          .map((doc) => Video.fromMap(doc.data() as Map<String, dynamic>, doc.id))
          .toList();
    } catch (e) {
      debugPrint('Error getting user videos: $e');
      return [];
    }
  }

  Future<void> updateVideoStatus(String videoId, VideoStatus status, {double? progress}) async {
    try {
      final updates = <String, dynamic>{
        'status': status.name,
      };
      if (progress != null) {
        updates['progress'] = progress;
      }
      await _videosCollection.doc(videoId).update(updates);
    } catch (e) {
      debugPrint('Error updating video status: $e');
      rethrow;
    }
  }

  Stream<Video> watchVideoStatus(String videoId) {
    return _videosCollection.doc(videoId).snapshots().map(
      (doc) => Video.fromMap(doc.data() as Map<String, dynamic>, doc.id),
    );
  }
}
