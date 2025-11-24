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
        
        // Log payment response details if available
        if (response.data is Map<String, dynamic>) {
          final data = response.data as Map<String, dynamic>;
          debugPrint('📦   Booking ID: ${data['booking_id']}');
          debugPrint('📦   Status: ${data['status']}');
          debugPrint('📦   Is Paid: ${data['is_paid']}');
          debugPrint('📦   Receipt No: ${data['receipt_no']}');
          debugPrint('📦   Paid At: ${data['paid_at']}');
        }
      }
    } catch (e, stackTrace) {
      if (kDebugMode) {
        debugPrint('❌ PaymentApi.mockPayment: Error - $e');
        debugPrint('❌ Stack trace: $stackTrace');
        if (e is DioException) {
          final statusCode = e.response?.statusCode;
          final responseData = e.response?.data;
          debugPrint('❌ Status Code: $statusCode');
          debugPrint('❌ Response Data: $responseData');
          debugPrint('❌ Request URL: ${e.requestOptions.uri}');
          
          // Log specific error details
          if (statusCode == 410) {
            debugPrint('❌ ERROR: Booking is not in ACCEPTED or CONFIRMED status');
            if (responseData is Map<String, dynamic>) {
              debugPrint('❌   Detail: ${responseData['detail']}');
            }
          } else if (statusCode == 402) {
            debugPrint('❌ ERROR: Payment processing failed');
            if (responseData is Map<String, dynamic>) {
              debugPrint('❌   Detail: ${responseData['detail']}');
            }
          }
        }
      }
      rethrow;
    }
  }
}

