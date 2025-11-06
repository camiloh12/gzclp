import 'package:dartz/dartz.dart';
import '../error/failures.dart';

/// Base class for all use cases
///
/// A use case represents a single unit of business logic.
/// It takes parameters of type [Params] and returns either a [Failure]
/// or a result of type [T].
abstract class UseCase<T, Params> {
  Future<Either<Failure, T>> call(Params params);
}

/// Used when a use case doesn't require any parameters
class NoParams {
  const NoParams();
}
