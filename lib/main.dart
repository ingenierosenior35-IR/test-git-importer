import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:Rival/routes/app_routes.dart';
import 'package:Rival/theme/theme_helper.dart';
import 'package:google_fonts/google_fonts.dart';

import 'core/utils/initial_bindings.dart';
import 'localization/app_localization.dart';

// import 'core/app_export.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  // Initialize Firebase
  try {
    await Firebase.initializeApp();
    
    // Verify that Firebase Storage is available
    debugPrint('✅ Firebase initialized successfully');
    debugPrint('📦 Firebase Storage Bucket: ${FirebaseStorage.instance.bucket}');
  } catch (e) {
    debugPrint('❌ Firebase initialization error: $e');
  }
  
  SystemChrome.setPreferredOrientations([
    DeviceOrientation.portraitUp,
  ]).then((value) {
    // Logger.init(kReleaseMode ? LogMode.live : LogMode.debug);
    runApp(MyApp());
  });
}

class MyApp extends StatelessWidget {
  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return GetMaterialApp(
      debugShowCheckedModeBanner: false,
      theme: theme.copyWith(
        textTheme: GoogleFonts.urbanistTextTheme(
          ThemeData.dark().textTheme,
        ),
      ),
      translations: AppLocalization(),
      locale: Get.deviceLocale, //for setting localization strings
      // ignore: prefer_const_constructors
      fallbackLocale: Locale('en', 'US'),
      title: 'Rival',
      initialBinding: InitialBindings(),
      initialRoute: AppRoutes.initialRoute,
      onGenerateRoute: (settings) {
        return AppRoutes.routesFactory(settings);
      },
      // getPages: AppRoutes.pages,
    );
  }
}
