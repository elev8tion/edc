# Design System Migration Guide

## Overview

This document provides a complete migration guide from the old inconsistent design patterns to the new unified design system.

## What's New

### 1. Design Token System

Located in `/lib/theme/app_theme.dart`:

- **AppSpacing**: Consistent spacing values (xs, sm, md, lg, xl, xxl, xxxl, huge)
- **AppColors**: Semantic color tokens (primaryText, secondaryText, accent, etc.)
- **AppRadius**: Border radius constants (xs to xxl, pill)
- **AppBorders**: Predefined border styles (primaryGlass, subtle, iconContainer)
- **AppAnimations**: Animation duration constants (fast, normal, slow, sequential delays)
- **AppSizes**: Component size constants (icons, avatars, cards, buttons)
- **AppBlur**: Glass blur strength constants (light, medium, strong, veryStrong)

### 2. Unified Components

#### UnifiedGlassCard

Replaces: `FrostedGlassCard`, `ClearGlassCard`, `GlassCard`, `GlassContainer`, `FrostedGlass`, `ClearGlass`

```dart
// Default frosted style
UnifiedGlassCard(
  child: Text('Content'),
)

// Factory constructors for common patterns
UnifiedGlassCard.frosted(
  child: Text('Frosted effect'),
)

UnifiedGlassCard.clear(
  child: Text('Clear effect'),
)

UnifiedGlassCard.elevated(
  child: Text('Elevated with shadow'),
)
```

#### GlassIconAvatar

Replaces: 15+ inline icon container patterns

```dart
// Default medium size (40px)
GlassIconAvatar(
  icon: Icons.person,
)

// Named constructors
GlassIconAvatar.small(icon: Icons.add)
GlassIconAvatar.medium(icon: Icons.chat)
GlassIconAvatar.large(icon: Icons.settings)

// Rectangular variant
GlassIconContainer(
  icon: Icons.menu,
  borderRadius: AppRadius.sm,
)
```

#### GlassSectionHeader

New component for consistent section headers

```dart
GlassSectionHeader(
  title: 'My Section',
  icon: Icons.book,
  actionIcon: Icons.add,
  onActionTap: () => _handleAdd(),
)
```

### 3. NavigationService Enhancements

Added convenience methods:

```dart
// Old way ❌
Navigator.pushNamed(context, AppRoutes.chat)

// New way ✅
NavigationService.goToChat()

// All available convenience methods:
NavigationService.goToChat()
NavigationService.goToDevotional()
NavigationService.goToPrayerJournal()
NavigationService.goToVerseExplorer()
NavigationService.goToSettings()
NavigationService.goToProfile()
NavigationService.goToReadingPlan()
NavigationService.goToMemoryVerses()
NavigationService.goToSermonNotes()
NavigationService.goToCommunity()
NavigationService.pop()
```

## Migration Checklist

### Phase 1: Import Updates

```dart
// Add new imports to all screen files
import '../theme/app_theme.dart';
import '../core/navigation/navigation_service.dart';
import '../components/unified_glass_card.dart';
import '../components/glass_icon_avatar.dart';
import '../components/glass_section_header.dart';
```

### Phase 2: Replace Hardcoded Values

#### Spacing

```dart
// Before ❌
padding: const EdgeInsets.all(20)
padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16)
margin: const EdgeInsets.all(16)
SizedBox(height: 24)

// After ✅
padding: AppSpacing.screenPadding
padding: AppSpacing.buttonPadding
margin: AppSpacing.cardPadding
SizedBox(height: AppSpacing.xxl)
```

#### Colors

```dart
// Before ❌
color: Colors.white
color: Colors.white.withValues(alpha: 0.8)
color: Colors.black
color: AppTheme.goldColor.withValues(alpha: 0.6)

// After ✅
color: AppColors.primaryText
color: AppColors.secondaryText
color: AppColors.darkPrimaryText  // On light backgrounds only!
color: AppColors.accentBorder
```

#### Border Radius

```dart
// Before ❌
borderRadius: BorderRadius.circular(20)
borderRadius: BorderRadius.circular(24)
borderRadius: BorderRadius.circular(10)

// After ✅
borderRadius: AppRadius.cardRadius  // 20
borderRadius: AppRadius.largeCardRadius  // 24
borderRadius: AppRadius.mediumRadius  // 12
```

#### Borders

```dart
// Before ❌
border: Border.all(
  color: AppTheme.goldColor.withValues(alpha: 0.6),
  width: 2.0,
)

// After ✅
border: AppBorders.primaryGlass
```

#### Animations

```dart
// Before ❌
.animate().fadeIn(duration: 600.ms)
delay: 200.ms
delay: 400.ms

// After ✅
.animate().fadeIn(duration: AppAnimations.fadeIn)
delay: AppAnimations.baseDelay
delay: AppAnimations.sectionDelay
```

### Phase 3: Replace Glass Components

```dart
// Before ❌
FrostedGlassCard(
  padding: const EdgeInsets.all(16),
  child: ...,
)

ClearGlassCard(
  padding: const EdgeInsets.all(8),
  child: ...,
)

// After ✅
UnifiedGlassCard.frosted(
  padding: AppSpacing.cardPadding,
  child: ...,
)

UnifiedGlassCard.clear(
  padding: AppSpacing.cardPadding,
  child: ...,
)
```

### Phase 4: Replace Icon Containers

```dart
// Before ❌
Container(
  width: 40,
  height: 40,
  decoration: BoxDecoration(
    shape: BoxShape.circle,
    border: Border.all(
      color: AppTheme.goldColor.withValues(alpha: 0.6),
      width: 1.5,
    ),
    color: AppTheme.primaryColor.withValues(alpha: 0.3),
  ),
  child: Icon(Icons.person, color: Colors.white, size: 20),
)

// After ✅
GlassIconAvatar(
  icon: Icons.person,
)
```

### Phase 5: Fix Navigation

```dart
// Before ❌
Navigator.pushNamed(context, AppRoutes.chat)
Navigator.pop(context)

// After ✅
NavigationService.goToChat()
NavigationService.pop()
```

### Phase 6: Fix Text Colors on Gradients

**CRITICAL**: Black text on dark gradient backgrounds is a readability issue.

```dart
// Before ❌ (on dark gradient background)
Text(
  'Subtitle',
  style: TextStyle(color: Colors.black),
)

// After ✅
Text(
  'Subtitle',
  style: TextStyle(color: AppColors.secondaryText),
)

// On light cards only:
Text(
  'Subtitle',
  style: TextStyle(color: AppColors.darkSecondaryText),
)
```

## File-by-File Migration Order

### High Priority (Phase 1)
1. ✅ `/lib/theme/app_theme.dart` - Design tokens added
2. ✅ `/lib/core/navigation/navigation_service.dart` - Convenience methods added
3. ✅ `/lib/components/unified_glass_card.dart` - Created
4. ✅ `/lib/components/glass_icon_avatar.dart` - Created
5. ✅ `/lib/components/glass_section_header.dart` - Created

### High Priority (Phase 2) - Main Screens
6. `/lib/screens/home_screen.dart` - 10 Navigator calls, 8 inline styles, 1 color issue
7. `/lib/screens/chat_screen.dart` - Navigator calls, spacing issues
8. `/lib/screens/devotional_screen.dart` - Color issues, spacing
9. `/lib/screens/prayer_journal_screen.dart` - Navigator calls, state management
10. `/lib/screens/settings_screen.dart` - Navigator calls, spacing

### Medium Priority (Phase 3) - Other Screens
11. `/lib/screens/profile_screen.dart`
12. `/lib/screens/verse_explorer_screen.dart`
13. `/lib/screens/reading_plan_screen.dart`
14. `/lib/screens/memory_verses_screen.dart`
15. `/lib/screens/sermon_notes_screen.dart`
16. `/lib/screens/community_screen.dart`

### Low Priority (Phase 4) - Cleanup
17. Delete deprecated components:
    - `/lib/components/frosted_glass_card.dart`
    - `/lib/components/clear_glass_card.dart`
    - `/lib/components/glass_card.dart` (keep GlassBottomSheet → migrate to UnifiedGlassBottomSheet)
    - `/lib/components/frosted_glass.dart`

## Testing Checklist

After migration, verify:

- [ ] All screens render correctly
- [ ] No black text on dark backgrounds
- [ ] Consistent spacing throughout app
- [ ] All navigation works (no broken routes)
- [ ] Glass effects look identical to before
- [ ] Animations have consistent timing
- [ ] No build errors or warnings
- [ ] Hot reload works properly
- [ ] All tests pass

## Benefits After Migration

1. **Reduced Code**: ~20% reduction by eliminating duplication
2. **Consistency**: All components follow same patterns
3. **Maintainability**: Change once, apply everywhere
4. **Accessibility**: Better contrast, semantic labels
5. **Developer Experience**: Autocomplete, clear API
6. **Performance**: Const constructors where possible

## Quick Reference

### Spacing Scale
```
xs: 4px   |  sm: 8px   |  md: 12px  |  lg: 16px
xl: 20px  |  xxl: 24px |  xxxl: 32px | huge: 40px
```

### Common Patterns
```dart
// Screen padding
padding: AppSpacing.screenPadding  // 20px all sides

// Card padding
padding: AppSpacing.cardPadding  // 16px all sides

// Vertical spacing between sections
SizedBox(height: AppSpacing.xxl)  // 24px

// Icon sizes
size: AppSizes.iconMd  // 24px (default)

// Avatar sizes
size: AppSizes.avatarMd  // 40px (default)
```

## Support

If you encounter issues during migration:
1. Check this guide for the correct pattern
2. Look at migrated files for examples
3. Ensure all imports are correct
4. Run `flutter clean && flutter pub get` if issues persist
