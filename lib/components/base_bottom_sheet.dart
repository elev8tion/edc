import 'dart:ui';
import 'package:flutter/material.dart';
import '../theme/app_theme.dart';

/// Base bottom sheet widget with consistent styling
class BaseBottomSheet extends StatelessWidget {
  final Widget child;
  final String? title;
  final bool showHandle;
  final double? height;

  const BaseBottomSheet({
    super.key,
    required this.child,
    this.title,
    this.showHandle = true,
    this.height,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return ClipRRect(
      borderRadius: const BorderRadius.vertical(
        top: Radius.circular(32),
      ),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 40, sigmaY: 40),
        child: Container(
          height: height,
          decoration: BoxDecoration(
            color: isDark
                ? Colors.white.withValues(alpha: 0.1)
                : Colors.white.withValues(alpha: 0.2),
            borderRadius: const BorderRadius.vertical(
              top: Radius.circular(32),
            ),
            border: Border.all(
              color: isDark ? Colors.white24 : Colors.white54,
              width: 2,
            ),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              if (showHandle)
                Container(
                  width: 40,
                  height: 4,
                  margin: const EdgeInsets.only(top: 12),
                  decoration: BoxDecoration(
                    color: Colors.white.withValues(alpha: 0.5),
                    borderRadius: BorderRadius.circular(AppRadius.xs / 4),
                  ),
                ),
              if (title != null)
                Padding(
                  padding: const EdgeInsets.all(24),
                  child: Text(
                    title!,
                    style: const TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                ),
              Flexible(child: child),
            ],
          ),
        ),
      ),
    );
  }
}

/// Helper function for showing bottom sheets with full-screen blur effect
Future<T?> showCustomBottomSheet<T>({
  required BuildContext context,
  required Widget child,
  String? title,
  bool showHandle = true,
  double? height,
}) {
  return showModalBottomSheet<T>(
    context: context,
    isScrollControlled: true,
    backgroundColor: Colors.transparent,
    enableDrag: true,
    isDismissible: true,
    barrierColor: Colors.black.withValues(alpha: 0.6),
    builder: (context) => BackdropFilter(
      filter: ImageFilter.blur(sigmaX: 20, sigmaY: 20),
      child: BaseBottomSheet(
        title: title,
        showHandle: showHandle,
        height: height,
        child: child,
      ),
    ),
  );
}
