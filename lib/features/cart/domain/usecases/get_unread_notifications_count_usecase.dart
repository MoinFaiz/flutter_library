import 'package:dartz/dartz.dart';
import 'package:flutter_library/core/error/failures.dart';
import 'package:flutter_library/features/cart/domain/repositories/cart_notification_repository.dart';

class GetUnreadNotificationsCountUseCase {
  final CartNotificationRepository repository;

  GetUnreadNotificationsCountUseCase({required this.repository});

  Future<Either<Failure, int>> call() async {
    return await repository.getUnreadCount();
  }
}
