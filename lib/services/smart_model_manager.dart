import 'dart:async';
import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:path_provider/path_provider.dart';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'model_downloader.dart';

/// Smart model manager that handles automatic background downloading
/// with multiple strategies for optimal user experience
class SmartModelManager {
  static SmartModelManager? _instance;
  static SmartModelManager get instance {
    _instance ??= SmartModelManager._internal();
    return _instance!;
  }

  SmartModelManager._internal();

  // Model options with sizes
  static const Map<String, ModelConfig> modelOptions = {
    'nano': ModelConfig(
      name: 'Gemma 270M',
      url: 'https://huggingface.co/google/gemma-3-270m-it/resolve/main/model.gguf',
      size: 110 * 1024 * 1024, // ~110MB
      quality: 'basic',
      bundleable: true,
    ),
    'mini': ModelConfig(
      name: 'Gemma 2B Q2_K',
      url: 'https://huggingface.co/lmstudio-community/gemma-2-2b-it-GGUF/resolve/main/gemma-2-2b-it-Q2_K.gguf',
      size: 400 * 1024 * 1024, // ~400MB
      quality: 'moderate',
      bundleable: true,
    ),
    'standard': ModelConfig(
      name: 'Gemma 2B Q4_K_M',
      url: 'https://huggingface.co/lmstudio-community/gemma-2-2b-it-GGUF/resolve/main/gemma-2-2b-it-Q4_K_M.gguf',
      size: 1577058304, // ~1.5GB
      quality: 'high',
      bundleable: false,
    ),
  };

  bool _isDownloading = false;
  double _downloadProgress = 0.0;
  StreamController<ModelStatus>? _statusController;
  Timer? _downloadTimer;

  /// Get current model status stream
  Stream<ModelStatus> get statusStream {
    _statusController ??= StreamController<ModelStatus>.broadcast();
    return _statusController!.stream;
  }

  /// Initialize and start smart download if needed
  Future<void> initialize() async {
    final prefs = await SharedPreferences.getInstance();
    final hasCompletedOnboarding = prefs.getBool('onboarding_completed') ?? false;

    // Check what models we have
    final hasNano = await _isModelDownloaded('nano');
    final hasMini = await _isModelDownloaded('mini');
    final hasStandard = await _isModelDownloaded('standard');

    // Determine download strategy
    if (!hasCompletedOnboarding) {
      // First launch - start progressive download during onboarding
      await _startProgressiveDownload();
    } else if (!hasStandard && !hasMini && !hasNano) {
      // No models at all - emergency download
      await _startEmergencyDownload();
    } else if (!hasStandard) {
      // Has basic model but not premium - background upgrade
      await _scheduleBackgroundUpgrade();
    }
  }

  /// Progressive download during onboarding
  Future<void> _startProgressiveDownload() async {
    debugPrint('📥 Starting progressive model download during onboarding');

    // First, try to get the mini model quickly
    if (!await _isModelDownloaded('mini')) {
      _downloadModel('mini', priority: true);
    }

    // Then schedule the full model for background
    _scheduleBackgroundUpgrade();
  }

  /// Emergency download when no models available
  Future<void> _startEmergencyDownload() async {
    debugPrint('🚨 No models found - starting emergency download');

    // Check connectivity
    final connectivityResult = await Connectivity().checkConnectivity();
    if (connectivityResult == ConnectivityResult.none) {
      _notifyStatus(ModelStatus(
        state: ModelState.error,
        message: 'No internet connection. AI features unavailable.',
      ));
      return;
    }

    // Download smallest usable model first
    await _downloadModel('mini', priority: true);
  }

  /// Schedule background upgrade to better model
  Future<void> _scheduleBackgroundUpgrade() async {
    // Wait for good conditions (WiFi, charging, etc.)
    Timer.periodic(const Duration(minutes: 5), (timer) async {
      if (await _shouldDownloadNow()) {
        timer.cancel();
        await _downloadModel('standard', priority: false);
      }
    });
  }

  /// Check if conditions are good for download
  Future<bool> _shouldDownloadNow() async {
    // Check WiFi
    final connectivityResult = await Connectivity().checkConnectivity();
    if (connectivityResult != ConnectivityResult.wifi) {
      return false; // Only download on WiFi
    }

    // Check storage
    final dir = await getApplicationDocumentsDirectory();
    final stat = await dir.stat();
    // Note: This is simplified - in production, use device_info_plus for accurate storage

    // Check time (prefer night time downloads)
    final hour = DateTime.now().hour;
    final isNightTime = hour >= 23 || hour <= 6;

    return true; // Simplified for now
  }

  /// Download a specific model
  Future<bool> _downloadModel(String modelKey, {required bool priority}) async {
    if (_isDownloading) return false;

    final config = modelOptions[modelKey];
    if (config == null) return false;

    _isDownloading = true;
    _notifyStatus(ModelStatus(
      state: ModelState.downloading,
      progress: 0,
      message: 'Downloading ${config.name}...',
    ));

    try {
      await ModelDownloader.downloadGemmaModel(
        modelUrl: config.url,
        modelSize: config.size,
        onProgress: (progress) {
          _downloadProgress = progress;
          _notifyStatus(ModelStatus(
            state: ModelState.downloading,
            progress: progress,
            message: 'Downloading ${config.name}: ${(progress * 100).toStringAsFixed(1)}%',
          ));
        },
        onError: (error) {
          _notifyStatus(ModelStatus(
            state: ModelState.error,
            message: error,
          ));
        },
        onSuccess: (path) {
          _saveModelPath(modelKey, path);
          _notifyStatus(ModelStatus(
            state: ModelState.ready,
            message: '${config.name} ready',
            modelPath: path,
          ));
        },
      );

      _isDownloading = false;
      return true;
    } catch (e) {
      _isDownloading = false;
      debugPrint('Download failed: $e');
      return false;
    }
  }

  /// Check if a model is downloaded
  Future<bool> _isModelDownloaded(String modelKey) async {
    final prefs = await SharedPreferences.getInstance();
    final path = prefs.getString('model_path_$modelKey');
    if (path == null) return false;

    final file = File(path);
    return await file.exists();
  }

  /// Save model path
  Future<void> _saveModelPath(String modelKey, String path) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('model_path_$modelKey', path);
  }

  /// Get best available model
  Future<String?> getBestAvailableModel() async {
    // Priority: standard > mini > nano
    for (final key in ['standard', 'mini', 'nano']) {
      if (await _isModelDownloaded(key)) {
        final prefs = await SharedPreferences.getInstance();
        return prefs.getString('model_path_$key');
      }
    }
    return null;
  }

  /// Notify status changes
  void _notifyStatus(ModelStatus status) {
    _statusController?.add(status);
  }

  /// Clean up resources
  void dispose() {
    _downloadTimer?.cancel();
    _statusController?.close();
  }
}

/// Model configuration
class ModelConfig {
  final String name;
  final String url;
  final int size;
  final String quality;
  final bool bundleable;

  const ModelConfig({
    required this.name,
    required this.url,
    required this.size,
    required this.quality,
    required this.bundleable,
  });
}

/// Model status
class ModelStatus {
  final ModelState state;
  final double? progress;
  final String? message;
  final String? modelPath;

  const ModelStatus({
    required this.state,
    this.progress,
    this.message,
    this.modelPath,
  });
}

/// Model states
enum ModelState {
  checking,
  downloading,
  ready,
  error,
}

/// Extension to original ModelDownloader
extension SmartDownloader on ModelDownloader {
  static Future<void> downloadGemmaModel({
    String? modelUrl,
    int? modelSize,
    required Function(double) onProgress,
    required Function(String) onError,
    required Function(String) onSuccess,
  }) async {
    // Use provided URL or default
    final url = modelUrl ?? ModelDownloader.modelUrl;
    final size = modelSize ?? ModelDownloader.modelSize;

    // Delegate to original downloader
    await ModelDownloader.downloadGemmaModel(
      onProgress: onProgress,
      onError: onError,
      onSuccess: onSuccess,
    );
  }
}