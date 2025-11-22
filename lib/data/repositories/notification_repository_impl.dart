import 'package:maawa_project/core/error/error_handler.dart';
import 'package:maawa_project/data/datasources/remote/notification_api.dart';
import 'package:maawa_project/domain/entities/notification.dart';
import 'package:maawa_project/domain/repositories/notification_repository.dart';

class NotificationRepositoryImpl implements NotificationRepository {
  final NotificationApi _notificationApi;

  NotificationRepositoryImpl(this._notificationApi);

  @override
  Future<void> registerFcmToken({
    required String token,
    required String platform,
  }) async {
    try {
      await _notificationApi.registerFcmToken(
        token: token,
        platform: platform,
      );
    } catch (e) {
      throw ErrorHandler.handleError(e);
    }
  }

  @override
  Future<void> unregisterFcmToken(String token) async {
    try {
      await _notificationApi.unregisterFcmToken(token);
    } catch (e) {
      throw ErrorHandler.handleError(e);
    }
  }

  @override
  Future<List<Notification>> getNotifications({bool? read}) async {
    try {
      final dtos = await _notificationApi.getNotifications(read: read);
      return dtos.map((dto) => dto.toDomain()).toList();
    } catch (e) {
      throw ErrorHandler.handleError(e);
    }
  }

  @override
  Future<void> markAsRead(String notificationId) async {
    try {
      await _notificationApi.markAsRead(notificationId);
    } catch (e) {
      throw ErrorHandler.handleError(e);
    }
  }

  @override
  Future<void> markAllAsRead() async {
    try {
      await _notificationApi.markAllAsRead();
    } catch (e) {
      throw ErrorHandler.handleError(e);
    }
  }
}

