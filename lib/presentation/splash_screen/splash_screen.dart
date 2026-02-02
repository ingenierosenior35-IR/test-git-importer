import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:Rival/core/app_export.dart';
import '../../core/constants/app_colors.dart';
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
      backgroundColor: AppColors.backgroundBlack,
      body: Center(
        child: Text(
          'Rival',
          style: GoogleFonts.urbanist(
            fontSize: 48,
            fontWeight: FontWeight.bold,
            color: AppColors.primary,
            letterSpacing: 2,
          ),
        ),
      ));
 }
}


