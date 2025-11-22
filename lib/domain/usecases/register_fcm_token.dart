import 'dart:io';
import 'package:maawa_project/domain/repositories/notification_repository.dart';

class RegisterFcmTokenUseCase {
  final NotificationRepository _repository;

  RegisterFcmTokenUseCase(this._repository);

  Future<void> call(String token) async {
    // Automatically detect platform
    final platform = Platform.isAndroid ? 'android' : 'ios';
    
    return await _repository.registerFcmToken(
      token: token,
      platform: platform,
    );
  }
}

