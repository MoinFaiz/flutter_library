import 'package:dartz/dartz.dart';
import '../error/failures.dart';

/// Base contract for all async domain use cases.
///
/// [Result] — the success type wrapped in [Either].
/// [Params] — input parameters. Use [NoParams] when the use case takes no input.
///
/// Usage:
/// ```dart
/// class MyUseCase extends UseCase<MyResult, MyParams> {
///   @override
///   Future<Either<Failure, MyResult>> call(MyParams params) { ... }
/// }
/// ```
abstract class UseCase<Result, Params> {
  Future<Either<Failure, Result>> call(Params params);
}

/// Use for streaming use cases that emit multiple values over time.
abstract class StreamUseCase<Result, Params> {
  Stream<Either<Failure, Result>> call(Params params);
}

/// Sentinel parameter type for use cases that require no input.
class NoParams {
  const NoParams();
}
