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
        title: const Text('System Settings', style: TextStyle(fontWeight: FontWeight.w900)),
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
                const SizedBox(height: 110), 

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

                // ── Section: Neural Core (Static Info) ────────────────────────
                _SectionLabel(label: 'OPERATIONAL CORE', isDark: isDark),
                const SizedBox(height: 8),
                Container(
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: isDark 
                        ? [const Color(0xFF6366F1).withOpacity(0.15), const Color(0xFF06B6D4).withOpacity(0.05)]
                        : [const Color(0xFF6366F1).withOpacity(0.05), const Color(0xFF06B6D4).withOpacity(0.02)],
                    ),
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(color: const Color(0xFF6366F1).withOpacity(0.2)),
                  ),
                  child: Column(
                    children: [
                      Row(
                        children: [
                          Container(
                            width: 48, height: 48,
                            decoration: BoxDecoration(
                              gradient: const LinearGradient(colors: [Color(0xFF6366F1), Color(0xFF06B6D4)]),
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: const Icon(Icons.psychology, color: Colors.white, size: 28),
                          ),
                          const SizedBox(width: 16),
                          const Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text('DenimAI v1.0 PRO', style: TextStyle(fontWeight: FontWeight.w900, fontSize: 16)),
                                Text('Multi-Head Research Engine', style: TextStyle(fontSize: 12, color: Colors.grey)),
                              ],
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 16),
                      const Divider(),
                      const SizedBox(height: 12),
                      _CoreInfoRow(label: 'Taxonomy', value: '21 Classes', isDark: isDark),
                      _CoreInfoRow(label: 'Architecture', value: 'EfficientNetB0', isDark: isDark),
                      _CoreInfoRow(label: 'Optimization', value: 'FP16 Quantized', isDark: isDark),
                    ],
                  ),
                ),

                const SizedBox(height: 32),

                // ── Section: About ───────────────────────────────────────────
                _SectionLabel(label: 'ABOUT SYSTEM', isDark: isDark),
                const SizedBox(height: 8),
                _GlassSettingsCard(
                  isDark: isDark,
                  child: Column(
                    children: [
                      _AboutRow(
                        icon: Icons.info_outline,
                        iconColor: const Color(0xFF6366F1),
                        label: 'Build',
                        value: 'v2.4.0-STABLE',
                        isDark: isDark,
                      ),
                      _Divider(isDark: isDark),
                      _AboutRow(
                        icon: Icons.update,
                        iconColor: const Color(0xFF10B981),
                        label: 'Kernel',
                        value: 'Apr 2026',
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
                      const Icon(Icons.auto_awesome, size: 20, color: Colors.grey),
                      const SizedBox(height: 12),
                      const Text(
                        'DENIM AI',
                        style: TextStyle(fontSize: 14, fontWeight: FontWeight.w900, letterSpacing: 4, color: Colors.grey),
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

class _SectionLabel extends StatelessWidget {
  final String label;
  final bool isDark;
  const _SectionLabel({required this.label, required this.isDark});

  @override
  Widget build(BuildContext context) {
    return Text(label, style: TextStyle(fontSize: 11, fontWeight: FontWeight.w900, letterSpacing: 1.5, color: isDark ? Colors.white24 : Colors.black26));
  }
}

class _GlassSettingsCard extends StatelessWidget {
  final Widget child;
  final bool isDark;
  const _GlassSettingsCard({required this.child, required this.isDark});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: isDark ? Colors.white.withOpacity(0.05) : Colors.white.withOpacity(0.8),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: isDark ? Colors.white.withOpacity(0.08) : Colors.black.withOpacity(0.05)),
      ),
      child: child,
    );
  }
}

class _ToggleRow extends StatelessWidget {
  final IconData icon;
  final Color iconColor;
  final String title, subtitle;
  final bool value, isDark;
  final ValueChanged<bool> onChanged;

  const _ToggleRow({required this.icon, required this.iconColor, required this.title, required this.subtitle, required this.value, required this.isDark, required this.onChanged});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Container(width: 40, height: 40, decoration: BoxDecoration(color: iconColor.withOpacity(0.1), borderRadius: BorderRadius.circular(10)), child: Icon(icon, color: iconColor, size: 20)),
        const SizedBox(width: 14),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(title, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15)),
              Text(subtitle, style: TextStyle(fontSize: 12, color: isDark ? Colors.white38 : Colors.black38)),
            ],
          ),
        ),
        Switch.adaptive(value: value, activeColor: const Color(0xFF6366F1), onChanged: onChanged),
      ],
    );
  }
}

class _CoreInfoRow extends StatelessWidget {
  final String label, value;
  final bool isDark;
  const _CoreInfoRow({required this.label, required this.value, required this.isDark});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: TextStyle(fontSize: 12, color: isDark ? Colors.white38 : Colors.black38)),
          Text(value, style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold)),
        ],
      ),
    );
  }
}

class _AboutRow extends StatelessWidget {
  final IconData icon;
  final Color iconColor;
  final String label, value;
  final bool isDark;

  const _AboutRow({required this.icon, required this.iconColor, required this.label, required this.value, required this.isDark});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Container(width: 34, height: 34, decoration: BoxDecoration(color: iconColor.withOpacity(0.1), borderRadius: BorderRadius.circular(8)), child: Icon(icon, color: iconColor, size: 17)),
        const SizedBox(width: 12),
        Expanded(child: Text(label, style: TextStyle(fontSize: 14, color: isDark ? Colors.white70 : Colors.black54))),
        Text(value, style: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold)),
      ],
    );
  }
}

class _Divider extends StatelessWidget {
  final bool isDark;
  const _Divider({required this.isDark});
  @override
  Widget build(BuildContext context) => Container(height: 1, margin: const EdgeInsets.symmetric(vertical: 10), color: isDark ? Colors.white.withOpacity(0.06) : Colors.black.withOpacity(0.05));
}
