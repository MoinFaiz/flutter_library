import 'package:dartz/dartz.dart';
import '../../../../core/error/failures.dart';
import '../../../../core/usecase/usecase.dart';
import '../entities/audit_event.dart';
import '../repositories/logging_repository.dart';

class TrackAuditEventParams {
  final String feature;
  final String action;
  final Map<String, dynamic>? parameters;
  final bool success;
  final String? userId;
  final String? sessionId;

  const TrackAuditEventParams({
    required this.feature,
    required this.action,
    this.parameters,
    this.success = true,
    this.userId,
    this.sessionId,
  });
}

/// Use case to track audit events
class TrackAuditEvent implements UseCase<void, TrackAuditEventParams> {
  final LoggingRepository repository;

  TrackAuditEvent(this.repository);

  @override
  Future<Either<Failure, void>> call(TrackAuditEventParams params) async {
    final configResult = await repository.getConfig();
    
    return configResult.fold(
      (failure) => Left(failure),
      (config) async {
        if (!config.enabled || !config.auditTrackingEnabled) {
          return const Right(null);
        }

        final event = AuditEvent(
          id: DateTime.now().millisecondsSinceEpoch.toString(),
          timestamp: DateTime.now(),
          userId: params.userId,
          sessionId: params.sessionId,
          feature: params.feature,
          action: params.action,
          parameters: params.parameters,
          success: params.success,
        );

        return repository.saveAuditEvent(event);
      },
    );
  }
}
