import 'package:freezed_annotation/freezed_annotation.dart';

part 'app_error.freezed.dart';

@freezed
class AppError with _$AppError {
  const factory AppError.network({
    required String message,
    String? details,
  }) = NetworkError;

  const factory AppError.database({
    required String message,
    String? details,
  }) = DatabaseError;

  const factory AppError.validation({
    required String message,
    String? field,
  }) = ValidationError;

  const factory AppError.permission({
    required String message,
    String? permission,
  }) = PermissionError;

  const factory AppError.unknown({
    required String message,
    String? details,
  }) = UnknownError;

  const factory AppError.api({
    required String message,
    int? statusCode,
    String? details,
  }) = ApiError;
}

extension AppErrorExtension on AppError {
  String get userMessage {
    return when(
      network: (message, _) => 'Network connection issue. Please check your internet connection.',
      database: (message, _) => 'Unable to save data. Please try again.',
      validation: (message, _) => message,
      permission: (message, _) => 'Permission required. Please grant the necessary permissions.',
      unknown: (message, _) => 'Something went wrong. Please try again.',
      api: (message, _, __) => 'Service temporarily unavailable. Please try again later.',
    );
  }

  bool get isRetryable {
    return when(
      network: (_, __) => true,
      database: (_, __) => true,
      validation: (_, __) => false,
      permission: (_, __) => false,
      unknown: (_, __) => true,
      api: (_, __, ___) => true,
    );
  }
}