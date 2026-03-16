import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';
import 'package:Rival/core/app_export.dart';
import 'package:Rival/presentation/splash_screen/models/splash_model.dart';

class SplashController extends GetxController {
  Rx<SplashModel> splashModelObj = SplashModel().obs;

  @override
  void onReady() {
    _getIsFirst();
  }

  _getIsFirst() async {
    // Allow Firebase to restore the persisted auth state before checking.
    await Future.delayed(const Duration(seconds: 3));

    // Use Firebase Auth as the authoritative source of truth.
    final firebaseUser = FirebaseAuth.instance.currentUser;
    final bool isSignIn = firebaseUser != null;

    debugPrint("Firebase currentUser: ${firebaseUser?.uid}");
    debugPrint("isSignIn ====== $isSignIn");

    if (isSignIn) {
      // Keep the pref in sync so other parts of the app that still read it
      // behave consistently.
      await PrefUtils.setIsSignIn(true);
      Get.offAllNamed(AppRoutes.mainContainerScreen);
    } else {
      await PrefUtils.setIsSignIn(false);
      Get.offAllNamed(AppRoutes.welcomeScreen);
    }
  }
}