import 'package:maawa_project/domain/entities/notification.dart';
import 'package:maawa_project/domain/repositories/notification_repository.dart';

class GetNotificationsUseCase {
  final NotificationRepository _repository;

  GetNotificationsUseCase(this._repository);

  Future<List<Notification>> call({bool? read}) async {
    return await _repository.getNotifications(read: read);
  }
}

