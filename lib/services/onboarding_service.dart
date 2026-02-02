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
        'onboardingCompleted': true,
        'sports': sports,
        'gender': gender,
        'height': height,
        'weight': weight,
        'profilePhotos': photoUrls ?? [],
        'profileCompletedAt': FieldValue.serverTimestamp(),
      }, SetOptions(merge: true));
    } catch (e) {
      debugPrint('Error saving onboarding data: $e');
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
        String fileName = 'profile_${DateTime.now().millisecondsSinceEpoch}_$i.jpg';
        Reference ref = _storage.ref().child('users/$uid/photos/$fileName');
        
        debugPrint('🔵 Uploading photo to: users/$uid/photos/$fileName');
        
        UploadTask uploadTask = ref.putFile(photos[i]);
        TaskSnapshot snapshot = await uploadTask;
        
        String downloadUrl = await snapshot.ref.getDownloadURL();
        photoUrls.add(downloadUrl);
        
        debugPrint('✅ Photo uploaded successfully: $downloadUrl');
      }
      
      return photoUrls;
    } on FirebaseException catch (e) {
      debugPrint('❌ Firebase Storage Error: ${e.code} - ${e.message}');
      
      // Provide more specific error messages
      String errorMessage;
      switch (e.code) {
        case 'storage/object-not-found':
          errorMessage = 'Error de configuración de almacenamiento. Contacta al administrador.';
          break;
        case 'storage/unauthorized':
          errorMessage = 'No tienes permiso para subir archivos. Verifica tu sesión.';
          break;
        case 'storage/canceled':
          errorMessage = 'Subida cancelada. Intenta de nuevo.';
          break;
        case 'storage/unknown':
          errorMessage = 'Error desconocido al subir la foto. Verifica tu conexión.';
          break;
        default:
          errorMessage = 'Error al subir la foto: ${e.message}';
      }
      
      throw Exception(errorMessage);
    } catch (e) {
      debugPrint('❌ Error uploading photos: $e');
      throw Exception('Error al subir la foto. Verifica tu conexión.');
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
