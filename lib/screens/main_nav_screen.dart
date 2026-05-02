import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:denim_classifier/screens/home_screen.dart';
import 'package:denim_classifier/screens/history_screen.dart';
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

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    // History and Profile use a ValueKey with timestamp so they reload
    // fresh from SharedPreferences every time the tab is tapped
    final Widget currentScreen = switch (_selectedIndex) {
      0 => _homeScreen,
      1 => HistoryScreen(key: ValueKey('history_$_selectedIndex')),
      2 => ProfileScreen(key: ValueKey('profile_$_selectedIndex')),
      3 => _settingsScreen,
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
          margin: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
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
              _buildNavItem(2, Icons.person, "Profile"),
              _buildNavItem(3, Icons.settings, "Settings"),
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
