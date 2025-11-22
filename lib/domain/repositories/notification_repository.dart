import 'package:maawa_project/domain/entities/notification.dart';

abstract class NotificationRepository {
  Future<void> registerFcmToken({
    required String token,
    required String platform,
  });
  Future<void> unregisterFcmToken(String token);
  Future<List<Notification>> getNotifications({bool? read});
  Future<void> markAsRead(String notificationId);
  Future<void> markAllAsRead();
}

