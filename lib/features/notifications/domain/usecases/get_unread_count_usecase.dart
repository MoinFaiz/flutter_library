import 'package:dartz/dartz.dart';
import 'package:flutter_library/core/error/failures.dart';
import 'package:flutter_library/features/notifications/domain/repositories/notifications_repository.dart';

class GetUnreadCountUseCase {
  final NotificationsRepository repository;

  GetUnreadCountUseCase(this.repository);

  Future<Either<Failure, int>> call() async {
    return await repository.getUnreadCount();
  }
}
