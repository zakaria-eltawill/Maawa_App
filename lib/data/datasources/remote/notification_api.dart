import 'package:flutter/foundation.dart';
import 'package:maawa_project/core/network/dio_client.dart';
import 'package:maawa_project/data/dto/notification_dto.dart';

class NotificationApi {
  final DioClient _dioClient;

  NotificationApi(this._dioClient);
  
  Future<List<NotificationDto>> getNotifications({
    bool? read,
  }) async {
    if (kDebugMode) {
      final baseUrl = _dioClient.dio.options.baseUrl;
      debugPrint('🔔 NotificationApi.getNotifications: Calling ${baseUrl}/me/notifications');
      if (read != null) {
        debugPrint('📋 Filter: read=$read');
      }
    }

    try {
      final queryParams = <String, dynamic>{};
      if (read != null) {
        queryParams['read'] = read;
      }

      final response = await _dioClient.get(
        '/me/notifications',
        queryParameters: queryParams.isNotEmpty ? queryParams : null,
      );

      debugPrint('✅ NotificationApi.getNotifications: Success - Status ${response.statusCode}');
      
      final data = response.data;
      
      // Handle paginated response
      if (data is Map<String, dynamic> && data['data'] is List) {
        final notifications = (data['data'] as List)
            .map((json) => NotificationDto.fromJson(json as Map<String, dynamic>))
            .toList();
        debugPrint('📋 Found ${notifications.length} notifications');
        return notifications;
      }
      
      // Handle direct list response
      if (data is List) {
        debugPrint('📋 Found ${data.length} notifications (direct list)');
        return data
            .map((json) => NotificationDto.fromJson(json as Map<String, dynamic>))
            .toList();
      }
      
      debugPrint('⚠️ Unexpected response format');
      return [];
    } catch (e) {
      debugPrint('❌ NotificationApi.getNotifications: Error - $e');
      rethrow;
    }
  }

  Future<void> markAsRead(String notificationId) async {
    if (kDebugMode) {
      final baseUrl = _dioClient.dio.options.baseUrl;
      debugPrint('✅ NotificationApi.markAsRead: Calling ${baseUrl}/me/notifications/$notificationId/read');
    }

    try {
      await _dioClient.put('/me/notifications/$notificationId/read');
      debugPrint('✅ NotificationApi.markAsRead: Notification marked as read');
    } catch (e) {
      debugPrint('❌ NotificationApi.markAsRead: Error - $e');
      rethrow;
    }
  }

  Future<void> markAllAsRead() async {
    if (kDebugMode) {
      final baseUrl = _dioClient.dio.options.baseUrl;
      debugPrint('✅ NotificationApi.markAllAsRead: Calling ${baseUrl}/me/notifications/read-all');
    }

    try {
      await _dioClient.put('/me/notifications/read-all');
      debugPrint('✅ NotificationApi.markAllAsRead: All notifications marked as read');
    } catch (e) {
      debugPrint('❌ NotificationApi.markAllAsRead: Error - $e');
      rethrow;
    }
  }

  Future<void> registerFcmToken({
    required String token,
    required String platform, // 'android' or 'ios'
  }) async {
    if (kDebugMode) {
      final baseUrl = _dioClient.dio.options.baseUrl;
      debugPrint('🔔 NotificationApi.registerFcmToken: Calling ${baseUrl}/me/fcm-tokens');
      debugPrint('📱 Platform: $platform, Token: ${token.substring(0, 20)}...');
    }

    try {
      await _dioClient.post(
        '/me/fcm-tokens',
        data: {
          'token': token,
          'platform': platform,
        },
      );

      debugPrint('✅ NotificationApi.registerFcmToken: Token registered successfully');
    } catch (e) {
      debugPrint('❌ NotificationApi.registerFcmToken: Error - $e');
      rethrow;
    }
  }

  /// Register FCM token using the /user/fcm_token endpoint
  /// This is an alternative endpoint format
  Future<void> updateFcmToken(String token) async {
    if (kDebugMode) {
      final baseUrl = _dioClient.dio.options.baseUrl;
      debugPrint('🔔 NotificationApi.updateFcmToken: Calling ${baseUrl}/user/fcm_token');
      debugPrint('📱 Token: ${token.substring(0, 20)}...');
    }

    try {
      final response = await _dioClient.post(
        '/user/fcm_token',
        data: {
          'fcm_token': token,
        },
      );

      if (response.statusCode == 200) {
        if (kDebugMode) {
          debugPrint('✅ NotificationApi.updateFcmToken: FCM UPDATED ✅ $token');
        }
      } else {
        if (kDebugMode) {
          debugPrint('❌ NotificationApi.updateFcmToken: FCM UPDATED ❌');
        }
      }
    } catch (e) {
      debugPrint('❌ NotificationApi.updateFcmToken: Error - $e');
      rethrow;
    }
  }

  Future<void> unregisterFcmToken(String token) async {
    if (kDebugMode) {
      final baseUrl = _dioClient.dio.options.baseUrl;
      debugPrint('🔕 NotificationApi.unregisterFcmToken: Calling ${baseUrl}/me/fcm-tokens/$token');
    }

    try {
      await _dioClient.delete('/me/fcm-tokens/$token');
      debugPrint('✅ NotificationApi.unregisterFcmToken: Token removed successfully');
    } catch (e) {
      debugPrint('❌ NotificationApi.unregisterFcmToken: Error - $e');
      rethrow;
    }
  }
}

