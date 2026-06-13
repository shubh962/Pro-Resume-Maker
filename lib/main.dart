import 'dart:io';
import 'package:flutter/material.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';
import 'home_screen.dart';
import 'resume_data.dart';
import 'app_constants.dart';
import 'notification_service.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  if (Platform.isAndroid || Platform.isIOS) {
    await MobileAds.instance.initialize();
  }

  await ResumeData().loadAllResumes();
  await NotificationService.instance.init();
  runApp(const ResumeMakerApp());
}

class ResumeMakerApp extends StatelessWidget {
  const ResumeMakerApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: AppConstants.appName,
      theme: ThemeData(
        useMaterial3: true,
        colorScheme: ColorScheme.fromSeed(
          seedColor: const Color(AppConstants.primaryInt),
          brightness: Brightness.light,
        ),
        scaffoldBackgroundColor: const Color(AppConstants.bgInt),
        fontFamily: 'Roboto',
        cardTheme: CardThemeData(
          elevation: 0,
          color: Colors.white,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        ),
        appBarTheme: const AppBarTheme(
          backgroundColor: Colors.transparent,
          elevation: 0,
          centerTitle: false,
        ),
        snackBarTheme: const SnackBarThemeData(
          behavior: SnackBarBehavior.floating,
          backgroundColor: Color(AppConstants.darkInt),
          contentTextStyle: TextStyle(color: Colors.white),
        ),
        floatingActionButtonTheme: const FloatingActionButtonThemeData(
          backgroundColor: Color(AppConstants.primaryInt),
          foregroundColor: Colors.white,
        ),
      ),
      home: const HomeScreen(),
    );
  }
}
