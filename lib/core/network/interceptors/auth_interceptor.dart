import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:maawa_project/core/storage/secure_storage.dart';

class AuthInterceptor extends Interceptor {
  final SecureStorage _secureStorage;

  AuthInterceptor(this._secureStorage);

  @override
  void onRequest(RequestOptions options, RequestInterceptorHandler handler) async {
    // For multipart/form-data requests, don't override Content-Type
    // Dio will set it automatically with the correct boundary
    if (options.data is FormData) {
      // Remove Content-Type header to let Dio set it automatically
      options.headers.remove('Content-Type');
    }
    
    final accessToken = await _secureStorage.getAccessToken();
    if (kDebugMode) {
      debugPrint('🔐 AuthInterceptor: Adding token to ${options.method} ${options.path}');
      debugPrint('🔐 Token exists: ${accessToken != null}');
      if (accessToken != null) {
        debugPrint('🔐 Token preview: ${accessToken.substring(0, accessToken.length > 20 ? 20 : accessToken.length)}...');
      } else {
        debugPrint('⚠️ AuthInterceptor: No access token found!');
      }
    }
    
    if (accessToken != null) {
      options.headers['Authorization'] = 'Bearer $accessToken';
    } else {
      if (kDebugMode) {
        debugPrint('⚠️ AuthInterceptor: No access token found!');
      }
    }
    handler.next(options);
  }
}

