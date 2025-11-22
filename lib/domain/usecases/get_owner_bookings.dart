import 'package:maawa_project/domain/entities/booking.dart';
import 'package:maawa_project/domain/repositories/booking_repository.dart';

class GetOwnerBookingsUseCase {
  final BookingRepository _repository;

  GetOwnerBookingsUseCase(this._repository);

  Future<List<Booking>> call() async {
    return await _repository.getOwnerBookings();
  }
}

