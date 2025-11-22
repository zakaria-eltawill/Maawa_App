import 'package:maawa_project/domain/repositories/booking_repository.dart';

class MockPaymentUseCase {
  final BookingRepository _repository;

  MockPaymentUseCase(this._repository);

  Future<void> call(String bookingId) async {
    // This will be handled in the data layer via payment API
    // For now, we'll create a placeholder
  }
}

