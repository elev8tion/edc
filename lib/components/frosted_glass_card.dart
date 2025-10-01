import 'package:flutter/material.dart';
import 'dart:ui';
import '../theme/app_theme.dart';

class FrostedGlassCard extends StatelessWidget {
  final Widget child;
  final VoidCallback? onTap;
  final EdgeInsetsGeometry? margin;
  final EdgeInsetsGeometry? padding;
  final double borderRadius;
  final double blurStrength;

  const FrostedGlassCard({
    super.key,
    required this.child,
    this.onTap,
    this.margin,
    this.padding = const EdgeInsets.all(16),
    this.borderRadius = 20,
    this.blurStrength = 40.0,
  });

  @override
  Widget build(BuildContext context) {
    Widget cardWidget = Container(
      margin: margin,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(borderRadius),
        border: Border.all(
          color: AppTheme.goldColor.withValues(alpha: 0.6),
          width: 2.0,
        ),
        boxShadow: AppTheme.elevatedShadow,
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(borderRadius - 2),
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: blurStrength, sigmaY: blurStrength),
          child: Container(
            padding: padding,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(borderRadius - 2),
              gradient: LinearGradient(
                colors: [
                  Colors.white.withValues(alpha: 0.15),
                  Colors.white.withValues(alpha: 0.08),
                ],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
            ),
            child: child,
          ),
        ),
      ),
    );

    if (onTap != null) {
      return GestureDetector(
        onTap: onTap,
        child: cardWidget,
      );
    }

    return cardWidget;
  }
}