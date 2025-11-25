import 'dart:io';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:maawa_project/core/di/providers.dart';
import 'package:maawa_project/core/error/failures.dart';
import 'package:maawa_project/data/datasources/remote/notification_api.dart';
import 'package:maawa_project/domain/entities/user.dart';
import 'package:maawa_project/domain/usecases/login.dart';
import 'package:maawa_project/domain/usecases/register.dart';

class AuthState {
  final bool isLoading;
  final User? user;
  final String? error;

  AuthState({
    this.isLoading = false,
    this.user,
    this.error,
  });

  AuthState copyWith({
    bool? isLoading,
    User? user,
    String? error,
  }) {
    return AuthState(
      isLoading: isLoading ?? this.isLoading,
      user: user ?? this.user,
      error: error,
    );
  }
}

class AuthController extends StateNotifier<AuthState> {
  final LoginUseCase _loginUseCase;
  final RegisterUseCase _registerUseCase;
  final NotificationApi? _notificationApi;

  AuthController(
    this._loginUseCase,
    this._registerUseCase,
    this._notificationApi,
  ) : super(AuthState());

  Future<bool> login(String email, String password) async {
    state = state.copyWith(isLoading: true, error: null);

    try {
      final user = await _loginUseCase(email, password);
      
      // Check if admin - not supported on mobile
      if (user.role == UserRole.admin) {
        state = state.copyWith(
          isLoading: false,
          error: 'Admin access is not supported on mobile. Please use the web interface.',
        );
        return false;
      }

      state = state.copyWith(isLoading: false, user: user);
      return true;
    } on Failure catch (e) {
      // Enhanced error message for 401 errors (likely inactive account)
      String errorMessage = e.message;
      if (errorMessage.contains('401') || errorMessage.toLowerCase().contains('unauthorized')) {
        errorMessage = 'تسجيل الدخول فشل. قد يكون حسابك غير نشط أو بيانات الدخول غير صحيحة.\n\nيرجى إنشاء حساب جديد أو التحقق من بيانات الدخول.';
      }
      state = state.copyWith(isLoading: false, error: errorMessage);
      return false;
    } catch (e) {
      String errorMessage = e.toString();
      if (errorMessage.contains('401') || errorMessage.toLowerCase().contains('unauthorized')) {
        errorMessage = 'تسجيل الدخول فشل. قد يكون حسابك غير نشط أو بيانات الدخول غير صحيحة.\n\nيرجى إنشاء حساب جديد أو التحقق من بيانات الدخول.';
      }
      state = state.copyWith(isLoading: false, error: errorMessage);
      return false;
    }
  }

  Future<bool> register({
    required String name,
    required String email,
    required String password,
    required String passwordConfirmation,
    required String role,
    required String phoneNumber,
    required String region,
  }) async {
    state = state.copyWith(isLoading: true, error: null);

    try {
      final user = await _registerUseCase(
        name: name,
        email: email,
        password: password,
        passwordConfirmation: passwordConfirmation,
        role: role,
        phoneNumber: phoneNumber,
        region: region,
      );
      state = state.copyWith(isLoading: false, user: user);
      return true;
    } on Failure catch (e) {
      state = state.copyWith(isLoading: false, error: e.message);
      return false;
    } catch (e) {
      state = state.copyWith(isLoading: false, error: e.toString());
      return false;
    }
  }

  /// Update FCM token with backend
  Future<void> updateFcm() async {
    if (_notificationApi == null) {
      if (kDebugMode) {
        debugPrint('⚠️ AuthController.updateFcm: NotificationApi not available');
      }
      return;
    }

    try {
      final fcmToken = await FirebaseMessaging.instance.getToken();
      if (fcmToken != null) {
        // Use the working endpoint /me/fcm-tokens instead of /user/fcm_token
        await _notificationApi.registerFcmToken(
          token: fcmToken,
          platform: Platform.isAndroid ? 'android' : 'ios',
        );
        if (kDebugMode) {
          debugPrint('✅ AuthController.updateFcm: FCM UPDATED ✅ $fcmToken');
        }
      } else {
        if (kDebugMode) {
          debugPrint('⚠️ AuthController.updateFcm: FCM token is null');
        }
      }
    } catch (e) {
      if (kDebugMode) {
        debugPrint('❌ AuthController.updateFcm: Error - $e');
      }
      // Don't throw error, just log it
    }
  }
}

final authControllerProvider =
    StateNotifierProvider<AuthController, AuthState>((ref) {
  final loginUseCase = ref.read(loginUseCaseProvider);
  final registerUseCase = ref.read(registerUseCaseProvider);
  final notificationApi = ref.read(notificationApiProvider);
  return AuthController(loginUseCase, registerUseCase, notificationApi);
});

