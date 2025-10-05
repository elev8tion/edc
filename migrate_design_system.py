#!/usr/bin/env python3
"""
Design System Migration Script

This script automates the migration from old patterns to the new design token system.
It performs the following transformations:
1. Replace hardcoded spacing values with AppSpacing constants
2. Replace hardcoded colors with AppColors constants
3. Replace Navigator calls with NavigationService
4. Replace old glass components with UnifiedGlassCard
5. Add missing imports
"""

import re
import os
from pathlib import Path

# Migration mappings
SPACING_REPLACEMENTS = {
    r'const EdgeInsets\.all\(20\)': 'AppSpacing.screenPadding',
    r'const EdgeInsets\.all\(24\)': 'AppSpacing.screenPaddingLarge',
    r'const EdgeInsets\.all\(16\)': 'AppSpacing.cardPadding',
    r'const EdgeInsets\.all\(8\)': 'const EdgeInsets.all(AppSpacing.sm)',
    r'const EdgeInsets\.all\(12\)': 'const EdgeInsets.all(AppSpacing.md)',

    r'const EdgeInsets\.symmetric\(horizontal: 20\)': 'AppSpacing.horizontalXl',
    r'const EdgeInsets\.symmetric\(horizontal: 24\)': 'AppSpacing.horizontalXxl',
    r'const EdgeInsets\.symmetric\(horizontal: 16\)': 'AppSpacing.horizontalLg',
    r'const EdgeInsets\.symmetric\(horizontal: 12\)': 'AppSpacing.horizontalMd',
    r'const EdgeInsets\.symmetric\(horizontal: 8\)': 'AppSpacing.horizontalSm',

    r'const EdgeInsets\.symmetric\(vertical: 20\)': 'AppSpacing.verticalXl',
    r'const EdgeInsets\.symmetric\(vertical: 16\)': 'AppSpacing.verticalLg',
    r'const EdgeInsets\.symmetric\(vertical: 12\)': 'AppSpacing.verticalMd',
    r'const EdgeInsets\.symmetric\(vertical: 8\)': 'AppSpacing.verticalSm',

    r'SizedBox\(height: 24\)': 'SizedBox(height: AppSpacing.xxl)',
    r'SizedBox\(height: 20\)': 'SizedBox(height: AppSpacing.xl)',
    r'SizedBox\(height: 16\)': 'SizedBox(height: AppSpacing.lg)',
    r'SizedBox\(height: 12\)': 'SizedBox(height: AppSpacing.md)',
    r'SizedBox\(height: 8\)': 'SizedBox(height: AppSpacing.sm)',

    r'SizedBox\(width: 24\)': 'SizedBox(width: AppSpacing.xxl)',
    r'SizedBox\(width: 20\)': 'SizedBox(width: AppSpacing.xl)',
    r'SizedBox\(width: 16\)': 'SizedBox(width: AppSpacing.lg)',
    r'SizedBox\(width: 12\)': 'SizedBox(width: AppSpacing.md)',
    r'SizedBox\(width: 8\)': 'SizedBox(width: AppSpacing.sm)',
}

COLOR_REPLACEMENTS = {
    r'color: Colors\.white,': 'color: AppColors.primaryText,',
    r'color: Colors\.white\.withValues\(alpha: 0\.8\)': 'color: AppColors.secondaryText',
    r'color: Colors\.white\.withValues\(alpha: 0\.6\)': 'color: AppColors.tertiaryText',
}

NAVIGATION_REPLACEMENTS = {
    r'Navigator\.pushNamed\(context, AppRoutes\.chat\)': 'NavigationService.goToChat()',
    r'Navigator\.pushNamed\(context, AppRoutes\.devotional\)': 'NavigationService.goToDevotional()',
    r'Navigator\.pushNamed\(context, AppRoutes\.prayerJournal\)': 'NavigationService.goToPrayerJournal()',
    r'Navigator\.pushNamed\(context, AppRoutes\.verseExplorer\)': 'NavigationService.goToVerseExplorer()',
    r'Navigator\.pushNamed\(context, AppRoutes\.settings\)': 'NavigationService.goToSettings()',
    r'Navigator\.pushNamed\(context, AppRoutes\.profile\)': 'NavigationService.goToProfile()',
    r'Navigator\.pushNamed\(context, AppRoutes\.readingPlan\)': 'NavigationService.goToReadingPlan()',
    r'Navigator\.pushNamed\(context, AppRoutes\.memoryVerses\)': 'NavigationService.goToMemoryVerses()',
    r'Navigator\.pushNamed\(context, AppRoutes\.sermonNotes\)': 'NavigationService.goToSermonNotes()',
    r'Navigator\.pushNamed\(context, AppRoutes\.community\)': 'NavigationService.goToCommunity()',
    r'Navigator\.pop\(context\)': 'NavigationService.pop()',
}

ANIMATION_REPLACEMENTS = {
    r'600\.ms': 'AppAnimations.slow',
    r'400\.ms': 'AppAnimations.normal',
    r'200\.ms': 'AppAnimations.fast',
}

IMPORT_REPLACEMENTS = {
    r"import '../components/frosted_glass_card.dart';": "import '../components/unified_glass_card.dart';",
    r"import '../components/clear_glass_card.dart';": "import '../components/unified_glass_card.dart';",
    r"import '../components/glass_card.dart';": "import '../components/unified_glass_card.dart';",
}

def add_missing_imports(content: str) -> str:
    """Add missing imports if needed"""
    imports = []

    # Check if NavigationService is used but not imported
    if 'NavigationService' in content and "import '../core/navigation/navigation_service.dart';" not in content:
        imports.append("import '../core/navigation/navigation_service.dart';")

    # Check if AppSpacing/AppColors are used but theme import is missing
    if ('AppSpacing' in content or 'AppColors' in content or 'AppRadius' in content) and \
       "import '../theme/app_theme.dart';" not in content:
        imports.append("import '../theme/app_theme.dart';")

    if imports:
        # Find the last import line
        import_pattern = r"import\s+['\"].*?['\"];"
        matches = list(re.finditer(import_pattern, content))
        if matches:
            last_import_end = matches[-1].end()
            return content[:last_import_end] + '\n' + '\n'.join(imports) + content[last_import_end:]

    return content

def migrate_file(file_path: Path) -> bool:
    """Migrate a single file"""
    try:
        with open(file_path, 'r', encoding='utf-8') as f:
            content = f.read()

        original_content = content
        changes_made = False

        # Apply spacing replacements
        for pattern, replacement in SPACING_REPLACEMENTS.items():
            new_content = re.sub(pattern, replacement, content)
            if new_content != content:
                changes_made = True
                content = new_content

        # Apply color replacements
        for pattern, replacement in COLOR_REPLACEMENTS.items():
            new_content = re.sub(pattern, replacement, content)
            if new_content != content:
                changes_made = True
                content = new_content

        # Apply navigation replacements
        for pattern, replacement in NAVIGATION_REPLACEMENTS.items():
            new_content = re.sub(pattern, replacement, content)
            if new_content != content:
                changes_made = True
                content = new_content

        # Apply animation replacements
        for pattern, replacement in ANIMATION_REPLACEMENTS.items():
            new_content = re.sub(pattern, replacement, content)
            if new_content != content:
                changes_made = True
                content = new_content

        # Apply import replacements
        for pattern, replacement in IMPORT_REPLACEMENTS.items():
            new_content = re.sub(pattern, replacement, content)
            if new_content != content:
                changes_made = True
                content = new_content

        # Add missing imports
        content = add_missing_imports(content)

        # Only write if changes were made
        if content != original_content:
            with open(file_path, 'w', encoding='utf-8') as f:
                f.write(content)
            print(f"✅ Migrated: {file_path}")
            return True
        else:
            print(f"⏭️  No changes: {file_path}")
            return False

    except Exception as e:
        print(f"❌ Error migrating {file_path}: {e}")
        return False

def main():
    """Main migration function"""
    print("=" * 80)
    print("Design System Migration Tool")
    print("=" * 80)

    # Get the project root
    script_dir = Path(__file__).parent
    screens_dir = script_dir / 'lib' / 'screens'

    if not screens_dir.exists():
        print(f"❌ Screens directory not found: {screens_dir}")
        return

    # Find all Dart files in screens directory
    dart_files = list(screens_dir.glob('*.dart'))

    print(f"\nFound {len(dart_files)} screen files to migrate\n")

    migrated_count = 0
    for dart_file in sorted(dart_files):
        if migrate_file(dart_file):
            migrated_count += 1

    print("\n" + "=" * 80)
    print(f"Migration complete!")
    print(f"✅ {migrated_count} files migrated")
    print(f"⏭️  {len(dart_files) - migrated_count} files unchanged")
    print("=" * 80)
    print("\nNext steps:")
    print("1. Run 'flutter analyze' to check for issues")
    print("2. Review changes with 'git diff'")
    print("3. Test the app thoroughly")
    print("4. Run 'flutter test' to ensure tests pass")

if __name__ == '__main__':
    main()
