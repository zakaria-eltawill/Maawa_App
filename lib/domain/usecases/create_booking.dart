import 'package:maawa_project/domain/entities/booking.dart';
import 'package:maawa_project/domain/repositories/booking_repository.dart';

class CreateBookingUseCase {
  final BookingRepository _repository;

  CreateBookingUseCase(this._repository);

  Future<Booking> call({
    required String propertyId,
    required DateTime checkIn,
    required DateTime checkOut,
    int? guests,
  }) async {
    return await _repository.createBooking(
      propertyId: propertyId,
      checkIn: checkIn,
      checkOut: checkOut,
      guests: guests,
    );
  }
}

