import 'package:dartz/dartz.dart';
import 'package:flutter_library/core/error/failures.dart';
import 'package:flutter_library/features/notifications/domain/repositories/notifications_repository.dart';

class MarkNotificationAsReadUseCase {
  final NotificationsRepository repository;

  MarkNotificationAsReadUseCase(this.repository);

  Future<Either<Failure, void>> call(String notificationId) async {
    return await repository.markAsRead(notificationId);
  }
}
