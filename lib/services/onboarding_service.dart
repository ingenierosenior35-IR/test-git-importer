import 'dart:io';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/foundation.dart';

class OnboardingService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseStorage _storage = FirebaseStorage.instance;

  // Save onboarding data
  Future<void> saveOnboardingData({
    required String uid,
    required List<String> sports,
    required String gender,
    required Map<String, dynamic> height,
    required Map<String, dynamic> weight,
    List<String>? photoUrls,
  }) async {
    try {
      await _firestore.collection('users').doc(uid).set({
        'onboarding_completed': true,
        'sports': sports,
        'gender': gender,
        'height': height,
        'weight': weight,
        'profilePhotos': photoUrls ?? [],
        'profileCompletedAt': FieldValue.serverTimestamp(),
      }, SetOptions(merge: true));
      debugPrint('✅ Onboarding data saved successfully');
    } catch (e) {
      debugPrint('❌ Error saving onboarding data: $e');
      rethrow;
    }
  }

  // Upload photos to Firebase Storage
  Future<List<String>> uploadPhotos({
    required String uid,
    required List<File> photos,
  }) async {
    List<String> photoUrls = [];

    try {
      for (int i = 0; i < photos.length; i++) {
        final file = photos[i];
        
        // Create reference with proper path
        final String fileName = 'profile_${uid}_${DateTime.now().millisecondsSinceEpoch}_$i.jpg';
        final Reference storageRef = _storage
            .ref()
            .child('user_profiles')
            .child(uid)
            .child(fileName);
        
        debugPrint('📤 Uploading photo to: ${storageRef.fullPath}');
        
        // Upload file with metadata
        final UploadTask uploadTask = storageRef.putFile(
          file,
          SettableMetadata(
            contentType: 'image/jpeg',
            customMetadata: {'uploaded_by': uid},
          ),
        );
        
        // Wait for completion
        final TaskSnapshot snapshot = await uploadTask;
        
        // Get download URL
        final String downloadUrl = await snapshot.ref.getDownloadURL();
        photoUrls.add(downloadUrl);
        
        debugPrint('✅ Photo uploaded successfully: $downloadUrl');
      }
      
      return photoUrls;
    } catch (e) {
      debugPrint('❌ Error uploading photos: $e');
      if (e is FirebaseException) {
        debugPrint('Firebase error code: ${e.code}');
        debugPrint('Firebase error message: ${e.message}');
      }
      rethrow;
    }
  }

  // Delete photo from Firebase Storage
  Future<void> deletePhoto(String photoUrl) async {
    try {
      Reference ref = _storage.refFromURL(photoUrl);
      await ref.delete();
    } catch (e) {
      debugPrint('Error deleting photo: $e');
      // Don't rethrow - photo deletion is not critical
    }
  }
}
