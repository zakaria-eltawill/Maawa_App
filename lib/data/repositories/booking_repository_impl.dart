import 'package:flutter/foundation.dart';
import 'package:maawa_project/core/error/error_handler.dart';
import 'package:maawa_project/data/datasources/remote/booking_api.dart';
import 'package:maawa_project/domain/entities/booking.dart';
import 'package:maawa_project/domain/repositories/booking_repository.dart';

class BookingRepositoryImpl implements BookingRepository {
  final BookingApi _bookingApi;

  BookingRepositoryImpl(this._bookingApi);

  @override
  Future<List<Booking>> getBookings() async {
    try {
      debugPrint('🔍 BookingRepository: Fetching bookings');
      final dtos = await _bookingApi.getBookings();
      debugPrint('✅ BookingRepository: Received ${dtos.length} bookings from API');
      
      if (dtos.isNotEmpty) {
        debugPrint('🔍 First DTO details:');
        debugPrint('  - property: ${dtos.first.property}');
        debugPrint('  - tenant: ${dtos.first.tenant}');
        if (dtos.first.property != null) {
          debugPrint('  - property.title: ${dtos.first.property!.title}');
          debugPrint('  - property.thumbnail: ${dtos.first.property!.thumbnail}');
          debugPrint('  - property.imageUrlResolved: ${dtos.first.property!.imageUrlResolved}');
        }
      }
      
      final bookings = dtos.map((dto) => dto.toDomain()).toList();
      debugPrint('📦 BookingRepository: Mapped to ${bookings.length} domain bookings');
      
      if (bookings.isNotEmpty) {
        debugPrint('📝 First booking: ${bookings.first.propertyName} - ${bookings.first.status}');
        debugPrint('🖼️  Thumbnail: ${bookings.first.propertyThumbnail}');
      }
      
      return bookings;
    } catch (e, stackTrace) {
      debugPrint('❌ BookingRepository: Error fetching bookings: $e');
      debugPrint('❌ Stack trace: $stackTrace');
      throw ErrorHandler.handleError(e);
    }
  }

  @override
  Future<Booking> createBooking({
    required String propertyId,
    required DateTime checkIn,
    required DateTime checkOut,
    int? guests,
  }) async {
    try {
      debugPrint('🔍 BookingRepository.createBooking: Creating booking');
      final dto = await _bookingApi.createBooking(
        propertyId: propertyId,
        checkIn: checkIn,
        checkOut: checkOut,
        guests: guests,
      );
      debugPrint('✅ BookingRepository.createBooking: Booking DTO received');
      debugPrint('✅   Booking ID: ${dto.id}');
      debugPrint('✅   Status: ${dto.status}');
      
      final booking = dto.toDomain();
      debugPrint('✅ BookingRepository.createBooking: Successfully converted to domain model');
      return booking;
    } catch (e, stackTrace) {
      debugPrint('❌ BookingRepository.createBooking: Error creating booking');
      debugPrint('❌   Error: $e');
      debugPrint('❌   Stack trace: $stackTrace');
      throw ErrorHandler.handleError(e);
    }
  }

  @override
  Future<Booking> getBookingById(String id) async {
    try {
      debugPrint('🔍 BookingRepository: Fetching booking by ID: $id');
      final dto = await _bookingApi.getBookingById(id);
      debugPrint('✅ BookingRepository: Successfully fetched booking');
      final booking = dto.toDomain();
      debugPrint('📦 BookingRepository: Mapped to domain - ${booking.propertyName}');
      return booking;
    } catch (e, stackTrace) {
      debugPrint('❌ BookingRepository: Error fetching booking $id: $e');
      debugPrint('❌ Stack trace: $stackTrace');
      throw ErrorHandler.handleError(e);
    }
  }

  @override
  Future<List<Booking>> getOwnerBookings() async {
    try {
      debugPrint('🔍 BookingRepository: Fetching owner bookings');
      // Use /bookings endpoint - backend automatically filters by role
      // Owners will only see bookings for their properties
      final dtos = await _bookingApi.getBookings();
      debugPrint('✅ BookingRepository: Received ${dtos.length} owner bookings from API');
      
      final bookings = dtos.map((dto) => dto.toDomain()).toList();
      debugPrint('📦 BookingRepository: Mapped to ${bookings.length} domain bookings');
      
      return bookings;
    } catch (e, stackTrace) {
      debugPrint('❌ BookingRepository: Error fetching owner bookings: $e');
      debugPrint('❌ Stack trace: $stackTrace');
      throw ErrorHandler.handleError(e);
    }
  }

  @override
  Future<List<Booking>> getOwnerBookingsByStatus(String status) async {
    try {
      debugPrint('🔍 BookingRepository: Fetching owner bookings with status: $status');
      final dtos = await _bookingApi.getOwnerBookingsByStatus(status);
      debugPrint('✅ BookingRepository: Received ${dtos.length} owner bookings with status $status');
      
      if (dtos.isNotEmpty && kDebugMode) {
        debugPrint('🔍 First booking DTO details:');
        debugPrint('  - property: ${dtos.first.property}');
        if (dtos.first.property != null) {
          debugPrint('  - property.title: ${dtos.first.property!.title}');
          debugPrint('  - property.name: ${dtos.first.property!.name}');
          debugPrint('  - property.thumbnail: ${dtos.first.property!.thumbnail}');
          debugPrint('  - property.imageUrlResolved: ${dtos.first.property!.imageUrlResolved}');
          debugPrint('  - property.imageUrls: ${dtos.first.property!.imageUrls}');
        }
      }
      
      final bookings = dtos.map((dto) => dto.toDomain()).toList();
      
      if (bookings.isNotEmpty && kDebugMode) {
        debugPrint('📝 First booking domain: ${bookings.first.propertyName}');
        debugPrint('🖼️  Thumbnail: ${bookings.first.propertyThumbnail}');
      }
      
      return bookings;
    } catch (e, stackTrace) {
      debugPrint('❌ BookingRepository: Error fetching owner bookings by status: $e');
      debugPrint('❌ Stack trace: $stackTrace');
      throw ErrorHandler.handleError(e);
    }
  }

  @override
  Future<Booking> ownerDecision({
    required String bookingId,
    required String decision,
    String? reason,
  }) async {
    try {
      debugPrint('🔍 BookingRepository.ownerDecision: Making decision');
      debugPrint('🔍   Booking ID: $bookingId');
      debugPrint('🔍   Decision: $decision');
      
      final dto = await _bookingApi.ownerDecision(
        bookingId: bookingId,
        decision: decision,
        reason: reason,
      );
      
      debugPrint('✅ BookingRepository.ownerDecision: Booking DTO received');
      debugPrint('✅   Booking ID: ${dto.id}');
      debugPrint('✅   Status: ${dto.status}');
      
      final booking = dto.toDomain();
      debugPrint('✅ BookingRepository.ownerDecision: Successfully converted to domain model');
      return booking;
    } catch (e, stackTrace) {
      debugPrint('❌ BookingRepository.ownerDecision: Error making decision');
      debugPrint('❌   Error: $e');
      debugPrint('❌   Stack trace: $stackTrace');
      throw ErrorHandler.handleError(e);
    }
  }
}

