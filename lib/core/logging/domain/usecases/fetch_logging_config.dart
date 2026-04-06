import 'package:dartz/dartz.dart';
import '../../../../core/error/failures.dart';
import '../../../../core/usecase/usecase.dart';
import '../entities/log_config.dart';
import '../repositories/logging_repository.dart';

/// Use case to fetch remote logging configuration
class FetchLoggingConfig implements UseCase<LogConfig, NoParams> {
  final LoggingRepository repository;

  FetchLoggingConfig(this.repository);

  @override
  Future<Either<Failure, LogConfig>> call(NoParams params) async {
    return repository.fetchRemoteConfig();
  }
}
