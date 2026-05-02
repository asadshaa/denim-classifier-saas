import 'dart:math' as math;
import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:lottie/lottie.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'main_nav_screen.dart';

// ─── Data Model ──────────────────────────────────────────────────────────────

class _OBData {
  final String animation;
  final String badge;
  final String title;
  final String subtitle;
  final String description;
  final List<String> bullets;
  final List<Color> gradient;
  final IconData badgeIcon;

  const _OBData({
    required this.animation,
    required this.badge,
    required this.title,
    required this.subtitle,
    required this.description,
    required this.bullets,
    required this.gradient,
    required this.badgeIcon,
  });
}

const List<_OBData> _pages = [
  // ── Page 1: Welcome / Hero ────────────────────────────────────────────────
  _OBData(
    animation: 'assets/animations/Welcome.json',
    badge: 'AI-Powered',
    badgeIcon: Icons.auto_awesome_rounded,
    title: 'DenimAI',
    subtitle: 'Professional Fabric Intelligence',
    description:
        'The most accurate denim fabric classification platform — built for '
        'textile professionals, quality inspectors, and fabric enthusiasts.',
    bullets: [
      '5-Class Denim Recognition',
      'On-Device AI · No Internet Needed',
      'Instant Confidence Scores',
    ],
    gradient: [Color(0xFF0F0C29), Color(0xFF302B63), Color(0xFF24243E)],
  ),

  // ── Page 2: How It Works ──────────────────────────────────────────────────
  _OBData(
    animation: 'assets/animations/search.json',
    badge: 'How It Works',
    badgeIcon: Icons.play_circle_outline_rounded,
    title: 'Three Steps to\nClassification',
    subtitle: 'Fast · Accurate · Reliable',
    description:
        'Our streamlined workflow makes fabric analysis effortless — from '
        'capture to result in seconds.',
    bullets: [
      '① Pick or shoot a fabric photo',
      '② AI preprocesses & analyzes texture',
      '③ Get confidence scores for all classes',
    ],
    gradient: [Color(0xFF1A1A2E), Color(0xFF16213E), Color(0xFF0F3460)],
  ),

  // ── Page 3: Classification Power ─────────────────────────────────────────
  _OBData(
    animation: 'assets/animations/search.json',
    badge: '5 Fabric Classes',
    badgeIcon: Icons.layers_rounded,
    title: 'Industrial-Grade\nPrecision',
    subtitle: 'Know Your Denim Exactly',
    description:
        'DenimAI recognizes 5 professional fabric codes used in real '
        'textile manufacturing and quality control.',
    bullets: [
      '1553-EL  ·  1830-BZ  ·  1976W-RS01',
      'P140406-BB  ·  PRT0235-AY',
      'Weight, stretch & finish details',
    ],
    gradient: [Color(0xFF0D1B2A), Color(0xFF1B263B), Color(0xFF415A77)],
  ),

  // ── Page 4: Launch ────────────────────────────────────────────────────────
  _OBData(
    animation: 'assets/animations/Rocket Launch.json',
    badge: "You're All Set",
    badgeIcon: Icons.rocket_launch_rounded,
    title: 'Start Classifying\nDenim Today',
    subtitle: 'Your Fabric Lab, In Your Pocket',
    description:
        'Choose a TFLite model, load a fabric image, and receive professional '
        'classification results with confidence analytics — all offline.',
    bullets: [
      'History tracking & export',
      'Dark & Light themes',
      'Share results instantly',
    ],
    gradient: [Color(0xFF091C32), Color(0xFF1A3B5D), Color(0xFF0E5C8A)],
  ),
];

// ─── Main Screen ─────────────────────────────────────────────────────────────

class OnboardingScreen extends StatefulWidget {
  const OnboardingScreen({super.key});

  @override
  State<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends State<OnboardingScreen>
    with TickerProviderStateMixin {
  final PageController _pageCtrl = PageController();
  int _currentPage = 0;

  // Per-page animation controller (resets on page change)
  late AnimationController _contentAnim;
  late Animation<double> _fadeAnim;
  late Animation<Offset> _slideAnim;

  // Background gradient animation
  late AnimationController _bgAnim;

  @override
  void initState() {
    super.initState();

    _bgAnim = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 8),
    )..repeat(reverse: true);

    _contentAnim = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 700),
    );

    _fadeAnim = CurvedAnimation(parent: _contentAnim, curve: Curves.easeOut);
    _slideAnim = Tween<Offset>(
      begin: const Offset(0, 0.12),
      end: Offset.zero,
    ).animate(CurvedAnimation(parent: _contentAnim, curve: Curves.easeOutCubic));

    _contentAnim.forward();
  }

  @override
  void dispose() {
    _pageCtrl.dispose();
    _contentAnim.dispose();
    _bgAnim.dispose();
    super.dispose();
  }

  void _onPageChanged(int index) {
    setState(() => _currentPage = index);
    _contentAnim.forward(from: 0);
  }

  void _nextPage() {
    if (_currentPage < _pages.length - 1) {
      _pageCtrl.nextPage(
        duration: const Duration(milliseconds: 500),
        curve: Curves.easeInOutCubic,
      );
    } else {
      _completeOnboarding();
    }
  }

  Future<void> _completeOnboarding() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('seenOnboarding', true);
    if (!mounted) return;
    Navigator.pushReplacement(
      context,
      PageRouteBuilder(
        pageBuilder: (_, __, ___) => const MainNavScreen(),
        transitionsBuilder: (_, anim, __, child) =>
            FadeTransition(opacity: anim, child: child),
        transitionDuration: const Duration(milliseconds: 600),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final page = _pages[_currentPage];
    final size = MediaQuery.of(context).size;

    return Scaffold(
      body: AnimatedContainer(
        duration: const Duration(milliseconds: 600),
        curve: Curves.easeInOut,
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: page.gradient,
          ),
        ),
        child: Stack(
          children: [
            // ── Animated Mesh Background ───────────────────────────────────
            _AnimatedMeshBackground(animController: _bgAnim, size: size),

            // ── Pages ──────────────────────────────────────────────────────
            PageView.builder(
              controller: _pageCtrl,
              itemCount: _pages.length,
              onPageChanged: _onPageChanged,
              itemBuilder: (ctx, i) => _PageContent(
                data: _pages[i],
                fadeAnim: _fadeAnim,
                slideAnim: _slideAnim,
                isFirst: i == 0,
              ),
            ),

            // ── Bottom Controls ────────────────────────────────────────────
            Positioned(
              left: 0,
              right: 0,
              bottom: 0,
              child: _BottomBar(
                currentPage: _currentPage,
                totalPages: _pages.length,
                isLast: _currentPage == _pages.length - 1,
                onNext: _nextPage,
                onSkip: _completeOnboarding,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ─── Page Content ─────────────────────────────────────────────────────────────

class _PageContent extends StatelessWidget {
  final _OBData data;
  final Animation<double> fadeAnim;
  final Animation<Offset> slideAnim;
  final bool isFirst;

  const _PageContent({
    required this.data,
    required this.fadeAnim,
    required this.slideAnim,
    required this.isFirst,
  });

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;

    return SafeArea(
      bottom: false,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 28),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            SizedBox(height: size.height * 0.04),

            // ── Badge chip ─────────────────────────────────────────────────
            FadeTransition(
              opacity: fadeAnim,
              child: _BadgeChip(icon: data.badgeIcon, label: data.badge),
            ),

            SizedBox(height: size.height * 0.02),

            // ── Lottie Animation ───────────────────────────────────────────
            SizedBox(
              height: size.height * 0.28,
              child: Center(
                child: Lottie.asset(
                  data.animation,
                  fit: BoxFit.contain,
                  errorBuilder: (_, __, ___) => Icon(
                    data.badgeIcon,
                    size: 100,
                    color: Colors.white.withOpacity(0.4),
                  ),
                ),
              ),
            ),

            SizedBox(height: size.height * 0.03),

            // ── Title ──────────────────────────────────────────────────────
            SlideTransition(
              position: slideAnim,
              child: FadeTransition(
                opacity: fadeAnim,
                child: Text(
                  data.title,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 34,
                    fontWeight: FontWeight.w800,
                    height: 1.15,
                    letterSpacing: -0.5,
                  ),
                ),
              ),
            ),

            const SizedBox(height: 8),

            // ── Subtitle ───────────────────────────────────────────────────
            FadeTransition(
              opacity: fadeAnim,
              child: Text(
                data.subtitle,
                style: TextStyle(
                  color: Colors.white.withOpacity(0.55),
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                  letterSpacing: 0.5,
                ),
              ),
            ),

            const SizedBox(height: 18),

            // ── Divider line ───────────────────────────────────────────────
            FadeTransition(
              opacity: fadeAnim,
              child: Container(
                width: 48,
                height: 3,
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.5),
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
            ),

            const SizedBox(height: 16),

            // ── Description ────────────────────────────────────────────────
            SlideTransition(
              position: slideAnim,
              child: FadeTransition(
                opacity: fadeAnim,
                child: Text(
                  data.description,
                  style: TextStyle(
                    color: Colors.white.withOpacity(0.75),
                    fontSize: 15,
                    height: 1.6,
                  ),
                ),
              ),
            ),

            const SizedBox(height: 20),

            // ── Bullet Points ──────────────────────────────────────────────
            ...data.bullets.map((bullet) {
              return SlideTransition(
                position: slideAnim,
                child: FadeTransition(
                  opacity: fadeAnim,
                  child: Padding(
                    padding: const EdgeInsets.only(bottom: 10),
                    child: _BulletRow(text: bullet),
                  ),
                ),
              );
            }),
          ],
        ),
      ),
    );
  }
}

// ─── Sub Widgets ──────────────────────────────────────────────────────────────

class _BadgeChip extends StatelessWidget {
  final IconData icon;
  final String label;
  const _BadgeChip({required this.icon, required this.label});

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(20),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 8, sigmaY: 8),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 7),
          decoration: BoxDecoration(
            color: Colors.white.withOpacity(0.12),
            borderRadius: BorderRadius.circular(20),
            border: Border.all(color: Colors.white.withOpacity(0.2)),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(icon, color: Colors.white, size: 14),
              const SizedBox(width: 6),
              Text(
                label,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                  letterSpacing: 0.4,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _BulletRow extends StatelessWidget {
  final String text;
  const _BulletRow({required this.text});

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Container(
          width: 6,
          height: 6,
          decoration: BoxDecoration(
            color: Colors.white.withOpacity(0.6),
            shape: BoxShape.circle,
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Text(
            text,
            style: TextStyle(
              color: Colors.white.withOpacity(0.8),
              fontSize: 14,
              fontWeight: FontWeight.w500,
            ),
          ),
        ),
      ],
    );
  }
}

// ─── Bottom Navigation Bar ────────────────────────────────────────────────────

class _BottomBar extends StatelessWidget {
  final int currentPage;
  final int totalPages;
  final bool isLast;
  final VoidCallback onNext;
  final VoidCallback onSkip;

  const _BottomBar({
    required this.currentPage,
    required this.totalPages,
    required this.isLast,
    required this.onNext,
    required this.onSkip,
  });

  @override
  Widget build(BuildContext context) {
    final bottomPad = MediaQuery.of(context).padding.bottom;

    return ClipRect(
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 20, sigmaY: 20),
        child: Container(
          padding: EdgeInsets.fromLTRB(28, 20, 28, 20 + bottomPad),
          decoration: BoxDecoration(
            color: Colors.black.withOpacity(0.25),
            border: Border(
              top: BorderSide(color: Colors.white.withOpacity(0.1)),
            ),
          ),
          child: Row(
            children: [
              // Skip
              if (!isLast)
                TextButton(
                  onPressed: onSkip,
                  child: Text(
                    'Skip',
                    style: TextStyle(
                      color: Colors.white.withOpacity(0.55),
                      fontSize: 14,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                )
              else
                const SizedBox(width: 60),

              // Dot Indicators
              Expanded(
                child: Center(
                  child: _DotIndicator(
                    current: currentPage,
                    total: totalPages,
                  ),
                ),
              ),

              // Next / Get Started button
              AnimatedContainer(
                duration: const Duration(milliseconds: 300),
                width: isLast ? 140 : 52,
                height: 52,
                child: ElevatedButton(
                  onPressed: onNext,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.white,
                    foregroundColor: const Color(0xFF0F0C29),
                    padding: EdgeInsets.zero,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(26),
                    ),
                    elevation: 0,
                  ),
                  child: isLast
                      ? const Text(
                          'Get Started',
                          style: TextStyle(
                            fontWeight: FontWeight.w700,
                            fontSize: 13,
                          ),
                        )
                      : const Icon(Icons.arrow_forward_rounded),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// ─── Dot Indicator ────────────────────────────────────────────────────────────

class _DotIndicator extends StatelessWidget {
  final int current;
  final int total;
  const _DotIndicator({required this.current, required this.total});

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: List.generate(total, (i) {
        final isActive = i == current;
        return AnimatedContainer(
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeOut,
          margin: const EdgeInsets.symmetric(horizontal: 4),
          width: isActive ? 24 : 8,
          height: 8,
          decoration: BoxDecoration(
            color: isActive
                ? Colors.white
                : Colors.white.withOpacity(0.3),
            borderRadius: BorderRadius.circular(4),
          ),
        );
      }),
    );
  }
}

// ─── Animated Mesh Background ─────────────────────────────────────────────────

class _AnimatedMeshBackground extends StatelessWidget {
  final AnimationController animController;
  final Size size;
  const _AnimatedMeshBackground({
    required this.animController,
    required this.size,
  });

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: animController,
      builder: (_, __) {
        final t = animController.value;
        return CustomPaint(
          size: size,
          painter: _MeshPainter(t: t),
        );
      },
    );
  }
}

class _MeshPainter extends CustomPainter {
  final double t;
  _MeshPainter({required this.t});

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()..style = PaintingStyle.fill;

    // Orb 1 — top right
    final orb1X = size.width * 0.85 + math.sin(t * math.pi * 2) * 40;
    final orb1Y = size.height * 0.15 + math.cos(t * math.pi * 2) * 30;
    paint.shader = RadialGradient(
      colors: [
        Colors.blue.withOpacity(0.18),
        Colors.transparent,
      ],
    ).createShader(Rect.fromCircle(center: Offset(orb1X, orb1Y), radius: 180));
    canvas.drawCircle(Offset(orb1X, orb1Y), 180, paint);

    // Orb 2 — bottom left
    final orb2X = size.width * 0.15 + math.cos(t * math.pi * 2 + 1) * 30;
    final orb2Y = size.height * 0.75 + math.sin(t * math.pi * 2 + 1) * 40;
    paint.shader = RadialGradient(
      colors: [
        Colors.purple.withOpacity(0.15),
        Colors.transparent,
      ],
    ).createShader(Rect.fromCircle(center: Offset(orb2X, orb2Y), radius: 200));
    canvas.drawCircle(Offset(orb2X, orb2Y), 200, paint);

    // Orb 3 — center
    final orb3X = size.width * 0.5 + math.sin(t * math.pi * 2 + 2) * 20;
    final orb3Y = size.height * 0.45 + math.cos(t * math.pi * 2 + 2) * 20;
    paint.shader = RadialGradient(
      colors: [
        Colors.cyan.withOpacity(0.08),
        Colors.transparent,
      ],
    ).createShader(Rect.fromCircle(center: Offset(orb3X, orb3Y), radius: 150));
    canvas.drawCircle(Offset(orb3X, orb3Y), 150, paint);
  }

  @override
  bool shouldRepaint(_MeshPainter old) => old.t != t;
}
