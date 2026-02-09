import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';
import '../../../../core/errors/exceptions.dart';

abstract class AuthLocalDataSource {
  Future<void> createOrUpdateUser({
    required String uid,
    String? phoneNumber,
    String? email,
    String? displayName,
    String? photoURL,
    required String provider,
  });
  
  Future<bool> isPhoneNumberRegistered(String phoneNumber);
  Future<bool> isOnboardingCompleted(String uid);
  Future<Map<String, dynamic>?> getUserData(String uid);
}

class AuthLocalDataSourceImpl implements AuthLocalDataSource {
  final FirebaseFirestore firestore;

  AuthLocalDataSourceImpl({required this.firestore});

  CollectionReference get usersCollection => firestore.collection('users');

  @override
  Future<void> createOrUpdateUser({
    required String uid,
    String? phoneNumber,
    String? email,
    String? displayName,
    String? photoURL,
    required String provider,
  }) async {
    try {
      DocumentReference userDoc = usersCollection.doc(uid);
      DocumentSnapshot doc = await userDoc.get();
      
      if (doc.exists) {
        await userDoc.update({
          'lastLogin': FieldValue.serverTimestamp(),
          if (phoneNumber != null) 'phoneNumber': phoneNumber,
          if (email != null) 'email': email,
          if (displayName != null) 'displayName': displayName,
          if (photoURL != null) 'photoURL': photoURL,
        });
      } else {
        await userDoc.set({
          'uid': uid,
          'phoneNumber': phoneNumber,
          'email': email,
          'displayName': displayName,
          'photoURL': photoURL,
          'provider': provider,
          'onboardingCompleted': false,
          'createdAt': FieldValue.serverTimestamp(),
          'lastLogin': FieldValue.serverTimestamp(),
        });
      }
    } catch (e) {
      debugPrint('Error creating/updating user: $e');
      throw CacheException('Failed to create/update user: $e');
    }
  }

  @override
  Future<bool> isPhoneNumberRegistered(String phoneNumber) async {
    try {
      QuerySnapshot querySnapshot = await usersCollection
          .where('phoneNumber', isEqualTo: phoneNumber)
          .limit(1)
          .get();
      
      return querySnapshot.docs.isNotEmpty;
    } catch (e) {
      debugPrint('Error checking phone number: $e');
      return false;
    }
  }

  @override
  Future<bool> isOnboardingCompleted(String uid) async {
    try {
      DocumentSnapshot doc = await usersCollection.doc(uid).get();
      if (doc.exists) {
        Map<String, dynamic>? data = doc.data() as Map<String, dynamic>?;
        return data?['onboardingCompleted'] == true;
      }
      return false;
    } catch (e) {
      debugPrint('Error checking onboarding status: $e');
      return false;
    }
  }

  @override
  Future<Map<String, dynamic>?> getUserData(String uid) async {
    try {
      DocumentSnapshot doc = await usersCollection.doc(uid).get();
      if (doc.exists) {
        return doc.data() as Map<String, dynamic>?;
      }
      return null;
    } catch (e) {
      debugPrint('Error getting user data: $e');
      throw CacheException('Failed to get user data: $e');
    }
  }
}
