import 'package:flutter/foundation.dart';
import 'package:json_annotation/json_annotation.dart';
import 'package:maawa_project/core/config/app_config.dart';
import 'package:maawa_project/domain/entities/booking.dart';

part 'booking_dto.g.dart';

@JsonSerializable()
class BookingDto {
  final String id;
  @JsonKey(name: 'property_id')
  final String propertyId;
  // Nested property details for card display
  final BookingPropertyDto? property;
  @JsonKey(name: 'tenant_id')
  final String tenantId;
  // Nested tenant details for card display
  final BookingTenantDto? tenant;
  @JsonKey(name: 'check_in')
  final String checkIn;
  @JsonKey(name: 'check_out')
  final String checkOut;
  final String status;
  final int? guests;
  // Backend returns 'total', not 'total_price'
  @JsonKey(name: 'total')
  final double total;
  @JsonKey(name: 'is_paid', defaultValue: false)
  final bool isPaid;
  @JsonKey(name: 'payment_due_at')
  final String? paymentDueAt;
  @JsonKey(name: 'created_at')
  final String? createdAt;
  @JsonKey(name: 'updated_at')
  final String? updatedAt;
  @JsonKey(name: 'rejection_reason')
  final String? rejectionReason;
  final List<BookingTimelineEventDto>? timeline;

  BookingDto({
    required this.id,
    required this.propertyId,
    this.property,
    required this.tenantId,
    this.tenant,
    required this.checkIn,
    required this.checkOut,
    required this.status,
    this.guests,
    required this.total,
    this.isPaid = false,
    this.paymentDueAt,
    this.createdAt,
    this.updatedAt,
    this.rejectionReason,
    this.timeline,
  });

  factory BookingDto.fromJson(Map<String, dynamic> json) =>
      _$BookingDtoFromJson(json);

  Map<String, dynamic> toJson() => _$BookingDtoToJson(this);

  Booking toDomain() {
    // Resolve property thumbnail URL
    String? thumbnailUrl;
    if (property != null) {
      if (kDebugMode) {
        debugPrint('📸 Booking $id - Property image resolution:');
        debugPrint('   Property title: ${property!.title ?? property!.name}');
        debugPrint('   Property thumbnail: ${property!.thumbnail}');
        debugPrint('   Property thumbnailUrl: ${property!.thumbnailUrl}');
        debugPrint('   Property imageUrl: ${property!.imageUrl}');
        debugPrint('   Property imageUrls: ${property!.imageUrls}');
        debugPrint('   Property images: ${property!.images}');
        debugPrint('   Property photos: ${property!.photos}');
        debugPrint('   Property gallery: ${property!.gallery}');
        debugPrint('   imageUrlResolved: ${property!.imageUrlResolved}');
      }
      
      if (property!.imageUrlResolved != null) {
        final rawUrl = property!.imageUrlResolved!;
        thumbnailUrl = AppConfig.resolveAssetUrl(rawUrl);
        if (kDebugMode) {
          debugPrint('   ✅ Using resolved URL: $thumbnailUrl');
        }
      } else {
        if (kDebugMode) {
          debugPrint('   ⚠️ No image URL resolved from property data');
        }
      }
    } else {
      if (kDebugMode) {
        debugPrint('⚠️ Booking $id - Property is null');
      }
    }
    
    return Booking(
      id: id,
      propertyId: propertyId,
      propertyName: property?.title ?? property?.name,
      propertyType: property?.type,
      propertyCity: property?.city,
      propertyThumbnail: thumbnailUrl,
      tenantId: tenant?.id ?? tenantId, // Use tenant.id if available, fallback to tenantId
      tenantName: tenant?.name,
      tenantEmail: tenant?.email,
      tenantPhone: tenant?.phoneNumber,
      tenantRegion: tenant?.region,
      ownerName: property?.owner?.name,
      ownerPhone: property?.owner?.phoneNumber,
      checkIn: DateTime.parse(checkIn),
      checkOut: DateTime.parse(checkOut),
      status: BookingStatus.fromString(status),
      guests: guests,
      totalPrice: total, // Use 'total' from backend
      isPaid: isPaid,
      createdAt: createdAt != null ? DateTime.parse(createdAt!) : DateTime.now(),
      updatedAt: updatedAt != null ? DateTime.parse(updatedAt!) : null,
      rejectionReason: rejectionReason,
      timeline: timeline?.map((e) => e.toDomain()).toList() ?? [],
    );
  }
}

@JsonSerializable()
class BookingTimelineEventDto {
  final String status;
  final String timestamp;
  final String? note;

  BookingTimelineEventDto({
    required this.status,
    required this.timestamp,
    this.note,
  });

  factory BookingTimelineEventDto.fromJson(Map<String, dynamic> json) =>
      _$BookingTimelineEventDtoFromJson(json);

  Map<String, dynamic> toJson() => _$BookingTimelineEventDtoToJson(this);

  BookingTimelineEvent toDomain() {
    return BookingTimelineEvent(
      status: BookingStatus.fromString(status),
      timestamp: DateTime.parse(timestamp),
      note: note,
    );
  }
}

@JsonSerializable()
class CreateBookingRequestDto {
  @JsonKey(name: 'property_id')
  final String propertyId;
  @JsonKey(name: 'check_in')
  final String checkIn;
  @JsonKey(name: 'check_out')
  final String checkOut;
  final int? guests;

  CreateBookingRequestDto({
    required this.propertyId,
    required this.checkIn,
    required this.checkOut,
    this.guests,
  });

  factory CreateBookingRequestDto.fromJson(Map<String, dynamic> json) =>
      _$CreateBookingRequestDtoFromJson(json);

  Map<String, dynamic> toJson() => _$CreateBookingRequestDtoToJson(this);
}

@JsonSerializable()
class OwnerDecisionRequestDto {
  final String decision;
  final String? reason;

  OwnerDecisionRequestDto({
    required this.decision,
    this.reason,
  });

  factory OwnerDecisionRequestDto.fromJson(Map<String, dynamic> json) =>
      _$OwnerDecisionRequestDtoFromJson(json);

  Map<String, dynamic> toJson() => _$OwnerDecisionRequestDtoToJson(this);
}

// Nested property details in booking response
@JsonSerializable()
class BookingPropertyDto {
  final String? title;
  final String? name;
  final String? type;
  final String? city;
  final double? price;
  // Backend might use different field names for images
  final String? thumbnail;
  final String? photo;
  final String? image;
  @JsonKey(name: 'thumbnail_url')
  final String? thumbnailUrl;
  @JsonKey(name: 'image_url')
  final String? imageUrl;
  // Support for image arrays (like PropertyDto)
  @JsonKey(name: 'image_urls', defaultValue: <dynamic>[])
  final List<dynamic> imageUrls;
  @JsonKey(name: 'images', defaultValue: <dynamic>[])
  final List<dynamic> images;
  @JsonKey(name: 'photos', defaultValue: <dynamic>[])
  final List<dynamic> photos;
  @JsonKey(name: 'gallery', defaultValue: <dynamic>[])
  final List<dynamic> gallery;
  // Owner information nested in property
  final BookingPropertyOwnerDto? owner;

  BookingPropertyDto({
    this.title,
    this.name,
    this.type,
    this.city,
    this.price,
    this.thumbnail,
    this.photo,
    this.image,
    this.thumbnailUrl,
    this.imageUrl,
    this.imageUrls = const [],
    this.images = const [],
    this.photos = const [],
    this.gallery = const [],
    this.owner,
  });

  // Get the first available image URL
  // Priority: arrays (first item) > single image fields
  String? get imageUrlResolved {
    // Check arrays first (most common format)
    if (imageUrls.isNotEmpty) {
      final first = imageUrls.first;
      if (first is String && first.isNotEmpty) {
        return first;
      }
    }
    if (images.isNotEmpty) {
      final first = images.first;
      if (first is String && first.isNotEmpty) {
        return first;
      }
    }
    if (photos.isNotEmpty) {
      final first = photos.first;
      if (first is String && first.isNotEmpty) {
        return first;
      }
    }
    if (gallery.isNotEmpty) {
      final first = gallery.first;
      if (first is String && first.isNotEmpty) {
        return first;
      }
    }
    
    // Fall back to single image fields
    return thumbnail ?? 
           thumbnailUrl ?? 
           photo ?? 
           image ?? 
           imageUrl;
  }

  factory BookingPropertyDto.fromJson(Map<String, dynamic> json) =>
      _$BookingPropertyDtoFromJson(json);

  Map<String, dynamic> toJson() => _$BookingPropertyDtoToJson(this);
}

// Nested tenant details in booking response
@JsonSerializable()
class BookingTenantDto {
  final String id;
  final String? name;
  final String? email;
  @JsonKey(name: 'phone_number')
  final String? phoneNumber;
  final String? region;

  BookingTenantDto({
    required this.id,
    this.name,
    this.email,
    this.phoneNumber,
    this.region,
  });

  factory BookingTenantDto.fromJson(Map<String, dynamic> json) =>
      _$BookingTenantDtoFromJson(json);

  Map<String, dynamic> toJson() => _$BookingTenantDtoToJson(this);
}

// Nested owner details in booking property response
@JsonSerializable()
class BookingPropertyOwnerDto {
  final String id;
  final String? name;
  @JsonKey(name: 'phone_number')
  final String? phoneNumber;
  final String? email;
  final String? region;

  BookingPropertyOwnerDto({
    required this.id,
    this.name,
    this.phoneNumber,
    this.email,
    this.region,
  });

  factory BookingPropertyOwnerDto.fromJson(Map<String, dynamic> json) =>
      _$BookingPropertyOwnerDtoFromJson(json);

  Map<String, dynamic> toJson() => _$BookingPropertyOwnerDtoToJson(this);
}

