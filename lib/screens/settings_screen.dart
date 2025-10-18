import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:share_plus/share_plus.dart';
import 'package:auto_size_text/auto_size_text.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:path_provider/path_provider.dart';
import 'package:image_picker/image_picker.dart';
import '../core/services/database_service.dart';
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
import '../components/glass_button.dart';
import '../components/base_bottom_sheet.dart';
import 'subscription_settings_screen.dart';

class SettingsScreen extends ConsumerStatefulWidget {
  const SettingsScreen({super.key});

  @override
  ConsumerState<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends ConsumerState<SettingsScreen> {
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
    final profilePicturePath = ref.watch(profilePicturePathProvider);

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
          // Profile picture in header (matches home screen)
          GestureDetector(
            onTap: () => _showProfilePictureOptions(),
            child: profilePicturePath.when(
              data: (path) => _buildAvatarCircle(path),
              loading: () => _buildAvatarCircle(null),
              error: (_, __) => _buildAvatarCircle(null),
            ),
          ),
        ],
      ),
    ).animate().fadeIn(duration: AppAnimations.slow).slideY(begin: -0.3);
  }

  Widget _buildAvatarCircle(String? imagePath) {
    final hasImage = imagePath != null && File(imagePath).existsSync();

    return Stack(
      children: [
        Container(
          width: ResponsiveUtils.scaleSize(context, 40, minScale: 0.85, maxScale: 1.2),
          height: ResponsiveUtils.scaleSize(context, 40, minScale: 0.85, maxScale: 1.2),
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            border: Border.all(
              color: AppTheme.goldColor.withValues(alpha: 0.6),
              width: 1.5,
            ),
            color: hasImage ? null : AppTheme.primaryColor.withValues(alpha: 0.3),
          ),
          child: hasImage
              ? ClipOval(
                  child: Image.file(
                    File(imagePath),
                    fit: BoxFit.cover,
                  ),
                )
              : Icon(
                  Icons.person,
                  color: AppColors.primaryText,
                  size: ResponsiveUtils.iconSize(context, 20),
                ),
        ),
        // Plus icon indicator
        Positioned(
          right: 0,
          bottom: 0,
          child: Container(
            width: 16,
            height: 16,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: AppTheme.primaryColor,
              border: Border.all(
                color: AppTheme.goldColor.withValues(alpha: 0.6),
                width: 1.5,
              ),
            ),
            child: Icon(
              Icons.add,
              size: 10,
              color: Colors.white,
            ),
          ),
        ),
      ],
    ).animate().fadeIn(duration: AppAnimations.slow, delay: AppAnimations.normal).scale(begin: const Offset(0.8, 0.8));
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
              _buildInfoTile('Bible Version', 'WEB'),
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
              _buildActionTile(
                'Delete All Data',
                '⚠️ Permanently delete all your data',
                Icons.warning_amber_rounded,
                () => _showDeleteAllDataDialog(),
                isDestructive: true,
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

  Widget _buildActionTile(String title, String subtitle, IconData icon, VoidCallback onTap, {bool isDestructive = false}) {
    final textColor = AppColors.primaryText;
    final subtitleColor = Colors.white.withValues(alpha: 0.7);
    final iconColor = isDestructive ? Colors.red : AppColors.primaryText;
    final borderColor = isDestructive ? Colors.red.withValues(alpha: 0.3) : Colors.white.withValues(alpha: 0.1);

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
              color: isDestructive
                  ? Colors.red.withValues(alpha: 0.05)
                  : Colors.black.withValues(alpha: 0.1),
              borderRadius: AppRadius.mediumRadius,
              border: Border.all(
                color: borderColor,
                width: 1,
              ),
            ),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(AppSpacing.sm),
                  decoration: BoxDecoration(
                    color: isDestructive
                        ? Colors.red.withValues(alpha: 0.1)
                        : Colors.white.withValues(alpha: 0.1),
                    borderRadius: AppRadius.smallRadius,
                  ),
                  child: Icon(
                    icon,
                    color: iconColor,
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
                          color: textColor,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        subtitle,
                        style: TextStyle(
                          fontSize: ResponsiveUtils.fontSize(context, 13, minSize: 11, maxSize: 15),
                          color: subtitleColor,
                        ),
                      ),
                    ],
                  ),
                ),
                Icon(
                  Icons.arrow_forward_ios,
                  color: isDestructive
                      ? Colors.red.withValues(alpha: 0.5)
                      : Colors.white.withValues(alpha: 0.5),
                  size: ResponsiveUtils.iconSize(context, 16),
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

  void _showProfilePictureOptions() {
    showCustomBottomSheet(
      context: context,
      title: 'Profile Picture',
      child: Padding(
        padding: const EdgeInsets.only(bottom: 20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              leading: const Icon(Icons.photo_library, color: Colors.white),
              title: const Text('Choose from Gallery', style: TextStyle(color: Colors.white)),
              onTap: () async {
                NavigationService.pop();
                await _pickImageFromGallery();
              },
            ),
            ListTile(
              leading: const Icon(Icons.camera_alt, color: Colors.white),
              title: const Text('Take Photo', style: TextStyle(color: Colors.white)),
              onTap: () async {
                NavigationService.pop();
                await _takePhoto();
              },
            ),
            if (ref.read(profilePicturePathProvider).value != null)
              ListTile(
                leading: const Icon(Icons.delete_outline, color: Colors.red),
                title: const Text('Remove Photo', style: TextStyle(color: Colors.red)),
                onTap: () async {
                  NavigationService.pop();
                  await _removeProfilePicture();
                },
              ),
            const SizedBox(height: AppSpacing.xl),
          ],
        ),
      ),
    );
  }

  Future<void> _pickImageFromGallery() async {
    try {
      final service = ref.read(profilePictureServiceProvider);
      final path = await service.pickFromGallery();

      if (path != null) {
        ref.invalidate(profilePicturePathProvider);
        _showSnackBar('✅ Profile picture updated');
      }
    } catch (e) {
      _showSnackBar('❌ Failed to pick image: $e');
    }
  }

  Future<void> _takePhoto() async {
    try {
      final service = ref.read(profilePictureServiceProvider);
      final path = await service.takePhoto();

      if (path != null) {
        ref.invalidate(profilePicturePathProvider);
        _showSnackBar('✅ Profile picture updated');
      }
    } catch (e) {
      _showSnackBar('❌ Failed to take photo: $e');
    }
  }

  Future<void> _removeProfilePicture() async {
    try {
      final service = ref.read(profilePictureServiceProvider);
      final removed = await service.removeProfilePicture();

      if (removed) {
        ref.invalidate(profilePicturePathProvider);
        _showSnackBar('✅ Profile picture removed');
      } else {
        _showSnackBar('❌ Failed to remove profile picture');
      }
    } catch (e) {
      _showSnackBar('❌ Failed to remove profile picture: $e');
    }
  }

  void _showClearCacheDialog() {
    showDialog(
      context: context,
      builder: (context) => Dialog(
        backgroundColor: Colors.transparent,
        child: Container(
          constraints: BoxConstraints(
            maxWidth: ResponsiveUtils.maxContentWidth(context),
          ),
          child: FrostedGlassCard(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Header
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
                        borderRadius: BorderRadius.circular(AppRadius.xs + 2),
                        border: Border.all(
                          color: AppTheme.primaryColor.withValues(alpha: 0.3),
                          width: 1,
                        ),
                      ),
                      child: Icon(
                        Icons.cleaning_services,
                        color: AppColors.primaryText,
                        size: ResponsiveUtils.iconSize(context, 20),
                      ),
                    ),
                    const SizedBox(width: AppSpacing.md),
                    Text(
                      'Clear Cache',
                      style: TextStyle(
                        fontSize: ResponsiveUtils.fontSize(context, 20, minSize: 18, maxSize: 24),
                        fontWeight: FontWeight.w700,
                        color: AppColors.primaryText,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: AppSpacing.md),
                Text(
                  'This will free up storage space but may require re-downloading some content.',
                  style: TextStyle(
                    fontSize: ResponsiveUtils.fontSize(context, 13, minSize: 11, maxSize: 15),
                    color: Colors.white.withValues(alpha: 0.7),
                  ),
                ),
                const SizedBox(height: AppSpacing.xl),

                // Actions
                Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    TextButton(
                      onPressed: () => NavigationService.pop(),
                      style: TextButton.styleFrom(
                        padding: const EdgeInsets.symmetric(
                          horizontal: AppSpacing.lg,
                          vertical: AppSpacing.md,
                        ),
                      ),
                      child: Text(
                        'Cancel',
                        style: TextStyle(
                          color: Colors.white.withValues(alpha: 0.7),
                          fontSize: ResponsiveUtils.fontSize(context, 14, minSize: 12, maxSize: 16),
                        ),
                      ),
                    ),
                    const SizedBox(width: AppSpacing.sm),
                    TextButton(
                      onPressed: () async {
                        NavigationService.pop();
                        await _clearCache();
                      },
                      style: TextButton.styleFrom(
                        padding: const EdgeInsets.symmetric(
                          horizontal: AppSpacing.lg,
                          vertical: AppSpacing.md,
                        ),
                        backgroundColor: AppTheme.primaryColor.withValues(alpha: 0.2),
                      ),
                      child: Text(
                        'Clear',
                        style: TextStyle(
                          color: AppTheme.primaryColor,
                          fontSize: ResponsiveUtils.fontSize(context, 14, minSize: 12, maxSize: 16),
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Future<void> _clearCache() async {
    try {
      // Clear Flutter image cache
      imageCache.clear();
      imageCache.clearLiveImages();

      // Clear temporary directory
      final tempDir = await getTemporaryDirectory();
      if (await tempDir.exists()) {
        await tempDir.delete(recursive: true);
        await tempDir.create();
      }

      // Clear app cache directory (does not delete user data/database)
      try {
        final cacheDir = await getApplicationCacheDirectory();
        if (await cacheDir.exists()) {
          await cacheDir.delete(recursive: true);
          await cacheDir.create();
        }
      } catch (e) {
        debugPrint('Could not clear cache directory: $e');
      }

      _showSnackBar('✅ Cache cleared successfully');
    } catch (e) {
      _showSnackBar('❌ Failed to clear cache: $e');
    }
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

  void _showDeleteAllDataDialog() {
    final confirmController = TextEditingController();

    showDialog(
      context: context,
      builder: (context) => Dialog(
        backgroundColor: Colors.transparent,
        child: Container(
          constraints: BoxConstraints(
            maxHeight: MediaQuery.of(context).size.height * 0.8,
            maxWidth: ResponsiveUtils.maxContentWidth(context),
          ),
          child: FrostedGlassCard(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Header
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(AppSpacing.sm),
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          colors: [
                            Colors.red.withValues(alpha: 0.3),
                            Colors.red.withValues(alpha: 0.1),
                          ],
                        ),
                        borderRadius: BorderRadius.circular(AppRadius.xs + 2),
                        border: Border.all(
                          color: Colors.red.withValues(alpha: 0.3),
                          width: 1,
                        ),
                      ),
                      child: Icon(
                        Icons.warning_amber_rounded,
                        color: Colors.red,
                        size: ResponsiveUtils.iconSize(context, 20),
                      ),
                    ),
                    const SizedBox(width: AppSpacing.md),
                    Text(
                      'Delete All Data',
                      style: TextStyle(
                        fontSize: ResponsiveUtils.fontSize(context, 20, minSize: 18, maxSize: 24),
                        fontWeight: FontWeight.w700,
                        color: AppColors.primaryText,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: AppSpacing.md),
                Text(
                  '⚠️ THIS ACTION CANNOT BE UNDONE ⚠️',
                  style: TextStyle(
                    fontSize: ResponsiveUtils.fontSize(context, 14, minSize: 12, maxSize: 16),
                    fontWeight: FontWeight.bold,
                    color: Colors.red,
                  ),
                ),
                const SizedBox(height: AppSpacing.xl),

                // Scrollable Content
                Expanded(
                  child: SingleChildScrollView(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'This will permanently delete:',
                          style: TextStyle(
                            fontSize: ResponsiveUtils.fontSize(context, 14, minSize: 12, maxSize: 16),
                            fontWeight: FontWeight.w600,
                            color: Colors.white,
                          ),
                        ),
                        const SizedBox(height: AppSpacing.md),
                        _buildDeleteItem('✝️ All prayer journal entries'),
                        _buildDeleteItem('💬 All AI chat conversations'),
                        _buildDeleteItem('📖 Reading plan progress'),
                        _buildDeleteItem('🌟 Favorite verses'),
                        _buildDeleteItem('📝 Devotional completion history'),
                        _buildDeleteItem('⚙️ All app settings and preferences'),
                        _buildDeleteItem('👤 Profile picture'),
                        _buildDeleteItem('📊 All statistics and progress'),
                        const SizedBox(height: AppSpacing.lg),
                        Container(
                          padding: const EdgeInsets.all(AppSpacing.md),
                          decoration: BoxDecoration(
                            color: Colors.red.withValues(alpha: 0.1),
                            borderRadius: BorderRadius.circular(AppRadius.sm),
                            border: Border.all(color: Colors.red.withValues(alpha: 0.3)),
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                '⚠️ Before proceeding:',
                                style: TextStyle(
                                  fontSize: ResponsiveUtils.fontSize(context, 13, minSize: 11, maxSize: 15),
                                  fontWeight: FontWeight.bold,
                                  color: Colors.red,
                                ),
                              ),
                              const SizedBox(height: AppSpacing.sm),
                              Text(
                                '• Export your prayer journal first (Settings > Export Data)\n• This will reset the app to factory defaults\n• You will need to reconfigure all settings',
                                style: TextStyle(
                                  fontSize: ResponsiveUtils.fontSize(context, 12, minSize: 10, maxSize: 14),
                                  color: Colors.white.withValues(alpha: 0.9),
                                  height: 1.4,
                                ),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: AppSpacing.lg),
                        Text(
                          'Type DELETE to confirm:',
                          style: TextStyle(
                            fontSize: ResponsiveUtils.fontSize(context, 13, minSize: 11, maxSize: 15),
                            fontWeight: FontWeight.w600,
                            color: Colors.white,
                          ),
                        ),
                        const SizedBox(height: AppSpacing.sm),
                        TextField(
                          controller: confirmController,
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: ResponsiveUtils.fontSize(context, 14, minSize: 12, maxSize: 16),
                          ),
                          decoration: InputDecoration(
                            hintText: 'Type DELETE',
                            hintStyle: TextStyle(
                              color: Colors.white.withValues(alpha: 0.3),
                              fontSize: ResponsiveUtils.fontSize(context, 14, minSize: 12, maxSize: 16),
                            ),
                            enabledBorder: OutlineInputBorder(
                              borderSide: BorderSide(color: Colors.white.withValues(alpha: 0.3)),
                              borderRadius: BorderRadius.circular(AppRadius.sm),
                            ),
                            focusedBorder: OutlineInputBorder(
                              borderSide: BorderSide(color: Colors.red, width: 2),
                              borderRadius: BorderRadius.circular(AppRadius.sm),
                            ),
                            contentPadding: const EdgeInsets.all(AppSpacing.md),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: AppSpacing.xl),

                // Actions
                Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    TextButton(
                      onPressed: () {
                        confirmController.dispose();
                        NavigationService.pop();
                      },
                      style: TextButton.styleFrom(
                        padding: const EdgeInsets.symmetric(
                          horizontal: AppSpacing.lg,
                          vertical: AppSpacing.md,
                        ),
                      ),
                      child: Text(
                        'Cancel',
                        style: TextStyle(
                          color: Colors.white.withValues(alpha: 0.7),
                          fontSize: ResponsiveUtils.fontSize(context, 14, minSize: 12, maxSize: 16),
                        ),
                      ),
                    ),
                    const SizedBox(width: AppSpacing.sm),
                    TextButton(
                      onPressed: () async {
                        if (confirmController.text.trim() == 'DELETE') {
                          confirmController.dispose();
                          NavigationService.pop();
                          await _deleteAllData();
                        } else {
                          _showSnackBar('❌ You must type DELETE to confirm');
                        }
                      },
                      style: TextButton.styleFrom(
                        padding: const EdgeInsets.symmetric(
                          horizontal: AppSpacing.lg,
                          vertical: AppSpacing.md,
                        ),
                        backgroundColor: Colors.red.withValues(alpha: 0.2),
                      ),
                      child: Text(
                        'Delete Everything',
                        style: TextStyle(
                          color: Colors.red,
                          fontSize: ResponsiveUtils.fontSize(context, 14, minSize: 12, maxSize: 16),
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildDeleteItem(String text) {
    return Padding(
      padding: const EdgeInsets.only(left: 8, bottom: 6),
      child: Row(
        children: [
          Icon(Icons.close, color: Colors.red, size: 16),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              text,
              style: TextStyle(
                color: Colors.white.withValues(alpha: 0.9),
                fontSize: 13,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _deleteAllData() async {
    try {
      // Show loading indicator
      showDialog(
        context: context,
        barrierDismissible: false,
        builder: (context) => Dialog(
          backgroundColor: Colors.transparent,
          child: FrostedGlassCard(
            child: Padding(
              padding: const EdgeInsets.all(AppSpacing.lg),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  CircularProgressIndicator(
                    valueColor: AlwaysStoppedAnimation<Color>(AppTheme.primaryColor),
                  ),
                  const SizedBox(width: AppSpacing.lg),
                  Text(
                    'Deleting all data...',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: ResponsiveUtils.fontSize(context, 14, minSize: 12, maxSize: 16),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      );

      // 1. Reset database (clears all prayer, chat, favorites, reading plans, etc.)
      final dbService = DatabaseService();
      await dbService.resetDatabase();

      // 2. Clear SharedPreferences (all app settings)
      final prefs = await SharedPreferences.getInstance();
      await prefs.clear();

      // 3. Remove profile picture
      try {
        final profileService = ref.read(profilePictureServiceProvider);
        await profileService.removeProfilePicture();
      } catch (e) {
        debugPrint('Profile picture removal failed: $e');
      }

      // 4. Clear all cache
      try {
        imageCache.clear();
        imageCache.clearLiveImages();
        final tempDir = await getTemporaryDirectory();
        if (await tempDir.exists()) {
          await tempDir.delete(recursive: true);
          await tempDir.create();
        }
        final cacheDir = await getApplicationCacheDirectory();
        if (await cacheDir.exists()) {
          await cacheDir.delete(recursive: true);
          await cacheDir.create();
        }
      } catch (e) {
        debugPrint('Cache clearing failed: $e');
      }

      // Close loading dialog
      if (mounted) {
        NavigationService.pop();
      }

      // Show success message
      _showSnackBar('✅ All data deleted. App will restart.');

      // Wait a moment then exit the app (user needs to restart)
      await Future.delayed(const Duration(seconds: 2));
      if (mounted) {
        // Reset the app state by navigating to home
        NavigationService.goToHome();
      }
    } catch (e) {
      // Close loading dialog
      if (mounted) {
        NavigationService.pop();
      }
      _showSnackBar('❌ Failed to delete data: $e');
    }
  }

  void _showHelpDialog() {
    showDialog(
      context: context,
      builder: (context) => Dialog(
        backgroundColor: Colors.transparent,
        child: Container(
          constraints: BoxConstraints(
            maxHeight: MediaQuery.of(context).size.height * 0.8,
            maxWidth: ResponsiveUtils.maxContentWidth(context),
          ),
          child: FrostedGlassCard(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Header
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
                        borderRadius: BorderRadius.circular(AppRadius.xs + 2),
                        border: Border.all(
                          color: AppTheme.primaryColor.withValues(alpha: 0.3),
                          width: 1,
                        ),
                      ),
                      child: Icon(
                        Icons.help_outline,
                        color: AppColors.primaryText,
                        size: ResponsiveUtils.iconSize(context, 20),
                      ),
                    ),
                    const SizedBox(width: AppSpacing.md),
                    Text(
                      'Help & FAQ',
                      style: TextStyle(
                        fontSize: ResponsiveUtils.fontSize(context, 20, minSize: 18, maxSize: 24),
                        fontWeight: FontWeight.w700,
                        color: AppColors.primaryText,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: AppSpacing.md),
                Text(
                  'Find answers to common questions',
                  style: TextStyle(
                    fontSize: ResponsiveUtils.fontSize(context, 13, minSize: 11, maxSize: 15),
                    color: Colors.white.withValues(alpha: 0.7),
                  ),
                ),
                const SizedBox(height: AppSpacing.xl),

                // Scrollable FAQ List
                Expanded(
                  child: SingleChildScrollView(
                    child: Column(
                      children: [
                        _buildFAQSection('Getting Started', [
                          _FAQItem(
                            question: 'How do I get started?',
                            answer: 'Welcome! Start by exploring the Home screen where you\'ll find daily devotionals, verse of the day, and quick access to prayer and Bible reading. Navigate using the menu in the top left corner.',
                          ),
                          _FAQItem(
                            question: 'Is the app free to use?',
                            answer: 'Yes! Everyday Christian offers a free trial with daily message limits for AI chat. Upgrade to Premium for unlimited AI conversations and full access to all features.',
                          ),
                          _FAQItem(
                            question: 'Which Bible version is used?',
                            answer: 'The app uses the World English Bible (WEB), a modern public domain translation that\'s faithful to the original texts and easy to read.',
                          ),
                        ]),
                        const SizedBox(height: AppSpacing.lg),

                        _buildFAQSection('Bible Reading', [
                          _FAQItem(
                            question: 'Can I read the Bible offline?',
                            answer: 'Yes! The entire Bible is downloaded when you first install the app. You can read all 66 books, chapters, and verses without an internet connection.',
                          ),
                          _FAQItem(
                            question: 'How do I search for verses?',
                            answer: 'Navigate to the Bible section from the home menu. Use the search bar to find verses by keywords, or browse by book, chapter, and verse.',
                          ),
                          _FAQItem(
                            question: 'Can I change the Bible version?',
                            answer: 'The World English Bible (WEB) is currently the only version available. This ensures consistent offline access and optimal performance.',
                          ),
                        ]),
                        const SizedBox(height: AppSpacing.lg),

                        _buildFAQSection('Prayer Journal', [
                          _FAQItem(
                            question: 'How do I add a prayer?',
                            answer: 'Open the Prayer Journal from the home menu and tap the floating + button. Enter your prayer title, description, and choose a category (Personal, Family, Health, etc.), then save.',
                          ),
                          _FAQItem(
                            question: 'Can I mark prayers as answered?',
                            answer: 'Yes! Open any prayer and tap "Mark as Answered". You can add a description of how God answered your prayer. View all answered prayers in the "Answered" tab.',
                          ),
                          _FAQItem(
                            question: 'How do I export my prayer journal?',
                            answer: 'Go to Settings > Data & Privacy > Export Data. This creates a formatted text file containing all your prayers (both active and answered) that you can save or share.',
                          ),
                          _FAQItem(
                            question: 'Can I organize prayers by category?',
                            answer: 'Yes! Each prayer can be assigned to a category. Use the category filter at the top of the Prayer Journal to view prayers by specific categories.',
                          ),
                        ]),
                        const SizedBox(height: AppSpacing.lg),

                        _buildFAQSection('Devotionals & Reading Plans', [
                          _FAQItem(
                            question: 'Where can I find daily devotionals?',
                            answer: 'Daily devotionals appear on your Home screen. You can mark devotionals as completed to track your progress and build your devotional streak.',
                          ),
                          _FAQItem(
                            question: 'How do reading plans work?',
                            answer: 'Choose a reading plan from the Reading Plans section. Tap "Start Plan" to begin. The app tracks your progress as you complete daily readings. Only one plan can be active at a time.',
                          ),
                          _FAQItem(
                            question: 'Can I track my devotional streak?',
                            answer: 'Yes! The app automatically tracks how many consecutive days you\'ve completed devotionals. View your current streak on your Profile screen.',
                          ),
                        ]),
                        const SizedBox(height: AppSpacing.lg),

                        _buildFAQSection('AI Chat & Support', [
                          _FAQItem(
                            question: 'What can I ask the AI?',
                            answer: 'You can ask about Scripture interpretation, prayer requests, life challenges, faith questions, and daily encouragement. The AI provides biblically-grounded guidance and support.',
                          ),
                          _FAQItem(
                            question: 'How many messages can I send?',
                            answer: 'Free users have a daily message limit. Premium subscribers get unlimited messages. Check Settings > Subscription to see your current plan and remaining messages.',
                          ),
                          _FAQItem(
                            question: 'Are my conversations saved?',
                            answer: 'Yes! All your AI conversations are saved to your device. Each chat creates a new session that you can access from the conversation history.',
                          ),
                        ]),
                        const SizedBox(height: AppSpacing.lg),

                        _buildFAQSection('Notifications', [
                          _FAQItem(
                            question: 'How do I change notification times?',
                            answer: 'Go to Settings > Notifications > Notification Time. Select your preferred time for daily reminders.',
                          ),
                          _FAQItem(
                            question: 'Can I turn off specific notifications?',
                            answer: 'Yes! In Settings > Notifications, you can toggle each notification type (Daily Devotional, Prayer Reminders, Verse of the Day) independently.',
                          ),
                          _FAQItem(
                            question: 'Why aren\'t I receiving notifications?',
                            answer: 'Check your device settings to ensure notifications are enabled for Everyday Christian. Also verify that each notification type is enabled in Settings > Notifications.',
                          ),
                        ]),
                        const SizedBox(height: AppSpacing.lg),

                        _buildFAQSection('Settings & Customization', [
                          _FAQItem(
                            question: 'How do I adjust text size?',
                            answer: 'Go to Settings > Appearance > Text Size. Use the slider to adjust text size throughout the app from 80% to 150% of normal size.',
                          ),
                          _FAQItem(
                            question: 'Can I add a profile picture?',
                            answer: 'Yes! Tap your profile avatar in Settings or on your Profile screen. Choose to take a photo or select one from your gallery.',
                          ),
                          _FAQItem(
                            question: 'What does offline mode do?',
                            answer: 'Offline mode allows you to use core features (Bible reading, viewing saved prayers and devotionals) without an internet connection. AI chat requires internet.',
                          ),
                        ]),
                        const SizedBox(height: AppSpacing.lg),

                        _buildFAQSection('Data & Privacy', [
                          _FAQItem(
                            question: 'Is my data private and secure?',
                            answer: 'Yes! Your prayers, notes, and personal data are stored securely on your device. We never sell your information to third parties.',
                          ),
                          _FAQItem(
                            question: 'What data is stored on my device?',
                            answer: 'The Bible content, your prayers, conversation history, reading plan progress, devotional completion records, and app preferences are all stored locally.',
                          ),
                          _FAQItem(
                            question: 'What\'s the difference between Clear Cache and Delete All Data?',
                            answer: 'Clear Cache removes temporary files (image cache, temp directories) to free up storage space. Your prayers, settings, and all personal data remain safe. Delete All Data permanently erases everything including prayers, conversations, settings, and resets the app to factory defaults.',
                          ),
                          _FAQItem(
                            question: 'How do I clear cached data?',
                            answer: 'Go to Settings > Data & Privacy > Clear Cache. This removes temporary files and image cache to free up storage space. Your prayers, conversations, and personal data are NOT deleted - only temporary cache files are removed.',
                          ),
                          _FAQItem(
                            question: 'How do I delete all my data?',
                            answer: 'Go to Settings > Data & Privacy > Delete All Data. You\'ll be asked to type "DELETE" to confirm. This permanently erases all prayers, conversations, reading plans, favorites, settings, and profile picture. Export your prayer journal first if you want to keep a backup. This action cannot be undone.',
                          ),
                        ]),
                      ],
                    ),
                  ),
                ),

                const SizedBox(height: AppSpacing.xl),

                // Close Button
                GlassButton(
                  text: 'Close',
                  height: 48,
                  onPressed: () => NavigationService.pop(),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildFAQSection(String title, List<_FAQItem> items) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.only(left: 4, bottom: 8),
          child: Text(
            title,
            style: TextStyle(
              fontSize: ResponsiveUtils.fontSize(context, 16, minSize: 14, maxSize: 18),
              fontWeight: FontWeight.w700,
              color: AppTheme.goldColor,
            ),
          ),
        ),
        ...items.map((item) => _buildFAQTile(item.question, item.answer)),
      ],
    );
  }

  Widget _buildFAQTile(String question, String answer) {
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      decoration: BoxDecoration(
        color: Colors.black.withValues(alpha: 0.2),
        borderRadius: AppRadius.mediumRadius,
        border: Border.all(
          color: Colors.white.withValues(alpha: 0.1),
          width: 1,
        ),
      ),
      child: Theme(
        data: Theme.of(context).copyWith(
          dividerColor: Colors.transparent,
        ),
        child: ExpansionTile(
          tilePadding: AppSpacing.cardPadding,
          childrenPadding: const EdgeInsets.only(
            left: AppSpacing.lg,
            right: AppSpacing.lg,
            bottom: AppSpacing.md,
          ),
          title: Text(
            question,
            style: TextStyle(
              fontSize: ResponsiveUtils.fontSize(context, 14, minSize: 12, maxSize: 16),
              fontWeight: FontWeight.w600,
              color: AppColors.primaryText,
            ),
          ),
          iconColor: AppColors.primaryText,
          collapsedIconColor: Colors.white.withValues(alpha: 0.5),
          children: [
            Text(
              answer,
              style: TextStyle(
                fontSize: ResponsiveUtils.fontSize(context, 13, minSize: 11, maxSize: 15),
                color: Colors.white.withValues(alpha: 0.8),
                height: 1.5,
              ),
            ),
          ],
        ),
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
    showDialog(
      context: context,
      builder: (context) => Dialog(
        backgroundColor: Colors.transparent,
        child: Container(
          constraints: BoxConstraints(
            maxHeight: MediaQuery.of(context).size.height * 0.85,
            maxWidth: ResponsiveUtils.maxContentWidth(context),
          ),
          child: FrostedGlassCard(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Header
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
                        borderRadius: BorderRadius.circular(AppRadius.xs + 2),
                        border: Border.all(
                          color: AppTheme.primaryColor.withValues(alpha: 0.3),
                          width: 1,
                        ),
                      ),
                      child: Icon(
                        Icons.privacy_tip_outlined,
                        color: AppColors.primaryText,
                        size: ResponsiveUtils.iconSize(context, 20),
                      ),
                    ),
                    const SizedBox(width: AppSpacing.md),
                    Text(
                      'Privacy Policy',
                      style: TextStyle(
                        fontSize: ResponsiveUtils.fontSize(context, 20, minSize: 18, maxSize: 24),
                        fontWeight: FontWeight.w700,
                        color: AppColors.primaryText,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: AppSpacing.sm),
                Text(
                  'Last Updated: October 15, 2025',
                  style: TextStyle(
                    fontSize: ResponsiveUtils.fontSize(context, 12, minSize: 10, maxSize: 14),
                    color: Colors.white.withValues(alpha: 0.6),
                  ),
                ),
                const SizedBox(height: AppSpacing.xl),

                // Scrollable Privacy Policy Content
                Expanded(
                  child: Container(
                    decoration: BoxDecoration(
                      color: Colors.black.withValues(alpha: 0.2),
                      borderRadius: AppRadius.mediumRadius,
                      border: Border.all(
                        color: Colors.white.withValues(alpha: 0.1),
                        width: 1,
                      ),
                    ),
                    child: SingleChildScrollView(
                      padding: AppSpacing.cardPadding,
                      child: _buildPrivacyPolicyContent(),
                    ),
                  ),
                ),

                const SizedBox(height: AppSpacing.xl),

                // Close Button
                GlassButton(
                  text: 'Close',
                  height: 48,
                  onPressed: () => NavigationService.pop(),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildPrivacyPolicyContent() {
    return SelectableText.rich(
      TextSpan(
        style: TextStyle(
          fontSize: ResponsiveUtils.fontSize(context, 14, minSize: 12, maxSize: 16),
          color: AppColors.primaryText,
          height: 1.6,
        ),
        children: [
          // Introduction Section
          TextSpan(
            text: '1. INTRODUCTION\n\n',
            style: TextStyle(
              fontSize: ResponsiveUtils.fontSize(context, 16, minSize: 14, maxSize: 18),
              fontWeight: FontWeight.w700,
              color: AppTheme.goldColor,
            ),
          ),
          const TextSpan(
            text: 'Welcome to Everyday Christian. We are deeply committed to your privacy and have built this application on a privacy-first foundation.\n\n'
                'Everyday Christian provides AI-powered pastoral guidance, daily Bible verses, devotionals, prayer journal, and comprehensive verse library.\n\n',
          ),
          TextSpan(
            text: 'OUR PRIVACY-FIRST COMMITMENT:\n',
            style: const TextStyle(fontWeight: FontWeight.w600),
          ),
          const TextSpan(
            text: '• NO user accounts required - use completely anonymously\n'
                '• NO personal information collection\n'
                '• NO location tracking\n'
                '• NO third-party analytics\n'
                '• NO advertising networks\n'
                '• NO data monetization\n'
                '• Local-first storage - data stays on your device\n\n',
          ),

          // Information We Collect
          TextSpan(
            text: '2. INFORMATION WE COLLECT\n\n',
            style: TextStyle(
              fontSize: ResponsiveUtils.fontSize(context, 16, minSize: 14, maxSize: 18),
              fontWeight: FontWeight.w700,
              color: AppTheme.goldColor,
            ),
          ),
          TextSpan(
            text: 'Stored Locally on Your Device:\n',
            style: const TextStyle(fontWeight: FontWeight.w600),
          ),
          const TextSpan(
            text: 'All data is stored exclusively on your device using secure SQLite database:\n'
                '• Prayer journal entries and reflections\n'
                '• Favorite verses and bookmarks\n'
                '• Reading history and progress\n'
                '• AI chat history (Premium users only)\n'
                '• App settings and preferences\n'
                '• Devotional completion records\n\n',
          ),
          TextSpan(
            text: 'We Do NOT Collect:\n',
            style: const TextStyle(fontWeight: FontWeight.w600),
          ),
          const TextSpan(
            text: '❌ Personal identification (name, email, phone)\n'
                '❌ Location data or GPS coordinates\n'
                '❌ Device tracking identifiers\n'
                '❌ Behavioral analytics\n'
                '❌ Payment information (handled by Apple/Google)\n\n',
          ),

          // Third-Party Services
          TextSpan(
            text: '3. THIRD-PARTY SERVICES\n\n',
            style: TextStyle(
              fontSize: ResponsiveUtils.fontSize(context, 16, minSize: 14, maxSize: 18),
              fontWeight: FontWeight.w700,
              color: AppTheme.goldColor,
            ),
          ),
          TextSpan(
            text: 'Google Gemini API (Premium AI Chat Only):\n',
            style: const TextStyle(fontWeight: FontWeight.w600),
          ),
          const TextSpan(
            text: 'When using Premium AI guidance, your chat messages are sent anonymously to Google\'s Gemini API:\n'
                '• Anonymous requests - no personal identifiers\n'
                '• Session-based context for coherent responses\n'
                '• No cross-session tracking\n'
                '• Content filtering for harmful theology\n'
                '• Crisis detection triggers professional resources\n\n'
                'Free tier users: No data leaves your device.\n\n',
          ),

          // Data Security
          TextSpan(
            text: '4. DATA SECURITY\n\n',
            style: TextStyle(
              fontSize: ResponsiveUtils.fontSize(context, 16, minSize: 14, maxSize: 18),
              fontWeight: FontWeight.w700,
              color: AppTheme.goldColor,
            ),
          ),
          const TextSpan(
            text: 'We implement industry-standard security:\n'
                '• Secure SQLite database storage\n'
                '• Optional biometric authentication (Face ID, Touch ID)\n'
                '• No cloud storage or external servers\n'
                '• TLS/SSL encrypted API communications\n'
                '• Regular security audits\n\n',
          ),

          // Data Sharing
          TextSpan(
            text: '5. DATA SHARING\n\n',
            style: TextStyle(
              fontSize: ResponsiveUtils.fontSize(context, 16, minSize: 14, maxSize: 18),
              fontWeight: FontWeight.w700,
              color: AppTheme.goldColor,
            ),
          ),
          TextSpan(
            text: 'We Do Not Sell Your Data:\n',
            style: const TextStyle(fontWeight: FontWeight.w600),
          ),
          const TextSpan(
            text: 'We categorically do not and will never sell, rent, or monetize your data. Our only revenue is from optional Premium subscriptions (\$35/year).\n\n',
          ),
          TextSpan(
            text: 'Third-Party Sharing:\n',
            style: const TextStyle(fontWeight: FontWeight.w600),
          ),
          const TextSpan(
            text: '• Google Gemini API: Message text only (Premium feature)\n'
                '• Apple/Google: Subscription validation (anonymous)\n'
                '• NO analytics, advertising, or tracking services\n\n',
          ),

          // Sensitive Information
          TextSpan(
            text: '6. SENSITIVE INFORMATION\n\n',
            style: TextStyle(
              fontSize: ResponsiveUtils.fontSize(context, 16, minSize: 14, maxSize: 18),
              fontWeight: FontWeight.w700,
              color: AppTheme.goldColor,
            ),
          ),
          const TextSpan(
            text: 'We recognize this app processes sensitive religious data:\n'
                '• Religious beliefs revealed through app usage\n'
                '• Emotional and mental health concerns\n'
                '• Personal circumstances and struggles\n\n'
                'Special Protections:\n'
                '• Local storage minimizes exposure\n'
                '• Anonymous API calls (no identity)\n'
                '• No profiling or cross-app tracking\n'
                '• Crisis content triggers safety resources\n\n',
          ),

          // Children's Privacy
          TextSpan(
            text: '7. CHILDREN\'S PRIVACY (COPPA)\n\n',
            style: TextStyle(
              fontSize: ResponsiveUtils.fontSize(context, 16, minSize: 14, maxSize: 18),
              fontWeight: FontWeight.w700,
              color: AppTheme.goldColor,
            ),
          ),
          const TextSpan(
            text: 'Age Requirements:\n'
                '• General Use: Ages 13+ (parental guidance recommended for 13-17)\n'
                '• Under 13: Premium AI chat requires parental consent\n\n'
                'Parental Rights:\n'
                '• Review locally stored data\n'
                '• Delete data via app settings\n'
                '• Control Premium subscriptions\n\n',
          ),

          // Your Rights
          TextSpan(
            text: '8. YOUR PRIVACY RIGHTS\n\n',
            style: TextStyle(
              fontSize: ResponsiveUtils.fontSize(context, 16, minSize: 14, maxSize: 18),
              fontWeight: FontWeight.w700,
              color: AppTheme.goldColor,
            ),
          ),
          TextSpan(
            text: 'Universal Rights:\n',
            style: const TextStyle(fontWeight: FontWeight.w600),
          ),
          const TextSpan(
            text: '• Right to Access: View stored data in app\n'
                '• Right to Delete: Settings > Delete All Data\n'
                '• Right to Correct: Edit content directly\n'
                '• Right to Export: Settings > Export My Data\n'
                '• Right to Withdraw Consent: Cancel subscription or uninstall\n\n',
          ),
          TextSpan(
            text: 'California (CCPA/CPRA) & EU (GDPR) Rights:\n',
            style: const TextStyle(fontWeight: FontWeight.w600),
          ),
          const TextSpan(
            text: 'Additional rights for California and EU residents apply. '
                'We do NOT sell personal information. '
                'Contact support@everydaychristian.app for requests.\n\n',
          ),

          // Data Retention
          TextSpan(
            text: '9. DATA RETENTION\n\n',
            style: TextStyle(
              fontSize: ResponsiveUtils.fontSize(context, 16, minSize: 14, maxSize: 18),
              fontWeight: FontWeight.w700,
              color: AppTheme.goldColor,
            ),
          ),
          const TextSpan(
            text: 'Local Storage: Retained indefinitely until you delete it\n'
                'Google Gemini: Retained per Google\'s AI data use policy\n'
                'Subscription Data: Managed by Apple/Google (7 years for financial records)\n\n'
                'You control retention through deletion options in Settings.\n\n',
          ),

          // Contact Information
          TextSpan(
            text: '10. CONTACT US\n\n',
            style: TextStyle(
              fontSize: ResponsiveUtils.fontSize(context, 16, minSize: 14, maxSize: 18),
              fontWeight: FontWeight.w700,
              color: AppTheme.goldColor,
            ),
          ),
          const TextSpan(
            text: 'For privacy inquiries or to exercise your rights:\n\n'
                'Email: support@everydaychristian.app\n'
                'Response Time: Within 30 days\n\n'
                'EU residents: Contact your local Data Protection Authority\n'
                'California residents: California Attorney General (oag.ca.gov/privacy)\n\n',
          ),

          // Footer
          TextSpan(
            text: '\n━━━━━━━━━━━━━━━━━━━━\n\n',
            style: TextStyle(color: Colors.white.withValues(alpha: 0.3)),
          ),
          TextSpan(
            text: 'By using Everyday Christian, you acknowledge that you have read and understood this Privacy Policy and agree to its terms.\n\n',
            style: TextStyle(
              fontStyle: FontStyle.italic,
              color: Colors.white.withValues(alpha: 0.8),
            ),
          ),
          TextSpan(
            text: 'For the complete Privacy Policy, visit Settings > Legal > Privacy Policy or contact support@everydaychristian.app\n',
            style: TextStyle(
              fontSize: ResponsiveUtils.fontSize(context, 12, minSize: 10, maxSize: 14),
              color: Colors.white.withValues(alpha: 0.6),
            ),
          ),
        ],
      ),
    );
  }

  void _showTermsOfService() {
    showDialog(
      context: context,
      builder: (context) => Dialog(
        backgroundColor: Colors.transparent,
        child: Container(
          constraints: BoxConstraints(
            maxHeight: MediaQuery.of(context).size.height * 0.85,
            maxWidth: ResponsiveUtils.maxContentWidth(context),
          ),
          child: FrostedGlassCard(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Header
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
                        borderRadius: BorderRadius.circular(AppRadius.xs + 2),
                        border: Border.all(
                          color: AppTheme.primaryColor.withValues(alpha: 0.3),
                          width: 1,
                        ),
                      ),
                      child: Icon(
                        Icons.description_outlined,
                        color: AppColors.primaryText,
                        size: ResponsiveUtils.iconSize(context, 20),
                      ),
                    ),
                    const SizedBox(width: AppSpacing.md),
                    Text(
                      'Terms of Service',
                      style: TextStyle(
                        fontSize: ResponsiveUtils.fontSize(context, 20, minSize: 18, maxSize: 24),
                        fontWeight: FontWeight.w700,
                        color: AppColors.primaryText,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: AppSpacing.sm),
                Text(
                  'Last Updated: October 17, 2025',
                  style: TextStyle(
                    fontSize: ResponsiveUtils.fontSize(context, 12, minSize: 10, maxSize: 14),
                    color: Colors.white.withValues(alpha: 0.6),
                  ),
                ),
                const SizedBox(height: AppSpacing.xl),

                // Scrollable Terms Content
                Expanded(
                  child: Container(
                    decoration: BoxDecoration(
                      color: Colors.black.withValues(alpha: 0.2),
                      borderRadius: AppRadius.mediumRadius,
                      border: Border.all(
                        color: Colors.white.withValues(alpha: 0.1),
                        width: 1,
                      ),
                    ),
                    child: SingleChildScrollView(
                      padding: AppSpacing.cardPadding,
                      child: _buildTermsOfServiceContent(),
                    ),
                  ),
                ),

                const SizedBox(height: AppSpacing.xl),

                // Close Button
                GlassButton(
                  text: 'Close',
                  height: 48,
                  onPressed: () => NavigationService.pop(),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildTermsOfServiceContent() {
    return SelectableText.rich(
      TextSpan(
        style: TextStyle(
          fontSize: ResponsiveUtils.fontSize(context, 14, minSize: 12, maxSize: 16),
          color: AppColors.primaryText,
          height: 1.6,
        ),
        children: [
          // Agreement to Terms
          TextSpan(
            text: '1. AGREEMENT TO TERMS\n\n',
            style: TextStyle(
              fontSize: ResponsiveUtils.fontSize(context, 16, minSize: 14, maxSize: 18),
              fontWeight: FontWeight.w700,
              color: AppTheme.goldColor,
            ),
          ),
          TextSpan(
            text: 'BY DOWNLOADING, INSTALLING, OR USING EVERYDAY CHRISTIAN, YOU AGREE TO BE BOUND BY THESE TERMS AND OUR PRIVACY POLICY. IF YOU DO NOT AGREE, DO NOT USE THE APP.\n\n',
            style: const TextStyle(fontWeight: FontWeight.w600),
          ),
          TextSpan(
            text: 'Age Requirements:\n',
            style: const TextStyle(fontWeight: FontWeight.w600),
          ),
          const TextSpan(
            text: '• Users 13+ may use all features\n'
                '• Under 13: Free features allowed with parental consent; Premium AI chat requires verifiable parental consent\n'
                '• Parents are responsible for monitoring children\'s use\n\n',
          ),

          // Service Description
          TextSpan(
            text: '2. DESCRIPTION OF SERVICE\n\n',
            style: TextStyle(
              fontSize: ResponsiveUtils.fontSize(context, 16, minSize: 14, maxSize: 18),
              fontWeight: FontWeight.w700,
              color: AppTheme.goldColor,
            ),
          ),
          TextSpan(
            text: 'Core Features (Free):\n',
            style: const TextStyle(fontWeight: FontWeight.w600),
          ),
          const TextSpan(
            text: '• 31,103 Bible verses (World English Bible)\n'
                '• Daily devotionals and Bible reading plans\n'
                '• Personal prayer journal with categories\n'
                '• Verse bookmarking and favorites\n'
                '• Crisis intervention resources (988 Lifeline)\n'
                '• Biometric authentication\n\n',
          ),
          TextSpan(
            text: 'Premium Features (\$35/year):\n',
            style: const TextStyle(fontWeight: FontWeight.w600),
          ),
          const TextSpan(
            text: '• AI-powered pastoral guidance (Google Gemini API)\n'
                '• 150 AI chat messages per month\n'
                '• Scripture-based guidance on faith questions\n'
                '• Conversation history stored locally\n\n',
          ),

          // Subscription Terms
          TextSpan(
            text: '3. PREMIUM SUBSCRIPTION\n\n',
            style: TextStyle(
              fontSize: ResponsiveUtils.fontSize(context, 16, minSize: 14, maxSize: 18),
              fontWeight: FontWeight.w700,
              color: AppTheme.goldColor,
            ),
          ),
          TextSpan(
            text: 'Subscription Details:\n',
            style: const TextStyle(fontWeight: FontWeight.w600),
          ),
          const TextSpan(
            text: '• Price: \$35/year USD (varies by region)\n'
                '• Features: 150 messages/month, all Premium features\n'
                '• Auto-Renewal: Renews annually unless canceled 24 hours before renewal\n'
                '• Refunds: Subject to Apple/Google refund policies\n'
                '• Unused messages do NOT roll over\n\n',
          ),
          TextSpan(
            text: 'Manage Subscription:\n',
            style: const TextStyle(fontWeight: FontWeight.w600),
          ),
          const TextSpan(
            text: '• iOS: Settings > [Your Name] > Subscriptions\n'
                '• Android: Google Play Store > Menu > Subscriptions\n\n',
          ),

          // User Conduct
          TextSpan(
            text: '4. USER CONDUCT & CONTENT POLICY\n\n',
            style: TextStyle(
              fontSize: ResponsiveUtils.fontSize(context, 16, minSize: 14, maxSize: 18),
              fontWeight: FontWeight.w700,
              color: AppTheme.goldColor,
            ),
          ),
          TextSpan(
            text: 'Prohibited Content:\n',
            style: const TextStyle(fontWeight: FontWeight.w600),
          ),
          const TextSpan(
            text: '❌ Hate speech, harassment, threats, or violence\n'
                '❌ Obscene, pornographic, or sexually explicit content\n'
                '❌ Promoting self-harm, suicide, or eating disorders\n'
                '❌ Prosperity gospel or spiritual manipulation\n'
                '❌ Spam or unsolicited promotional content\n\n',
          ),
          TextSpan(
            text: 'Enforcement:\n',
            style: const TextStyle(fontWeight: FontWeight.w600),
          ),
          const TextSpan(
            text: '• Warnings for policy violations\n'
                '• Temporary suspension of AI chat\n'
                '• Permanent suspension for severe violations\n'
                '• Account termination for repeated violations\n\n',
          ),

          // AI Disclaimer
          TextSpan(
            text: '5. AI GUIDANCE DISCLAIMER\n\n',
            style: TextStyle(
              fontSize: ResponsiveUtils.fontSize(context, 16, minSize: 14, maxSize: 18),
              fontWeight: FontWeight.w700,
              color: AppTheme.goldColor,
            ),
          ),
          TextSpan(
            text: 'AI IS NOT A SUBSTITUTE FOR:\n',
            style: const TextStyle(fontWeight: FontWeight.w600),
          ),
          const TextSpan(
            text: '• Professional mental health counseling\n'
                '• Medical advice, diagnosis, or treatment\n'
                '• Legal or financial advice\n'
                '• Professional pastoral counseling from clergy\n'
                '• Crisis intervention services\n\n'
                'AI responses are based on training data and may contain inaccuracies. '
                'Verify important matters with qualified clergy or professionals.\n\n'
                'IN CRISIS? Call 988 Suicide & Crisis Lifeline or 911 immediately.\n\n',
          ),

          // Intellectual Property
          TextSpan(
            text: '6. INTELLECTUAL PROPERTY\n\n',
            style: TextStyle(
              fontSize: ResponsiveUtils.fontSize(context, 16, minSize: 14, maxSize: 18),
              fontWeight: FontWeight.w700,
              color: AppTheme.goldColor,
            ),
          ),
          const TextSpan(
            text: 'You receive a limited, non-exclusive, non-transferable license to use the App for personal, non-commercial purposes.\n\n',
          ),
          TextSpan(
            text: 'You retain rights to:\n',
            style: const TextStyle(fontWeight: FontWeight.w600),
          ),
          const TextSpan(
            text: '• Your prayer journal entries\n'
                '• Your bookmarks and notes\n'
                '• Your AI chat conversations (stored locally)\n\n',
          ),
          TextSpan(
            text: 'Bible Translation:\n',
            style: const TextStyle(fontWeight: FontWeight.w600),
          ),
          const TextSpan(
            text: 'World English Bible (WEB) - Public Domain\n\n',
          ),

          // Disclaimers
          TextSpan(
            text: '7. DISCLAIMERS & LIMITATIONS\n\n',
            style: TextStyle(
              fontSize: ResponsiveUtils.fontSize(context, 16, minSize: 14, maxSize: 18),
              fontWeight: FontWeight.w700,
              color: AppTheme.goldColor,
            ),
          ),
          TextSpan(
            text: 'THE APP IS PROVIDED "AS IS" AND "AS AVAILABLE":\n',
            style: const TextStyle(fontWeight: FontWeight.w600),
          ),
          const TextSpan(
            text: '• We do NOT warrant accuracy of content or AI responses\n'
                '• We do NOT guarantee uninterrupted availability\n'
                '• We are NOT responsible for Google Gemini API performance\n\n',
          ),
          TextSpan(
            text: 'Limitation of Liability:\n',
            style: const TextStyle(fontWeight: FontWeight.w600),
          ),
          const TextSpan(
            text: 'Our total liability shall not exceed the amount you paid in the last 12 months or \$100 USD, whichever is greater.\n\n'
                'We are NOT liable for:\n'
                '• Loss of locally stored data\n'
                '• Inaccurate or harmful AI content\n'
                '• Emotional distress or spiritual harm\n'
                '• Consequential or indirect damages\n\n',
          ),

          // Dispute Resolution
          TextSpan(
            text: '8. DISPUTE RESOLUTION\n\n',
            style: TextStyle(
              fontSize: ResponsiveUtils.fontSize(context, 16, minSize: 14, maxSize: 18),
              fontWeight: FontWeight.w700,
              color: AppTheme.goldColor,
            ),
          ),
          TextSpan(
            text: 'Governing Law:\n',
            style: const TextStyle(fontWeight: FontWeight.w600),
          ),
          const TextSpan(
            text: 'These Terms are governed by the laws of [INSERT STATE], United States.\n\n',
          ),
          TextSpan(
            text: 'Informal Resolution:\n',
            style: const TextStyle(fontWeight: FontWeight.w600),
          ),
          const TextSpan(
            text: 'Before filing a claim, contact support@everydaychristian.app for good-faith negotiation (60 days).\n\n',
          ),
          TextSpan(
            text: 'Arbitration:\n',
            style: const TextStyle(fontWeight: FontWeight.w600),
          ),
          const TextSpan(
            text: 'Disputes will be resolved through binding individual arbitration (American Arbitration Association).\n\n'
                'NO CLASS ACTIONS: Claims brought only individually, not as class member.\n\n'
                'Opt-Out: Send written notice within 30 days of accepting Terms.\n\n'
                'Time Limit: Claims must be filed within ONE YEAR or are permanently barred.\n\n',
          ),

          // Termination
          TextSpan(
            text: '9. TERMINATION\n\n',
            style: TextStyle(
              fontSize: ResponsiveUtils.fontSize(context, 16, minSize: 14, maxSize: 18),
              fontWeight: FontWeight.w700,
              color: AppTheme.goldColor,
            ),
          ),
          TextSpan(
            text: 'By You:\n',
            style: const TextStyle(fontWeight: FontWeight.w600),
          ),
          const TextSpan(
            text: 'Uninstall the App or cancel Premium subscription anytime.\n\n',
          ),
          TextSpan(
            text: 'By Us:\n',
            style: const TextStyle(fontWeight: FontWeight.w600),
          ),
          const TextSpan(
            text: 'We may suspend/terminate access for:\n'
                '• Terms violations\n'
                '• Repeated content policy violations (3+ strikes)\n'
                '• Fraudulent or illegal activity\n\n'
                'No refunds for violations. Locally stored data remains on your device.\n\n',
          ),

          // Changes to Terms
          TextSpan(
            text: '10. MODIFICATIONS TO TERMS\n\n',
            style: TextStyle(
              fontSize: ResponsiveUtils.fontSize(context, 16, minSize: 14, maxSize: 18),
              fontWeight: FontWeight.w700,
              color: AppTheme.goldColor,
            ),
          ),
          const TextSpan(
            text: 'We may modify these Terms at any time:\n'
                '• Updates shown via in-app notification\n'
                '• Material changes require acceptance before continued use\n'
                '• Your continued use constitutes acceptance\n\n'
                'Material changes include pricing, features, limitations, dispute resolution, or new fees.\n\n',
          ),

          // Contact
          TextSpan(
            text: '11. CONTACT INFORMATION\n\n',
            style: TextStyle(
              fontSize: ResponsiveUtils.fontSize(context, 16, minSize: 14, maxSize: 18),
              fontWeight: FontWeight.w700,
              color: AppTheme.goldColor,
            ),
          ),
          const TextSpan(
            text: 'Questions about these Terms?\n\n'
                'Email: support@everydaychristian.app\n'
                'Response Time: 7 business days (general), 30 days (legal)\n\n'
                'Premium Support: Apple App Store or Google Play Store\n'
                'Technical Support: support@everydaychristian.app\n'
                'Content Violations: support@everydaychristian.app\n\n',
          ),

          // Footer
          TextSpan(
            text: '\n━━━━━━━━━━━━━━━━━━━━\n\n',
            style: TextStyle(color: Colors.white.withValues(alpha: 0.3)),
          ),
          TextSpan(
            text: 'BY USING EVERYDAY CHRISTIAN, YOU ACKNOWLEDGE THAT YOU HAVE READ, UNDERSTOOD, AND AGREE TO BE BOUND BY THESE TERMS OF SERVICE.\n\n',
            style: TextStyle(
              fontWeight: FontWeight.w600,
              fontStyle: FontStyle.italic,
              color: Colors.white.withValues(alpha: 0.9),
            ),
          ),
          TextSpan(
            text: 'For the complete Terms of Service, visit Settings > Legal > Terms of Service or contact support@everydaychristian.app\n',
            style: TextStyle(
              fontSize: ResponsiveUtils.fontSize(context, 12, minSize: 10, maxSize: 14),
              color: Colors.white.withValues(alpha: 0.6),
            ),
          ),
        ],
      ),
    );
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

// FAQ Item Model
class _FAQItem {
  final String question;
  final String answer;

  _FAQItem({
    required this.question,
    required this.answer,
  });
}