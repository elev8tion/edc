import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/prayer_category.dart';
import '../services/category_service.dart';
import '../error/error_handler.dart';
import 'app_providers.dart';

// Category Service Provider
final categoryServiceProvider = Provider<CategoryService>((ref) {
  final database = ref.watch(databaseServiceProvider);
  return CategoryService(database);
});

// Active Categories Provider
final activeCategoriesProvider = FutureProvider<List<PrayerCategory>>((ref) async {
  try {
    final service = ref.read(categoryServiceProvider);
    return await service.getActiveCategories();
  } catch (error) {
    throw ErrorHandler.handle(error);
  }
});

// All Categories Provider (including inactive)
final allCategoriesProvider = FutureProvider<List<PrayerCategory>>((ref) async {
  try {
    final service = ref.read(categoryServiceProvider);
    return await service.getAllCategories();
  } catch (error) {
    throw ErrorHandler.handle(error);
  }
});

// Category by ID Provider
final categoryByIdProvider = FutureProvider.family<PrayerCategory?, String>((ref, id) async {
  try {
    final service = ref.read(categoryServiceProvider);
    return await service.getCategoryById(id);
  } catch (error) {
    throw ErrorHandler.handle(error);
  }
});

// Category Statistics Provider
final categoryStatisticsProvider = FutureProvider.family<CategoryStatistics, String>((ref, categoryId) async {
  try {
    final service = ref.read(categoryServiceProvider);
    return await service.getCategoryStatistics(categoryId);
  } catch (error) {
    throw ErrorHandler.handle(error);
  }
});

// All Category Statistics Provider
final allCategoryStatisticsProvider = FutureProvider<List<CategoryStatistics>>((ref) async {
  try {
    final service = ref.read(categoryServiceProvider);
    return await service.getAllCategoryStatistics();
  } catch (error) {
    throw ErrorHandler.handle(error);
  }
});

// Custom Category Count Provider
final customCategoryCountProvider = FutureProvider<int>((ref) async {
  try {
    final service = ref.read(categoryServiceProvider);
    return await service.getCustomCategoryCount();
  } catch (error) {
    throw ErrorHandler.handle(error);
  }
});

// Selected Category Filter State Provider (for UI filtering)
final selectedCategoryFilterProvider = StateProvider<String?>((ref) => null);

// Category Actions
final categoryActionsProvider = Provider<CategoryActions>((ref) {
  final service = ref.read(categoryServiceProvider);

  return CategoryActions(
    createCategory: (name, iconCodePoint, colorValue) async {
      try {
        final category = await service.createCategory(
          name: name,
          iconCodePoint: iconCodePoint,
          colorValue: colorValue,
        );

        // Invalidate providers to refresh UI
        ref.invalidate(activeCategoriesProvider);
        ref.invalidate(allCategoriesProvider);
        ref.invalidate(customCategoryCountProvider);
        ref.invalidate(allCategoryStatisticsProvider);

        return category;
      } catch (error) {
        throw ErrorHandler.handle(error);
      }
    },
    updateCategory: (category) async {
      try {
        await service.updateCategory(category);

        // Invalidate providers to refresh UI
        ref.invalidate(activeCategoriesProvider);
        ref.invalidate(allCategoriesProvider);
        ref.invalidate(categoryByIdProvider(category.id));
        ref.invalidate(allCategoryStatisticsProvider);
      } catch (error) {
        throw ErrorHandler.handle(error);
      }
    },
    deleteCategory: (id) async {
      try {
        await service.deleteCategory(id);

        // Invalidate providers to refresh UI
        ref.invalidate(activeCategoriesProvider);
        ref.invalidate(allCategoriesProvider);
        ref.invalidate(customCategoryCountProvider);
        ref.invalidate(allCategoryStatisticsProvider);
      } catch (error) {
        throw ErrorHandler.handle(error);
      }
    },
    toggleCategoryActive: (id) async {
      try {
        await service.toggleCategoryActive(id);

        // Invalidate providers to refresh UI
        ref.invalidate(activeCategoriesProvider);
        ref.invalidate(allCategoriesProvider);
        ref.invalidate(categoryByIdProvider(id));
      } catch (error) {
        throw ErrorHandler.handle(error);
      }
    },
    reorderCategories: (categoryIds) async {
      try {
        await service.reorderCategories(categoryIds);

        // Invalidate providers to refresh UI
        ref.invalidate(activeCategoriesProvider);
        ref.invalidate(allCategoriesProvider);
      } catch (error) {
        throw ErrorHandler.handle(error);
      }
    },
    resetToDefaults: () async {
      try {
        await service.resetToDefaults();

        // Invalidate providers to refresh UI
        ref.invalidate(activeCategoriesProvider);
        ref.invalidate(allCategoriesProvider);
        ref.invalidate(customCategoryCountProvider);
        ref.invalidate(allCategoryStatisticsProvider);
      } catch (error) {
        throw ErrorHandler.handle(error);
      }
    },
    isCategoryNameAvailable: (name, {excludeId}) async {
      try {
        return await service.isCategoryNameAvailable(name, excludeId: excludeId);
      } catch (error) {
        throw ErrorHandler.handle(error);
      }
    },
  );
});

class CategoryActions {
  final Future<PrayerCategory> Function(String name, int iconCodePoint, int colorValue) createCategory;
  final Future<void> Function(PrayerCategory category) updateCategory;
  final Future<void> Function(String id) deleteCategory;
  final Future<void> Function(String id) toggleCategoryActive;
  final Future<void> Function(List<String> categoryIds) reorderCategories;
  final Future<void> Function() resetToDefaults;
  final Future<bool> Function(String name, {String? excludeId}) isCategoryNameAvailable;

  CategoryActions({
    required this.createCategory,
    required this.updateCategory,
    required this.deleteCategory,
    required this.toggleCategoryActive,
    required this.reorderCategories,
    required this.resetToDefaults,
    required this.isCategoryNameAvailable,
  });
}
