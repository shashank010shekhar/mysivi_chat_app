import 'dart:io';
import 'package:http/http.dart' as http;
import 'app_exceptions.dart';

/// Centralized error handler that converts various errors to AppExceptions
class ErrorHandler {
  /// Handle and convert errors to AppExceptions
  static AppException handleError(dynamic error) {
    if (error is AppException) {
      return error;
    }

    if (error is SocketException) {
      return const NoInternetException();
    }

    if (error is HttpException) {
      return NetworkException(
        'Network error: ${error.message}',
        originalError: error,
      );
    }

    if (error is FormatException) {
      return InvalidDataException(
        'Invalid data format: ${error.message}',
        originalError: error,
      );
    }

    if (error is TimeoutException) {
      return const TimeoutException();
    }

    // Handle http package exceptions
    if (error.toString().contains('SocketException') ||
        error.toString().contains('Failed host lookup')) {
      return const NoInternetException();
    }

    if (error.toString().contains('timeout')) {
      return const TimeoutException();
    }

    // Generic error
    return UnknownException(
      error.toString().isNotEmpty
          ? error.toString()
          : 'An unexpected error occurred. Please try again.',
      originalError: error,
    );
  }

  /// Handle HTTP response errors
  static AppException handleHttpResponse(http.Response response) {
    switch (response.statusCode) {
      case 400:
        return const ServerException('Bad request. Please check your input.');
      case 401:
        return const ServerException('Unauthorized. Please try again.');
      case 403:
        return const ServerException('Access forbidden.');
      case 404:
        return const ServerException('Resource not found.');
      case 500:
        return const ServerException(
            'Server error. Please try again later.');
      case 502:
        return const ServerException(
            'Bad gateway. Please try again later.');
      case 503:
        return const ServerException(
            'Service unavailable. Please try again later.');
      default:
        return ServerException(
          'Server error (${response.statusCode}). Please try again.',
          statusCode: response.statusCode,
        );
    }
  }

  /// Get user-friendly error message
  static String getErrorMessage(AppException exception) {
    return exception.message;
  }
}

