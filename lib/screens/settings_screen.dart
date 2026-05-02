import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:denim_classifier/providers/classifier_provider.dart';
import 'package:denim_classifier/providers/theme_provider.dart';
import 'package:denim_classifier/widgets/animated_orb_background.dart';

class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final themeProvider = Provider.of<ThemeProvider>(context);
    final classifierProvider = Provider.of<ClassifierProvider>(context);
    final isDark = themeProvider.isDarkMode;

    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        elevation: 0,
        backgroundColor: Colors.transparent,
        title: Text(
          'Settings',
          style: TextStyle(
            fontWeight: FontWeight.w800,
            fontSize: 20,
            color: isDark ? Colors.white : const Color(0xFF0F0C29),
          ),
        ),
        centerTitle: false,
      ),
      body: Stack(
        children: [
          AnimatedOrbBackground(
            orbs: isDark ? OrbConfig.dark : OrbConfig.light,
            speed: 0.65,
          ),
          SingleChildScrollView(
            padding: const EdgeInsets.fromLTRB(20, 0, 20, 100),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SizedBox(height: 110), // space below translucent appbar

                // ── Section: Appearance ───────────────────────────────────────
                _SectionLabel(label: 'APPEARANCE', isDark: isDark),
                const SizedBox(height: 8),
                _GlassSettingsCard(
                  isDark: isDark,
                  child: _ToggleRow(
                    icon: isDark ? Icons.dark_mode_rounded : Icons.light_mode_rounded,
                    iconColor: isDark ? const Color(0xFF8B5CF6) : const Color(0xFFF59E0B),
                    title: 'Dark Mode',
                    subtitle: isDark ? 'Dark theme active' : 'Light theme active',
                    value: isDark,
                    isDark: isDark,
                    onChanged: (val) {
                      HapticFeedback.selectionClick();
                      themeProvider.toggleTheme(val);
                    },
                  ),
                ),

                const SizedBox(height: 32),

                // ── Section: Classification Model ──────────────────────────────
                _SectionLabel(label: 'AI MODEL SELECTION', isDark: isDark),
                const SizedBox(height: 8),
                _ModelCard(
                  isDark: isDark,
                  title: 'DenimAI Multi-Head',
                  subtitle: 'denim_model.tflite',
                  description: '21 main classes × 5 subclasses — quantized for fast on-device inference.',
                  icon: Icons.auto_awesome_outlined,
                  gradient: const [Color(0xFF8B5CF6), Color(0xFF6366F1)],
                  value: 'denim_model.tflite',
                  selectedValue: classifierProvider.selectedModel,
                  onTap: () {
                    HapticFeedback.mediumImpact();
                    classifierProvider.setModel('denim_model.tflite');
                  },
                ),
                const SizedBox(height: 12),
                _ModelCard(
                  isDark: isDark,
                  title: 'Legacy Float32',
                  subtitle: 'best_model.tflite',
                  description: '5-class floating-point model. Use for backward compatibility only.',
                  icon: Icons.history_outlined,
                  gradient: const [Color(0xFF6366F1), Color(0xFF4F46E5)],
                  value: 'best_model.tflite',
                  selectedValue: classifierProvider.selectedModel,
                  onTap: () {
                    HapticFeedback.mediumImpact();
                    classifierProvider.setModel('best_model.tflite');
                  },
                ),

                const SizedBox(height: 32),

                // ── Section: About ───────────────────────────────────────────
                _SectionLabel(label: 'ABOUT DENIM AI', isDark: isDark),
                const SizedBox(height: 8),
                _GlassSettingsCard(
                  isDark: isDark,
                  child: Column(
                    children: [
                      _AboutRow(
                        icon: Icons.info_outline,
                        iconColor: const Color(0xFF6366F1),
                        label: 'Version',
                        value: '2.4.0-PRO',
                        isDark: isDark,
                      ),
                      _Divider(isDark: isDark),
                      _AboutRow(
                        icon: Icons.update,
                        iconColor: const Color(0xFF10B981),
                        label: 'Last Updated',
                        value: 'Apr 2026',
                        isDark: isDark,
                      ),
                      _Divider(isDark: isDark),
                      _AboutRow(
                        icon: Icons.verified_user_outlined,
                        iconColor: const Color(0xFFF59E0B),
                        label: 'License',
                        value: 'Enterprise',
                        isDark: isDark,
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 40),

                // ── Footer ───────────────────────────────────────────────────
                Center(
                  child: Column(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: isDark ? Colors.white.withOpacity(0.05) : Colors.black.withOpacity(0.05),
                          shape: BoxShape.circle,
                        ),
                        child: Icon(
                          Icons.auto_awesome,
                          size: 20,
                          color: isDark ? Colors.white24 : Colors.black26,
                        ),
                      ),
                      const SizedBox(height: 12),
                      Text(
                        'DENIM AI',
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w900,
                          letterSpacing: 4,
                          color: isDark ? Colors.white24 : Colors.black26,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        'Professional Fabric Intelligence',
                        style: TextStyle(
                          fontSize: 12,
                          color: isDark ? Colors.white38 : Colors.black38,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

// ── Section Label ─────────────────────────────────────────────────────────────

class _SectionLabel extends StatelessWidget {
  final String label;
  final bool isDark;
  const _SectionLabel({required this.label, required this.isDark});

  @override
  Widget build(BuildContext context) {
    return Text(
      label,
      style: TextStyle(
        fontSize: 11,
        fontWeight: FontWeight.w700,
        letterSpacing: 1.2,
        color: isDark ? Colors.white38 : Colors.black38,
      ),
    );
  }
}

// ── Glass Settings Card ────────────────────────────────────────────────────────

class _GlassSettingsCard extends StatelessWidget {
  final Widget child;
  final bool isDark;
  const _GlassSettingsCard({required this.child, required this.isDark});

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(18),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
        child: Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: isDark
                ? Colors.white.withOpacity(0.06)
                : Colors.white.withOpacity(0.8),
            borderRadius: BorderRadius.circular(18),
            border: Border.all(
              color: isDark
                  ? Colors.white.withOpacity(0.1)
                  : Colors.black.withOpacity(0.07),
            ),
          ),
          child: child,
        ),
      ),
    );
  }
}

// ── Toggle Row ────────────────────────────────────────────────────────────────

class _ToggleRow extends StatelessWidget {
  final IconData icon;
  final Color iconColor;
  final String title;
  final String subtitle;
  final bool value;
  final bool isDark;
  final ValueChanged<bool> onChanged;

  const _ToggleRow({
    required this.icon,
    required this.iconColor,
    required this.title,
    required this.subtitle,
    required this.value,
    required this.isDark,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Container(
          width: 40,
          height: 40,
          decoration: BoxDecoration(
            color: iconColor.withOpacity(0.12),
            borderRadius: BorderRadius.circular(10),
          ),
          child: Icon(icon, color: iconColor, size: 20),
        ),
        const SizedBox(width: 14),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: TextStyle(
                  fontWeight: FontWeight.w600,
                  fontSize: 15,
                  color: isDark ? Colors.white : const Color(0xFF0F0C29),
                ),
              ),
              Text(
                subtitle,
                style: TextStyle(
                  fontSize: 12,
                  color: isDark ? Colors.white38 : Colors.black38,
                ),
              ),
            ],
          ),
        ),
        Switch.adaptive(
          value: value,
          activeColor: const Color(0xFF6366F1),
          onChanged: onChanged,
        ),
      ],
    );
  }
}

// ── Model Card ────────────────────────────────────────────────────────────────

class _ModelCard extends StatelessWidget {
  final bool isDark;
  final String title;
  final String subtitle;
  final String description;
  final IconData icon;
  final List<Color> gradient;
  final String value;
  final String selectedValue;
  final VoidCallback onTap;

  const _ModelCard({
    required this.isDark,
    required this.title,
    required this.subtitle,
    required this.description,
    required this.icon,
    required this.gradient,
    required this.value,
    required this.selectedValue,
    required this.onTap,
  });

  bool get _selected => value == selectedValue;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 250),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          gradient: _selected
              ? LinearGradient(
                  colors: [gradient[0].withOpacity(0.15), gradient[1].withOpacity(0.08)])
              : null,
          color: _selected
              ? null
              : (isDark
                  ? Colors.white.withOpacity(0.05)
                  : Colors.white.withOpacity(0.7)),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: _selected
                ? gradient[0].withOpacity(0.5)
                : (isDark
                    ? Colors.white.withOpacity(0.1)
                    : Colors.black.withOpacity(0.07)),
            width: _selected ? 1.5 : 1,
          ),
        ),
        child: Row(
          children: [
            Container(
              width: 46,
              height: 46,
              decoration: BoxDecoration(
                gradient: LinearGradient(colors: gradient),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(icon, color: Colors.white, size: 22),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: TextStyle(
                      fontWeight: FontWeight.w700,
                      fontSize: 14,
                      color: isDark ? Colors.white : const Color(0xFF0F0C29),
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    subtitle,
                    style: TextStyle(
                      fontSize: 11,
                      color: isDark ? Colors.white38 : Colors.black38,
                      fontFamily: 'monospace',
                    ),
                  ),
                  const SizedBox(height: 3),
                  Text(
                    description,
                    style: TextStyle(
                      fontSize: 12,
                      color: isDark ? Colors.white54 : Colors.black45,
                    ),
                  ),
                ],
              ),
            ),
            AnimatedContainer(
              duration: const Duration(milliseconds: 250),
              width: 22,
              height: 22,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: _selected
                    ? LinearGradient(colors: gradient)
                    : null,
                color: _selected
                    ? null
                    : (isDark
                        ? Colors.white.withOpacity(0.1)
                        : Colors.black.withOpacity(0.08)),
                border: _selected
                    ? null
                    : Border.all(
                        color: isDark
                            ? Colors.white.withOpacity(0.2)
                            : Colors.black.withOpacity(0.15)),
              ),
              child: _selected
                  ? const Icon(Icons.check, color: Colors.white, size: 14)
                  : null,
            ),
          ],
        ),
      ),
    );
  }
}

// ── About Row ─────────────────────────────────────────────────────────────────

class _AboutRow extends StatelessWidget {
  final IconData icon;
  final Color iconColor;
  final String label;
  final String value;
  final bool isDark;

  const _AboutRow({
    required this.icon,
    required this.iconColor,
    required this.label,
    required this.value,
    required this.isDark,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Container(
          width: 34,
          height: 34,
          decoration: BoxDecoration(
            color: iconColor.withOpacity(0.1),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Icon(icon, color: iconColor, size: 17),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Text(
            label,
            style: TextStyle(
              fontSize: 14,
              color: isDark ? Colors.white70 : Colors.black54,
            ),
          ),
        ),
        Text(
          value,
          style: TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w600,
            color: isDark ? Colors.white : const Color(0xFF0F0C29),
          ),
        ),
      ],
    );
  }
}

class _Divider extends StatelessWidget {
  final bool isDark;
  const _Divider({required this.isDark});

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 1,
      margin: const EdgeInsets.symmetric(vertical: 10),
      color: isDark ? Colors.white.withOpacity(0.06) : Colors.black.withOpacity(0.05),
    );
  }
}
