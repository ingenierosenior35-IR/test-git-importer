import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import '../theme/theme_helper.dart';
import '../localization/app_localization.dart';
import 'routes/app_routes.dart';
import 'bindings/initial_bindings.dart';
import 'config/app_config.dart';

class MyApp extends StatelessWidget {
  const MyApp({super.key});

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
      locale: Get.deviceLocale,
      fallbackLocale: const Locale('en', 'US'),
      title: AppConfig.appName,
      initialBinding: InitialBindings(),
      initialRoute: AppRoutes.initialRoute,
      onGenerateRoute: (settings) {
        return AppRoutes.routesFactory(settings);
      },
    );
  }
}
