import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:percent_indicator/percent_indicator.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:denim_classifier/utils/fabric_data.dart';
import 'package:denim_classifier/widgets/animated_orb_background.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  int _totalScans = 0;
  String _topClass = '—';
  double _avgConfidence = 0;
  Map<String, int> _classCounts = {};
  bool _isLoading = true;

  // Matching colors per class (same as HistoryScreen)
  static const Map<String, Color> _classColors = {
    '1553-EL':      Color(0xFF6366F1),
    '1830-BZ':      Color(0xFF10B981),
    '1976W-RS01':   Color(0xFFF59E0B),
    'P140406-BB':   Color(0xFF3B82F6),
    'PRT0235-AY':   Color(0xFF8B5CF6),
  };

  static const Map<String, String> _classEmoji = {
    '1553-EL':      '🔵',
    '1830-BZ':      '🟢',
    '1976W-RS01':   '🟤',
    'P140406-BB':   '🟦',
    'PRT0235-AY':   '🟣',
  };

  @override
  void initState() {
    super.initState();
    _loadStats();
  }

  Future<void> _loadStats() async {
    final prefs = await SharedPreferences.getInstance();
    final jsonStr = prefs.getString('scan_history_json');
    if (jsonStr != null) {
      try {
        final decoded = jsonDecode(jsonStr) as List<dynamic>;
        final history = decoded.cast<Map<String, dynamic>>();
        int total = history.length;
        Map<String, int> counts = { for (var c in FabricData.classes) c: 0 };
        double totalConf = 0;

        for (final item in history) {
          final label = item['label'] as String? ?? '';
          final conf = (item['confidence'] as num?)?.toDouble() ?? 0.0;
          if (counts.containsKey(label)) counts[label] = counts[label]! + 1;
          totalConf += conf;
        }

        String top = '—';
        if (counts.values.any((v) => v > 0)) {
          top = counts.entries.reduce((a, b) => a.value >= b.value ? a : b).key;
        }

        setState(() {
          _totalScans = total;
          _avgConfidence = total > 0 ? totalConf / total : 0;
          _topClass = top;
          _classCounts = counts;
          _isLoading = false;
        });
        return;
      } catch (_) {}
    }
    setState(() => _isLoading = false);
  }

  @override
  Widget build(BuildContext context) {
    final primary = Theme.of(context).colorScheme.primary;
    final secondary = Theme.of(context).colorScheme.secondary;
    final onSurface = Theme.of(context).colorScheme.onSurface;
    final cardColor = Theme.of(context).cardColor;

    return Scaffold(
      appBar: AppBar(title: const Text('Your Profile')),
      body: Stack(
        children: [
          AnimatedOrbBackground(
            orbs: Theme.of(context).brightness == Brightness.dark
                ? OrbConfig.dark
                : OrbConfig.light,
            speed: 0.6,
          ),
          _isLoading
              ? const Center(child: CircularProgressIndicator())
              : SingleChildScrollView(
                  padding: const EdgeInsets.fromLTRB(16, 16, 16, 100),
              child: Column(
                children: [
                  // ── Profile Banner ──────────────────────────────────
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.symmetric(vertical: 28, horizontal: 20),
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: [primary, secondary],
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      ),
                      borderRadius: BorderRadius.circular(24),
                    ),
                    child: Column(
                      children: [
                        CircleAvatar(
                          radius: 36,
                          backgroundColor: Colors.white.withOpacity(0.2),
                          child: const Text('👤', style: TextStyle(fontSize: 36)),
                        ),
                        const SizedBox(height: 12),
                        const Text(
                          'Denim Analyst',
                          style: TextStyle(color: Colors.white, fontSize: 22, fontWeight: FontWeight.bold),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          _totalScans == 0
                              ? 'Start scanning to earn your badge!'
                              : _totalScans >= 25 ? '🏆 Expert Classifier'
                              : _totalScans >= 10 ? '🌟 Experienced Analyst'
                              : '🌱 Getting Started',
                          style: TextStyle(color: Colors.white.withOpacity(0.85), fontSize: 14),
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 20),

                  // ── Stats Row ───────────────────────────────────────
                  Row(
                    children: [
                      _StatCard(
                        label: 'Total Scans', value: _totalScans.toString(),
                        icon: Icons.document_scanner, color: primary,
                        cardColor: cardColor, onSurface: onSurface,
                      ),
                      const SizedBox(width: 12),
                      _StatCard(
                        label: 'Top Class',
                        value: _topClass == '—' ? '—' : _topClass,
                        subLabel: _topClass == '—' ? '' : (FabricData.classesEng[_topClass] ?? ''),
                        icon: Icons.emoji_events,
                        color: const Color(0xFFFFD700),
                        cardColor: cardColor, onSurface: onSurface,
                      ),
                      const SizedBox(width: 12),
                      _StatCard(
                        label: 'Avg. Confidence',
                        value: '${(_avgConfidence * 100).toStringAsFixed(0)}%',
                        icon: Icons.bar_chart, color: secondary,
                        cardColor: cardColor, onSurface: onSurface,
                      ),
                    ],
                  ),

                  const SizedBox(height: 20),

                  // ── Bar Chart: Class Distribution ───────────────────
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      color: cardColor,
                      borderRadius: BorderRadius.circular(20),
                      boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.08), blurRadius: 10)],
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Icon(Icons.bar_chart_rounded, color: primary),
                            const SizedBox(width: 8),
                            Text(
                              'Class Distribution',
                              style: TextStyle(fontSize: 17, fontWeight: FontWeight.bold, color: onSurface),
                            ),
                          ],
                        ),
                        const SizedBox(height: 4),
                        Text(
                          'Scans by denim classification',
                          style: TextStyle(fontSize: 12, color: onSurface.withOpacity(0.5)),
                        ),
                        const SizedBox(height: 20),

                        if (_totalScans == 0)
                          Center(
                            child: Padding(
                              padding: const EdgeInsets.all(20),
                              child: Text('No scans yet', style: TextStyle(color: onSurface.withOpacity(0.4))),
                            ),
                          )
                        else
                          ...FabricData.classes.map((cls) {
                            final count = _classCounts[cls] ?? 0;
                            final frac = _totalScans > 0 ? count / _totalScans : 0.0;
                            final color = _classColors[cls] ?? primary;
                            final emoji = _classEmoji[cls] ?? '🔵';
                            final desc = FabricData.classesEng[cls] ?? '';

                            return Padding(
                              padding: const EdgeInsets.only(bottom: 18),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Row(
                                    children: [
                                      Text(emoji, style: const TextStyle(fontSize: 16)),
                                      const SizedBox(width: 8),
                                      Expanded(
                                        child: Column(
                                          crossAxisAlignment: CrossAxisAlignment.start,
                                          children: [
                                            Text(
                                              cls,
                                              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13, color: onSurface),
                                            ),
                                            Text(
                                              desc,
                                              style: TextStyle(fontSize: 11, color: onSurface.withOpacity(0.5)),
                                              maxLines: 1, overflow: TextOverflow.ellipsis,
                                            ),
                                          ],
                                        ),
                                      ),
                                      const SizedBox(width: 8),
                                      Text(
                                        '$count scan${count == 1 ? '' : 's'}',
                                        style: TextStyle(fontSize: 11, color: onSurface.withOpacity(0.5)),
                                      ),
                                      const SizedBox(width: 8),
                                      SizedBox(
                                        width: 38,
                                        child: Text(
                                          '${(frac * 100).toInt()}%',
                                          textAlign: TextAlign.right,
                                          style: TextStyle(color: color, fontWeight: FontWeight.bold, fontSize: 13),
                                        ),
                                      ),
                                    ],
                                  ),
                                  const SizedBox(height: 8),
                                  LinearPercentIndicator(
                                    lineHeight: 10,
                                    percent: frac.clamp(0.0, 1.0),
                                    progressColor: color,
                                    backgroundColor: color.withOpacity(0.12),
                                    barRadius: const Radius.circular(5),
                                    padding: EdgeInsets.zero,
                                    animation: true,
                                    animationDuration: 600,
                                  ),
                                ],
                              ),
                            );
                          }),
                      ],
                    ),
                  ),

                  const SizedBox(height: 20),

                  // ── Confidence Overview ─────────────────────────────
                  if (_totalScans > 0) ...[
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(20),
                      decoration: BoxDecoration(
                        color: cardColor,
                        borderRadius: BorderRadius.circular(20),
                        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.08), blurRadius: 10)],
                      ),
                      child: Row(
                        children: [
                          CircularPercentIndicator(
                            radius: 48,
                            lineWidth: 8,
                            percent: _avgConfidence.clamp(0.0, 1.0),
                            center: Text(
                              '${(_avgConfidence * 100).toStringAsFixed(0)}%',
                              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18, color: primary),
                            ),
                            progressColor: primary,
                            backgroundColor: primary.withOpacity(0.12),
                            circularStrokeCap: CircularStrokeCap.round,
                            animation: true,
                          ),
                          const SizedBox(width: 20),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  'Average Confidence',
                                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 15, color: onSurface),
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  _avgConfidence >= 0.85
                                      ? 'Excellent — model is very sure about your scans.'
                                      : _avgConfidence >= 0.65
                                          ? 'Good — most predictions are reliable.'
                                          : 'Low — try better lighting or closer shots.',
                                  style: TextStyle(fontSize: 12, color: onSurface.withOpacity(0.6)),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 20),
                  ],

                  // ── Achievements ────────────────────────────────────
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      color: cardColor,
                      borderRadius: BorderRadius.circular(20),
                      boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.08), blurRadius: 10)],
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            const Icon(Icons.military_tech, color: Color(0xFFFFD700)),
                            const SizedBox(width: 8),
                            Text(
                              'Achievements',
                              style: TextStyle(fontSize: 17, fontWeight: FontWeight.bold, color: onSurface),
                            ),
                          ],
                        ),
                        const SizedBox(height: 16),
                        _AchievementTile(emoji: '🎯', title: 'First Scan', desc: 'Classify your first denim fabric', unlocked: _totalScans >= 1, onSurface: onSurface),
                        _AchievementTile(emoji: '🔟', title: '10 Scans', desc: 'Reach 10 total scans', unlocked: _totalScans >= 10, onSurface: onSurface),
                        _AchievementTile(
                          emoji: '🌈', title: 'Denim Explorer',
                          desc: 'Scan at least 3 different denim classes',
                          unlocked: _classCounts.values.where((v) => v > 0).length >= 3,
                          onSurface: onSurface,
                        ),
                        _AchievementTile(emoji: '🏆', title: 'Expert Classifier', desc: 'Reach 25 total scans', unlocked: _totalScans >= 25, onSurface: onSurface),
                        _AchievementTile(
                          emoji: '✅', title: 'Full Coverage',
                          desc: 'Scan all 5 denim classes at least once',
                          unlocked: _classCounts.values.every((v) => v > 0),
                          onSurface: onSurface,
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

// ── Reusable widgets ──────────────────────────────────────────────────────────

class _StatCard extends StatelessWidget {
  final String label, value;
  final String subLabel;
  final IconData icon;
  final Color color, cardColor, onSurface;

  const _StatCard({
    required this.label,
    required this.value,
    this.subLabel = '',
    required this.icon,
    required this.color,
    required this.cardColor,
    required this.onSurface,
  });

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 8),
        decoration: BoxDecoration(
          color: cardColor,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.08), blurRadius: 8)],
        ),
        child: Column(
          children: [
            Icon(icon, color: color, size: 24),
            const SizedBox(height: 6),
            Text(value, style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold, color: onSurface), textAlign: TextAlign.center,),
            if (subLabel.isNotEmpty) ...[
              const SizedBox(height: 2),
              Text(subLabel, style: TextStyle(fontSize: 9, color: onSurface.withOpacity(0.45)), textAlign: TextAlign.center, maxLines: 2, overflow: TextOverflow.ellipsis),
            ],
            const SizedBox(height: 4),
            Text(label, textAlign: TextAlign.center, style: TextStyle(fontSize: 10, color: onSurface.withOpacity(0.55))),
          ],
        ),
      ),
    );
  }
}

class _AchievementTile extends StatelessWidget {
  final String emoji, title, desc;
  final bool unlocked;
  final Color onSurface;

  const _AchievementTile({
    required this.emoji, required this.title, required this.desc,
    required this.unlocked, required this.onSurface,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        children: [
          Container(
            width: 44, height: 44,
            decoration: BoxDecoration(
              color: unlocked ? const Color(0xFFFFD700).withOpacity(0.15) : onSurface.withOpacity(0.05),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Center(child: Text(unlocked ? emoji : '🔒', style: const TextStyle(fontSize: 22))),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title, style: TextStyle(fontWeight: FontWeight.bold, color: unlocked ? onSurface : onSurface.withOpacity(0.4))),
                Text(desc, style: TextStyle(fontSize: 12, color: onSurface.withOpacity(0.5))),
              ],
            ),
          ),
          if (unlocked) const Icon(Icons.check_circle, color: Color(0xFF22C55E), size: 20),
        ],
      ),
    );
  }
}
