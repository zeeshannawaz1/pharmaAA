import 'package:flutter/material.dart';
import 'core/widgets/main_app_widget.dart';
import 'injection_container.dart' as di;
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_analytics/firebase_analytics.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';
import 'firebase_options.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  MobileAds.instance.initialize();
  di.init();
  runApp(const MyApp());
}

FirebaseAnalytics analytics = FirebaseAnalytics.instance;

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'A&A DISTRIBUTOR',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        fontFamily: 'Poppins',
        primaryColor: Color(0xFF2CB5B4),
        scaffoldBackgroundColor: Color(0xFFF6FCFC),
        colorScheme: ColorScheme.fromSeed(
          seedColor: Color(0xFF2CB5B4),
          brightness: Brightness.light,
        ),
        cardTheme: CardThemeData(
          color: Colors.white,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(24),
          ),
          elevation: 4,
        ),
        elevatedButtonTheme: ElevatedButtonThemeData(
          style: ElevatedButton.styleFrom(
            backgroundColor: Color(0xFF2CB5B4),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(24),
            ),
            elevation: 2,
            textStyle: TextStyle(fontWeight: FontWeight.bold),
          ),
        ),
        iconTheme: IconThemeData(
          color: Color(0xFF2CB5B4),
          size: 28,
        ),
        sliderTheme: SliderThemeData(
          activeTrackColor: Color(0xFF2CB5B4),
          thumbColor: Color(0xFF2CB5B4),
          overlayColor: Color(0x332CB5B4),
          inactiveTrackColor: Color(0xFFB2DFDB),
        ),
        textTheme: TextTheme(
          titleLarge: TextStyle(color: Color(0xFF2CB5B4), fontWeight: FontWeight.bold),
          bodyMedium: TextStyle(color: Color(0xFF2CB5B4)),
        ),
        appBarTheme: AppBarTheme(
          backgroundColor: Color(0xFF2CB5B4),
          foregroundColor: Colors.white,
          elevation: 0,
          iconTheme: IconThemeData(color: Colors.white),
          titleTextStyle: TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
            fontSize: 20,
          ),
        ),
        floatingActionButtonTheme: FloatingActionButtonThemeData(
          backgroundColor: Color(0xFF2CB5B4),
          foregroundColor: Colors.white,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
        ),
      ),
      home: const MainAppWidget(),
    );
  }
} 
