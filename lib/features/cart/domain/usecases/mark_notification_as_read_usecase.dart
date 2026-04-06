import 'package:dartz/dartz.dart';
import 'package:flutter_library/core/error/failures.dart';
import 'package:flutter_library/features/cart/domain/repositories/cart_notification_repository.dart';

class MarkNotificationAsReadUseCase {
  final CartNotificationRepository repository;

  MarkNotificationAsReadUseCase({required this.repository});

  Future<Either<Failure, void>> call(String notificationId) async {
    return await repository.markAsRead(notificationId);
  }
}
