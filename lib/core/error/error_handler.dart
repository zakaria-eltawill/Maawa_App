import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:maawa_project/core/error/failures.dart';

class ErrorHandler {
  static Failure handleError(dynamic error) {
    if (error is DioException) {
      return _handleDioError(error);
    } else if (error is Exception) {
      return UnknownFailure(error.toString());
    } else {
      return UnknownFailure('An unknown error occurred');
    }
  }

  static Failure _handleDioError(DioException error) {
    if (kDebugMode) {
      debugPrint('🔴 ErrorHandler: ${error.type}');
      debugPrint('🔴 Status: ${error.response?.statusCode}');
      debugPrint('🔴 URL: ${error.requestOptions.uri}');
      debugPrint('🔴 Response data: ${error.response?.data}');
    }
    
    switch (error.type) {
      case DioExceptionType.connectionTimeout:
      case DioExceptionType.sendTimeout:
      case DioExceptionType.receiveTimeout:
        final url = error.requestOptions.uri.toString();
        return NetworkFailure(
          'Connection timeout. Could not reach server at $url. Please check:\n'
          '1. Backend server is running\n'
          '2. Correct API URL is configured\n'
          '3. Network connectivity',
        );

      case DioExceptionType.badResponse:
        final statusCode = error.response?.statusCode;
        final data = error.response?.data;

        if (statusCode == 401) {
          final errorType = data is Map<String, dynamic> ? data['type'] : null;
          if (errorType == 'token_expired') {
            return UnauthorizedFailure('Session expired. Please login again.');
          }
          return UnauthorizedFailure('Unauthorized. Please login again.');
        } else if (statusCode == 400) {
          // Bad Request - Extract detail message
          final message = data is Map<String, dynamic>
              ? data['detail'] ?? data['message'] ?? 'Bad request'
              : 'Bad request';
          return ValidationFailure(message.toString());
        } else if (statusCode == 403) {
          final message = data is Map<String, dynamic>
              ? data['detail'] ?? data['message'] ?? 'Access forbidden'
              : 'Access forbidden';
          return UnauthorizedFailure(message.toString());
        } else if (statusCode == 404) {
          final url = error.requestOptions.uri.toString();
          final method = error.requestOptions.method;
          return NotFoundFailure(
            'Resource not found (404).\n'
            'URL: $method $url\n'
            'Please verify the API endpoint exists on the backend.',
          );
        } else if (statusCode == 402) {
          // Payment Required / Payment Failed
          final message = data is Map<String, dynamic>
              ? data['detail'] ?? data['message'] ?? 'Payment failed. Please try again.'
              : 'Payment failed. Please try again.';
          return ValidationFailure(message.toString());
        } else if (statusCode == 410) {
          // Gone - Resource no longer available (e.g., booking not in valid status for payment)
          final message = data is Map<String, dynamic>
              ? data['detail'] ?? data['message'] ?? 'This booking cannot be paid. It may not be in a valid status.'
              : 'This booking cannot be paid. It may not be in a valid status.';
          return ValidationFailure(message.toString());
        } else if (statusCode == 422) {
          // Validation error - Extract detailed errors
          if (data is Map<String, dynamic>) {
            final errors = data['errors'];
            if (errors is Map<String, dynamic>) {
              final errorMessages = <String>[];
              errors.forEach((field, messages) {
                if (messages is List) {
                  errorMessages.addAll(messages.map((e) => '• $e'));
                } else {
                  errorMessages.add('• $messages');
                }
              });
              if (errorMessages.isNotEmpty) {
                return ValidationFailure(errorMessages.join('\n'));
              }
            }
            final message = data['detail'] ?? data['message'];
            if (message != null) {
              return ValidationFailure(message.toString());
            }
          }
          return ValidationFailure('Validation error. Please check your input.');
        } else if (statusCode != null && statusCode >= 500) {
          String serverMessage = 'Server error. Please try again later.';
          if (data is Map<String, dynamic>) {
            final message = data['detail'] ?? data['message'];
            if (message != null) {
              final messageStr = message.toString();
              // Check for database column errors and provide user-friendly message
              if (messageStr.contains('is_paid') && messageStr.contains('Column not found')) {
                serverMessage = 'Database configuration error. The booking payment feature requires a database update. Please contact support.';
              } else {
                serverMessage = '$serverMessage\n\nDetails: $messageStr';
              }
            }
          }
          return ServerFailure(serverMessage);
        } else {
          final message = data is Map<String, dynamic>
              ? data['detail'] ?? data['message'] ?? 'An error occurred'
              : 'An error occurred';
          return ServerFailure(message.toString());
        }

      case DioExceptionType.cancel:
        return NetworkFailure('Request cancelled.');

      case DioExceptionType.connectionError:
        final url = error.requestOptions.uri.toString();
        return NetworkFailure(
          'Connection error. Could not connect to $url. Please check:\n'
          '1. Backend server is running\n'
          '2. Correct API URL is configured\n'
          '3. Network connectivity',
        );

      case DioExceptionType.badCertificate:
        return NetworkFailure('Certificate error. Please try again.');

      case DioExceptionType.unknown:
        if (error.message?.contains('SocketException') == true) {
          return NetworkFailure('No internet connection. Please check your network.');
        }
        final url = error.requestOptions.uri.toString();
        return UnknownFailure(
          error.message ?? 'An unknown error occurred. URL: $url',
        );
    }
  }
}

