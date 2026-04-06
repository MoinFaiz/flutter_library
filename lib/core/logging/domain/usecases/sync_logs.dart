import 'package:dartz/dartz.dart';
import '../../../../core/error/failures.dart';
import '../../../../core/usecase/usecase.dart';
import '../repositories/logging_repository.dart';

/// Use case to sync logs to server
class SyncLogs implements UseCase<void, NoParams> {
  final LoggingRepository repository;

  SyncLogs(this.repository);

  @override
  Future<Either<Failure, void>> call(NoParams params) async {
    final configResult = await repository.getConfig();
    
    return configResult.fold(
      (failure) => Left(failure),
      (config) async {
        if (!config.enabled || !config.remoteLoggingEnabled) {
          return const Right(null);
        }

        // Get local logs
        final logsResult = await repository.getLocalLogs();
        
        return logsResult.fold(
          (failure) => Left(failure),
          (logs) async {
            if (logs.isEmpty) {
              return const Right(null);
            }

            // Sync to server
            final syncResult = await repository.syncLogsToServer(logs);
            
            return syncResult.fold(
              (failure) => Left(failure),
              (_) async {
                // Clear local logs after successful sync
                return repository.clearLocalLogs();
              },
            );
          },
        );
      },
    );
  }
}
