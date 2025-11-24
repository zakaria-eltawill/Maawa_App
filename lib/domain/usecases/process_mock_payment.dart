import 'package:maawa_project/core/error/error_handler.dart';
import 'package:maawa_project/data/datasources/remote/payment_api.dart';

class ProcessMockPaymentUseCase {
  final PaymentApi _paymentApi;

  ProcessMockPaymentUseCase(this._paymentApi);

  Future<void> call({
    required String bookingId,
    bool fail = false,
  }) async {
    try {
      return await _paymentApi.mockPayment(
        bookingId: bookingId,
        fail: fail,
      );
    } catch (e) {
      // Convert exceptions to failures for consistent error handling
      throw ErrorHandler.handleError(e);
    }
  }
}

