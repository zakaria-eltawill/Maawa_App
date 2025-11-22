import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:maawa_project/core/network/dio_client.dart';

class PaymentApi {
  final DioClient _dioClient;

  PaymentApi(this._dioClient);

  Future<void> mockPayment({
    required String bookingId,
    bool fail = false,
  }) async {
    if (kDebugMode) {
      final baseUrl = _dioClient.dio.options.baseUrl;
      debugPrint('💳 PaymentApi.mockPayment: Calling $baseUrl/payments/mock');
      debugPrint('📦 Booking ID: $bookingId, Fail: $fail');
    }

    try {
      final response = await _dioClient.post(
        '/payments/mock',
        data: {
          'booking_id': bookingId,
          'fail': fail,
        },
      );

      if (kDebugMode) {
        debugPrint('✅ PaymentApi.mockPayment: Payment processed successfully');
        debugPrint('📦 Response status: ${response.statusCode}');
        debugPrint('📦 Response data: ${response.data}');
      }
    } catch (e, stackTrace) {
      if (kDebugMode) {
        debugPrint('❌ PaymentApi.mockPayment: Error - $e');
        debugPrint('❌ Stack trace: $stackTrace');
        if (e is DioException) {
          debugPrint('❌ Status Code: ${e.response?.statusCode}');
          debugPrint('❌ Response Data: ${e.response?.data}');
          debugPrint('❌ Request URL: ${e.requestOptions.uri}');
        }
      }
      rethrow;
    }
  }
}

