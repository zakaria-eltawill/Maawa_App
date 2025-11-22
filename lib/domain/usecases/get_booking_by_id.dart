import 'package:maawa_project/domain/entities/booking.dart';
import 'package:maawa_project/domain/repositories/booking_repository.dart';

class GetBookingByIdUseCase {
  final BookingRepository _repository;

  GetBookingByIdUseCase(this._repository);

  Future<Booking> call(String id) async {
    return await _repository.getBookingById(id);
  }
}

