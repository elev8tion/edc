/// Disclaimer Screen
/// Shown on first launch to inform users of app limitations
///
/// Must be acknowledged before using the app

import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:auto_size_text/auto_size_text.dart';
import '../utils/responsive_utils.dart';
import '../theme/app_theme.dart';

class DisclaimerScreen extends StatefulWidget {
  const DisclaimerScreen({Key? key}) : super(key: key);

  @override
  State<DisclaimerScreen> createState() => _DisclaimerScreenState();
}

class _DisclaimerScreenState extends State<DisclaimerScreen> {
  bool _agreedToTerms = false;
  static const String _disclaimerAgreedKey = 'disclaimer_agreed';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey.shade50,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header
              const SizedBox(height: 40),
              Center(
                child: Icon(
                  Icons.warning_amber_rounded,
                  size: ResponsiveUtils.iconSize(context, 64),
                  color: Colors.orange.shade700,
                ),
              ),
              const SizedBox(height: 24),
              Text(
                'Important Disclaimer',
                style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                      color: Colors.grey.shade900,
                    ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 8),
              Text(
                'Please read carefully before using this app',
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      color: Colors.grey.shade600,
                    ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 40),

              // Disclaimer content
              _buildDisclaimerSection(
                icon: Icons.psychology_outlined,
                title: 'Not Professional Counseling',
                content:
                    'This app provides pastoral guidance and biblical encouragement. It is NOT a substitute for professional mental health counseling, medical advice, or emergency services.',
              ),
              const SizedBox(height: 24),
              _buildDisclaimerSection(
                icon: Icons.emergency,
                title: 'Crisis Resources',
                content:
                    'If you are experiencing a mental health crisis:\n\n'
                    '• Call 988 (Suicide & Crisis Lifeline)\n'
                    '• Text HOME to 741741 (Crisis Text Line)\n'
                    '• Call 911 for immediate danger\n'
                    '• Go to your nearest emergency room',
              ),
              const SizedBox(height: 24),
              _buildDisclaimerSection(
                icon: Icons.medical_services_outlined,
                title: 'Medical & Legal Advice',
                content:
                    'This app does NOT provide medical diagnoses or legal advice. For medical concerns, see a licensed doctor. For legal issues, consult an attorney.',
              ),
              const SizedBox(height: 24),
              _buildDisclaimerSection(
                icon: Icons.smart_toy_outlined,
                title: 'AI Limitations',
                content:
                    'This app uses artificial intelligence, which can make mistakes. Responses may not always be accurate or appropriate. Use discernment and seek human guidance when needed.',
              ),
              const SizedBox(height: 24),
              _buildDisclaimerSection(
                icon: Icons.people_outline,
                title: 'Recommended Use',
                content:
                    'We encourage you to:\n\n'
                    '• Engage with a local church community\n'
                    '• Speak with a pastor or spiritual advisor\n'
                    '• Seek professional therapy when appropriate\n'
                    '• Use this app as a supplement, not replacement',
              ),
              const SizedBox(height: 40),

              // Agreement checkbox
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.blue.shade50,
                  borderRadius: AppRadius.mediumRadius,
                  border: Border.all(
                    color: _agreedToTerms ? Colors.blue.shade400 : Colors.grey.shade300,
                    width: 2,
                  ),
                ),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Checkbox(
                      value: _agreedToTerms,
                      onChanged: (value) {
                        setState(() => _agreedToTerms = value ?? false);
                      },
                      activeColor: Colors.blue.shade700,
                    ),
                    Expanded(
                      child: Padding(
                        padding: const EdgeInsets.only(top: 12, left: 8),
                        child: Text(
                          'I understand and acknowledge that this app provides pastoral guidance only and is not a substitute for professional counseling, medical advice, or emergency services.',
                          style: TextStyle(
                            fontSize: ResponsiveUtils.fontSize(context, 14, minSize: 12, maxSize: 16),
                            color: Colors.grey.shade800,
                            height: 1.5,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 24),

              // Continue button
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: _agreedToTerms ? _onContinue : null,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.blue.shade700,
                    disabledBackgroundColor: Colors.grey.shade300,
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(
                      borderRadius: AppRadius.mediumRadius,
                    ),
                  ),
                  child: const Text(
                    'Continue to App',
                    style: TextStyle(
                      fontSize: ResponsiveUtils.fontSize(context, 16, minSize: 14, maxSize: 18),
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 40),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildDisclaimerSection({
    required IconData icon,
    required String title,
    required String content,
  }) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: AppRadius.mediumRadius,
        boxShadow: [
          BoxShadow(
            color: Colors.grey.shade200,
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, color: Colors.blue.shade700, size: ResponsiveUtils.iconSize(context, 24)),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  title,
                  style: TextStyle(
                    fontSize: ResponsiveUtils.fontSize(context, 16, minSize: 14, maxSize: 18),
                    fontWeight: FontWeight.bold,
                    color: Colors.grey.shade900,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Text(
            content,
            style: TextStyle(
              fontSize: ResponsiveUtils.fontSize(context, 14, minSize: 12, maxSize: 16),
              color: Colors.grey.shade700,
              height: 1.5,
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _onContinue() async {
    // Save agreement to preferences
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_disclaimerAgreedKey, true);

    if (mounted) {
      // Navigate to home screen
      Navigator.of(context).pushReplacementNamed('/home');
    }
  }

  /// Check if user has already agreed to disclaimer
  static Future<bool> hasAgreedToDisclaimer() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getBool(_disclaimerAgreedKey) ?? false;
  }

  /// Show disclaimer if not yet agreed
  static Future<void> showIfNeeded(BuildContext context) async {
    final hasAgreed = await hasAgreedToDisclaimer();
    if (!hasAgreed && context.mounted) {
      Navigator.of(context).pushReplacement(
        MaterialPageRoute(
          builder: (_) => const DisclaimerScreen(),
        ),
      );
    }
  }
}
