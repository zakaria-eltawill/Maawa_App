import 'package:maawa_project/domain/repositories/notification_repository.dart';

class MarkAllNotificationsReadUseCase {
  final NotificationRepository _repository;

  MarkAllNotificationsReadUseCase(this._repository);

  Future<void> call() async {
    return await _repository.markAllAsRead();
  }
}

