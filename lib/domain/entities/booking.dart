import 'package:equatable/equatable.dart';

enum BookingStatus {
  pending,
  accepted,
  confirmed,
  completed,
  rejected,
  expired,
  canceled;

  static BookingStatus fromString(String status) {
    switch (status.toLowerCase()) {
      case 'pending':
        return BookingStatus.pending;
      case 'accepted':
        return BookingStatus.accepted;
      case 'confirmed':
        return BookingStatus.confirmed;
      case 'completed':
        return BookingStatus.completed;
      case 'rejected':
        return BookingStatus.rejected;
      case 'expired':
        return BookingStatus.expired;
      case 'canceled':
        return BookingStatus.canceled;
      default:
        return BookingStatus.pending;
    }
  }
}

class Booking extends Equatable {
  final String id;
  final String propertyId;
  final String? propertyName;
  final String? propertyType;
  final String? propertyCity;
  final String? propertyThumbnail;
  final String tenantId;
  final String? tenantName;
  final String? tenantEmail;
  final String? tenantPhone;
  final String? tenantRegion;
  final String? ownerName;
  final String? ownerPhone;
  final DateTime checkIn;
  final DateTime checkOut;
  final BookingStatus status;
  final int? guests;
  final double totalPrice;
  final bool isPaid;
  final DateTime createdAt;
  final DateTime? updatedAt;
  final String? rejectionReason;
  final List<BookingTimelineEvent> timeline;

  const Booking({
    required this.id,
    required this.propertyId,
    this.propertyName,
    this.propertyType,
    this.propertyCity,
    this.propertyThumbnail,
    required this.tenantId,
    this.tenantName,
    this.tenantEmail,
    this.tenantPhone,
    this.tenantRegion,
    this.ownerName,
    this.ownerPhone,
    required this.checkIn,
    required this.checkOut,
    required this.status,
    this.guests,
    required this.totalPrice,
    this.isPaid = false,
    required this.createdAt,
    this.updatedAt,
    this.rejectionReason,
    required this.timeline,
  });

  @override
  List<Object?> get props => [
        id,
        propertyId,
        propertyName,
        propertyType,
        propertyCity,
        propertyThumbnail,
        tenantId,
        tenantName,
        tenantEmail,
        tenantPhone,
        tenantRegion,
        ownerName,
        ownerPhone,
        checkIn,
        checkOut,
        status,
      guests,
      totalPrice,
      isPaid,
      createdAt,
      updatedAt,
      rejectionReason,
      timeline,
    ];
}

class BookingTimelineEvent extends Equatable {
  final BookingStatus status;
  final DateTime timestamp;
  final String? note;

  const BookingTimelineEvent({
    required this.status,
    required this.timestamp,
    this.note,
  });

  @override
  List<Object?> get props => [status, timestamp, note];
}

