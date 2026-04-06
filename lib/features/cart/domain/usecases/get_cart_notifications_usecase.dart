import 'package:dartz/dartz.dart';
import 'package:flutter_library/core/error/failures.dart';
import 'package:flutter_library/features/cart/domain/entities/cart_notification.dart';
import 'package:flutter_library/features/cart/domain/repositories/cart_notification_repository.dart';

class GetCartNotificationsUseCase {
  final CartNotificationRepository repository;

  GetCartNotificationsUseCase({required this.repository});

  Future<Either<Failure, List<CartNotification>>> call() async {
    return await repository.getNotifications();
  }
}
