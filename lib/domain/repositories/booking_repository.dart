import 'package:maawa_project/domain/entities/booking.dart';

abstract class BookingRepository {
  Future<List<Booking>> getBookings(); // Tenant bookings
  Future<List<Booking>> getOwnerBookings(); // Owner bookings
  Future<List<Booking>> getOwnerBookingsByStatus(String status); // Owner bookings by status (pending, accepted, rejected, etc.)
  Future<Booking> createBooking({
    required String propertyId,
    required DateTime checkIn,
    required DateTime checkOut,
    int? guests,
  });
  Future<Booking> getBookingById(String id);
  Future<Booking> ownerDecision({
    required String bookingId,
    required String decision, // ACCEPT or REJECT
    String? reason,
  });
}

