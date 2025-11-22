import 'package:maawa_project/domain/entities/booking.dart';
import 'package:maawa_project/domain/repositories/booking_repository.dart';

class OwnerDecisionUseCase {
  final BookingRepository _repository;

  OwnerDecisionUseCase(this._repository);

  Future<Booking> call({
    required String bookingId,
    required String decision,
    String? reason,
  }) async {
    return await _repository.ownerDecision(
      bookingId: bookingId,
      decision: decision,
      reason: reason,
    );
  }
}

