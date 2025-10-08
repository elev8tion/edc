/// Crisis Dialog Widget
/// Non-dismissible dialog shown when crisis is detected
/// Provides immediate access to crisis resources and hotlines

import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import '../services/crisis_detection_service.dart';

/// Non-dismissible crisis intervention dialog
class CrisisDialog extends StatelessWidget {
  final CrisisDetectionResult crisisResult;
  final VoidCallback onAcknowledge;

  const CrisisDialog({
    Key? key,
    required this.crisisResult,
    required this.onAcknowledge,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      // Prevent dismissing by back button
      onWillPop: () async => false,
      child: AlertDialog(
        backgroundColor: Colors.red.shade50,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
          side: BorderSide(color: Colors.red.shade400, width: 2),
        ),
        title: Row(
          children: [
            Icon(Icons.warning_rounded, color: Colors.red.shade700, size: 32),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                'Crisis Resources',
                style: TextStyle(
                  color: Colors.red.shade900,
                  fontWeight: FontWeight.bold,
                  fontSize: 20,
                ),
              ),
            ),
          ],
        ),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Crisis message
              Text(
                crisisResult.getMessage(),
                style: TextStyle(
                  fontSize: 16,
                  height: 1.5,
                  color: Colors.grey.shade900,
                ),
              ),
              const SizedBox(height: 24),

              // Hotline button
              _buildHotlineButton(context),

              const SizedBox(height: 16),

              // Additional resources
              _buildAdditionalResources(),

              const SizedBox(height: 24),

              // Important notice
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.orange.shade50,
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: Colors.orange.shade300),
                ),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Icon(Icons.info_outline, color: Colors.orange.shade700, size: 20),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        'If you are in immediate danger, call 911 or go to your nearest emergency room.',
                        style: TextStyle(
                          fontSize: 14,
                          color: Colors.orange.shade900,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
        actions: [
          // Acknowledge button (only way to dismiss)
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: () {
                Navigator.of(context).pop();
                onAcknowledge();
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.grey.shade700,
                padding: const EdgeInsets.symmetric(vertical: 16),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
              child: const Text(
                'I understand and have noted these resources',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  /// Build primary hotline call button
  Widget _buildHotlineButton(BuildContext context) {
    final hotline = crisisResult.getHotline();
    final isPhoneNumber = hotline.startsWith('988') || hotline.startsWith('800');

    return SizedBox(
      width: double.infinity,
      child: ElevatedButton.icon(
        onPressed: () => _callHotline(context, hotline),
        icon: Icon(isPhoneNumber ? Icons.phone : Icons.message, size: 24),
        label: Text(
          isPhoneNumber ? 'Call $hotline Now' : hotline,
          style: const TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
          ),
        ),
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.red.shade600,
          foregroundColor: Colors.white,
          padding: const EdgeInsets.symmetric(vertical: 16),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(8),
          ),
        ),
      ),
    );
  }

  /// Build additional crisis resources section
  Widget _buildAdditionalResources() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Additional Resources:',
          style: TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 14,
            color: Colors.grey.shade700,
          ),
        ),
        const SizedBox(height: 8),
        _buildResourceTile(
          icon: Icons.chat_bubble_outline,
          title: 'Crisis Text Line',
          subtitle: 'Text HOME to 741741',
          onTap: () => _launchSMS('741741', 'HOME'),
        ),
        if (crisisResult.type == CrisisType.suicide) ...[
          _buildResourceTile(
            icon: Icons.language,
            title: '988 Lifeline Website',
            subtitle: 'Chat online at 988lifeline.org',
            onTap: () => _launchURL('https://988lifeline.org'),
          ),
        ],
        if (crisisResult.type == CrisisType.abuse) ...[
          _buildResourceTile(
            icon: Icons.language,
            title: 'RAINN Online Chat',
            subtitle: 'rainn.org/get-help',
            onTap: () => _launchURL('https://www.rainn.org/get-help'),
          ),
        ],
      ],
    );
  }

  /// Build a resource list tile
  Widget _buildResourceTile({
    required IconData icon,
    required String title,
    required String subtitle,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(8),
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 4),
        child: Row(
          children: [
            Icon(icon, size: 20, color: Colors.blue.shade700),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: TextStyle(
                      fontWeight: FontWeight.w600,
                      fontSize: 14,
                      color: Colors.grey.shade900,
                    ),
                  ),
                  Text(
                    subtitle,
                    style: TextStyle(
                      fontSize: 12,
                      color: Colors.grey.shade600,
                    ),
                  ),
                ],
              ),
            ),
            Icon(Icons.arrow_forward_ios, size: 16, color: Colors.grey.shade400),
          ],
        ),
      ),
    );
  }

  /// Call crisis hotline
  Future<void> _callHotline(BuildContext context, String hotline) async {
    String number;

    if (hotline == '988') {
      number = 'tel:988';
    } else if (hotline.startsWith('800')) {
      number = 'tel:$hotline';
    } else if (hotline.contains('741741')) {
      await _launchSMS('741741', 'HOME');
      return;
    } else {
      return;
    }

    final uri = Uri.parse(number);

    try {
      if (await canLaunchUrl(uri)) {
        await launchUrl(uri);
      } else {
        if (context.mounted) {
          _showErrorSnackbar(context, 'Unable to make call. Please dial $hotline manually.');
        }
      }
    } catch (e) {
      if (context.mounted) {
        _showErrorSnackbar(context, 'Error: ${e.toString()}');
      }
    }
  }

  /// Launch SMS to crisis text line
  Future<void> _launchSMS(String number, String body) async {
    final uri = Uri.parse('sms:$number?body=$body');

    try {
      if (await canLaunchUrl(uri)) {
        await launchUrl(uri);
      }
    } catch (e) {
      // Silently fail - user can manually text
    }
  }

  /// Launch URL
  Future<void> _launchURL(String url) async {
    final uri = Uri.parse(url);

    try {
      if (await canLaunchUrl(uri)) {
        await launchUrl(uri, mode: LaunchMode.externalApplication);
      }
    } catch (e) {
      // Silently fail
    }
  }

  /// Show error snackbar
  void _showErrorSnackbar(BuildContext context, String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.red.shade700,
      ),
    );
  }

  /// Show crisis dialog
  static Future<void> show(
    BuildContext context, {
    required CrisisDetectionResult crisisResult,
    required VoidCallback onAcknowledge,
  }) {
    return showDialog(
      context: context,
      barrierDismissible: false, // Cannot dismiss by tapping outside
      builder: (context) => CrisisDialog(
        crisisResult: crisisResult,
        onAcknowledge: onAcknowledge,
      ),
    );
  }
}
