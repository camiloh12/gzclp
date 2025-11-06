import 'package:equatable/equatable.dart';

/// Base class for all failures in the application
///
/// Failures represent errors that have been caught and handled,
/// as opposed to exceptions which are unexpected errors.
abstract class Failure extends Equatable {
  final String message;

  const Failure(this.message);

  @override
  List<Object> get props => [message];
}

/// Failure related to database operations
class DatabaseFailure extends Failure {
  const DatabaseFailure(super.message);
}

/// Failure when data is not found
class NotFoundFailure extends Failure {
  const NotFoundFailure(super.message);
}

/// Failure related to data validation
class ValidationFailure extends Failure {
  const ValidationFailure(super.message);
}

/// Failure related to network operations
class NetworkFailure extends Failure {
  const NetworkFailure(super.message);
}

/// Failure related to cache operations
class CacheFailure extends Failure {
  const CacheFailure(super.message);
}
