import 'package:flutter/material.dart';
import 'package:percent_indicator/percent_indicator.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:denim_classifier/utils/fabric_taxonomy.dart';
import 'package:denim_classifier/widgets/animated_orb_background.dart';
import 'package:denim_classifier/models/prediction_record.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  @override
  Widget build(BuildContext context) {
    final primary = Theme.of(context).colorScheme.primary;
    final secondary = Theme.of(context).colorScheme.secondary;
    final onSurface = Theme.of(context).colorScheme.onSurface;
    final cardColor = Theme.of(context).cardColor;
    final box = Hive.box<PredictionRecord>('predictions');

    return Scaffold(
      appBar: AppBar(title: const Text('System Intelligence', style: TextStyle(fontWeight: FontWeight.bold))),
      body: Stack(
        children: [
          AnimatedOrbBackground(
            orbs: Theme.of(context).brightness == Brightness.dark
                ? OrbConfig.dark
                : OrbConfig.light,
            speed: 0.6,
          ),
          ValueListenableBuilder(
            valueListenable: box.listenable(),
            builder: (context, Box<PredictionRecord> box, _) {
              final records = box.values.toList().cast<PredictionRecord>();
              final totalScans = records.length;
              
              // Calculate Analytics
              double totalConf = 0;
              double totalLatency = 0;
              Map<String, int> counts = {};
              for (var r in records) {
                totalConf += r.confidenceMain;
                totalLatency += r.inferenceTime;
                counts[r.mainClass] = (counts[r.mainClass] ?? 0) + 1;
              }
              
              final avgConfidence = totalScans > 0 ? totalConf / totalScans : 0.0;
              final avgLatency = totalScans > 0 ? totalLatency / totalScans : 0.0;
              final topClass = counts.isEmpty ? '—' : counts.entries.reduce((a, b) => a.value >= b.value ? a : b).key;
              final distinctClasses = counts.keys.length;
              final diversityScore = (distinctClasses / 21); // Based on 21 total classes

              return SingleChildScrollView(
                padding: const EdgeInsets.fromLTRB(16, 16, 16, 100),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // ── Enterprise Identity ─────────────────────────────
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.symmetric(vertical: 24, horizontal: 20),
                      decoration: BoxDecoration(
                        color: cardColor,
                        borderRadius: BorderRadius.circular(24),
                        border: Border.all(color: primary.withOpacity(0.1)),
                        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 20)],
                      ),
                      child: Row(
                        children: [
                          Container(
                            width: 60, height: 60,
                            decoration: BoxDecoration(
                              color: primary.withOpacity(0.1),
                              shape: BoxShape.circle,
                            ),
                            child: Center(child: Icon(Icons.psychology, color: primary, size: 32)),
                          ),
                          const SizedBox(width: 16),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                const Text(
                                  'DenimAI Research Hub',
                                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                                ),
                                const SizedBox(height: 2),
                                Text(
                                  'Edge Intelligence Node #492',
                                  style: TextStyle(fontSize: 12, color: onSurface.withOpacity(0.5), letterSpacing: 1),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),

                    const SizedBox(height: 24),

                    // ── Primary Performance Metrics ──────────────────────
                    const _SectionHeader(title: 'Operational Status'),
                    const SizedBox(height: 12),
                    Row(
                      children: [
                        _StatCard(
                          label: 'Throughput', value: totalScans.toString(),
                          subLabel: 'Total Scans',
                          icon: Icons.speed, color: primary,
                          cardColor: cardColor, onSurface: onSurface,
                        ),
                        const SizedBox(width: 12),
                        _StatCard(
                          label: 'Precision',
                          value: '${(avgConfidence * 100).toStringAsFixed(1)}%',
                          subLabel: 'Avg Confidence',
                          icon: Icons.verified_user,
                          color: const Color(0xFF10B981),
                          cardColor: cardColor, onSurface: onSurface,
                        ),
                        const SizedBox(width: 12),
                        _StatCard(
                          label: 'Latency',
                          value: '${avgLatency.toInt()}ms',
                          subLabel: 'Processing',
                          icon: Icons.timer, color: secondary,
                          cardColor: cardColor, onSurface: onSurface,
                        ),
                      ],
                    ),

                    const SizedBox(height: 24),

                    // ── Taxonomy Coverage ─────────────────────────────
                    const _SectionHeader(title: 'Taxonomy Diversity'),
                    const SizedBox(height: 12),
                    Container(
                      padding: const EdgeInsets.all(20),
                      decoration: BoxDecoration(
                        color: cardColor,
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(color: onSurface.withOpacity(0.05)),
                      ),
                      child: Column(
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text('$distinctClasses / 21', style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
                                  Text('Unique Classes Identified', style: TextStyle(fontSize: 12, color: onSurface.withOpacity(0.5))),
                                ],
                              ),
                              CircularPercentIndicator(
                                radius: 28,
                                lineWidth: 4,
                                percent: diversityScore.clamp(0.0, 1.0),
                                center: Text('${(diversityScore * 100).toInt()}%', style: const TextStyle(fontSize: 10, fontWeight: FontWeight.bold)),
                                progressColor: primary,
                                backgroundColor: primary.withOpacity(0.1),
                                circularStrokeCap: CircularStrokeCap.round,
                              ),
                            ],
                          ),
                          const Divider(height: 32),
                          if (totalScans == 0)
                             Text('No classification data detected.', style: TextStyle(color: onSurface.withOpacity(0.4), fontSize: 13))
                          else
                            ...counts.entries.take(3).map((entry) {
                               final frac = entry.value / totalScans;
                               final color = FabricTaxonomy.colorFor(entry.key);
                               return Padding(
                                 padding: const EdgeInsets.only(bottom: 12),
                                 child: Row(
                                   children: [
                                     Container(width: 8, height: 8, decoration: BoxDecoration(color: color, shape: BoxShape.circle)),
                                     const SizedBox(width: 12),
                                     Expanded(child: Text(entry.key, style: const TextStyle(fontSize: 13, fontWeight: FontWeight.bold))),
                                     Text('${(frac * 100).toInt()}%', style: TextStyle(fontSize: 12, color: onSurface.withOpacity(0.5))),
                                   ],
                                 ),
                               );
                            }),
                        ],
                      ),
                    ),

                    const SizedBox(height: 24),

                    // ── Model Insights ──────────────────────────────────
                    const _SectionHeader(title: 'Model Intelligence'),
                    const SizedBox(height: 12),
                    Container(
                      padding: const EdgeInsets.all(20),
                      decoration: BoxDecoration(
                        color: cardColor,
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(color: onSurface.withOpacity(0.05)),
                      ),
                      child: Column(
                        children: [
                          _InsightRow(
                            icon: Icons.memory,
                            label: 'Engine',
                            value: 'Mobile GPU (TFLite Delegate)',
                            color: Colors.blue,
                            onSurface: onSurface,
                          ),
                          const Divider(height: 24),
                          _InsightRow(
                            icon: Icons.layers,
                            label: 'Architecture',
                            value: 'EfficientNetB0 (Multi-Head)',
                            color: Colors.purple,
                            onSurface: onSurface,
                          ),
                          const Divider(height: 24),
                          _InsightRow(
                            icon: Icons.auto_graph,
                            label: 'XAI Status',
                            value: 'Grad-CAM Ready',
                            color: Colors.orange,
                            onSurface: onSurface,
                          ),
                          const Divider(height: 24),
                          _InsightRow(
                            icon: Icons.cloud_done,
                            label: 'Sync Status',
                            value: 'Cloud Link Active',
                            color: Colors.green,
                            onSurface: onSurface,
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              );
            },
          ),
        ],
      ),
    );
  }
}

class _SectionHeader extends StatelessWidget {
  final String title;
  const _SectionHeader({required this.title});

  @override
  Widget build(BuildContext context) {
    return Text(
      title.toUpperCase(),
      style: TextStyle(
        fontSize: 11,
        fontWeight: FontWeight.w900,
        color: Theme.of(context).colorScheme.onSurface.withOpacity(0.4),
        letterSpacing: 1.5,
      ),
    );
  }
}

class _StatCard extends StatelessWidget {
  final String label, value, subLabel;
  final IconData icon;
  final Color color, cardColor, onSurface;

  const _StatCard({
    required this.label, required this.value, this.subLabel = '',
    required this.icon, required this.color, required this.cardColor, required this.onSurface,
  });

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: cardColor,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: onSurface.withOpacity(0.05)),
        ),
        child: Column(
          children: [
            Icon(icon, color: color, size: 20),
            const SizedBox(height: 8),
            Text(value, style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold, color: onSurface)),
            const SizedBox(height: 2),
            Text(label, style: TextStyle(fontSize: 9, fontWeight: FontWeight.bold, color: onSurface.withOpacity(0.6))),
          ],
        ),
      ),
    );
  }
}

class _InsightRow extends StatelessWidget {
  final IconData icon;
  final String label, value;
  final Color color, onSurface;

  const _InsightRow({
    required this.icon, required this.label, required this.value,
    required this.color, required this.onSurface,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Container(
          width: 36, height: 36,
          decoration: BoxDecoration(color: color.withOpacity(0.1), borderRadius: BorderRadius.circular(10)),
          child: Icon(icon, color: color, size: 18),
        ),
        const SizedBox(width: 12),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(label, style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: onSurface.withOpacity(0.5))),
            Text(value, style: const TextStyle(fontSize: 13, fontWeight: FontWeight.bold)),
          ],
        ),
      ],
    );
  }
}
