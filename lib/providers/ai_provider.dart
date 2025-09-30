import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../services/ai_service.dart';
import '../services/local_ai_service.dart';

/// Provider for AI service instance
final aiServiceProvider = Provider<AIService>((ref) {
  return AIServiceFactory.instance;
});

/// Provider for AI service initialization status
final aiServiceInitializedProvider = FutureProvider<bool>((ref) async {
  try {
    await AIServiceFactory.initialize();
    return true;
  } catch (e) {
    return false;
  }
});

/// Provider for AI service readiness
final aiServiceReadyProvider = Provider<bool>((ref) {
  final aiService = ref.watch(aiServiceProvider);
  return aiService.isReady;
});

/// Provider for AI performance stats
final aiPerformanceProvider = Provider<Map<String, dynamic>>((ref) {
  return AIPerformanceMonitor.stats;
});

/// Provider that watches for AI service state changes
final aiServiceStateProvider = StateNotifierProvider<AIServiceStateNotifier, AIServiceState>((ref) {
  return AIServiceStateNotifier(ref.read(aiServiceProvider));
});

/// State notifier for AI service state management
class AIServiceStateNotifier extends StateNotifier<AIServiceState> {
  final AIService _aiService;

  AIServiceStateNotifier(this._aiService) : super(AIServiceState.initializing()) {
    _initialize();
  }

  Future<void> _initialize() async {
    try {
      state = AIServiceState.initializing();
      await _aiService.initialize();

      if (_aiService.isReady) {
        state = AIServiceState.ready();
      } else {
        state = AIServiceState.fallback('AI model not available, using fallback responses');
      }
    } catch (e) {
      state = AIServiceState.error(e.toString());
    }
  }

  Future<void> reinitialize() async {
    await _initialize();
  }
}

/// AI service state
abstract class AIServiceState {
  const AIServiceState();

  factory AIServiceState.initializing() = _Initializing;
  factory AIServiceState.ready() = _Ready;
  factory AIServiceState.fallback(String reason) = _Fallback;
  factory AIServiceState.error(String message) = _Error;

  T when<T>({
    required T Function() initializing,
    required T Function() ready,
    required T Function(String reason) fallback,
    required T Function(String message) error,
  }) {
    if (this is _Initializing) return initializing();
    if (this is _Ready) return ready();
    if (this is _Fallback) return fallback((this as _Fallback).reason);
    if (this is _Error) return error((this as _Error).message);
    throw Exception('Unknown AI service state');
  }

  bool get isReady => this is _Ready;
  bool get isError => this is _Error;
  bool get isFallback => this is _Fallback;
  bool get isInitializing => this is _Initializing;
}

class _Initializing extends AIServiceState {
  const _Initializing();
}

class _Ready extends AIServiceState {
  const _Ready();
}

class _Fallback extends AIServiceState {
  final String reason;
  const _Fallback(this.reason);
}

class _Error extends AIServiceState {
  final String message;
  const _Error(this.message);
}