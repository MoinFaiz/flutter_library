import 'package:dartz/dartz.dart';
import 'package:flutter_library/core/error/failures.dart';
import 'package:flutter_library/features/notifications/domain/repositories/notifications_repository.dart';

class RejectBookRequestUseCase {
  final NotificationsRepository repository;

  RejectBookRequestUseCase(this.repository);

  Future<Either<Failure, void>> call(String notificationId, String? reason) async {
    return await repository.rejectBookRequest(notificationId, reason);
  }
}
