import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:image_picker/image_picker.dart';
import 'package:denim_classifier/providers/classifier_provider.dart';
import 'package:denim_classifier/screens/results_screen.dart';
import 'package:denim_classifier/widgets/animated_orb_background.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> with SingleTickerProviderStateMixin {
  late AnimationController _pulseAnim;

  @override
  void initState() {
    super.initState();

    _pulseAnim = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1200),
    )..repeat(reverse: true);
  }

  @override
  void dispose() {
    _pulseAnim.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Consumer<ClassifierProvider>(
      builder: (context, provider, _) {
        final canAnalyze = provider.image != null && !provider.isLoading;
        final orbs = isDark ? OrbConfig.dark : OrbConfig.light;

        return Scaffold(
          extendBodyBehindAppBar: true,
          appBar: AppBar(
            elevation: 0,
            backgroundColor: Colors.transparent,
            title: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(6),
                  decoration: BoxDecoration(
                    gradient: const LinearGradient(
                      colors: [Color(0xFF6366F1), Color(0xFF06B6D4)],
                    ),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: const Icon(Icons.auto_awesome, color: Colors.white, size: 16),
                ),
                const SizedBox(width: 10),
                Text(
                  'DenimAI',
                  style: TextStyle(
                    fontWeight: FontWeight.w800,
                    fontSize: 20,
                    color: isDark ? Colors.white : const Color(0xFF0F0C29),
                  ),
                ),
              ],
            ),
          ),
          body: Stack(
            children: [
              // ── Animated Background ───────────────────────────────────────
              AnimatedOrbBackground(orbs: orbs),

              // ── Content ───────────────────────────────────────────────────
              SafeArea(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.fromLTRB(20, 12, 20, 120),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // ── Hero Header ───────────────────────────────────
                      _buildHeader(isDark),
                      const SizedBox(height: 24),

                      // ── Model Selector ────────────────────────────────
                      _buildModelSelector(context, provider, isDark),
                      const SizedBox(height: 20),

                      // ── Image Upload Zone ─────────────────────────────
                      _buildImageZone(context, provider, isDark),
                      const SizedBox(height: 20),

                      // ── Camera / Gallery Buttons ──────────────────────
                      _buildInputButtons(context, provider),
                      const SizedBox(height: 28),

                      // ── Analyze Button ────────────────────────────────
                      _buildAnalyzeButton(context, provider, canAnalyze),
                    ],
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  // ── Header ─────────────────────────────────────────────────────────────────
  Widget _buildHeader(bool isDark) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Fabric Analysis',
          style: TextStyle(
            fontSize: 30,
            fontWeight: FontWeight.w800,
            color: isDark ? Colors.white : const Color(0xFF0F0C29),
            letterSpacing: -0.5,
          ),
        ),
        const SizedBox(height: 6),
        Text(
          'Upload or capture a denim fabric image to classify it instantly.',
          style: TextStyle(
            fontSize: 14,
            color: isDark ? Colors.white54 : Colors.black45,
            height: 1.5,
          ),
        ),
      ],
    );
  }

  // ── Model Selector ─────────────────────────────────────────────────────────
  Widget _buildModelSelector(
      BuildContext context, ClassifierProvider provider, bool isDark) {
    const models = ['denim_model.tflite', 'best_model.tflite'];
    const labels = ['Multi-Head (21×5)', 'Float32 (Legacy)'];
    const icons = [Icons.auto_awesome_outlined, Icons.history_outlined];

    return ClipRRect(
      borderRadius: BorderRadius.circular(16),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
        child: Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: isDark ? Colors.white.withOpacity(0.06) : Colors.white.withOpacity(0.7),
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              color: isDark ? Colors.white.withOpacity(0.1) : Colors.black.withOpacity(0.08),
            ),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Icon(Icons.smart_toy_outlined, size: 16,
                      color: isDark ? Colors.white60 : Colors.black45),
                  const SizedBox(width: 6),
                  Text(
                    'AI Model',
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                      color: isDark ? Colors.white60 : Colors.black45,
                      letterSpacing: 0.5,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              Row(
                children: List.generate(2, (i) {
                  final selected = provider.selectedModel == models[i];
                  return Expanded(
                    child: GestureDetector(
                      onTap: () {
                        HapticFeedback.selectionClick();
                        provider.setModel(models[i]);
                      },
                      child: AnimatedContainer(
                        duration: const Duration(milliseconds: 250),
                        margin: EdgeInsets.only(right: i == 0 ? 8 : 0),
                        padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 8),
                        decoration: BoxDecoration(
                          gradient: selected
                              ? const LinearGradient(
                                  colors: [Color(0xFF6366F1), Color(0xFF06B6D4)],
                                )
                              : null,
                          color: selected
                              ? null
                              : (isDark
                                  ? Colors.white.withOpacity(0.05)
                                  : Colors.black.withOpacity(0.04)),
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(
                            color: selected
                                ? Colors.transparent
                                : (isDark
                                    ? Colors.white.withOpacity(0.12)
                                    : Colors.black.withOpacity(0.1)),
                          ),
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(
                              icons[i],
                              size: 16,
                              color: selected
                                  ? Colors.white
                                  : (isDark ? Colors.white54 : Colors.black38),
                            ),
                            const SizedBox(width: 6),
                            Flexible(
                              child: Text(
                                labels[i],
                                style: TextStyle(
                                  fontSize: 12,
                                  fontWeight: FontWeight.w600,
                                  color: selected
                                      ? Colors.white
                                      : (isDark ? Colors.white54 : Colors.black45),
                                ),
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  );
                }),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // ── Image Zone ─────────────────────────────────────────────────────────────
  Widget _buildImageZone(
      BuildContext context, ClassifierProvider provider, bool isDark) {
    final primary = Theme.of(context).colorScheme.primary;

    return AnimatedBuilder(
      animation: _pulseAnim,
      builder: (_, child) {
        final pulse = provider.image == null ? _pulseAnim.value : 0.0;
        return Container(
          height: 280,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(28),
            border: Border.all(
              color: provider.image != null
                  ? Colors.transparent
                  : primary.withOpacity(0.3 + pulse * 0.3),
              width: 2,
            ),
            gradient: provider.image == null
                ? LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: isDark
                        ? [
                            Colors.white.withOpacity(0.04 + pulse * 0.02),
                            Colors.white.withOpacity(0.02),
                          ]
                        : [
                            const Color(0xFF6366F1).withOpacity(0.04 + pulse * 0.03),
                            const Color(0xFF06B6D4).withOpacity(0.03),
                          ],
                  )
                : null,
            boxShadow: provider.image != null
                ? [
                    BoxShadow(
                      color: primary.withOpacity(0.15),
                      blurRadius: 30,
                      offset: const Offset(0, 10),
                    ),
                  ]
                : null,
          ),
          child: child,
        );
      },
      child: ClipRRect(
        borderRadius: BorderRadius.circular(28),
        child: provider.image == null
            ? _buildEmptyZone(context, isDark)
            : Hero(
                tag: 'fabric_image',
                child: Image.file(
                  provider.image!,
                  width: double.infinity,
                  height: double.infinity,
                  fit: BoxFit.cover,
                ),
              ),
      ),
    );
  }

  Widget _buildEmptyZone(BuildContext context, bool isDark) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            width: 72,
            height: 72,
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  const Color(0xFF6366F1).withOpacity(0.15),
                  const Color(0xFF06B6D4).withOpacity(0.15),
                ],
              ),
              shape: BoxShape.circle,
            ),
            child: const Icon(
              Icons.add_photo_alternate_outlined,
              size: 32,
              color: Color(0xFF6366F1),
            ),
          ),
          const SizedBox(height: 16),
          Text(
            'No Image Selected',
            style: TextStyle(
              fontSize: 17,
              fontWeight: FontWeight.w700,
              color: isDark ? Colors.white70 : const Color(0xFF0F0C29),
            ),
          ),
          const SizedBox(height: 6),
          Text(
            'Use the buttons below to capture\nor choose a fabric photo',
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 13,
              color: isDark ? Colors.white38 : Colors.black38,
              height: 1.5,
            ),
          ),
        ],
      ),
    );
  }

  // ── Input Buttons ──────────────────────────────────────────────────────────
  Widget _buildInputButtons(BuildContext context, ClassifierProvider provider) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Row(
      children: [
        Expanded(
          child: _InputCard(
            icon: Icons.camera_alt_rounded,
            label: 'Camera',
            subtitle: 'Take a photo',
            gradient: const [Color(0xFF6366F1), Color(0xFF8B5CF6)],
            isDark: isDark,
            onTap: () {
              HapticFeedback.mediumImpact();
              provider.pickImage(ImageSource.camera);
            },
          ),
        ),
        const SizedBox(width: 14),
        Expanded(
          child: _InputCard(
            icon: Icons.photo_library_rounded,
            label: 'Gallery',
            subtitle: 'Choose a photo',
            gradient: const [Color(0xFF06B6D4), Color(0xFF0EA5E9)],
            isDark: isDark,
            onTap: () {
              HapticFeedback.mediumImpact();
              provider.pickImage(ImageSource.gallery);
            },
          ),
        ),
      ],
    );
  }

  // ── Analyze Button ─────────────────────────────────────────────────────────
  Widget _buildAnalyzeButton(
      BuildContext context, ClassifierProvider provider, bool canAnalyze) {
    return AnimatedOpacity(
      duration: const Duration(milliseconds: 300),
      opacity: canAnalyze ? 1.0 : 0.5,
      child: Container(
        height: 64,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(32),
          gradient: const LinearGradient(
            colors: [Color(0xFF6366F1), Color(0xFF06B6D4)],
          ),
          boxShadow: canAnalyze
              ? [
                  BoxShadow(
                    color: const Color(0xFF6366F1).withOpacity(0.4),
                    blurRadius: 24,
                    offset: const Offset(0, 8),
                  ),
                ]
              : [],
        ),
        child: Material(
          color: Colors.transparent,
          child: InkWell(
            borderRadius: BorderRadius.circular(32),
            onTap: canAnalyze
                ? () async {
                    HapticFeedback.heavyImpact();
                    await provider.classifyImage();
                    if (context.mounted) {
                      if (provider.result != null) {
                        Navigator.push(
                          context,
                          PageRouteBuilder(
                            pageBuilder: (_, __, ___) => ResultsScreen(
                              result: provider.result!,
                              imagePath: provider.image!.path,
                              modelName: provider.selectedModel,
                            ),
                            transitionsBuilder: (_, anim, __, child) =>
                                FadeTransition(opacity: anim, child: child),
                            transitionDuration: const Duration(milliseconds: 400),
                          ),
                        );
                      } else if (provider.lastError != null) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text('Error analyzing: ${provider.lastError}'),
                            backgroundColor: Colors.redAccent,
                            duration: const Duration(seconds: 4),
                          ),
                        );
                      }
                    }
                  }
                : null,
            child: Center(
              child: provider.isLoading
                  ? const SizedBox(
                      width: 26,
                      height: 26,
                      child: CircularProgressIndicator(
                        color: Colors.white,
                        strokeWidth: 2.5,
                      ),
                    )
                  : Row(
                      mainAxisSize: MainAxisSize.min,
                      children: const [
                        Icon(Icons.auto_awesome, color: Colors.white, size: 20),
                        SizedBox(width: 10),
                        Text(
                          'Analyze Fabric',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 18,
                            fontWeight: FontWeight.w700,
                            letterSpacing: -0.2,
                          ),
                        ),
                      ],
                    ),
            ),
          ),
        ),
      ),
    );
  }
}

// ── Input Card Widget ──────────────────────────────────────────────────────────
class _InputCard extends StatelessWidget {
  final IconData icon;
  final String label;
  final String subtitle;
  final List<Color> gradient;
  final bool isDark;
  final VoidCallback onTap;

  const _InputCard({
    required this.icon,
    required this.label,
    required this.subtitle,
    required this.gradient,
    required this.isDark,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: ClipRRect(
        borderRadius: BorderRadius.circular(20),
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 8, sigmaY: 8),
          child: Container(
            padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 16),
            decoration: BoxDecoration(
              color: isDark
                  ? Colors.white.withOpacity(0.06)
                  : Colors.white.withOpacity(0.75),
              borderRadius: BorderRadius.circular(20),
              border: Border.all(
                color: isDark
                    ? Colors.white.withOpacity(0.1)
                    : Colors.black.withOpacity(0.07),
              ),
            ),
            child: Column(
              children: [
                Container(
                  width: 48,
                  height: 48,
                  decoration: BoxDecoration(
                    gradient: LinearGradient(colors: gradient),
                    borderRadius: BorderRadius.circular(14),
                  ),
                  child: Icon(icon, color: Colors.white, size: 24),
                ),
                const SizedBox(height: 10),
                Text(
                  label,
                  style: TextStyle(
                    fontWeight: FontWeight.w700,
                    fontSize: 15,
                    color: isDark ? Colors.white : const Color(0xFF0F0C29),
                  ),
                ),
                const SizedBox(height: 2),
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
        ),
      ),
    );
  }
}

