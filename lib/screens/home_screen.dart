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
      duration: const Duration(milliseconds: 1500),
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
                  child: const Icon(Icons.psychology, color: Colors.white, size: 16),
                ),
                const SizedBox(width: 10),
                const Text(
                  'DenimAI Research',
                  style: TextStyle(fontWeight: FontWeight.w900, fontSize: 18),
                ),
              ],
            ),
          ),
          body: Stack(
            children: [
              AnimatedOrbBackground(orbs: orbs),
              SafeArea(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.fromLTRB(20, 12, 20, 120),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _buildHeader(isDark),
                      const SizedBox(height: 24),

                      // ── Status Indicator (Replaced Model Selector) ─────
                      _buildSystemStatus(isDark),
                      const SizedBox(height: 24),

                      // ── Image Scanner Zone ─────────────────────────────
                      _buildScannerZone(context, provider, isDark),
                      const SizedBox(height: 24),

                      // ── Input Buttons ──────────────────────
                      _buildInputButtons(context, provider),
                      const SizedBox(height: 28),

                      // ── Analyze Button ────────────────────────────────
                      _buildAnalyzeButton(context, provider, canAnalyze),
                      
                      const SizedBox(height: 32),
                      _buildProTips(isDark),
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

  Widget _buildHeader(bool isDark) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Neural Fabric Scan',
          style: TextStyle(fontSize: 32, fontWeight: FontWeight.w900, letterSpacing: -1),
        ),
        const SizedBox(height: 6),
        Text(
          'Precision classification across 21 denim material classes.',
          style: TextStyle(fontSize: 14, color: isDark ? Colors.white54 : Colors.black54),
        ),
      ],
    );
  }

  Widget _buildSystemStatus(bool isDark) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
      decoration: BoxDecoration(
        color: isDark ? Colors.white.withOpacity(0.05) : Colors.black.withOpacity(0.05),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: isDark ? Colors.white.withOpacity(0.1) : Colors.black.withOpacity(0.05)),
      ),
      child: Row(
        children: [
          Container(
            width: 8, height: 8,
            decoration: const BoxDecoration(color: Color(0xFF10B981), shape: BoxShape.circle),
          ),
          const SizedBox(width: 12),
          const Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('NEURAL ENGINE ACTIVE', style: TextStyle(fontSize: 10, fontWeight: FontWeight.w900, letterSpacing: 1)),
                Text('EfficientNetB0 Multi-Head [21+5] Loaded', style: TextStyle(fontSize: 11, color: Colors.grey)),
              ],
            ),
          ),
          Icon(Icons.bolt, color: Colors.amber.withOpacity(0.8), size: 16),
        ],
      ),
    );
  }

  Widget _buildScannerZone(BuildContext context, ClassifierProvider provider, bool isDark) {
    final primary = Theme.of(context).colorScheme.primary;

    return Center(
      child: Stack(
        alignment: Alignment.center,
        children: [
          AnimatedBuilder(
            animation: _pulseAnim,
            builder: (context, child) {
              return Container(
                width: double.infinity,
                height: 320,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(32),
                  border: Border.all(
                    color: provider.image != null ? primary.withOpacity(0.3) : primary.withOpacity(0.1 + _pulseAnim.value * 0.2),
                    width: 2,
                  ),
                ),
                child: child,
              );
            },
            child: ClipRRect(
              borderRadius: BorderRadius.circular(30),
              child: provider.image == null
                  ? _buildEmptyScanner(isDark)
                  : Hero(tag: 'fabric_image', child: Image.file(provider.image!, fit: BoxFit.cover)),
            ),
          ),
          // Viewfinder Corners
          Positioned(top: 20, left: 20, child: _ScannerCorner(angle: 0, color: primary)),
          Positioned(top: 20, right: 20, child: _ScannerCorner(angle: 90, color: primary)),
          Positioned(bottom: 20, left: 20, child: _ScannerCorner(angle: 270, color: primary)),
          Positioned(bottom: 20, right: 20, child: _ScannerCorner(angle: 180, color: primary)),
          
          if (provider.image != null)
            Positioned(
              top: 20, right: 20,
              child: IconButton(
                icon: const CircleAvatar(backgroundColor: Colors.black54, child: Icon(Icons.close, color: Colors.white, size: 16)),
                onPressed: () => provider.clearCurrentScan(),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildEmptyScanner(bool isDark) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Icon(Icons.filter_center_focus, size: 64, color: isDark ? Colors.white24 : Colors.black12),
        const SizedBox(height: 16),
        Text('POINT & CAPTURE', style: TextStyle(fontSize: 14, fontWeight: FontWeight.w900, color: isDark ? Colors.white38 : Colors.black26)),
      ],
    );
  }

  Widget _buildInputButtons(BuildContext context, ClassifierProvider provider) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Row(
      children: [
        Expanded(
          child: _ActionCard(
            icon: Icons.camera_alt, label: 'Capture', 
            color: const Color(0xFF6366F1), isDark: isDark,
            onTap: () => provider.pickImage(ImageSource.camera),
          ),
        ),
        const SizedBox(width: 16),
        Expanded(
          child: _ActionCard(
            icon: Icons.photo_library, label: 'Import', 
            color: const Color(0xFF06B6D4), isDark: isDark,
            onTap: () => provider.pickImage(ImageSource.gallery),
          ),
        ),
      ],
    );
  }

  Widget _buildAnalyzeButton(BuildContext context, ClassifierProvider provider, bool canAnalyze) {
    return SizedBox(
      width: double.infinity,
      height: 64,
      child: ElevatedButton(
        onPressed: canAnalyze ? () async {
          HapticFeedback.heavyImpact();
          await provider.classifyImage();
          if (context.mounted && provider.result != null) {
            Navigator.push(context, MaterialPageRoute(builder: (_) => ResultsScreen(
              result: provider.result!, imagePath: provider.image!.path, modelName: 'Multi-Head v1.0',
            )));
          }
        } : null,
        style: ElevatedButton.styleFrom(
          backgroundColor: const Color(0xFF6366F1),
          foregroundColor: Colors.white,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
          elevation: canAnalyze ? 8 : 0,
          shadowColor: const Color(0xFF6366F1).withOpacity(0.5),
        ),
        child: provider.isLoading 
          ? const CircularProgressIndicator(color: Colors.white)
          : const Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.analytics_outlined),
                const SizedBox(width: 12),
                Text('EXECUTE CLASSIFICATION', style: TextStyle(fontWeight: FontWeight.w900, letterSpacing: 1)),
              ],
            ),
      ),
    );
  }

  Widget _buildProTips(bool isDark) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text('RESEARCH GUIDELINES', style: TextStyle(fontSize: 11, fontWeight: FontWeight.w900, letterSpacing: 1.2, color: Colors.grey)),
        const SizedBox(height: 12),
        _TipItem(icon: Icons.light_mode_outlined, text: 'Ensure neutral, bright lighting for color accuracy.', isDark: isDark),
        _TipItem(icon: Icons.zoom_in, text: 'Capture fabric texture from 10-15cm distance.', isDark: isDark),
      ],
    );
  }
}

class _ScannerCorner extends StatelessWidget {
  final double angle;
  final Color color;
  const _ScannerCorner({required this.angle, required this.color});

  @override
  Widget build(BuildContext context) {
    return Transform.rotate(
      angle: angle * 3.14159 / 180,
      child: Container(
        width: 30, height: 30,
        decoration: BoxDecoration(
          border: Border(
            top: BorderSide(color: color, width: 4),
            left: BorderSide(color: color, width: 4),
          ),
        ),
      ),
    );
  }
}

class _ActionCard extends StatelessWidget {
  final IconData icon;
  final String label;
  final Color color;
  final bool isDark;
  final VoidCallback onTap;

  const _ActionCard({required this.icon, required this.label, required this.color, required this.isDark, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(20),
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 20),
        decoration: BoxDecoration(
          color: color.withOpacity(0.1),
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: color.withOpacity(0.2)),
        ),
        child: Column(
          children: [
            Icon(icon, color: color, size: 28),
            const SizedBox(height: 8),
            Text(label, style: TextStyle(fontWeight: FontWeight.w900, fontSize: 14, color: isDark ? Colors.white : Colors.black87)),
          ],
        ),
      ),
    );
  }
}

class _TipItem extends StatelessWidget {
  final IconData icon;
  final String text;
  final bool isDark;
  const _TipItem({required this.icon, required this.text, required this.isDark});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        children: [
          Icon(icon, size: 16, color: Colors.grey),
          const SizedBox(width: 12),
          Expanded(child: Text(text, style: TextStyle(fontSize: 12, color: isDark ? Colors.white38 : Colors.black45))),
        ],
      ),
    );
  }
}
