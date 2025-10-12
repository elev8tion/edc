import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:auto_size_text/auto_size_text.dart';
import '../services/smart_model_manager.dart';
import '../services/hybrid_ai_service.dart';
import '../utils/responsive_utils.dart';

/// Smart onboarding that downloads AI model in background
class SmartOnboardingScreen extends ConsumerStatefulWidget {
  const SmartOnboardingScreen({super.key});

  @override
  ConsumerState<SmartOnboardingScreen> createState() => _SmartOnboardingScreenState();
}

class _SmartOnboardingScreenState extends ConsumerState<SmartOnboardingScreen> {
  final PageController _pageController = PageController();
  int _currentPage = 0;
  ModelStatus? _modelStatus;
  bool _downloadStarted = false;

  // Onboarding content (extends time for download)
  final List<OnboardingPage> pages = [
    OnboardingPage(
      title: 'Welcome to Everyday Christian',
      subtitle: 'Your personal guide to biblical wisdom',
      icon: Icons.book,
      description: 'Experience God\'s word in a new way with AI-powered pastoral guidance tailored just for you.',
      duration: const Duration(seconds: 8), // Extra time for reading
    ),
    OnboardingPage(
      title: 'Private & Secure',
      subtitle: 'Your conversations stay on your device',
      icon: Icons.lock,
      description: 'All AI processing happens locally on your phone. Your spiritual journey remains completely private.',
      duration: const Duration(seconds: 8),
    ),
    OnboardingPage(
      title: 'Biblical Wisdom',
      subtitle: 'Grounded in Scripture',
      icon: Icons.menu_book,
      description: 'Every response is rooted in biblical truth, with relevant verses and pastoral insights.',
      duration: const Duration(seconds: 8),
    ),
    OnboardingPage(
      title: 'Available Offline',
      subtitle: 'God\'s word, anywhere',
      icon: Icons.offline_bolt,
      description: 'Once set up, access guidance even without internet. Perfect for retreats, travel, or quiet moments.',
      duration: const Duration(seconds: 8),
    ),
    OnboardingPage(
      title: 'Personalized for You',
      subtitle: 'Understanding your journey',
      icon: Icons.person,
      description: 'The AI learns your spiritual themes and provides relevant guidance for your specific needs.',
      duration: const Duration(seconds: 8),
    ),
  ];

  @override
  void initState() {
    super.initState();
    _startSmartSetup();
  }

  Future<void> _startSmartSetup() async {
    // Start model download immediately
    if (!_downloadStarted) {
      _downloadStarted = true;
      final modelManager = SmartModelManager.instance;

      // Initialize (starts download automatically)
      await modelManager.initialize();

      // Listen for status updates
      modelManager.statusStream.listen((status) {
        if (mounted) {
          setState(() {
            _modelStatus = status;
          });

          // Auto-advance if still on early pages and download completes
          if (status.state == ModelState.ready && _currentPage < 3) {
            // Speed up remaining pages
            _skipToEnd();
          }
        }
      });
    }

    // Auto-advance pages slowly (gives time for download)
    _startAutoAdvance();
  }

  void _startAutoAdvance() {
    if (_currentPage < pages.length - 1) {
      Future.delayed(pages[_currentPage].duration, () {
        if (mounted && _currentPage < pages.length - 1) {
          _pageController.nextPage(
            duration: const Duration(milliseconds: 500),
            curve: Curves.easeInOut,
          );
          _startAutoAdvance(); // Continue auto-advance
        }
      });
    }
  }

  void _skipToEnd() {
    _pageController.animateToPage(
      pages.length - 1,
      duration: const Duration(milliseconds: 500),
      curve: Curves.easeInOut,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          // Onboarding pages
          PageView.builder(
            controller: _pageController,
            onPageChanged: (index) {
              setState(() {
                _currentPage = index;
              });
            },
            itemCount: pages.length,
            itemBuilder: (context, index) {
              return _buildPage(pages[index]);
            },
          ),

          // Progress indicators
          Positioned(
            bottom: 100,
            left: 0,
            right: 0,
            child: Column(
              children: [
                // Model download status (subtle)
                if (_modelStatus != null) _buildModelStatus(),

                const SizedBox(height: 20),

                // Page dots
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: List.generate(
                    pages.length,
                    (index) => Container(
                      margin: const EdgeInsets.symmetric(horizontal: 4),
                      width: index == _currentPage ? 24 : 8,
                      height: 8,
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(4),
                        color: index == _currentPage
                            ? Theme.of(context).primaryColor
                            : Colors.grey.withOpacity(0.3),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),

          // Continue button
          Positioned(
            bottom: 40,
            left: 20,
            right: 20,
            child: ElevatedButton(
              onPressed: _canContinue() ? _onContinue : null,
              style: ElevatedButton.styleFrom(
                padding: const EdgeInsets.symmetric(vertical: 16),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              child: Text(
                _getButtonText(),
                style: TextStyle(fontSize: ResponsiveUtils.fontSize(context, 18, minSize: 16, maxSize: 20)),
              ),
            ),
          ),

          // Skip button (if download is taking too long)
          if (_currentPage > 2 &&
              _modelStatus?.state == ModelState.downloading)
            Positioned(
              top: 50,
              right: 20,
              child: TextButton(
                onPressed: _onSkipDownload,
                child: const Text('Skip download'),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildPage(OnboardingPage page) {
    return Padding(
      padding: const EdgeInsets.all(40),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            page.icon,
            size: ResponsiveUtils.iconSize(context, 100),
            color: Theme.of(context).primaryColor,
          ),
          const SizedBox(height: 40),
          Text(
            page.title,
            style: TextStyle(
              fontSize: ResponsiveUtils.fontSize(context, 28, minSize: 24, maxSize: 32),
              fontWeight: FontWeight.bold,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 16),
          Text(
            page.subtitle,
            style: TextStyle(
              fontSize: ResponsiveUtils.fontSize(context, 18, minSize: 16, maxSize: 20),
              color: Colors.grey[600],
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 24),
          Text(
            page.description,
            style: TextStyle(
              fontSize: ResponsiveUtils.fontSize(context, 16, minSize: 14, maxSize: 18),
              color: Colors.grey[700],
              height: 1.5,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildModelStatus() {
    if (_modelStatus == null) return const SizedBox.shrink();

    String statusText = '';
    Color statusColor = Colors.grey;
    bool showProgress = false;

    switch (_modelStatus!.state) {
      case ModelState.checking:
        statusText = 'Preparing AI assistant...';
        statusColor = Colors.blue;
        break;
      case ModelState.downloading:
        statusText = _modelStatus!.message ?? 'Downloading AI model...';
        statusColor = Colors.orange;
        showProgress = true;
        break;
      case ModelState.ready:
        statusText = '✓ AI assistant ready';
        statusColor = Colors.green;
        break;
      case ModelState.error:
        statusText = 'AI will download when connected';
        statusColor = Colors.grey;
        break;
    }

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 40),
      child: Column(
        children: [
          Text(
            statusText,
            style: TextStyle(
              color: statusColor,
              fontSize: ResponsiveUtils.fontSize(context, 14, minSize: 12, maxSize: 16),
            ),
          ),
          if (showProgress && _modelStatus!.progress != null) ...[
            const SizedBox(height: 8),
            LinearProgressIndicator(
              value: _modelStatus!.progress,
              backgroundColor: Colors.grey[300],
              valueColor: AlwaysStoppedAnimation<Color>(statusColor),
            ),
          ],
        ],
      ),
    );
  }

  bool _canContinue() {
    // Can continue on last page OR if model is ready
    return _currentPage == pages.length - 1 ||
           _modelStatus?.state == ModelState.ready;
  }

  String _getButtonText() {
    if (_currentPage < pages.length - 1) {
      return 'Next';
    }
    if (_modelStatus?.state == ModelState.ready) {
      return 'Get Started';
    }
    if (_modelStatus?.state == ModelState.downloading) {
      return 'Continue (Download in background)';
    }
    return 'Get Started';
  }

  void _onContinue() {
    if (_currentPage < pages.length - 1) {
      _pageController.nextPage(
        duration: const Duration(milliseconds: 500),
        curve: Curves.easeInOut,
      );
    } else {
      // Complete onboarding
      Navigator.of(context).pushReplacementNamed('/home');
    }
  }

  void _onSkipDownload() {
    // Continue without waiting for download
    // The app will use templates until model is ready
    _skipToEnd();
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }
}

class OnboardingPage {
  final String title;
  final String subtitle;
  final IconData icon;
  final String description;
  final Duration duration;

  const OnboardingPage({
    required this.title,
    required this.subtitle,
    required this.icon,
    required this.description,
    required this.duration,
  });
}