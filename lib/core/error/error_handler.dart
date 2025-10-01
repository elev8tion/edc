import 'dart:io';
import 'package:sqflite/sqflite.dart';
import 'app_error.dart';

class ErrorHandler {
  static AppError handle(dynamic error) {
    if (error is AppError) {
      return error;
    }

    if (error is SocketException) {
      return const AppError.network(
        message: 'No internet connection',
        details: 'Please check your network connection and try again',
      );
    }

    if (error is HttpException) {
      return AppError.api(
        message: 'Server error',
        statusCode: error.message.contains('404') ? 404 : 500,
        details: error.message,
      );
    }

    if (error is DatabaseException) {
      return AppError.database(
        message: 'Database error',
        details: error.toString(),
      );
    }

    if (error is FormatException) {
      return AppError.validation(
        message: 'Invalid data format',
      );
    }

    if (error is ArgumentError) {
      return AppError.validation(
        message: error.message?.toString() ?? 'Invalid input',
      );
    }

    // Default unknown error
    return AppError.unknown(
      message: 'An unexpected error occurred',
      details: error.toString(),
    );
  }

  static void logError(AppError error, {StackTrace? stackTrace}) {
    // In a production app, you would send this to a crash reporting service
    print('Error: ${error.toString()}');
    if (stackTrace != null) {
      print('Stack trace: ${stackTrace.toString()}');
    }
  }
}