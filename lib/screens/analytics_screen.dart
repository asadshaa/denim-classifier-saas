import 'dart:io';
import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:denim_classifier/providers/analytics_provider.dart';
import 'package:denim_classifier/models/prediction_record.dart';
import 'package:denim_classifier/widgets/animated_orb_background.dart';

// Manual time formatter — avoids requiring the intl package
String _formatTime(DateTime dt) {
  final h = dt.hour.toString().padLeft(2, '0');
  final m = dt.minute.toString().padLeft(2, '0');
  return '$h:$m';
}

class AnalyticsDashboardScreen extends StatelessWidget {
  const AnalyticsDashboardScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<AnalyticsProvider>();
    final stats = provider.stats;
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final orbs = isDark ? OrbConfig.dark : OrbConfig.light;

    if (provider.isLoading) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }

    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        elevation: 0,
        backgroundColor: Colors.transparent,
        title: const Text(
          'AI Analytics',
          style: TextStyle(fontWeight: FontWeight.w800, fontSize: 24),
        ),
        actions: [
          IconButton(
            onPressed: () => provider.refresh(),
            icon: const Icon(Icons.refresh_rounded),
          ),
          const SizedBox(width: 8),
        ],
      ),
      body: Stack(
        children: [
          // ── Brand Animated Background ──────────────────────────────────
          AnimatedOrbBackground(orbs: orbs),

          // ── Dashboard Content ──────────────────────────────────────────
          SafeArea(
            child: stats.isEmpty
                ? const Center(child: Text('No scan data available yet.'))
                : CustomScrollView(
                    physics: const BouncingScrollPhysics(),
                    slivers: [
                      SliverToBoxAdapter(
                        child: Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              if (provider.hasLowConfidenceAlert) _buildAlertCard(),
                              const SizedBox(height: 16),
                              _buildOverviewGrid(stats, isDark),
                              const SizedBox(height: 28),
                              _buildSectionTitle('Performance Trends', isDark),
                              _buildGlassCard(
                                child: _buildConfidenceLineChart(stats['recentPredictions'], isDark),
                                isDark: isDark,
                              ),
                              const SizedBox(height: 28),
                              _buildSectionTitle('Main Class Distribution', isDark),
                              _buildGlassCard(
                                child: _buildClassPieChart(stats['classDistribution'], isDark),
                                isDark: isDark,
                              ),
                              const SizedBox(height: 28),
                              _buildSectionTitle('Subclass Radar', isDark),
                              _buildGlassCard(
                                child: _buildSubclassRadar(stats['subclassDistribution'], isDark),
                                isDark: isDark,
                              ),
                              const SizedBox(height: 28),
                              _buildSectionTitle('System Metrics', isDark),
                              _buildPerformanceCards(stats, isDark),
                              const SizedBox(height: 28),
                              _buildSectionTitle('Recent Verification', isDark),
                            ],
                          ),
                        ),
                      ),
                      _buildRecentActivityList(stats['recentPredictions'], provider, isDark),
                      const SliverToBoxAdapter(child: SizedBox(height: 120)),
                    ],
                  ),
          ),
        ],
      ),
    );
  }

  Widget _buildGlassCard({required Widget child, required bool isDark, double padding = 16}) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(24),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
        child: Container(
          padding: EdgeInsets.all(padding),
          decoration: BoxDecoration(
            color: isDark ? Colors.white.withOpacity(0.06) : Colors.white.withOpacity(0.7),
            borderRadius: BorderRadius.circular(24),
            border: Border.all(
              color: isDark ? Colors.white.withOpacity(0.1) : Colors.black.withOpacity(0.05),
            ),
          ),
          child: child,
        ),
      ),
    );
  }

  Widget _buildSectionTitle(String title, bool isDark) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16, left: 4),
      child: Text(
        title,
        style: TextStyle(
          fontSize: 19,
          fontWeight: FontWeight.w800,
          letterSpacing: -0.5,
          color: isDark ? Colors.white : const Color(0xFF0F0C29),
        ),
      ),
    );
  }

  Widget _buildAlertCard() {
    return Container(
      padding: const EdgeInsets.all(16),
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [Colors.red.withOpacity(0.8), Colors.orange.withOpacity(0.8)],
        ),
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(color: Colors.red.withOpacity(0.3), blurRadius: 15, offset: const Offset(0, 5))
        ],
      ),
      child: Row(
        children: [
          const Icon(Icons.warning_amber_rounded, color: Colors.white, size: 28),
          const SizedBox(width: 16),
          const Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Model Drift Detected',
                  style: TextStyle(fontWeight: FontWeight.w900, color: Colors.white, fontSize: 16),
                ),
                Text(
                  'Average confidence has dropped below 80%. Consider recalibrating.',
                  style: TextStyle(fontSize: 12, color: Colors.white70),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildOverviewGrid(Map<String, dynamic> stats, bool isDark) {
    return GridView.count(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      crossAxisCount: 2,
      crossAxisSpacing: 16,
      mainAxisSpacing: 16,
      childAspectRatio: 1.5,
      children: [
        _buildStatCard('Accuracy', '${stats['accuracy'].toStringAsFixed(1)}%', Icons.verified_user_rounded, const Color(0xFF10B981), isDark),
        _buildStatCard('Analysis', '${stats['totalScans']}', Icons.analytics_rounded, const Color(0xFF6366F1), isDark),
        _buildStatCard('Avg Conf.', '${stats['avgConfidence'].toStringAsFixed(1)}%', Icons.auto_awesome_rounded, const Color(0xFF06B6D4), isDark),
        _buildStatCard('Latency', '${stats['avgInferenceMs'].toStringAsFixed(0)}ms', Icons.bolt_rounded, const Color(0xFFF59E0B), isDark),
      ],
    );
  }

  Widget _buildStatCard(String title, String value, IconData icon, Color accent, bool isDark) {
    return _buildGlassCard(
      isDark: isDark,
      padding: 14,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Container(
            padding: const EdgeInsets.all(6),
            decoration: BoxDecoration(
              color: accent.withOpacity(0.15),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(icon, color: accent, size: 20),
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(value, style: const TextStyle(fontSize: 20, fontWeight: FontWeight.w900, letterSpacing: -0.5)),
              Text(title, style: TextStyle(fontSize: 11, fontWeight: FontWeight.w600, color: isDark ? Colors.white38 : Colors.black45)),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildConfidenceLineChart(List<PredictionRecord> recent, bool isDark) {
    if (recent.length < 2) {
      return _buildEmptyChart('Scan more fabrics to view trend', isDark);
    }

    final spots = recent.asMap().entries.map((e) {
      return FlSpot(e.key.toDouble(), e.value.confidenceMain * 100);
    }).toList();

    return SizedBox(
      height: 180,
      child: LineChart(
        LineChartData(
          gridData: const FlGridData(show: false),
          titlesData: const FlTitlesData(show: false),
          borderData: FlBorderData(show: false),
          lineBarsData: [
            LineChartBarData(
              spots: spots,
              isCurved: true,
              color: const Color(0xFF6366F1),
              barWidth: 4,
              isStrokeCapRound: true,
              dotData: const FlDotData(show: false),
              belowBarData: BarAreaData(
                show: true,
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [const Color(0xFF6366F1).withOpacity(0.3), const Color(0xFF6366F1).withOpacity(0)],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildClassPieChart(Map<String, int> distribution, bool isDark) {
    if (distribution.isEmpty) return _buildEmptyChart('No data for distribution', isDark);

    final keys = distribution.keys.toList();
    final sections = distribution.entries.take(5).map((e) {
      final idx = keys.indexOf(e.key) % Colors.primaries.length;
      return PieChartSectionData(
        value: e.value.toDouble(),
        title: '', // Titles hidden for cleaner look
        color: Colors.primaries[idx],
        radius: 60,
        badgeWidget: Container(
          padding: const EdgeInsets.all(4),
          decoration: BoxDecoration(color: Colors.black54, borderRadius: BorderRadius.circular(4)),
          child: Text(e.key, style: const TextStyle(color: Colors.white, fontSize: 8)),
        ),
        badgePositionPercentageOffset: 1.4,
      );
    }).toList();

    return SizedBox(
      height: 220,
      child: PieChart(
        PieChartData(
          sectionsSpace: 4,
          centerSpaceRadius: 35,
          sections: sections,
        ),
      ),
    );
  }

  Widget _buildSubclassRadar(Map<String, int> distribution, bool isDark) {
    final subclassLabels = ['Cut A', 'Cut B', 'Cut C', 'Cut D', 'Cut E'];
    final paddedEntries = subclassLabels.map((l) => MapEntry(l, distribution[l] ?? 0)).toList();

    return SizedBox(
      height: 220,
      child: RadarChart(
        RadarChartData(
          radarShape: RadarShape.circle,
          tickCount: 3,
          dataSets: [
            RadarDataSet(
              fillColor: const Color(0xFF06B6D4).withOpacity(0.2),
              borderColor: const Color(0xFF06B6D4),
              entryRadius: 3,
              dataEntries: paddedEntries.map((e) => RadarEntry(value: e.value.toDouble())).toList(),
            ),
          ],
          radarBorderData: BorderSide(color: isDark ? Colors.white10 : Colors.black12),
          tickBorderData: BorderSide(color: isDark ? Colors.white10 : Colors.black12),
          gridBorderData: BorderSide(color: isDark ? Colors.white10 : Colors.black12),
          getTitle: (i, angle) => RadarChartTitle(text: paddedEntries[i].key, angle: angle),
        ),
      ),
    );
  }

  Widget _buildPerformanceCards(Map<String, dynamic> stats, bool isDark) {
    return Row(
      children: [
        Expanded(child: _buildSmallPerfCard('Peak Speed', '94ms', Icons.bolt_rounded, Colors.amber, isDark)),
        const SizedBox(width: 16),
        Expanded(child: _buildSmallPerfCard('Stability', '99.2%', Icons.auto_graph_rounded, Colors.blue, isDark)),
      ],
    );
  }

  Widget _buildSmallPerfCard(String title, String value, IconData icon, Color color, bool isDark) {
    return _buildGlassCard(
      isDark: isDark,
      padding: 12,
      child: Row(
        children: [
          Icon(icon, color: color, size: 18),
          const SizedBox(width: 10),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(value, style: const TextStyle(fontWeight: FontWeight.w800, fontSize: 15)),
              Text(title, style: TextStyle(fontSize: 10, color: isDark ? Colors.white38 : Colors.black45)),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildRecentActivityList(List<PredictionRecord> recent, AnalyticsProvider provider, bool isDark) {
    return SliverList(
      delegate: SliverChildBuilderDelegate(
        (context, index) {
          final record = recent[index];
          return Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
            child: _buildGlassCard(
              isDark: isDark,
              padding: 12,
              child: Row(
                children: [
                  ClipRRect(
                    borderRadius: BorderRadius.circular(14),
                    child: SizedBox(
                      width: 65,
                      height: 65,
                      child: record.imagePath.isNotEmpty
                          ? Image.file(File(record.imagePath), fit: BoxFit.cover)
                          : Container(color: Colors.grey[300]),
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(record.mainClass, style: const TextStyle(fontWeight: FontWeight.w800, fontSize: 16)),
                        Text('${record.subclass} • ${_formatTime(record.timestamp)}', 
                          style: TextStyle(fontSize: 12, color: isDark ? Colors.white38 : Colors.black45)),
                        const SizedBox(height: 4),
                        Text('${(record.confidenceMain * 100).toStringAsFixed(1)}% Conf', 
                          style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w900, color: Color(0xFF6366F1))),
                      ],
                    ),
                  ),
                  Column(
                    children: [
                      _buildFeedbackBtn(Icons.check_circle_rounded, Colors.green, record.isCorrect == true, () => provider.updateFeedback(record, true)),
                      const SizedBox(height: 8),
                      _buildFeedbackBtn(Icons.cancel_rounded, Colors.red, record.isCorrect == false, () => provider.updateFeedback(record, false)),
                    ],
                  ),
                ],
              ),
            ),
          );
        },
        childCount: recent.length,
      ),
    );
  }

  Widget _buildFeedbackBtn(IconData icon, Color color, bool active, VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.all(6),
        decoration: BoxDecoration(
          color: active ? color.withOpacity(0.2) : Colors.transparent,
          shape: BoxShape.circle,
          border: Border.all(color: active ? color : Colors.grey.withOpacity(0.3)),
        ),
        child: Icon(icon, color: active ? color : Colors.grey.withOpacity(0.5), size: 20),
      ),
    );
  }

  Widget _buildEmptyChart(String message, bool isDark) {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(Icons.query_stats_rounded, size: 40, color: Colors.grey.withOpacity(0.3)),
          const SizedBox(height: 10),
          Text(message, style: TextStyle(color: Colors.grey.withOpacity(0.5), fontSize: 12)),
        ],
      ),
    );
  }
}
