import 'dart:async';
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
    bool isSignIn = await PrefUtils.getIsSignIn();
    bool isIntro = await PrefUtils.getIsIntro();
    
    Timer(const Duration(seconds: 3), () {
      debugPrint("is intro ====== $isIntro");
      debugPrint("isSignIn ====== $isSignIn");
      
      // If signed in, go to main app; otherwise show welcome/login
      if (isSignIn) {
        Get.toNamed(AppRoutes.mainContainerScreen);
      } else {
        Get.toNamed(AppRoutes.welcomeScreen);
      }
    });
  }
}