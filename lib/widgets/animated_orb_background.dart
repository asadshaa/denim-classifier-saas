import 'dart:math' as math;
import 'package:flutter/material.dart';

/// Drop this anywhere in a [Stack] as the first child.
/// It fills its parent with slowly drifting glowing orbs.
///
/// Usage:
/// ```dart
/// Stack(
///   children: [
///     const AnimatedOrbBackground(),   // ← first
///     // ... your screen content ...
///   ],
/// )
/// ```
class AnimatedOrbBackground extends StatefulWidget {
  /// Override the orb definitions. Leave null to use defaults.
  final List<OrbConfig>? orbs;

  /// Speed multiplier. 1.0 = default (8 s cycle). Lower = slower.
  final double speed;

  const AnimatedOrbBackground({super.key, this.orbs, this.speed = 1.0});

  @override
  State<AnimatedOrbBackground> createState() => _AnimatedOrbBackgroundState();
}

class _AnimatedOrbBackgroundState extends State<AnimatedOrbBackground>
    with SingleTickerProviderStateMixin {
  late final AnimationController _ctrl;

  @override
  void initState() {
    super.initState();
    final ms = (8000 / widget.speed).round();
    _ctrl = AnimationController(
      vsync: this,
      duration: Duration(milliseconds: ms),
    )..repeat(reverse: true);
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  List<OrbConfig> get _orbs =>
      widget.orbs ?? OrbConfig.defaults;

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Stack(
      fit: StackFit.expand,
      children: [
        // Base gradient for depth
        Positioned.fill(
          child: Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: isDark
                    ? [const Color(0xFF0F0C29), const Color(0xFF1E1B4B)]
                    : [const Color(0xFFF8FAFC), const Color(0xFFEEF2FF)],
              ),
            ),
          ),
        ),
        // Animated orbs painted on top
        Positioned.fill(
          child: AnimatedBuilder(
            animation: _ctrl,
            builder: (_, __) => CustomPaint(
              painter: _OrbPainter(t: _ctrl.value, orbs: _orbs),
            ),
          ),
        ),
      ],
    );
  }
}

// ─── Orb Configuration ────────────────────────────────────────────────────────

class OrbConfig {
  /// Fractional position [0,1] — base center of the orb.
  final double fx, fy;

  /// How far (in logical pixels) the orb drifts in x and y.
  final double driftX, driftY;

  /// Phase offset so orbs don't all move in sync.
  final double phase;

  /// Radius of the orb glow.
  final double radius;

  /// Center color of the radial gradient (the glow).
  final Color color;

  /// Opacity of the glow at its center.
  final double opacity;

  const OrbConfig({
    required this.fx,
    required this.fy,
    this.driftX = 30,
    this.driftY = 25,
    this.phase = 0,
    required this.radius,
    required this.color,
    this.opacity = 0.35,
  });

  /// Default three-orb layout matching the onboarding style.
  static const List<OrbConfig> defaults = [
    OrbConfig(
      fx: 0.85, fy: 0.12,
      driftX: 40, driftY: 30,
      phase: 0,
      radius: 350,
      color: Color(0xFF6366F1),
      opacity: 0.25,
    ),
    OrbConfig(
      fx: 0.12, fy: 0.72,
      driftX: 30, driftY: 40,
      phase: 1.0,
      radius: 380,
      color: Color(0xFF8B5CF6),
      opacity: 0.20,
    ),
    OrbConfig(
      fx: 0.50, fy: 0.42,
      driftX: 20, driftY: 20,
      phase: 2.0,
      radius: 300,
      color: Color(0xFF06B6D4),
      opacity: 0.15,
    ),
  ];

  /// Vibrant palette for dark mode
  static const List<OrbConfig> dark = [
    OrbConfig(
      fx: 0.80, fy: 0.10,
      driftX: 50, driftY: 35,
      phase: 0,
      radius: 400,
      color: Color(0xFF6366F1),
      opacity: 0.35,
    ),
    OrbConfig(
      fx: 0.05, fy: 0.80,
      driftX: 35, driftY: 50,
      phase: 1.5,
      radius: 420,
      color: Color(0xFF8B5CF6),
      opacity: 0.28,
    ),
    OrbConfig(
      fx: 0.60, fy: 0.50,
      driftX: 25, driftY: 25,
      phase: 2.8,
      radius: 320,
      color: Color(0xFF06B6D4),
      opacity: 0.22,
    ),
  ];

  /// Soft but visible palette for light mode
  static const List<OrbConfig> light = [
    OrbConfig(
      fx: 0.90, fy: 0.05,
      driftX: 40, driftY: 30,
      phase: 0,
      radius: 380,
      color: Color(0xFF818CF8),
      opacity: 0.16,
    ),
    OrbConfig(
      fx: 0.05, fy: 0.85,
      driftX: 30, driftY: 40,
      phase: 1.4,
      radius: 400,
      color: Color(0xFFA78BFA),
      opacity: 0.14,
    ),
    OrbConfig(
      fx: 0.50, fy: 0.40,
      driftX: 20, driftY: 20,
      phase: 2.6,
      radius: 320,
      color: Color(0xFF22D3EE),
      opacity: 0.12,
    ),
  ];
}

// ─── Painter ──────────────────────────────────────────────────────────────────

class _OrbPainter extends CustomPainter {
  final double t;
  final List<OrbConfig> orbs;

  _OrbPainter({required this.t, required this.orbs});

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()..style = PaintingStyle.fill;

    for (final orb in orbs) {
      final cx = size.width * orb.fx +
          math.sin((t + orb.phase) * math.pi * 2) * orb.driftX;
      final cy = size.height * orb.fy +
          math.cos((t + orb.phase) * math.pi * 2) * orb.driftY;

      final center = Offset(cx, cy);
      paint.shader = RadialGradient(
        colors: [
          orb.color.withOpacity(orb.opacity),
          orb.color.withOpacity(0),
        ],
      ).createShader(
        Rect.fromCircle(center: center, radius: orb.radius),
      );
      canvas.drawCircle(center, orb.radius, paint);
    }
  }

  @override
  bool shouldRepaint(_OrbPainter old) => old.t != t;
}
