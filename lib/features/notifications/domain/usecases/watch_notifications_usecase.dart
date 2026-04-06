import 'package:flutter_library/features/notifications/domain/entities/notification.dart';
import 'package:flutter_library/features/notifications/domain/repositories/notifications_repository.dart';

class WatchNotificationsUseCase {
  final NotificationsRepository repository;

  WatchNotificationsUseCase(this.repository);

  Stream<List<AppNotification>> call() {
    return repository.watchNotifications();
  }
}
