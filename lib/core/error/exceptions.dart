/// Base exception class for database operations
class DatabaseException implements Exception {
  final String message;
  final dynamic cause;

  DatabaseException(this.message, [this.cause]);

  @override
  String toString() =>
      'DatabaseException: $message${cause != null ? ' (Cause: $cause)' : ''}';
}

/// Exception thrown when data is not found
class NotFoundException implements Exception {
  final String message;

  NotFoundException(this.message);

  @override
  String toString() => 'NotFoundException: $message';
}

/// Exception thrown when validation fails
class ValidationException implements Exception {
  final String message;
  final Map<String, String>? errors;

  ValidationException(this.message, [this.errors]);

  @override
  String toString() =>
      'ValidationException: $message${errors != null ? ' (Errors: $errors)' : ''}';
}

/// Exception thrown when a transaction fails
class TransactionException implements Exception {
  final String message;
  final dynamic cause;

  TransactionException(this.message, [this.cause]);

  @override
  String toString() =>
      'TransactionException: $message${cause != null ? ' (Cause: $cause)' : ''}';
}
