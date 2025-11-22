import 'package:dio/dio.dart';
import 'package:uuid/uuid.dart';

class IdempotencyInterceptor extends Interceptor {
  final Set<String> _mutatingMethods = {'POST', 'PUT', 'PATCH'};

  @override
  void onRequest(RequestOptions options, RequestInterceptorHandler handler) {
    // Add idempotency key for mutating requests that don't already have one
    if (_mutatingMethods.contains(options.method.toUpperCase()) &&
        !options.headers.containsKey('X-Idempotency-Key')) {
      options.headers['X-Idempotency-Key'] = const Uuid().v4();
    }
    handler.next(options);
  }
}

