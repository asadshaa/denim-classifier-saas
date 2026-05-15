import 'dart:math' as math;
import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

/// Premium splash screen showcasing both US Denim brand assets.
///
/// Animation sequence:
///   1. Ice-blue gradient background fades in with floating orbs
///   2. Crest logo (`us-denim-logo.png`) appears with heartbeat pulse
///   3. Wordmark (`us_denim_logo.png`) slides up below the crest
///   4. Ice-blue shimmer line sweeps across
///   5. Everything fades out → navigates to [nextScreen]
class SplashScreen extends StatefulWidget {
  final Widget nextScreen;
  const SplashScreen({super.key, required this.nextScreen});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen>
    with TickerProviderStateMixin {

  // ── Animation Controllers ──────────────────────────────────────────────────
  late final AnimationController _orbCtrl;        // Background orbs
  late final AnimationController _crestFadeCtrl;  // Crest fade-in
  late final AnimationController _heartbeatCtrl;  // Heartbeat pulse
  late final AnimationController _wordmarkCtrl;   // Wordmark slide-up
  late final AnimationController _shimmerCtrl;    // Ice shimmer sweep
  late final AnimationController _exitCtrl;       // Exit fade

  // ── Derived Animations ─────────────────────────────────────────────────────
  late final Animation<double> _crestFade;
  late final Animation<double> _crestScale;
  late final Animation<double> _heartbeat;
  late final Animation<double> _wordmarkFade;
  late final Animation<Offset> _wordmarkSlide;
  late final Animation<double> _shimmerPosition;
  late final Animation<double> _exitFade;

  // ── Brand Colours (extracted from logos) ────────────────────────────────────
  static const _navyDeep   = Color(0xFF0A1628);
  static const _navyMid    = Color(0xFF0F1D32);
  static const _iceBlue    = Color(0xFF7DD3FC);  // sky-300
  static const _iceCyan    = Color(0xFF67E8F9);  // cyan-300
  static const _steelBlue  = Color(0xFF64748B);  // slate-500
  static const _cream      = Color(0xFFF5F0E8);
  static const _gold       = Color(0xFFD4A853);

  @override
  void initState() {
    super.initState();

    // Lock status bar to light icons on dark bg
    SystemChrome.setSystemUIOverlayStyle(
      const SystemUiOverlayStyle(statusBarIconBrightness: Brightness.light),
    );

    // Background orbs — continuous
    _orbCtrl = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 8),
    )..repeat(reverse: true);

    // Crest fade + initial scale (0.8 → 1.0)
    _crestFadeCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 900),
    );
    _crestFade = CurvedAnimation(parent: _crestFadeCtrl, curve: Curves.easeOut);
    _crestScale = Tween<double>(begin: 0.8, end: 1.0).animate(
      CurvedAnimation(parent: _crestFadeCtrl, curve: Curves.easeOutBack),
    );

    // Heartbeat: cardiac double-pulse
    _heartbeatCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1000),
    );
    _heartbeat = TweenSequence<double>([
      TweenSequenceItem(
        tween: Tween(begin: 1.0, end: 1.15)
            .chain(CurveTween(curve: Curves.easeOut)),
        weight: 12,
      ),
      TweenSequenceItem(
        tween: Tween(begin: 1.15, end: 0.96)
            .chain(CurveTween(curve: Curves.easeIn)),
        weight: 10,
      ),
      TweenSequenceItem(
        tween: Tween(begin: 0.96, end: 1.10)
            .chain(CurveTween(curve: Curves.easeOut)),
        weight: 10,
      ),
      TweenSequenceItem(
        tween: Tween(begin: 1.10, end: 1.0)
            .chain(CurveTween(curve: Curves.easeInOut)),
        weight: 18,
      ),
      TweenSequenceItem(tween: ConstantTween(1.0), weight: 50),
    ]).animate(_heartbeatCtrl);

    // Wordmark slide up + fade
    _wordmarkCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 800),
    );
    _wordmarkFade = CurvedAnimation(
      parent: _wordmarkCtrl,
      curve: Curves.easeOut,
    );
    _wordmarkSlide = Tween<Offset>(
      begin: const Offset(0, 0.5),
      end: Offset.zero,
    ).animate(CurvedAnimation(parent: _wordmarkCtrl, curve: Curves.easeOutCubic));

    // Ice shimmer sweep (left → right)
    _shimmerCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1200),
    );
    _shimmerPosition = Tween<double>(begin: -0.3, end: 1.3).animate(
      CurvedAnimation(parent: _shimmerCtrl, curve: Curves.easeInOut),
    );

    // Exit
    _exitCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 600),
    );
    _exitFade = CurvedAnimation(parent: _exitCtrl, curve: Curves.easeIn);

    _runSequence();
  }

  Future<void> _runSequence() async {
    await Future.delayed(const Duration(milliseconds: 200));

    // 1) Crest logo fades in
    _crestFadeCtrl.forward();
    await Future.delayed(const Duration(milliseconds: 500));

    // 2) Heartbeat (Reduced to 1 pulse for speed)
    for (int i = 0; i < 1; i++) {
      _heartbeatCtrl.forward(from: 0);
      await Future.delayed(const Duration(milliseconds: 800));
    }

    // 3) Wordmark slides up
    _wordmarkCtrl.forward();
    await Future.delayed(const Duration(milliseconds: 400));

    // 4) Ice shimmer sweep
    _shimmerCtrl.forward();
    await Future.delayed(const Duration(milliseconds: 600));

    // 5) Hold briefly, then exit
    await Future.delayed(const Duration(milliseconds: 200));
    _exitCtrl.forward();
    await Future.delayed(const Duration(milliseconds: 400));

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
    _orbCtrl.dispose();
    _crestFadeCtrl.dispose();
    _heartbeatCtrl.dispose();
    _wordmarkCtrl.dispose();
    _shimmerCtrl.dispose();
    _exitCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    final bottomPad = MediaQuery.of(context).padding.bottom;

    return Scaffold(
      body: AnimatedBuilder(
        animation: _exitFade,
        builder: (_, child) => Opacity(
          opacity: 1.0 - _exitFade.value,
          child: child,
        ),
        child: Container(
          width: double.infinity,
          height: double.infinity,
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: [_navyDeep, _navyMid, _navyDeep],
              stops: [0.0, 0.5, 1.0],
            ),
          ),
          child: Stack(
            alignment: Alignment.center,
            children: [
              // ── Floating Ice Orbs ─────────────────────────────────────
              Positioned.fill(
                child: AnimatedBuilder(
                  animation: _orbCtrl,
                  builder: (_, __) => CustomPaint(
                    painter: _IceOrbPainter(t: _orbCtrl.value),
                  ),
                ),
              ),

              // ── Main Content Column ───────────────────────────────────
              Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  // ── Crest Logo with Heartbeat ─────────────────────────
                  FadeTransition(
                    opacity: _crestFade,
                    child: AnimatedBuilder(
                      animation: Listenable.merge([_crestScale, _heartbeat]),
                      builder: (_, child) => Transform.scale(
                        scale: _crestScale.value * _heartbeat.value,
                        child: child,
                      ),
                      child: Container(
                        width: 140,
                        height: 140,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          border: Border.all(
                            color: _iceBlue.withOpacity(0.25),
                            width: 2,
                          ),
                          boxShadow: [
                            BoxShadow(
                              color: _iceBlue.withOpacity(0.15),
                              blurRadius: 60,
                              spreadRadius: 20,
                            ),
                            BoxShadow(
                              color: _iceCyan.withOpacity(0.08),
                              blurRadius: 100,
                              spreadRadius: 40,
                            ),
                          ],
                        ),
                        child: ClipOval(
                          child: Container(
                            color: Colors.white,
                            padding: const EdgeInsets.all(16),
                            child: Image.asset(
                              'assets/images/us-denim-logo.png',
                              fit: BoxFit.contain,
                              errorBuilder: (_, __, ___) => Icon(
                                Icons.auto_awesome,
                                color: _steelBlue,
                                size: 56,
                              ),
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),

                  const SizedBox(height: 36),

                  // ── Ice Divider Line with Shimmer ─────────────────────
                  FadeTransition(
                    opacity: _crestFade,
                    child: AnimatedBuilder(
                      animation: _shimmerPosition,
                      builder: (_, __) {
                        return Container(
                          width: 200,
                          height: 1.5,
                          decoration: BoxDecoration(
                            gradient: LinearGradient(
                              colors: [
                                _iceBlue.withOpacity(0.0),
                                _iceBlue.withOpacity(0.15),
                                _iceBlue.withOpacity(0.5),
                                _iceBlue.withOpacity(0.15),
                                _iceBlue.withOpacity(0.0),
                              ],
                              stops: [
                                0.0,
                                (_shimmerPosition.value - 0.1).clamp(0.0, 1.0),
                                _shimmerPosition.value.clamp(0.0, 1.0),
                                (_shimmerPosition.value + 0.1).clamp(0.0, 1.0),
                                1.0,
                              ],
                            ),
                          ),
                        );
                      },
                    ),
                  ),

                  const SizedBox(height: 32),

                  // ── Wordmark Image ────────────────────────────────────
                  SlideTransition(
                    position: _wordmarkSlide,
                    child: FadeTransition(
                      opacity: _wordmarkFade,
                      child: SizedBox(
                        width: size.width * 0.65,
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(12),
                          child: Image.asset(
                            'assets/images/us_denim_logo.png',
                            fit: BoxFit.contain,
                            errorBuilder: (_, __, ___) => Column(
                              children: [
                                Text(
                                  'US DENIM',
                                  style: TextStyle(
                                    color: _cream,
                                    fontSize: 28,
                                    fontWeight: FontWeight.w900,
                                    letterSpacing: 6,
                                  ),
                                ),
                                const SizedBox(height: 6),
                                Text(
                                  'FABRIC INTELLIGENCE',
                                  style: TextStyle(
                                    color: _gold,
                                    fontSize: 11,
                                    fontWeight: FontWeight.w600,
                                    letterSpacing: 4,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),

                  const SizedBox(height: 40),

                  // ── Loading Pulse ──────────────────────────────────────
                  FadeTransition(
                    opacity: _crestFade,
                    child: _IcePulseLoader(color: _iceBlue),
                  ),
                ],
              ),

              // ── Version tag at bottom ─────────────────────────────────
              Positioned(
                bottom: bottomPad + 20,
                left: 0,
                right: 0,
                child: FadeTransition(
                  opacity: _wordmarkFade,
                  child: Text(
                    'v1.0  ·  EfficientNetB0 Multi-Head  ·  21×5',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      color: _iceBlue.withOpacity(0.2),
                      fontSize: 10,
                      letterSpacing: 0.8,
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
// Ice Orb Painter — floating ice-blue / cyan gradient orbs
// ═════════════════════════════════════════════════════════════════════════════════

class _IceOrbPainter extends CustomPainter {
  final double t;
  _IceOrbPainter({required this.t});

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()..style = PaintingStyle.fill;
    final pi2 = math.pi * 2;

    // Ice-blue orb — top right
    final o1 = Offset(
      size.width * 0.80 + math.sin(t * pi2) * 35,
      size.height * 0.15 + math.cos(t * pi2) * 25,
    );
    paint.shader = RadialGradient(colors: [
      const Color(0xFF7DD3FC).withOpacity(0.14),
      Colors.transparent,
    ]).createShader(Rect.fromCircle(center: o1, radius: 200));
    canvas.drawCircle(o1, 200, paint);

    // Cyan orb — bottom left
    final o2 = Offset(
      size.width * 0.18 + math.cos(t * pi2 + 1) * 30,
      size.height * 0.80 + math.sin(t * pi2 + 1) * 35,
    );
    paint.shader = RadialGradient(colors: [
      const Color(0xFF67E8F9).withOpacity(0.10),
      Colors.transparent,
    ]).createShader(Rect.fromCircle(center: o2, radius: 220));
    canvas.drawCircle(o2, 220, paint);

    // Steel-blue orb — center-left
    final o3 = Offset(
      size.width * 0.35 + math.sin(t * pi2 + 2.5) * 20,
      size.height * 0.45 + math.cos(t * pi2 + 2.5) * 20,
    );
    paint.shader = RadialGradient(colors: [
      const Color(0xFF94A3B8).withOpacity(0.07),
      Colors.transparent,
    ]).createShader(Rect.fromCircle(center: o3, radius: 160));
    canvas.drawCircle(o3, 160, paint);

    // Gold accent orb — top center
    final o4 = Offset(
      size.width * 0.55 + math.cos(t * pi2 + 3.8) * 15,
      size.height * 0.25 + math.sin(t * pi2 + 3.8) * 18,
    );
    paint.shader = RadialGradient(colors: [
      const Color(0xFFD4A853).withOpacity(0.06),
      Colors.transparent,
    ]).createShader(Rect.fromCircle(center: o4, radius: 120));
    canvas.drawCircle(o4, 120, paint);
  }

  @override
  bool shouldRepaint(_IceOrbPainter old) => old.t != t;
}

// ═════════════════════════════════════════════════════════════════════════════════
// Ice Pulse Loader — three dots pulsing in sequence
// ═════════════════════════════════════════════════════════════════════════════════

class _IcePulseLoader extends StatefulWidget {
  final Color color;
  const _IcePulseLoader({required this.color});

  @override
  State<_IcePulseLoader> createState() => _IcePulseLoaderState();
}

class _IcePulseLoaderState extends State<_IcePulseLoader>
    with SingleTickerProviderStateMixin {
  late final AnimationController _ctrl;

  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1200),
    )..repeat();
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 48,
      height: 12,
      child: AnimatedBuilder(
        animation: _ctrl,
        builder: (_, __) {
          return Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: List.generate(3, (i) {
              // Stagger each dot by 0.2
              final phase = (_ctrl.value + i * 0.2) % 1.0;
              final scale = 0.5 + 0.5 * math.sin(phase * math.pi);
              final opacity = 0.3 + 0.7 * math.sin(phase * math.pi);
              return Transform.scale(
                scale: scale,
                child: Container(
                  width: 8,
                  height: 8,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: widget.color.withOpacity(opacity),
                    boxShadow: [
                      BoxShadow(
                        color: widget.color.withOpacity(opacity * 0.4),
                        blurRadius: 8,
                        spreadRadius: 1,
                      ),
                    ],
                  ),
                ),
              );
            }),
          );
        },
      ),
    );
  }
}
