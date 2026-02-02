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
    bool isIntro = await PrefUtils. getIsIntro();
    
    Timer(const Duration(seconds:  2), () {
      debugPrint("is intro ====== $isIntro");
      debugPrint("isSignIn ====== $isSignIn");
      
      // Always navigate to welcome screen (login) after splash
      // Skip the old onboarding pages completely
      if (isSignIn) {
        Get.toNamed(AppRoutes.welcomeScreen);
      } else {
        Get.toNamed(AppRoutes.homeContainerScreen);
      }
    });
  }
}