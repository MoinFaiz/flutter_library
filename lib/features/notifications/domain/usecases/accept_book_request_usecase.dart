import 'package:dartz/dartz.dart';
import 'package:flutter_library/core/error/failures.dart';
import 'package:flutter_library/features/notifications/domain/repositories/notifications_repository.dart';

class AcceptBookRequestUseCase {
  final NotificationsRepository repository;

  AcceptBookRequestUseCase(this.repository);

  Future<Either<Failure, void>> call(String notificationId) async {
    return await repository.acceptBookRequest(notificationId);
  }
}
