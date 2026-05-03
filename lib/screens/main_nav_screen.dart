import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:denim_classifier/screens/home_screen.dart';
import 'package:denim_classifier/screens/history_screen.dart';
import 'package:denim_classifier/screens/analytics_screen.dart';
import 'package:denim_classifier/screens/profile_screen.dart';
import 'package:denim_classifier/screens/settings_screen.dart';

class MainNavScreen extends StatefulWidget {
  const MainNavScreen({super.key});

  @override
  State<MainNavScreen> createState() => _MainNavScreenState();
}

class _MainNavScreenState extends State<MainNavScreen> {
  int _selectedIndex = 0;

  // Tabs that should NOT be rebuilt every time (heavy/stateful)
  static const Widget _homeScreen = HomeScreen();
  static const Widget _settingsScreen = SettingsScreen();
  static const Widget _analyticsScreen = AnalyticsDashboardScreen();

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    final Widget currentScreen = switch (_selectedIndex) {
      0 => _homeScreen,
      1 => HistoryScreen(key: ValueKey('history_$_selectedIndex')),
      2 => _analyticsScreen,
      3 => ProfileScreen(key: ValueKey('profile_$_selectedIndex')),
      4 => _settingsScreen,
      _ => _homeScreen,
    };

    return Scaffold(
      extendBody: true,
      body: AnimatedSwitcher(
        duration: const Duration(milliseconds: 200),
        child: currentScreen,
      ),
      bottomNavigationBar: SafeArea(
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 10),
          margin: const EdgeInsets.symmetric(horizontal: 10, vertical: 10),
          decoration: BoxDecoration(
            color: isDark ? const Color(0xFF252525) : Colors.black,
            borderRadius: BorderRadius.circular(40),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.2),
                blurRadius: 20,
                offset: const Offset(0, 10),
              ),
            ],
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              _buildNavItem(0, Icons.adf_scanner, "Scan"),
              _buildNavItem(1, Icons.history, "History"),
              _buildNavItem(2, Icons.bar_chart_rounded, "Stats"),
              _buildNavItem(3, Icons.person, "Profile"),
              _buildNavItem(4, Icons.settings, "Setup"),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildNavItem(int index, IconData icon, String label) {
    final isSelected = _selectedIndex == index;

    return GestureDetector(
      onTap: () {
        HapticFeedback.selectionClick();
        setState(() => _selectedIndex = index);
      },
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
        decoration: isSelected
            ? BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(30),
              )
            : null,
        child: Row(
          children: [
            Icon(
              icon,
              color: isSelected ? Colors.black : Colors.grey,
              size: 22,
            ),
            if (isSelected) ...[
              const SizedBox(width: 6),
              Text(
                label,
                style: const TextStyle(
                  color: Colors.black,
                  fontWeight: FontWeight.bold,
                  fontSize: 13,
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
