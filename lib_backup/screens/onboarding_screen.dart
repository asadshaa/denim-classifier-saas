import 'package:flutter/material.dart';
import 'package:lottie/lottie.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'home_screen.dart';

class OnboardingScreen extends StatefulWidget {
  const OnboardingScreen({super.key});

  @override
  State<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends State<OnboardingScreen> {
  final PageController _controller = PageController();
  bool _isLastPage = false;

  final List<OnboardingPage> _pages = [
    OnboardingPage(
      animation: 'assets/animations/Welcome.json',
      title: 'Welcome to Denim AI',
      description: 'Identify denim fabrics with state-of-the-art AI.',
    ),
    OnboardingPage(
      animation: 'assets/animations/search.json',
      title: 'Analyze Texture',
      description: 'Scan fabric patterns and textures instantly.',
    ),
    OnboardingPage(
      animation: 'assets/animations/search.json', // Duplicate as per request "search.json, search.json"
      title: 'Precise Classification',
      description: 'Get detailed insights into fabric composition.',
    ),
    OnboardingPage(
      animation: 'assets/animations/Rocket Launch.json',
      title: 'Ready to Launch',
      description: 'Start classifying your denim collection now.',
    ),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          PageView.builder(
            controller: _controller,
            itemCount: _pages.length,
            onPageChanged: (index) {
              setState(() {
                _isLastPage = index == _pages.length - 1;
              });
            },
            itemBuilder: (context, index) {
              return _buildPage(_pages[index]);
            },
          ),
          Positioned(
            bottom: 50,
            left: 20,
            right: 20,
            child: _isLastPage
                ? ElevatedButton(
                    onPressed: _completeOnboarding,
                    style: ElevatedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(30),
                      ),
                    ),
                    child: const Text('Get Started', style: TextStyle(fontSize: 18)),
                  )
                : Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      TextButton(
                        onPressed: _completeOnboarding,
                        child: const Text('SKIP', style: TextStyle(color: Colors.grey)),
                      ),
                      SmoothPageIndicator(
                        controller: _controller,
                        count: _pages.length,
                      ),
                      IconButton(
                        onPressed: () {
                          _controller.nextPage(
                            duration: const Duration(milliseconds: 300),
                            curve: Curves.easeInOut,
                          );
                        },
                        icon: const Icon(Icons.arrow_forward),
                      ),
                    ],
                  ),
          ),
        ],
      ),
    );
  }

  Widget _buildPage(OnboardingPage page) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Lottie.asset(
          page.animation,
          height: 300,
          fit: BoxFit.contain,
          errorBuilder: (context, error, stackTrace) {
            return const Icon(Icons.error, size: 100, color: Colors.red);
          },
        ),
        const SizedBox(height: 30),
        Text(
          page.title,
          style: const TextStyle(fontSize: 28, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 15),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 40),
          child: Text(
            page.description,
            textAlign: TextAlign.center,
            style: const TextStyle(fontSize: 16, color: Colors.grey),
          ),
        ),
      ],
    );
  }

  Future<void> _completeOnboarding() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('seenOnboarding', true);

    if (!mounted) return;
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (context) => const HomeScreen()),
    );
  }
}

class OnboardingPage {
  final String animation;
  final String title;
  final String description;

  OnboardingPage({required this.animation, required this.title, required this.description});
}

// Minimal Page Indicator implementation since external package wasn't strictly requested in pubspec tasks
// but usually 'smooth_page_indicator' is good. I will implement a simple custom one to avoid adding deps 
// if user didn't ask, or I'll just use dots.
class SmoothPageIndicator extends StatelessWidget {
  final PageController controller;
  final int count;

  const SmoothPageIndicator({super.key, required this.controller, required this.count});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 10,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        shrinkWrap: true,
        itemCount: count,
        itemBuilder: (context, index) {
          return AnimatedBuilder(
            animation: controller,
            builder: (context, child) {
              double selectedness = 0.0;
              if (controller.hasClients && controller.position.hasContentDimensions) {
                 double page = controller.page ?? 0.0;
                 selectedness = 1.0 - (page - index).abs().clamp(0.0, 1.0);
              } else {
                 selectedness = index == 0 ? 1.0 : 0.0;
              }
              
              return Container(
                margin: const EdgeInsets.symmetric(horizontal: 4),
                width: 10 + (10 * selectedness),
                height: 10,
                decoration: BoxDecoration(
                  color: Color.lerp(Colors.grey.shade300, Colors.blue, selectedness),
                  borderRadius: BorderRadius.circular(5),
                ),
              );
            },
          );
        },
      ),
    );
  }
}
