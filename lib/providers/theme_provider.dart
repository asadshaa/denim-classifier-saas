import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:shared_preferences/shared_preferences.dart';

class ThemeProvider extends ChangeNotifier {
  ThemeMode _themeMode = ThemeMode.light; // Default to Light for "Clean/Solid" look unless user saved otherwise
  
  ThemeMode get themeMode => _themeMode;
  bool get isDarkMode => _themeMode == ThemeMode.dark;

  ThemeProvider() {
    _loadTheme();
  }

  void toggleTheme(bool isDark) {
    _themeMode = isDark ? ThemeMode.dark : ThemeMode.light;
    _saveTheme(isDark);
    notifyListeners();
  }

  Future<void> _loadTheme() async {
    final prefs = await SharedPreferences.getInstance();
    final isDark = prefs.getBool('isDarkMode') ?? false; // Default false (Light) matches the "clean" request
    _themeMode = isDark ? ThemeMode.dark : ThemeMode.light;
    notifyListeners();
  }

  Future<void> _saveTheme(bool isDark) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('isDarkMode', isDark);
  }

  // Professional Dark Theme
  ThemeData get darkTheme {
    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.dark,
      scaffoldBackgroundColor: const Color(0xFF101010), // Matte Black
      cardColor: const Color(0xFF1E1E1E), // Dark Grey Cards
      colorScheme: const ColorScheme.dark(
        primary: Color(0xFF80CBC4), // Soft Teal/Mint
        secondary: Color(0xFFB39DDB), // Soft Lavender (optional accent)
        surface: Color(0xFF1E1E1E),
        onPrimary: Colors.black,
        onSurface: Colors.white,
      ),
      textTheme: GoogleFonts.manropeTextTheme(ThemeData.dark().textTheme),
      appBarTheme: const AppBarTheme(
        backgroundColor: Colors.transparent,
        elevation: 0,
        centerTitle: true,
      ),
    );
  }

  // Professional Light Theme
  ThemeData get lightTheme {
    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.light,
      scaffoldBackgroundColor: const Color(0xFFF4F6F8), // Soft Blue-Grey White
      cardColor: Colors.white,
      colorScheme: const ColorScheme.light(
        primary: Color(0xFF00695C), // Deep Teal
        secondary: Color(0xFF263238), // Dark Blue Grey
        surface: Colors.white,
        onPrimary: Colors.white,
        onSurface: Color(0xFF212121),
      ),
      textTheme: GoogleFonts.manropeTextTheme(ThemeData.light().textTheme),
      appBarTheme: const AppBarTheme(
        backgroundColor: Colors.transparent,
        elevation: 0,
        centerTitle: true,
        titleTextStyle: TextStyle(color: Color(0xFF212121), fontSize: 20, fontWeight: FontWeight.bold),
        iconTheme: IconThemeData(color: Color(0xFF212121)),
      ),
    );
  }
}
