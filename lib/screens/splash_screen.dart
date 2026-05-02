import 'dart:math' as math;
import 'dart:ui';
import 'package:flutter/material.dart';

/// Premium splash screen with US Denim logo heartbeat animation.
///
/// Displayed on every app launch (after onboarding has been completed).
/// Shows the logo with a cardiac-pulse scale animation, then auto-navigates
/// to [nextScreen] after the animation completes.
class SplashScreen extends StatefulWidget {
  final Widget nextScreen;
  const SplashScreen({super.key, required this.nextScreen});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen>
    with TickerProviderStateMixin {
  // ── Heartbeat pulse on the logo ────────────────────────────────────────────
  late final AnimationController _heartbeatCtrl;
  late final Animation<double> _heartbeatAnim;

  // ── Fade in for logo + text ────────────────────────────────────────────────
  late final AnimationController _fadeCtrl;
  late final Animation<double> _fadeAnim;

  // ── Orb background drift ──────────────────────────────────────────────────
  late final AnimationController _orbCtrl;

  // ── Exit fade-out ─────────────────────────────────────────────────────────
  late final AnimationController _exitCtrl;
  late final Animation<double> _exitAnim;

  @override
  void initState() {
    super.initState();

    // Background orbs
    _orbCtrl = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 6),
    )..repeat(reverse: true);

    // Fade in (0 → 1) over 800ms
    _fadeCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 800),
    );
    _fadeAnim = CurvedAnimation(parent: _fadeCtrl, curve: Curves.easeOut);

    // Heartbeat: scale 1.0 → 1.15 → 1.0 → 1.12 → 1.0  (cardiac double-tap)
    _heartbeatCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1200),
    );
    _heartbeatAnim = TweenSequence<double>([
      TweenSequenceItem(tween: Tween(begin: 1.0, end: 1.18).chain(CurveTween(curve: Curves.easeOut)), weight: 15),
      TweenSequenceItem(tween: Tween(begin: 1.18, end: 0.95).chain(CurveTween(curve: Curves.easeIn)), weight: 12),
      TweenSequenceItem(tween: Tween(begin: 0.95, end: 1.12).chain(CurveTween(curve: Curves.easeOut)), weight: 13),
      TweenSequenceItem(tween: Tween(begin: 1.12, end: 1.0).chain(CurveTween(curve: Curves.easeInOut)), weight: 20),
      TweenSequenceItem(tween: ConstantTween(1.0), weight: 40), // rest
    ]).animate(_heartbeatCtrl);

    // Exit fade
    _exitCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 500),
    );
    _exitAnim = CurvedAnimation(parent: _exitCtrl, curve: Curves.easeIn);

    _startSequence();
  }

  Future<void> _startSequence() async {
    // Small delay so the widget is fully mounted
    await Future.delayed(const Duration(milliseconds: 200));

    // Fade in
    _fadeCtrl.forward();
    await Future.delayed(const Duration(milliseconds: 600));

    // Play heartbeat 3 times
    for (int i = 0; i < 3; i++) {
      _heartbeatCtrl.forward(from: 0);
      await Future.delayed(const Duration(milliseconds: 1200));
    }

    // Short pause then exit
    await Future.delayed(const Duration(milliseconds: 300));
    _exitCtrl.forward();
    await Future.delayed(const Duration(milliseconds: 500));

    if (!mounted) return;
    Navigator.pushReplacement(
      context,
      PageRouteBuilder(
        pageBuilder: (_, __, ___) => widget.nextScreen,
        transitionsBuilder: (_, anim, __, child) =>
            FadeTransition(opacity: anim, child: child),
        transitionDuration: const Duration(milliseconds: 600),
      ),
    );
  }

  @override
  void dispose() {
    _heartbeatCtrl.dispose();
    _fadeCtrl.dispose();
    _orbCtrl.dispose();
    _exitCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;

    return Scaffold(
      body: AnimatedBuilder(
        animation: _exitAnim,
        builder: (_, child) => Opacity(
          opacity: 1.0 - _exitAnim.value,
          child: child,
        ),
        child: Container(
          width: double.infinity,
          height: double.infinity,
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [
                Color(0xFF0F0C29),
                Color(0xFF1A1A3E),
                Color(0xFF0F0C29),
              ],
            ),
          ),
          child: Stack(
            children: [
              // ── Animated Orbs ──────────────────────────────────────────
              AnimatedBuilder(
                animation: _orbCtrl,
                builder: (_, __) {
                  return CustomPaint(
                    size: size,
                    painter: _SplashOrbPainter(t: _orbCtrl.value),
                  );
                },
              ),

              // ── Centered Logo + Text ──────────────────────────────────
              Center(
                child: FadeTransition(
                  opacity: _fadeAnim,
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      // Logo with heartbeat
                      AnimatedBuilder(
                        animation: _heartbeatAnim,
                        builder: (_, child) => Transform.scale(
                          scale: _heartbeatAnim.value,
                          child: child,
                        ),
                        child: Container(
                          width: 160,
                          height: 160,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            boxShadow: [
                              BoxShadow(
                                color: const Color(0xFF6366F1).withOpacity(0.3),
                                blurRadius: 60,
                                spreadRadius: 10,
                              ),
                            ],
                          ),
                          child: ClipOval(
                            child: Image.asset(
                              'assets/images/us_denim_logo.png',
                              fit: BoxFit.cover,
                              errorBuilder: (_, __, ___) => Container(
                                decoration: BoxDecoration(
                                  shape: BoxShape.circle,
                                  gradient: const LinearGradient(
                                    colors: [Color(0xFF6366F1), Color(0xFF06B6D4)],
                                  ),
                                ),
                                child: const Icon(
                                  Icons.auto_awesome,
                                  color: Colors.white,
                                  size: 64,
                                ),
                              ),
                            ),
                          ),
                        ),
                      ),

                      const SizedBox(height: 32),

                      // Brand name
                      const Text(
                        'US DENIM',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 32,
                          fontWeight: FontWeight.w900,
                          letterSpacing: 6,
                          height: 1,
                        ),
                      ),

                      const SizedBox(height: 10),

                      // Tagline
                      Text(
                        'FABRIC INTELLIGENCE',
                        style: TextStyle(
                          color: Colors.white.withOpacity(0.45),
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                          letterSpacing: 4,
                        ),
                      ),

                      const SizedBox(height: 48),

                      // Subtle loading indicator
                      SizedBox(
                        width: 32,
                        height: 32,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          valueColor: AlwaysStoppedAnimation<Color>(
                            Colors.white.withOpacity(0.25),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),

              // ── Version badge at bottom ───────────────────────────────
              Positioned(
                bottom: MediaQuery.of(context).padding.bottom + 24,
                left: 0,
                right: 0,
                child: FadeTransition(
                  opacity: _fadeAnim,
                  child: Text(
                    'v1.0.0  •  EfficientNetB0 Multi-Head',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      color: Colors.white.withOpacity(0.2),
                      fontSize: 11,
                      letterSpacing: 0.5,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// ═════════════════════════════════════════════════════════════════════════════════
// Splash Orb Painter — subtle floating gradient orbs
// ═════════════════════════════════════════════════════════════════════════════════

class _SplashOrbPainter extends CustomPainter {
  final double t;
  _SplashOrbPainter({required this.t});

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()..style = PaintingStyle.fill;

    // Indigo orb — top right
    final o1x = size.width * 0.78 + math.sin(t * math.pi * 2) * 30;
    final o1y = size.height * 0.18 + math.cos(t * math.pi * 2) * 25;
    paint.shader = RadialGradient(
      colors: [
        const Color(0xFF6366F1).withOpacity(0.20),
        Colors.transparent,
      ],
    ).createShader(Rect.fromCircle(center: Offset(o1x, o1y), radius: 180));
    canvas.drawCircle(Offset(o1x, o1y), 180, paint);

    // Cyan orb — bottom left
    final o2x = size.width * 0.22 + math.cos(t * math.pi * 2 + 1) * 25;
    final o2y = size.height * 0.78 + math.sin(t * math.pi * 2 + 1) * 30;
    paint.shader = RadialGradient(
      colors: [
        const Color(0xFF06B6D4).withOpacity(0.15),
        Colors.transparent,
      ],
    ).createShader(Rect.fromCircle(center: Offset(o2x, o2y), radius: 200));
    canvas.drawCircle(Offset(o2x, o2y), 200, paint);

    // Purple orb — center
    final o3x = size.width * 0.5 + math.sin(t * math.pi * 2 + 2) * 15;
    final o3y = size.height * 0.5 + math.cos(t * math.pi * 2 + 2) * 15;
    paint.shader = RadialGradient(
      colors: [
        const Color(0xFF8B5CF6).withOpacity(0.10),
        Colors.transparent,
      ],
    ).createShader(Rect.fromCircle(center: Offset(o3x, o3y), radius: 160));
    canvas.drawCircle(Offset(o3x, o3y), 160, paint);
  }

  @override
  bool shouldRepaint(_SplashOrbPainter old) => old.t != t;
}
