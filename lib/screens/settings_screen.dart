import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../theme/app_theme.dart';
import '../components/gradient_background.dart';
import '../components/frosted_glass_card.dart';
import '../components/blur_dropdown.dart';
import '../core/navigation/navigation_service.dart';
import '../core/providers/app_providers.dart';
import '../utils/responsive_utils.dart';

class SettingsScreen extends ConsumerStatefulWidget {
  const SettingsScreen({super.key});

  @override
  ConsumerState<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends ConsumerState<SettingsScreen> {
  // Local state for non-persisted settings
  bool _offlineMode = false;
  String _selectedBibleVersion = 'KJV';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          const GradientBackground(),
          SafeArea(
            child: Column(
              children: [
                _buildAppBar(),
                Expanded(
                  child: _buildSettingsContent(),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAppBar() {
    return Container(
      padding: AppSpacing.screenPadding,
      child: Row(
        children: [
          Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  Colors.white.withValues(alpha: 0.2),
                  Colors.white.withValues(alpha: 0.1),
                ],
              ),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: Colors.white.withValues(alpha: 0.2),
                width: 1,
              ),
            ),
            child: IconButton(
              icon: const Icon(Icons.arrow_back, color: Colors.white),
              onPressed: () => NavigationService.pop(),
            ),
          ),
          const SizedBox(width: AppSpacing.lg),
          Expanded(
            child: Text(
              'Settings',
              style: TextStyle(
                fontSize: ResponsiveUtils.fontSize(context, 24, minSize: 20, maxSize: 28),
                fontWeight: FontWeight.w700,
                color: AppColors.primaryText,
                shadows: [
                  Shadow(
                    color: Colors.black26,
                    offset: Offset(0, 2),
                    blurRadius: 4,
                  ),
                ],
              ),
            ),
          ),
          Container(
            padding: const EdgeInsets.all(AppSpacing.sm),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  AppTheme.goldColor.withValues(alpha: 0.3),
                  AppTheme.goldColor.withValues(alpha: 0.1),
                ],
              ),
              borderRadius: BorderRadius.circular(10),
              border: Border.all(
                color: AppTheme.goldColor.withValues(alpha: 0.4),
                width: 1,
              ),
            ),
            child: Icon(
              Icons.settings,
              color: AppColors.primaryText,
              size: ResponsiveUtils.iconSize(context, 20),
            ),
          ),
        ],
      ),
    ).animate().fadeIn(duration: AppAnimations.slow).slideY(begin: -0.3);
  }

  Widget _buildSettingsContent() {
    return SingleChildScrollView(
      padding: AppSpacing.horizontalXl,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildSettingsSection(
            'Notifications',
            Icons.notifications,
            [
              _buildSwitchTile(
                'Daily Devotional',
                'Receive daily devotional reminders',
                ref.watch(dailyNotificationsProvider),
                (value) => ref.read(dailyNotificationsProvider.notifier).toggle(value),
              ),
              _buildSwitchTile(
                'Prayer Reminders',
                'Get reminded to pray throughout the day',
                ref.watch(prayerRemindersProvider),
                (value) => ref.read(prayerRemindersProvider.notifier).toggle(value),
              ),
              _buildSwitchTile(
                'Verse of the Day',
                'Daily Bible verse notifications',
                ref.watch(verseOfTheDayProvider),
                (value) => ref.read(verseOfTheDayProvider.notifier).toggle(value),
              ),
              _buildTimePicker(
                'Notification Time',
                'Set your preferred time for daily notifications',
                ref.watch(notificationTimeProvider),
                (time) => ref.read(notificationTimeProvider.notifier).setTime(time),
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.xxl),
          _buildSettingsSection(
            'Bible Settings',
            Icons.menu_book,
            [
              _buildDropdownTile(
                'Bible Version',
                'Choose your preferred translation',
                _selectedBibleVersion,
                ['KJV', 'WEB'],
                (value) => setState(() => _selectedBibleVersion = value!),
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.xxl),
          _buildSettingsSection(
            'Appearance',
            Icons.palette,
            [
              _buildDropdownTile(
                'Theme',
                'Choose your app theme',
                ref.watch(themeModeProvider) == ThemeMode.dark ? 'Dark' : 'Light',
                ['Dark', 'Light'],
                (value) {
                  final mode = value == 'Dark' ? ThemeMode.dark : ThemeMode.light;
                  ref.read(themeModeProvider.notifier).setTheme(mode);
                },
              ),
              _buildDropdownTile(
                'Language',
                'Choose your preferred language',
                ref.watch(languageProvider),
                ['English', 'Spanish'],
                (value) => ref.read(languageProvider.notifier).setLanguage(value!),
              ),
              _buildSliderTile(
                'Text Size',
                'Adjust reading text size for better readability',
                ref.watch(textSizeProvider),
                12.0,
                24.0,
                (value) => ref.read(textSizeProvider.notifier).setTextSize(value),
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.xxl),
          _buildSettingsSection(
            'Data & Privacy',
            Icons.security,
            [
              _buildSwitchTile(
                'Offline Mode',
                'Use app without internet connection',
                _offlineMode,
                (value) => setState(() => _offlineMode = value),
              ),
              _buildActionTile(
                'Clear Cache',
                'Free up storage space',
                Icons.delete_outline,
                () => _showClearCacheDialog(),
              ),
              _buildActionTile(
                'Export Data',
                'Backup your prayers and notes',
                Icons.download,
                () => _exportUserData(),
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.xxl),
          _buildSettingsSection(
            'Support',
            Icons.help,
            [
              _buildActionTile(
                'Help & FAQ',
                'Get answers to common questions',
                Icons.help_outline,
                () => _showHelpDialog(),
              ),
              _buildActionTile(
                'Contact Support',
                'Get help with technical issues',
                Icons.email,
                () => _contactSupport(),
              ),
              _buildActionTile(
                'Rate App',
                'Share your feedback on the App Store',
                Icons.star_outline,
                () => _rateApp(),
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.xxl),
          _buildSettingsSection(
            'About',
            Icons.info,
            [
              _buildInfoTile('Version', '1.0.0'),
              _buildInfoTile('Build', '2024.10.01'),
              _buildActionTile(
                'Privacy Policy',
                'Read our privacy policy',
                Icons.privacy_tip,
                () => _showPrivacyPolicy(),
              ),
              _buildActionTile(
                'Terms of Service',
                'Read terms and conditions',
                Icons.description,
                () => _showTermsOfService(),
              ),
            ],
          ),
          const SizedBox(height: 40),
        ],
      ),
    );
  }

  Widget _buildSettingsSection(String title, IconData icon, List<Widget> children) {
    return FrostedGlassCard(
      padding: AppSpacing.screenPadding,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(AppSpacing.sm),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [
                      AppTheme.primaryColor.withValues(alpha: 0.3),
                      AppTheme.primaryColor.withValues(alpha: 0.1),
                    ],
                  ),
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(
                    color: AppTheme.primaryColor.withValues(alpha: 0.3),
                    width: 1,
                  ),
                ),
                child: Icon(
                  icon,
                  color: AppColors.primaryText,
                  size: ResponsiveUtils.iconSize(context, 20),
                ),
              ),
              const SizedBox(width: AppSpacing.md),
              Text(
                title,
                style: TextStyle(
                  fontSize: ResponsiveUtils.fontSize(context, 18, minSize: 16, maxSize: 20),
                  fontWeight: FontWeight.w700,
                  color: AppColors.primaryText,
                  shadows: [
                    Shadow(
                      color: Colors.black26,
                      offset: Offset(0, 1),
                      blurRadius: 2,
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.lg),
          ...children,
        ],
      ),
    ).animate().fadeIn(duration: AppAnimations.slow).slideY(begin: 0.3);
  }

  Widget _buildSwitchTile(String title, String subtitle, bool value, Function(bool) onChanged) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: AppSpacing.cardPadding,
      decoration: BoxDecoration(
        color: Colors.black.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: Colors.white.withValues(alpha: 0.1),
          width: 1,
        ),
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: TextStyle(
                    fontSize: ResponsiveUtils.fontSize(context, 16, minSize: 14, maxSize: 18),
                    fontWeight: FontWeight.w600,
                    color: AppColors.primaryText,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  subtitle,
                  style: TextStyle(
                    fontSize: ResponsiveUtils.fontSize(context, 13, minSize: 11, maxSize: 15),
                    color: Colors.white.withValues(alpha: 0.7),
                  ),
                ),
              ],
            ),
          ),
          Switch(
            value: value,
            onChanged: onChanged,
            activeColor: AppTheme.primaryColor,
            activeTrackColor: AppTheme.toggleActiveColor.withValues(alpha: 0.5),
            inactiveThumbColor: Colors.white.withValues(alpha: 0.5),
            inactiveTrackColor: Colors.grey.withValues(alpha: 0.3),
            trackOutlineColor: WidgetStateProperty.resolveWith((states) {
              if (states.contains(WidgetState.selected)) {
                return AppTheme.toggleActiveColor;
              }
              return Colors.grey.withValues(alpha: 0.5);
            }),
            trackOutlineWidth: WidgetStateProperty.all(2.0),
          ),
        ],
      ),
    );
  }

  Widget _buildSliderTile(String title, String subtitle, double value, double min, double max, Function(double) onChanged) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: AppSpacing.cardPadding,
      decoration: BoxDecoration(
        color: Colors.black.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: Colors.white.withValues(alpha: 0.1),
          width: 1,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: TextStyle(
                        fontSize: ResponsiveUtils.fontSize(context, 16, minSize: 14, maxSize: 18),
                        fontWeight: FontWeight.w600,
                        color: AppColors.primaryText,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      subtitle,
                      style: TextStyle(
                        fontSize: ResponsiveUtils.fontSize(context, 13, minSize: 11, maxSize: 15),
                        color: Colors.white.withValues(alpha: 0.7),
                      ),
                    ),
                  ],
                ),
              ),
              Text(
                '${value.round()}px',
                style: TextStyle(
                  fontSize: ResponsiveUtils.fontSize(context, 14, minSize: 12, maxSize: 16),
                  fontWeight: FontWeight.w600,
                  color: Colors.black,
                ),
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.md),
          SliderTheme(
            data: SliderTheme.of(context).copyWith(
              activeTrackColor: Colors.white,
              inactiveTrackColor: Colors.white.withValues(alpha: 0.2),
              thumbColor: Colors.white,
              overlayColor: Colors.white.withValues(alpha: 0.2),
            ),
            child: Slider(
              value: value,
              min: min,
              max: max,
              divisions: ((max - min) / 2).round(),
              onChanged: onChanged,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDropdownTile(String title, String subtitle, String value, List<String> options, Function(String?) onChanged) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: AppSpacing.cardPadding,
      decoration: BoxDecoration(
        color: Colors.black.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: Colors.white.withValues(alpha: 0.1),
          width: 1,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: TextStyle(
              fontSize: ResponsiveUtils.fontSize(context, 16, minSize: 14, maxSize: 18),
              fontWeight: FontWeight.w600,
              color: AppColors.primaryText,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            subtitle,
            style: TextStyle(
              fontSize: ResponsiveUtils.fontSize(context, 13, minSize: 11, maxSize: 15),
              color: Colors.white.withValues(alpha: 0.7),
            ),
          ),
          const SizedBox(height: AppSpacing.md),
          SizedBox(
            height: 40,
            child: BlurDropdown(
              value: value,
              items: options,
              hint: 'Select $title',
              onChanged: onChanged,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTimePicker(String title, String subtitle, String value, Function(String) onChanged) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: () => _showTimePicker(value, onChanged),
          borderRadius: BorderRadius.circular(12),
          child: Container(
            padding: AppSpacing.cardPadding,
            decoration: BoxDecoration(
              color: Colors.black.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: Colors.white.withValues(alpha: 0.1),
                width: 1,
              ),
            ),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(AppSpacing.sm),
                  decoration: BoxDecoration(
                    color: Colors.white.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Icon(
                    Icons.access_time,
                    color: AppColors.primaryText,
                    size: ResponsiveUtils.iconSize(context, 20),
                  ),
                ),
                const SizedBox(width: AppSpacing.md),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        title,
                        style: TextStyle(
                          fontSize: ResponsiveUtils.fontSize(context, 16, minSize: 14, maxSize: 18),
                          fontWeight: FontWeight.w600,
                          color: AppColors.primaryText,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        subtitle,
                        style: TextStyle(
                          fontSize: ResponsiveUtils.fontSize(context, 13, minSize: 11, maxSize: 15),
                          color: Colors.white.withValues(alpha: 0.7),
                        ),
                      ),
                    ],
                  ),
                ),
                Text(
                  value,
                  style: TextStyle(
                    fontSize: ResponsiveUtils.fontSize(context, 16, minSize: 14, maxSize: 18),
                    fontWeight: FontWeight.w600,
                    color: AppTheme.primaryColor,
                  ),
                ),
                const SizedBox(width: AppSpacing.sm),
                Icon(
                  Icons.chevron_right,
                  color: AppColors.tertiaryText,
                  size: ResponsiveUtils.iconSize(context, 20),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Future<void> _showTimePicker(String currentTime, Function(String) onChanged) async {
    final parts = currentTime.split(':');
    final initialTime = TimeOfDay(
      hour: int.parse(parts[0]),
      minute: int.parse(parts[1]),
    );

    final TimeOfDay? picked = await showTimePicker(
      context: context,
      initialTime: initialTime,
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: const ColorScheme.dark(
              primary: AppTheme.primaryColor,
              onPrimary: Colors.white,
              surface: Color(0xFF1E1E1E),
              onSurface: Colors.white,
            ),
            dialogBackgroundColor: const Color(0xFF1E1E1E),
          ),
          child: child!,
        );
      },
    );

    if (picked != null) {
      final hour = picked.hour.toString().padLeft(2, '0');
      final minute = picked.minute.toString().padLeft(2, '0');
      onChanged('$hour:$minute');
    }
  }

  Widget _buildActionTile(String title, String subtitle, IconData icon, VoidCallback onTap) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(12),
          child: Container(
            padding: AppSpacing.cardPadding,
            decoration: BoxDecoration(
              color: Colors.black.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: Colors.white.withValues(alpha: 0.1),
                width: 1,
              ),
            ),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(AppSpacing.sm),
                  decoration: BoxDecoration(
                    color: Colors.white.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Icon(
                    icon,
                    color: AppColors.primaryText,
                    size: ResponsiveUtils.iconSize(context, 20),
                  ),
                ),
                const SizedBox(width: AppSpacing.md),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        title,
                        style: TextStyle(
                          fontSize: ResponsiveUtils.fontSize(context, 16, minSize: 14, maxSize: 18),
                          fontWeight: FontWeight.w600,
                          color: AppColors.primaryText,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        subtitle,
                        style: TextStyle(
                          fontSize: ResponsiveUtils.fontSize(context, 13, minSize: 11, maxSize: 15),
                          color: Colors.white.withValues(alpha: 0.7),
                        ),
                      ),
                    ],
                  ),
                ),
                Icon(
                  Icons.arrow_forward_ios,
                  color: Colors.white.withValues(alpha: 0.5),
                  size: 16,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildInfoTile(String title, String value) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: AppSpacing.cardPadding,
      decoration: BoxDecoration(
        color: Colors.black.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: Colors.white.withValues(alpha: 0.1),
          width: 1,
        ),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            title,
            style: TextStyle(
              fontSize: ResponsiveUtils.fontSize(context, 16, minSize: 14, maxSize: 18),
              fontWeight: FontWeight.w600,
              color: AppColors.primaryText,
            ),
          ),
          Text(
            value,
            style: TextStyle(
              fontSize: ResponsiveUtils.fontSize(context, 15, minSize: 13, maxSize: 17),
              color: AppColors.secondaryText,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }

  void _showClearCacheDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: const Color(0xFF2D3748),
        title: const Text('Clear Cache', style: TextStyle(color: Colors.white)),
        content: const Text(
          'This will free up storage space but may require re-downloading some content.',
          style: TextStyle(color: Colors.white70),
        ),
        actions: [
          TextButton(
            onPressed: () => NavigationService.pop(),
            child: Text('Cancel', style: TextStyle(color: Colors.white.withValues(alpha: 0.7))),
          ),
          TextButton(
            onPressed: () {
              NavigationService.pop();
              _showSnackBar('Cache cleared successfully');
            },
            child: Text('Clear', style: TextStyle(color: AppTheme.primaryColor)),
          ),
        ],
      ),
    );
  }

  void _exportUserData() {
    _showSnackBar('Data export started - you will be notified when complete');
  }

  void _showHelpDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: const Color(0xFF2D3748),
        title: const Text('Help & FAQ', style: TextStyle(color: Colors.white)),
        content: const Text(
          'For help and support, please visit our website or contact us through the app.',
          style: TextStyle(color: Colors.white70),
        ),
        actions: [
          TextButton(
            onPressed: () => NavigationService.pop(),
            child: Text('Close', style: TextStyle(color: AppTheme.primaryColor)),
          ),
        ],
      ),
    );
  }

  void _contactSupport() {
    _showSnackBar('Opening email client...');
  }

  void _rateApp() {
    _showSnackBar('Opening App Store...');
  }

  void _showPrivacyPolicy() {
    _showSnackBar('Opening privacy policy...');
  }

  void _showTermsOfService() {
    _showSnackBar('Opening terms of service...');
  }

  void _showSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: AppTheme.primaryColor,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(10),
        ),
      ),
    );
  }
}