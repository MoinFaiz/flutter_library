import 'package:dartz/dartz.dart';
import 'package:flutter_library/core/error/failures.dart';
import 'package:flutter_library/features/notifications/domain/repositories/notifications_repository.dart';

class MarkAllNotificationsAsReadUseCase {
  final NotificationsRepository repository;

  MarkAllNotificationsAsReadUseCase(this.repository);

  Future<Either<Failure, void>> call() async {
    return await repository.markAllAsRead();
  }
}
