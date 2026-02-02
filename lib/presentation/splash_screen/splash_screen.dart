import 'package:flutter/material.dart';
import 'package:Rival/core/app_export.dart';
import 'controller/splash_controller.dart';




class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
 SplashController splashController = Get.put(SplashController());
 @override
 Widget build(BuildContext context) {
  mediaQueryData = MediaQuery.of(context);
  return Scaffold(
      backgroundColor: Colors.black,
      body: Center(
        child: Text(
          'Rival',
          style: TextStyle(
            fontSize: 48,
            fontWeight: FontWeight.bold,
            color: const Color(0xFFCDFF4D),
            letterSpacing: 2,
          ),
        ),
      ),
  );
 }


 onTapImgImage() {
  Get.toNamed(
   AppRoutes.onboardingOneScreen,
  );
 }
}


