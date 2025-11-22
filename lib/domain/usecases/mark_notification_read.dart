import 'package:maawa_project/domain/repositories/notification_repository.dart';

class MarkNotificationReadUseCase {
  final NotificationRepository _repository;

  MarkNotificationReadUseCase(this._repository);

  Future<void> call(String notificationId) async {
    return await _repository.markAsRead(notificationId);
  }
}

