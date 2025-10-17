import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:share_plus/share_plus.dart';
import 'package:auto_size_text/auto_size_text.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../theme/app_theme.dart';
import '../theme/app_gradients.dart';
import '../components/gradient_background.dart';
import '../components/frosted_glass_card.dart';
import '../components/blur_dropdown.dart';
import '../components/glassmorphic_fab_menu.dart';
import '../core/navigation/navigation_service.dart';
import '../core/providers/app_providers.dart';
import '../utils/responsive_utils.dart';
import '../widgets/time_picker/time_range_sheet.dart';
import '../widgets/time_picker/time_range_sheet_style.dart';
import '../widgets/time_picker/models/time_range_data.dart';
import '../components/glass_card.dart';
import 'subscription_settings_screen.dart';

class SettingsScreen extends ConsumerStatefulWidget {
  const SettingsScreen({super.key});

  @override
  ConsumerState<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends ConsumerState<SettingsScreen> {
  // Local state for non-persisted settings
  bool _offlineMode = false;
  String _selectedBibleVersion = 'WEB';

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
          const GlassmorphicFABMenu(),
          const SizedBox(width: AppSpacing.lg),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                AutoSizeText(
                  'Settings',
                  style: TextStyle(
                    fontSize: ResponsiveUtils.fontSize(context, 24, minSize: 20, maxSize: 28),
                    fontWeight: FontWeight.w700,
                    color: AppColors.primaryText,
                    shadows: AppTheme.textShadowStrong,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 4),
                AutoSizeText(
                  'Customize your app experience',
                  style: TextStyle(
                    fontSize: ResponsiveUtils.fontSize(context, 14, minSize: 12, maxSize: 16),
                    color: AppColors.secondaryText,
                    fontWeight: FontWeight.w500,
                  ),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
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
              const SizedBox(height: AppSpacing.md),
              _buildTestNotificationButton(context, ref),
            ],
          ),
          const SizedBox(height: AppSpacing.xxl),
          _buildSettingsSection(
            'Subscription',
            Icons.workspace_premium,
            [
              _buildNavigationTile(
                'Manage Subscription',
                _getSubscriptionStatus(ref),
                Icons.arrow_forward_ios,
                () {
                  Navigator.of(context).push(
                    MaterialPageRoute(
                      builder: (context) => const SubscriptionSettingsScreen(),
                    ),
                  );
                },
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
                ['WEB', 'WEB'],
                (value) => setState(() => _selectedBibleVersion = value!),
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.xxl),
          _buildSettingsSection(
            'Appearance',
            Icons.palette,
            [
              _buildSliderTile(
                'Text Size',
                'Adjust text size throughout the app',
                ref.watch(textSizeProvider),
                0.8,
                1.5,
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
                  gradient: AppGradients.customColored(
                    AppTheme.primaryColor,
                    startAlpha: 0.3,
                    endAlpha: 0.1,
                  ),
                  borderRadius: BorderRadius.circular(AppRadius.xs + 2),
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
                  shadows: AppTheme.textShadowSubtle,
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
        borderRadius: AppRadius.mediumRadius,
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
        borderRadius: AppRadius.mediumRadius,
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
                '${(value * 100).round()}%',
                style: TextStyle(
                  fontSize: ResponsiveUtils.fontSize(context, 14, minSize: 12, maxSize: 16),
                  fontWeight: FontWeight.w600,
                  color: AppColors.primaryText,
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
              divisions: ((max - min) / 0.1).round(),
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
        borderRadius: AppRadius.mediumRadius,
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
          borderRadius: AppRadius.mediumRadius,
          child: Container(
            padding: AppSpacing.cardPadding,
            decoration: BoxDecoration(
              color: Colors.black.withValues(alpha: 0.1),
              borderRadius: AppRadius.mediumRadius,
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
                    borderRadius: AppRadius.smallRadius,
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
                const SizedBox(width: AppSpacing.lg),
                Text(
                  _formatTimeTo12Hour(value),
                  style: TextStyle(
                    fontSize: ResponsiveUtils.fontSize(context, 16, minSize: 14, maxSize: 18),
                    fontWeight: FontWeight.w600,
                    color: Colors.white,
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

  String _formatTimeTo12Hour(String time24) {
    final parts = time24.split(':');
    final hour = int.parse(parts[0]);
    final minute = int.parse(parts[1]);

    final period = hour >= 12 ? 'PM' : 'AM';
    final hour12 = hour == 0 ? 12 : (hour > 12 ? hour - 12 : hour);
    final minuteStr = minute.toString().padLeft(2, '0');

    return '$hour12:$minuteStr $period';
  }

  Future<void> _showTimePicker(String currentTime, Function(String) onChanged) async {
    final parts = currentTime.split(':');
    final initialTime = TimeOfDay(
      hour: int.parse(parts[0]),
      minute: int.parse(parts[1]),
    );

    // Custom glassmorphic time picker style matching app theme components
    final customStyle = TimeRangeSheetStyle(
      // Match GlassBottomSheet - transparent background (blur from wrapper)
      sheetBackgroundColor: Colors.transparent,

      // Button styling matching GlassButton component
      buttonColor: Colors.transparent, // GlassButton uses gradient, not solid color
      cancelButtonColor: Colors.transparent,
      buttonTextColor: Colors.white,
      cancelButtonTextColor: Colors.white.withValues(alpha: 0.7),

      // Text colors for visibility
      labelTextColor: Colors.white.withValues(alpha: 0.9),
      selectedTimeTextColor: Colors.white,
      pickerTextColor: Colors.white.withValues(alpha: 0.3),
      selectedPickerTextColor: Colors.white,

      // Corner radius matching GlassButton (28) and GlassBottomSheet (24)
      cornerRadius: 24, // Sheet corner radius
      buttonCornerRadius: 28, // Button corner radius like GlassButton

      // Sheet dimensions
      sheetHeight: 450,
      pickerItemHeight: 45,
      buttonHeight: 56, // Match GlassButton height

      // Padding and spacing
      padding: const EdgeInsets.all(AppSpacing.lg),
      buttonPadding: const EdgeInsets.all(AppSpacing.md),

      // Use 12-hour format to match display
      use24HourFormat: false,

      // Custom button text
      confirmButtonText: 'Set Time',
      cancelButtonText: 'Cancel',

      // Enable haptic feedback
      enableHapticFeedback: true,
    );

    final result = await showGlassBottomSheet<TimeRangeData>(
      context: context,
      isScrollControlled: true,
      child: GlassBottomSheet(
        child: TimeRangeSheet(
          initialStartTime: initialTime,
          style: customStyle,
          singlePicker: true,
          allowInvalidRange: true,
          onConfirm: (start, end) {
            Navigator.of(context).pop(TimeRangeData(
              startTime: start,
              endTime: end,
            ));
          },
          onCancel: () => Navigator.of(context).pop(),
        ),
      ),
    );

    if (result != null) {
      final picked = result.startTime; // In single picker mode, use startTime
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
          borderRadius: AppRadius.mediumRadius,
          child: Container(
            padding: AppSpacing.cardPadding,
            decoration: BoxDecoration(
              color: Colors.black.withValues(alpha: 0.1),
              borderRadius: AppRadius.mediumRadius,
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
                    borderRadius: AppRadius.smallRadius,
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
                  size: ResponsiveUtils.iconSize(context, 16),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildTestNotificationButton(BuildContext context, WidgetRef ref) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: () async {
            try {
              final notificationService = ref.read(notificationServiceProvider);

              // Send test verse notification
              await notificationService.showDailyVerseNotification(
                verseReference: 'John 3:16',
                verseText: 'For God so loved the world, that he gave his only begotten Son, '
                    'that whoever believes in him should not perish, but have eternal life.',
              );

              if (context.mounted) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: const Text('✅ Test notification sent!'),
                    backgroundColor: AppTheme.primaryColor,
                    behavior: SnackBarBehavior.floating,
                    duration: const Duration(seconds: 2),
                  ),
                );
              }
            } catch (e) {
              if (context.mounted) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text('❌ Failed: $e'),
                    backgroundColor: Colors.red,
                    behavior: SnackBarBehavior.floating,
                    duration: const Duration(seconds: 3),
                  ),
                );
              }
            }
          },
          borderRadius: AppRadius.mediumRadius,
          child: Container(
            padding: AppSpacing.cardPadding,
            decoration: BoxDecoration(
              color: AppTheme.primaryColor.withValues(alpha: 0.2),
              borderRadius: AppRadius.mediumRadius,
              border: Border.all(
                color: AppTheme.primaryColor.withValues(alpha: 0.4),
                width: 1,
              ),
            ),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(AppSpacing.sm),
                  decoration: BoxDecoration(
                    color: AppTheme.primaryColor.withValues(alpha: 0.3),
                    borderRadius: AppRadius.smallRadius,
                  ),
                  child: Icon(
                    Icons.notification_add,
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
                        'Test Notification',
                        style: TextStyle(
                          fontSize: ResponsiveUtils.fontSize(context, 16, minSize: 14, maxSize: 18),
                          fontWeight: FontWeight.w600,
                          color: AppColors.primaryText,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        'Preview how notifications will appear',
                        style: TextStyle(
                          fontSize: ResponsiveUtils.fontSize(context, 13, minSize: 11, maxSize: 15),
                          color: Colors.white.withValues(alpha: 0.7),
                        ),
                      ),
                    ],
                  ),
                ),
                Icon(
                  Icons.send,
                  color: AppTheme.primaryColor,
                  size: ResponsiveUtils.iconSize(context, 20),
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
        borderRadius: AppRadius.mediumRadius,
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
            onPressed: () async {
              NavigationService.pop();
              // Clear disclaimer agreement to test it again
              final prefs = await SharedPreferences.getInstance();
              await prefs.remove('disclaimer_agreed');
              _showSnackBar('Cache cleared successfully (including disclaimer agreement)');
            },
            child: Text('Clear', style: TextStyle(color: AppTheme.primaryColor)),
          ),
        ],
      ),
    );
  }

  Future<void> _exportUserData() async {
    try {
      final prayerService = ref.read(prayerServiceProvider);
      final exportText = await prayerService.exportPrayerJournal();

      if (exportText.isEmpty) {
        _showSnackBar('No prayer data to export');
        return;
      }

      await Share.share(
        exportText,
        subject: 'Prayer Journal Export',
      );

      _showSnackBar('📤 Prayer journal exported successfully');
    } catch (e) {
      _showSnackBar('Failed to export: $e');
    }
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
          borderRadius: BorderRadius.circular(AppRadius.xs + 2),
        ),
      ),
    );
  }

  /// Get subscription status text
  String _getSubscriptionStatus(WidgetRef ref) {
    final isPremium = ref.watch(isPremiumProvider);
    final isInTrial = ref.watch(isInTrialProvider);
    final remainingMessages = ref.watch(remainingMessagesProvider);

    if (isPremium) {
      return '$remainingMessages messages left this month';
    } else if (isInTrial) {
      return '$remainingMessages messages left today';
    } else {
      return 'Start your free trial';
    }
  }

  /// Build navigation tile
  Widget _buildNavigationTile(
    String title,
    String subtitle,
    IconData trailingIcon,
    VoidCallback onTap,
  ) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(
          horizontal: AppSpacing.lg,
          vertical: AppSpacing.md,
        ),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [
              Colors.white.withValues(alpha: 0.1),
              Colors.white.withValues(alpha: 0.05),
            ],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          borderRadius: BorderRadius.circular(AppRadius.sm),
          border: Border.all(
            color: Colors.white.withValues(alpha: 0.2),
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
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      color: AppColors.primaryText,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    subtitle,
                    style: TextStyle(
                      fontSize: 14,
                      color: AppColors.secondaryText,
                    ),
                  ),
                ],
              ),
            ),
            Icon(
              trailingIcon,
              size: 18,
              color: AppColors.secondaryText,
            ),
          ],
        ),
      ),
    );
  }
}