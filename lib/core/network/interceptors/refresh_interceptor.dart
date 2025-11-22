import 'dart:async';
import 'package:dio/dio.dart';
import 'package:maawa_project/core/network/interceptors/auth_interceptor.dart';
import 'package:maawa_project/core/storage/secure_storage.dart';

class RefreshInterceptor extends Interceptor {
  final SecureStorage _secureStorage;
  final String _baseUrl;
  bool _isRefreshing = false;
  final List<_PendingRequest> _pendingRequests = [];

  RefreshInterceptor(this._secureStorage, this._baseUrl);

  @override
  void onError(DioException err, ErrorInterceptorHandler handler) async {
    if (err.response?.statusCode == 401) {
      // Token expired or invalid, try to refresh
      // Handle both "token_expired" and generic 401 "Unauthenticated" responses
      if (_isRefreshing) {
        // Already refreshing, queue this request
        final completer = Completer<Response>();
        _pendingRequests.add(_PendingRequest(
          requestOptions: err.requestOptions,
          completer: completer,
        ));
        handler.resolve(await completer.future);
        return;
      }

      _isRefreshing = true;

      try {
        final refreshToken = await _secureStorage.getRefreshToken();
        if (refreshToken == null) {
          _isRefreshing = false;
          _rejectPendingRequests('No refresh token');
          handler.reject(err);
          return;
        }

        // Create a fresh Dio instance without interceptors for refresh call
        final refreshDio = Dio(
          BaseOptions(
            baseUrl: _baseUrl,
            connectTimeout: const Duration(seconds: 30),
            receiveTimeout: const Duration(seconds: 30),
            headers: {
              'Accept': 'application/json',
              'Content-Type': 'application/json',
            },
          ),
        );

        final response = await refreshDio.post(
          '/auth/refresh',
          data: {'refresh_token': refreshToken},
        );

        if (response.statusCode == 200) {
          final data = response.data as Map<String, dynamic>;
          final newAccessToken = data['access_token'] as String;
          final newRefreshToken = data['refresh_token'] as String? ?? refreshToken;
          final expiresIn = data['expires_in']?.toString() ?? '3600';

          // Save new tokens
          await _secureStorage.setAccessToken(newAccessToken);
          await _secureStorage.setRefreshToken(newRefreshToken);
          await _secureStorage.setTokenExpiresIn(expiresIn);

          // Update original request with new token
          err.requestOptions.headers['Authorization'] = 'Bearer $newAccessToken';

          // Create a new Dio instance for retry (without refresh interceptor to avoid loop)
          final retryDio = Dio(
            BaseOptions(
              baseUrl: _baseUrl,
              connectTimeout: const Duration(seconds: 30),
              receiveTimeout: const Duration(seconds: 30),
              headers: err.requestOptions.headers,
            ),
          );

          // Add auth interceptor only (no refresh interceptor)
          retryDio.interceptors.add(
            AuthInterceptor(_secureStorage),
          );

          final retryResponse = await retryDio.request(
            err.requestOptions.path,
            options: Options(
              method: err.requestOptions.method,
              headers: err.requestOptions.headers,
            ),
            data: err.requestOptions.data,
            queryParameters: err.requestOptions.queryParameters,
          );

          // Resolve pending requests
          _resolvePendingRequests(newAccessToken, err.requestOptions);

          _isRefreshing = false;
          handler.resolve(retryResponse);
          return;
        } else {
          // Refresh failed, logout user
          await _secureStorage.clearTokens();
          _isRefreshing = false;
          _rejectPendingRequests('Refresh failed');
          handler.reject(err);
          return;
        }
      } catch (e) {
        // Refresh failed, logout user
        await _secureStorage.clearTokens();
        _isRefreshing = false;
        _rejectPendingRequests('Refresh error: $e');
        handler.reject(err);
        return;
      }
    }

    handler.next(err);
  }

  void _resolvePendingRequests(String newAccessToken, RequestOptions originalOptions) {
    final retryDio = Dio(
      BaseOptions(
        baseUrl: _baseUrl,
        connectTimeout: const Duration(seconds: 30),
        receiveTimeout: const Duration(seconds: 30),
      ),
    );

    retryDio.interceptors.add(AuthInterceptor(_secureStorage));

    for (final pendingRequest in _pendingRequests) {
      pendingRequest.requestOptions.headers['Authorization'] = 'Bearer $newAccessToken';
      final opts = Options(
        method: pendingRequest.requestOptions.method,
        headers: pendingRequest.requestOptions.headers,
      );

      retryDio
          .request(
            pendingRequest.requestOptions.path,
            options: opts,
            data: pendingRequest.requestOptions.data,
            queryParameters: pendingRequest.requestOptions.queryParameters,
          )
          .then((response) {
            pendingRequest.completer.complete(response);
          })
          .catchError((error) {
            pendingRequest.completer.completeError(error);
          });
    }
    _pendingRequests.clear();
  }

  void _rejectPendingRequests(String error) {
    for (final pendingRequest in _pendingRequests) {
      pendingRequest.completer.completeError(error);
    }
    _pendingRequests.clear();
  }
}

class _PendingRequest {
  final RequestOptions requestOptions;
  final Completer<Response> completer;

  _PendingRequest({
    required this.requestOptions,
    required this.completer,
  });
}
