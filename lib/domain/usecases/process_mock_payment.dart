import 'package:maawa_project/data/datasources/remote/payment_api.dart';

class ProcessMockPaymentUseCase {
  final PaymentApi _paymentApi;

  ProcessMockPaymentUseCase(this._paymentApi);

  Future<void> call({
    required String bookingId,
    bool fail = false,
  }) async {
    return await _paymentApi.mockPayment(
      bookingId: bookingId,
      fail: fail,
    );
  }
}

