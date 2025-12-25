/// Base exception class for app-specific errors
abstract class AppException implements Exception {
  final String message;
  final String? code;
  final dynamic originalError;

  const AppException(this.message, {this.code, this.originalError});

  @override
  String toString() => message;
}

/// Network-related exceptions
class NetworkException extends AppException {
  const NetworkException(super.message, {super.code, super.originalError});
}

class NoInternetException extends NetworkException {
  const NoInternetException({super.originalError})
      : super('No internet connection. Please check your network and try again.');
}

class TimeoutException extends NetworkException {
  const TimeoutException({super.originalError})
      : super('Request timed out. Please try again.');
}

class ServerException extends NetworkException {
  final int? statusCode;
  const ServerException(super.message, {this.statusCode, super.originalError});
}

/// Storage-related exceptions
class StorageException extends AppException {
  const StorageException(super.message, {super.code, super.originalError});
}

class StorageReadException extends StorageException {
  const StorageReadException({super.originalError})
      : super('Failed to read data from storage. Please try again.');
}

class StorageWriteException extends StorageException {
  const StorageWriteException({super.originalError})
      : super('Failed to save data. Please try again.');
}

/// Data-related exceptions
class DataException extends AppException {
  const DataException(super.message, {super.code, super.originalError});
}

class InvalidDataException extends DataException {
  const InvalidDataException(super.message, {super.originalError});
}

/// Unknown/Generic exceptions
class UnknownException extends AppException {
  const UnknownException(super.message, {super.originalError});
}

