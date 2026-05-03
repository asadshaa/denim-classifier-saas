import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:denim_classifier/providers/classifier_provider.dart';
import 'package:denim_classifier/providers/theme_provider.dart';
import 'package:denim_classifier/providers/analytics_provider.dart';
import 'package:denim_classifier/models/prediction_record.dart';
import 'package:denim_classifier/screens/onboarding_screen.dart';
import 'package:denim_classifier/screens/main_nav_screen.dart';
import 'package:denim_classifier/screens/splash_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Initialize Local Database
  await Hive.initFlutter();
  Hive.registerAdapter(PredictionRecordAdapter());
  await Hive.openBox<PredictionRecord>('predictions');

  // Check if onboarding is seen
  final prefs = await SharedPreferences.getInstance();
  final bool seenOnboarding = prefs.getBool('seenOnboarding') ?? false;

  // First launch → Onboarding; Returning users → Splash → Home
  final Widget startScreen = seenOnboarding
      ? const SplashScreen(nextScreen: MainNavScreen())
      : const OnboardingScreen();

  runApp(MyApp(startScreen: startScreen));
}

class MyApp extends StatelessWidget {
  final Widget startScreen;

  const MyApp({super.key, required this.startScreen});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => ClassifierProvider()),
        ChangeNotifierProvider(create: (_) => ThemeProvider()),
        ChangeNotifierProvider(create: (_) => AnalyticsProvider()),
      ],
      child: Consumer<ThemeProvider>(
        builder: (context, themeProvider, child) {
          return MaterialApp(
            title: 'Denim Classifier',
            debugShowCheckedModeBanner: false,
            // Theme Logic
            theme: themeProvider.lightTheme,
            darkTheme: themeProvider.darkTheme,
            themeMode: themeProvider.themeMode,
            
            home: startScreen,
          );
        },
      ),
    );
  }
}
