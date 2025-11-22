import 'package:equatable/equatable.dart';

class Property extends Equatable {
  final String id;
  final String name;
  final String? description;
  final String city;
  final String? address;
  final double? latitude;
  final double? longitude;
  final String propertyType;
  final double pricePerNight;
  final List<String> amenities;
  final List<String> imageUrls;
  final String? ownerId;
  final String? ownerName;
  final String? ownerPhone;
  final String? ownerEmail;
  final String? ownerRegion;
  final DateTime? createdAt;
  final DateTime? updatedAt;
  final double? averageRating;
  final int? reviewCount;
  final String? locationUrl;
  // Owner-specific statistics (only available when fetched via /owner/properties/:id)
  final int? bookingsCount;
  final double? totalRevenue;
  final int? version; // For conflict prevention when editing
  final List<DateTime> unavailableDates; // Dates that are already booked or unavailable

  const Property({
    required this.id,
    required this.name,
    this.description,
    required this.city,
    this.address,
    this.latitude,
    this.longitude,
    required this.propertyType,
    required this.pricePerNight,
    required this.amenities,
    required this.imageUrls,
    this.ownerId,
    this.ownerName,
    this.ownerPhone,
    this.ownerEmail,
    this.ownerRegion,
    this.createdAt,
    this.updatedAt,
    this.averageRating,
    this.reviewCount,
    this.locationUrl,
    this.bookingsCount,
    this.totalRevenue,
    this.version,
    this.unavailableDates = const [],
  });

  String get mapUrl {
    if (locationUrl != null && locationUrl!.isNotEmpty) {
      return locationUrl!;
    }
    if (latitude != null && longitude != null) {
      return 'https://www.google.com/maps?q=$latitude,$longitude';
    }
    return '';
  }

  @override
  List<Object?> get props => [
        id,
        name,
        description,
        city,
        address,
        latitude,
        longitude,
        propertyType,
        pricePerNight,
        amenities,
        imageUrls,
        ownerId,
        ownerName,
        ownerPhone,
        ownerEmail,
        ownerRegion,
        createdAt,
        updatedAt,
        averageRating,
        reviewCount,
        locationUrl,
        bookingsCount,
        totalRevenue,
        version,
        unavailableDates,
      ];
}

