import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:onnxruntime/onnxruntime.dart';
import 'package:path_provider/path_provider.dart';

/// Service for loading and managing ONNX models
class OnnxModelService {
  static OnnxModelService? _instance;
  OnnxSession? _session;

  bool _isInitialized = false;
  bool _isModelLoaded = false;

  // Model configuration
  static const String modelFileName = 'phi-3-mini-4k-instruct-cpu-int4-rtn-block-32-acc-level-4.onnx';
  static const String modelAssetPath = 'assets/models/$modelFileName';

  OnnxModelService._();

  static OnnxModelService get instance {
    _instance ??= OnnxModelService._();
    return _instance!;
  }

  bool get isReady => _isInitialized && _isModelLoaded;

  /// Initialize the ONNX model service
  Future<void> initialize() async {
    if (_isInitialized) {
      debugPrint('✅ ONNX Model Service already initialized');
      return;
    }

    try {
      debugPrint('🤖 Initializing ONNX Model Service...');

      // Initialize ONNX Runtime
      OnnxRuntime.initialize();
      _isInitialized = true;

      debugPrint('✅ ONNX Runtime initialized');
    } catch (e) {
      debugPrint('❌ Failed to initialize ONNX Runtime: $e');
      _isInitialized = false;
      rethrow;
    }
  }

  /// Load the Phi-3 Mini model
  Future<bool> loadModel() async {
    if (!_isInitialized) {
      debugPrint('❌ ONNX Runtime not initialized. Call initialize() first.');
      return false;
    }

    if (_isModelLoaded) {
      debugPrint('✅ Model already loaded');
      return true;
    }

    try {
      debugPrint('📦 Loading Phi-3 Mini INT4 model (~500 MB)...');

      // Check if model exists in assets
      final modelPath = await _getModelPath();

      if (modelPath == null) {
        debugPrint('⚠️ Model file not found. Using fallback responses.');
        return false;
      }

      // Create session options
      final sessionOptions = OnnxSessionOptions()
        ..setInterOpNumThreads(4)  // Use 4 threads for better performance
        ..setIntraOpNumThreads(4)
        ..setSessionGraphOptimizationLevel(
          GraphOptimizationLevel.ortEnableAll,
        );

      // Load the model
      _session = OnnxSession.fromFile(
        modelPath,
        sessionOptions,
      );

      _isModelLoaded = true;
      debugPrint('✅ Phi-3 Mini model loaded successfully');
      debugPrint('📊 Model input names: ${_session!.inputNames}');
      debugPrint('📊 Model output names: ${_session!.outputNames}');

      return true;
    } catch (e) {
      debugPrint('❌ Failed to load model: $e');
      _isModelLoaded = false;
      return false;
    }
  }

  /// Get the path to the model file
  Future<String?> _getModelPath() async {
    try {
      // Try to load from assets first
      final byteData = await rootBundle.load(modelAssetPath);

      // Copy to temp directory for ONNX Runtime to access
      final tempDir = await getTemporaryDirectory();
      final modelFile = File('${tempDir.path}/$modelFileName');

      await modelFile.writeAsBytes(
        byteData.buffer.asUint8List(),
        flush: true,
      );

      debugPrint('✅ Model copied to: ${modelFile.path}');
      return modelFile.path;
    } catch (e) {
      debugPrint('⚠️ Model not found in assets: $e');

      // Check if model exists in app documents directory (manual download)
      try {
        final docsDir = await getApplicationDocumentsDirectory();
        final manualModelPath = '${docsDir.path}/models/$modelFileName';
        final manualFile = File(manualModelPath);

        if (await manualFile.exists()) {
          debugPrint('✅ Found model in documents: $manualModelPath');
          return manualModelPath;
        }
      } catch (e2) {
        debugPrint('⚠️ Model not found in documents either: $e2');
      }

      return null;
    }
  }

  /// Run inference on the model
  Future<List<double>?> runInference(List<dynamic> inputData) async {
    if (!_isModelLoaded || _session == null) {
      debugPrint('❌ Model not loaded. Cannot run inference.');
      return null;
    }

    try {
      // Create input tensor
      final inputTensor = OnnxTensor.fromList(
        inputData,
        shape: [1, inputData.length],
      );

      // Run inference
      final outputs = await _session!.run([inputTensor]);

      if (outputs.isEmpty) {
        debugPrint('❌ No outputs from model');
        return null;
      }

      // Get the first output tensor
      final outputTensor = outputs.first as OnnxTensor;
      final result = outputTensor.data as List<double>;

      return result;
    } catch (e) {
      debugPrint('❌ Inference failed: $e');
      return null;
    }
  }

  /// Dispose of the model and free resources
  Future<void> dispose() async {
    try {
      _session?.release();
      _session = null;
      _isModelLoaded = false;

      debugPrint('🤖 ONNX Model Service disposed');
    } catch (e) {
      debugPrint('❌ Error disposing model: $e');
    }
  }

  /// Check if model file exists
  Future<bool> modelExists() async {
    try {
      await rootBundle.load(modelAssetPath);
      return true;
    } catch (e) {
      // Check documents directory
      try {
        final docsDir = await getApplicationDocumentsDirectory();
        final manualModelPath = '${docsDir.path}/models/$modelFileName';
        return await File(manualModelPath).exists();
      } catch (e2) {
        return false;
      }
    }
  }
}
