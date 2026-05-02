import 'dart:io';
import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:share_plus/share_plus.dart';
import 'package:denim_classifier/models/classification_result.dart';
import 'package:denim_classifier/utils/fabric_taxonomy.dart';
import 'package:denim_classifier/widgets/animated_orb_background.dart';

class ResultsScreen extends StatefulWidget {
  final ClassificationResult result;
  final String imagePath;
  final String modelName;

  const ResultsScreen({
    super.key,
    required this.result,
    required this.imagePath,
    required this.modelName,
  });

  @override
  State<ResultsScreen> createState() => _ResultsScreenState();
}

class _ResultsScreenState extends State<ResultsScreen>
    with TickerProviderStateMixin {
  late final AnimationController _entryCtrl;
  late final AnimationController _barCtrl;
  late final Animation<double> _fadeAnim;
  late final Animation<Offset> _slideAnim;

  @override
  void initState() {
    super.initState();
    HapticFeedback.mediumImpact();

    _entryCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 700),
    );
    _barCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1200),
    );

    _fadeAnim = CurvedAnimation(parent: _entryCtrl, curve: Curves.easeOut);
    _slideAnim = Tween<Offset>(
      begin: const Offset(0, 0.12),
      end: Offset.zero,
    ).animate(CurvedAnimation(parent: _entryCtrl, curve: Curves.easeOut));

    _entryCtrl.forward();
    Future.delayed(const Duration(milliseconds: 300), _barCtrl.forward);
  }

  @override
  void dispose() {
    _entryCtrl.dispose();
    _barCtrl.dispose();
    super.dispose();
  }

  ClassificationResult get r => widget.result;
  Color get _topColor => FabricTaxonomy.colorFor(r.topMainClass);
  List<({String label, double confidence, int index})> get _top5 => r.topN(5);

  // ── Share ───────────────────────────────────────────────────────────────────
  Future<void> _share() async {
    final text = StringBuffer()
      ..writeln('🏆 DenimAI — Fabric Classification')
      ..writeln()
      ..writeln('Main Class : ${r.topMainClass}  (${(r.topMainConfidence * 100).toStringAsFixed(1)}%)')
      ..writeln('Subclass   : ${r.topSubclass}  (${(r.topSubConfidence * 100).toStringAsFixed(1)}%)')
      ..writeln()
      ..writeln('Top Predictions:');
    for (final e in _top5) {
      text.writeln('  ${e.label}: ${(e.confidence * 100).toStringAsFixed(1)}%');
    }
    text
      ..writeln()
      ..writeln('⚡ Inference: ${r.inferenceMs} ms')
      ..writeln('🤖 Model: ${widget.modelName}');

    await Share.share(text.toString(), subject: 'Fabric Classification — ${r.topMainClass}');
  }

  // ── Build ───────────────────────────────────────────────────────────────────
  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: Container(
            padding: const EdgeInsets.all(6),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(isDark ? 0.12 : 0.7),
              shape: BoxShape.circle,
            ),
            child: Icon(Icons.arrow_back_ios_new,
                size: 16, color: isDark ? Colors.white : Colors.black87),
          ),
          onPressed: () => Navigator.pop(context),
        ),
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 12),
            child: IconButton(
              icon: Container(
                padding: const EdgeInsets.all(6),
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(isDark ? 0.12 : 0.7),
                  shape: BoxShape.circle,
                ),
                child: Icon(Icons.share_outlined,
                    size: 16, color: isDark ? Colors.white : Colors.black87),
              ),
              onPressed: _share,
            ),
          ),
        ],
      ),
      body: Stack(
        fit: StackFit.expand,
        children: [
          // ── Background ─────────────────────────────────────────────────────
          AnimatedOrbBackground(
            orbs: isDark ? OrbConfig.dark : OrbConfig.light,
            speed: 0.6,
          ),

          // ── Scrollable content ─────────────────────────────────────────────
          FadeTransition(
            opacity: _fadeAnim,
            child: SlideTransition(
              position: _slideAnim,
              child: CustomScrollView(
                slivers: [
                  // Hero image + class badge
                  SliverToBoxAdapter(child: _buildHeroCard(isDark)),
                  // Subclass pill
                  SliverToBoxAdapter(child: _buildSubclassRow(isDark)),
                  // Fabric specs
                  SliverToBoxAdapter(child: _buildSpecsCard(isDark)),
                  // Top predictions list
                  SliverToBoxAdapter(child: _buildPredictionsList(isDark)),
                  // Meta info
                  SliverToBoxAdapter(child: _buildMetaCard(isDark)),
                  const SliverToBoxAdapter(child: SizedBox(height: 120)),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ─────────────────────────────────────────────────────────────────────────
  // Hero Card — full-width image + main-class overlay
  // ─────────────────────────────────────────────────────────────────────────
  Widget _buildHeroCard(bool isDark) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 100, 16, 0),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(28),
        child: SizedBox(
          height: 300,
          child: Stack(
            fit: StackFit.expand,
            children: [
              // Fabric photo
              Hero(
                tag: 'fabric_image',
                child: Image.file(
                  File(widget.imagePath),
                  fit: BoxFit.cover,
                  errorBuilder: (_, __, ___) => Container(
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: [_topColor.withOpacity(0.5), _topColor.withOpacity(0.2)],
                      ),
                    ),
                    child: Icon(Icons.texture, size: 80, color: _topColor.withOpacity(0.5)),
                  ),
                ),
              ),
              // Gradient scrim
              Positioned.fill(
                child: DecoratedBox(
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                      colors: [Colors.transparent, Colors.black.withOpacity(0.75)],
                      stops: const [0.4, 1.0],
                    ),
                  ),
                ),
              ),
              // Class name overlay
              Positioned(
                left: 20,
                right: 20,
                bottom: 20,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // BEST MATCH badge
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                      decoration: BoxDecoration(
                        color: _topColor.withOpacity(0.9),
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: const Text(
                        '🏆  BEST MATCH',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 11,
                          fontWeight: FontWeight.w700,
                          letterSpacing: 0.8,
                        ),
                      ),
                    ),
                    const SizedBox(height: 8),
                    // Main class name
                    Text(
                      r.topMainClass,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 34,
                        fontWeight: FontWeight.w900,
                        letterSpacing: -1,
                        height: 1.1,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      FabricTaxonomy.descriptionFor(r.topMainClass),
                      style: TextStyle(
                        color: Colors.white.withOpacity(0.80),
                        fontSize: 13,
                      ),
                    ),
                    const SizedBox(height: 4),
                    // F1 reliability badge
                    Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                          decoration: BoxDecoration(
                            color: Colors.white.withOpacity(0.18),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              const Icon(Icons.verified_outlined,
                                  color: Colors.white, size: 12),
                              const SizedBox(width: 4),
                              Text(
                                'F1 ${(FabricTaxonomy.f1For(r.topMainClass) * 100).toStringAsFixed(0)}%  Model Reliability',
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontSize: 11,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    // Confidence bar
                    _ConfidenceBar(
                      value: r.topMainConfidence,
                      color: _topColor,
                      animation: _barCtrl,
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // ─────────────────────────────────────────────────────────────────────────
  // Subclass Row
  // ─────────────────────────────────────────────────────────────────────────
  Widget _buildSubclassRow(bool isDark) {
    final subColor = const Color(0xFF06B6D4);
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 0),
      child: Row(
        children: [
          // Subclass pill
          Expanded(
            child: _GlassCard(
              isDark: isDark,
              child: Row(
                children: [
                  Container(
                    width: 40,
                    height: 40,
                    decoration: BoxDecoration(
                      color: subColor.withOpacity(0.15),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Icon(Icons.layers_outlined, color: subColor, size: 20),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Subclass',
                          style: TextStyle(
                            fontSize: 11,
                            fontWeight: FontWeight.w600,
                            color: isDark ? Colors.white38 : Colors.black38,
                            letterSpacing: 0.5,
                          ),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          r.topSubclass,
                          style: TextStyle(
                            fontSize: 17,
                            fontWeight: FontWeight.w800,
                            color: isDark ? Colors.white : const Color(0xFF0F0C29),
                          ),
                        ),
                      ],
                    ),
                  ),
                  Text(
                    '${(r.topSubConfidence * 100).toStringAsFixed(1)}%',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w800,
                      color: subColor,
                    ),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(width: 12),
          // Combined confidence pill
          _GlassCard(
            isDark: isDark,
            child: Column(
              children: [
                Text(
                  '${(r.topMainConfidence * 100).toStringAsFixed(0)}%',
                  style: TextStyle(
                    fontSize: 26,
                    fontWeight: FontWeight.w900,
                    color: _topColor,
                    height: 1,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  'Main\nConf.',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 11,
                    color: isDark ? Colors.white38 : Colors.black38,
                    height: 1.2,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // ─────────────────────────────────────────────────────────────────────────
  // Top-5 Predictions
  // ─────────────────────────────────────────────────────────────────────────
  Widget _buildPredictionsList(bool isDark) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.only(bottom: 10),
            child: Text(
              'TOP PREDICTIONS',
              style: TextStyle(
                fontSize: 11,
                fontWeight: FontWeight.w700,
                letterSpacing: 1.2,
                color: isDark ? Colors.white38 : Colors.black38,
              ),
            ),
          ),
          ...List.generate(_top5.length, (i) {
            final entry = _top5[i];
            final color = FabricTaxonomy.colorFor(entry.label);
            final isTop = i == 0;
            return Padding(
              padding: const EdgeInsets.only(bottom: 10),
              child: _GlassCard(
                isDark: isDark,
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                child: Row(
                  children: [
                    // Rank badge
                    Container(
                      width: 36,
                      height: 36,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        gradient: isTop
                            ? LinearGradient(colors: [_topColor, _topColor.withOpacity(0.6)])
                            : null,
                        color: isTop ? null : color.withOpacity(0.12),
                      ),
                      child: Center(
                        child: Text(
                          ['🥇', '🥈', '🥉', '4', '5'][i],
                          style: TextStyle(
                            fontSize: i < 3 ? 16 : 13,
                            fontWeight: FontWeight.bold,
                            color: i < 3 ? null : color,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    // Name + bar
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            entry.label,
                            style: TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.w700,
                              color: isDark ? Colors.white : const Color(0xFF0F0C29),
                            ),
                          ),
                          const SizedBox(height: 6),
                          AnimatedBuilder(
                            animation: _barCtrl,
                            builder: (_, __) => ClipRRect(
                              borderRadius: BorderRadius.circular(4),
                              child: LinearProgressIndicator(
                                value: entry.confidence * _barCtrl.value,
                                minHeight: 5,
                                backgroundColor:
                                    isDark ? Colors.white12 : Colors.black.withOpacity(0.06),
                                valueColor: AlwaysStoppedAnimation<Color>(color),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(width: 12),
                    // Confidence %
                    Text(
                      '${(entry.confidence * 100).toStringAsFixed(1)}%',
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w800,
                        color: color,
                      ),
                    ),
                  ],
                ),
              ),
            );
          }),
        ],
      ),
    );
  }

  // ─────────────────────────────────────────────────────────────────────────
  // Meta Card — inference time + model name
  // ─────────────────────────────────────────────────────────────────────────
  Widget _buildMetaCard(bool isDark) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 4, 16, 0),
      child: _GlassCard(
        isDark: isDark,
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: [
            _MetaTile(
              icon: Icons.bolt_outlined,
              label: 'Inference',
              value: '${r.inferenceMs} ms',
              color: const Color(0xFFF59E0B),
            ),
            Container(width: 1, height: 40,
                color: isDark ? Colors.white12 : Colors.black12),
            _MetaTile(
              icon: Icons.verified_outlined,
              label: 'Accuracy',
              value: '98.73%',
              color: const Color(0xFF10B981),
            ),
            Container(width: 1, height: 40,
                color: isDark ? Colors.white12 : Colors.black12),
            _MetaTile(
              icon: Icons.layers_outlined,
              label: 'Classes',
              value: '21 × 5',
              color: const Color(0xFF06B6D4),
            ),
          ],
        ),
      ),
    );
  }

  // ─────────────────────────────────────────────────────────────────────────
  // Fabric Specifications Card
  // ─────────────────────────────────────────────────────────────────────────
  Widget _buildSpecsCard(bool isDark) {
    final specs = FabricTaxonomy.characteristicsFor(r.topMainClass);
    if (specs.isEmpty) return const SizedBox.shrink();
    final parts = specs.split(' • ');
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 0),
      child: _GlassCard(
        isDark: isDark,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(Icons.science_outlined, size: 16,
                    color: isDark ? Colors.white38 : Colors.black38),
                const SizedBox(width: 6),
                Text('FABRIC SPECIFICATIONS',
                    style: TextStyle(
                      fontSize: 11, fontWeight: FontWeight.w700,
                      letterSpacing: 1.2,
                      color: isDark ? Colors.white38 : Colors.black38,
                    )),
              ],
            ),
            const SizedBox(height: 12),
            Wrap(
              spacing: 10,
              runSpacing: 8,
              children: parts.map((part) {
                final kv = part.split(': ');
                return Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  decoration: BoxDecoration(
                    color: _topColor.withOpacity(0.08),
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(color: _topColor.withOpacity(0.15)),
                  ),
                  child: RichText(
                    text: TextSpan(children: [
                      TextSpan(
                        text: kv.isNotEmpty ? '${kv[0]}: ' : '',
                        style: TextStyle(fontSize: 12,
                            color: isDark ? Colors.white38 : Colors.black45),
                      ),
                      TextSpan(
                        text: kv.length > 1 ? kv[1] : '',
                        style: TextStyle(fontSize: 12, fontWeight: FontWeight.w700,
                            color: isDark ? Colors.white : const Color(0xFF0F0C29)),
                      ),
                    ]),
                  ),
                );
              }).toList(),
            ),
          ],
        ),
      ),
    );
  }
}

// ═══════════════════════════════════════════════════════════════════════════════
// Helper widgets
// ═══════════════════════════════════════════════════════════════════════════════

class _GlassCard extends StatelessWidget {
  final Widget child;
  final bool isDark;
  final EdgeInsets padding;

  const _GlassCard({
    required this.child,
    required this.isDark,
    this.padding = const EdgeInsets.all(16),
  });

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(20),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 12, sigmaY: 12),
        child: Container(
          padding: padding,
          decoration: BoxDecoration(
            color: isDark
                ? Colors.white.withOpacity(0.07)
                : Colors.white.withOpacity(0.75),
            borderRadius: BorderRadius.circular(20),
            border: Border.all(
              color: isDark
                  ? Colors.white.withOpacity(0.08)
                  : Colors.black.withOpacity(0.06),
            ),
          ),
          child: child,
        ),
      ),
    );
  }
}

class _ConfidenceBar extends StatelessWidget {
  final double value;
  final Color color;
  final Animation<double> animation;

  const _ConfidenceBar({
    required this.value,
    required this.color,
    required this.animation,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              'Confidence',
              style: TextStyle(color: Colors.white.withOpacity(0.7), fontSize: 12),
            ),
            AnimatedBuilder(
              animation: animation,
              builder: (_, __) => Text(
                '${(value * animation.value * 100).toStringAsFixed(1)}%',
                style: const TextStyle(
                    color: Colors.white, fontSize: 12, fontWeight: FontWeight.bold),
              ),
            ),
          ],
        ),
        const SizedBox(height: 6),
        ClipRRect(
          borderRadius: BorderRadius.circular(6),
          child: AnimatedBuilder(
            animation: animation,
            builder: (_, __) => LinearProgressIndicator(
              value: value * animation.value,
              minHeight: 8,
              backgroundColor: Colors.white.withOpacity(0.2),
              valueColor: AlwaysStoppedAnimation<Color>(color),
            ),
          ),
        ),
      ],
    );
  }
}

class _MetaTile extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;
  final Color color;

  const _MetaTile({
    required this.icon,
    required this.label,
    required this.value,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Column(
      children: [
        Icon(icon, color: color, size: 20),
        const SizedBox(height: 4),
        Text(value,
            style: TextStyle(
              fontWeight: FontWeight.w800,
              fontSize: 13,
              color: isDark ? Colors.white : const Color(0xFF0F0C29),
            )),
        Text(label,
            style: TextStyle(
              fontSize: 10,
              color: isDark ? Colors.white38 : Colors.black38,
            )),
      ],
    );
  }
}
