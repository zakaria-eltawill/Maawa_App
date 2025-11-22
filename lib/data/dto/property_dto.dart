import 'package:flutter/foundation.dart';
import 'package:json_annotation/json_annotation.dart';
import 'package:maawa_project/core/config/app_config.dart';
import 'package:maawa_project/domain/entities/property.dart';

part 'property_dto.g.dart';

@JsonSerializable()
class PropertyDto {
  final String id;
  final String? name;
  final String? title;
  final String? description;
  final String city;
  final String? address;
  final double? latitude;
  final double? longitude;
  @JsonKey(name: 'property_type')
  final String? propertyType;
  final String? type;
  @JsonKey(name: 'price_per_night')
  final double? pricePerNight;
  final double? price;
  @JsonKey(defaultValue: <dynamic>[])
  final List<dynamic> amenities;
  @JsonKey(name: 'amenities_list', defaultValue: <dynamic>[])
  final List<dynamic> amenitiesList;
  @JsonKey(name: 'image_urls', defaultValue: <dynamic>[])
  final List<dynamic> imageUrls;
  @JsonKey(name: 'images', defaultValue: <dynamic>[])
  final List<dynamic> images;
  final String? thumbnail;
  @JsonKey(name: 'owner_id')
  final String? ownerId;
  final PropertyOwnerDto? owner; // Backend may return owner as nested object
  // Support for owner phone directly on property (alternative format)
  @JsonKey(name: 'owner_phone')
  final String? ownerPhoneDirect;
  @JsonKey(name: 'owner_name')
  final String? ownerNameDirect;
  final PropertyLocationDto? location;
  @JsonKey(name: 'created_at')
  final String? createdAt;
  @JsonKey(name: 'updated_at')
  final String? updatedAt;
  @JsonKey(name: 'average_rating')
  final double? averageRating;
  @JsonKey(name: 'avg_rating')
  final double? avgRating;
  @JsonKey(name: 'review_count')
  final int? reviewCount;
  @JsonKey(name: 'reviews_count')
  final int? reviewsCount;
  // Owner-specific statistics
  @JsonKey(name: 'bookings_count')
  final int? bookingsCount;
  @JsonKey(name: 'total_revenue')
  final double? totalRevenue;
  @JsonKey(name: 'version')
  final int? version;
  @JsonKey(name: 'photos', defaultValue: <dynamic>[])
  final List<dynamic> photos;
  @JsonKey(name: 'gallery', defaultValue: <dynamic>[])
  final List<dynamic> gallery;
  @JsonKey(name: 'media', defaultValue: <dynamic>[])
  final List<dynamic> media;
  @JsonKey(name: 'unavailable_dates', defaultValue: <dynamic>[])
  final List<dynamic> unavailableDates;
  // Support for nested availability.unavailable_dates (backward compatibility)
  final Map<String, dynamic>? availability;

  PropertyDto({
    required this.id,
    this.name,
    this.title,
    this.description,
    required this.city,
    this.address,
    this.latitude,
    this.longitude,
    this.propertyType,
    this.type,
    this.pricePerNight,
    this.price,
    this.amenities = const [],
    this.amenitiesList = const [],
    this.imageUrls = const [],
    this.images = const [],
    this.thumbnail,
    this.ownerId,
    this.owner,
    this.ownerPhoneDirect,
    this.ownerNameDirect,
    this.location,
    this.createdAt,
    this.updatedAt,
    this.averageRating,
    this.avgRating,
    this.reviewCount,
    this.reviewsCount,
    this.bookingsCount,
    this.totalRevenue,
    this.version,
    this.photos = const [],
    this.gallery = const [],
    this.media = const [],
    this.unavailableDates = const [],
    this.availability,
  });

  factory PropertyDto.fromJson(Map<String, dynamic> json) =>
      _$PropertyDtoFromJson(json);

  Map<String, dynamic> toJson() => _$PropertyDtoToJson(this);

  Property toDomain() {
    final resolvedAmenities = _mergeStringLists([amenities, amenitiesList]);
    final resolvedLatitude = latitude ?? location?.latitude;
    final resolvedLongitude = longitude ?? location?.longitude;
    final resolvedLocationUrl =
        location?.mapUrl ?? location?.locationUrl ?? location?.externalUrl;

    final resolvedImages = _buildImageUrls([
      imageUrls,
      images,
      photos,
      gallery,
      media,
      if (thumbnail != null) [thumbnail!],
    ]);

    final resolvedName = name ?? title ?? 'Property';
    final resolvedType = propertyType ?? type ?? 'property';
    final resolvedPrice = pricePerNight ?? price ?? 0;
    // Backend returns both avg_rating and average_rating (aliases), prefer average_rating
    final rating = averageRating ?? avgRating;
    // Backend returns reviews_count (new) or review_count (old), prefer reviews_count
    final count = reviewsCount ?? reviewCount;
    
    // Parse unavailable dates from backend
    // Backend returns: Array of date strings in YYYY-MM-DD format: ["2025-12-06", "2025-12-07"]
    // Also supports nested availability.unavailable_dates for backward compatibility
    final List<DateTime> parsedUnavailableDates = [];
    
    // Get unavailable dates from root level (primary source)
    final datesToParse = <dynamic>[];
    if (unavailableDates.isNotEmpty) {
      datesToParse.addAll(unavailableDates);
    }
    // Fallback to nested availability.unavailable_dates if root level is empty
    if (datesToParse.isEmpty && availability != null) {
      final nestedDates = availability!['unavailable_dates'];
      if (nestedDates is List) {
        datesToParse.addAll(nestedDates);
        if (kDebugMode) {
          debugPrint('📅 PropertyDto.toDomain: Using nested availability.unavailable_dates');
        }
      }
    }
    
    if (datesToParse.isNotEmpty) {
      if (kDebugMode) {
        debugPrint('📅 PropertyDto.toDomain: Processing ${datesToParse.length} unavailable date entries');
        debugPrint('📅 PropertyDto.toDomain: First entry type: ${datesToParse.first.runtimeType}');
        debugPrint('📅 PropertyDto.toDomain: First entry: ${datesToParse.first}');
      }
      
      for (final dateValue in datesToParse) {
        try {
          if (dateValue is String) {
            // Parse date string (e.g., "2024-01-15" or "2024-01-15T00:00:00Z")
            final dateStr = dateValue.split('T')[0]; // Get date part only
            final date = DateTime.parse(dateStr);
            parsedUnavailableDates.add(DateTime(date.year, date.month, date.day));
          } else if (dateValue is Map) {
            // Handle date range format: {"check_in": "2024-01-15", "check_out": "2024-01-20"}
            final checkInStr = dateValue['check_in'] ?? dateValue['checkIn'] ?? dateValue['date'];
            final checkOutStr = dateValue['check_out'] ?? dateValue['checkOut'];
            
            if (checkInStr != null && checkOutStr != null) {
              // Parse date range and add all dates in the range
              final checkIn = DateTime.parse(checkInStr.toString().split('T')[0]);
              final checkOut = DateTime.parse(checkOutStr.toString().split('T')[0]);
              
              // Add all dates from check-in to check-out (exclusive of check-out)
              var currentDate = DateTime(checkIn.year, checkIn.month, checkIn.day);
              final endDate = DateTime(checkOut.year, checkOut.month, checkOut.day);
              
              while (currentDate.isBefore(endDate)) {
                parsedUnavailableDates.add(DateTime(currentDate.year, currentDate.month, currentDate.day));
                currentDate = currentDate.add(const Duration(days: 1));
              }
            } else {
              // Single date in map format
              final dateStr = dateValue['date'] ?? dateValue['date_string'];
              if (dateStr != null) {
                final cleanDateStr = dateStr.toString().split('T')[0];
                final date = DateTime.parse(cleanDateStr);
                parsedUnavailableDates.add(DateTime(date.year, date.month, date.day));
              }
            }
          }
        } catch (e) {
          if (kDebugMode) {
            debugPrint('⚠️ PropertyDto: Failed to parse unavailable date: $dateValue - $e');
          }
        }
      }
    }
    
    if (kDebugMode) {
      debugPrint('📅 PropertyDto.toDomain: Parsed ${parsedUnavailableDates.length} unavailable dates');
      if (parsedUnavailableDates.isNotEmpty) {
        debugPrint('📅 PropertyDto.toDomain: First unavailable date: ${parsedUnavailableDates.first}');
        debugPrint('📅 PropertyDto.toDomain: Last unavailable date: ${parsedUnavailableDates.last}');
      }
    }

    // Debug logging for owner information and rating
    if (kDebugMode) {
      final ownerData = owner;
      if (ownerData != null) {
        debugPrint('📦 PropertyDto.toDomain: Owner parsed - name: ${ownerData.name}, phone: ${ownerData.phoneNumber}');
      } else {
        debugPrint('📦 PropertyDto.toDomain: Owner is null');
        debugPrint('📦 PropertyDto.toDomain: Owner ID from field: $ownerId');
      }
      
      // Debug rating data
      debugPrint('⭐ PropertyDto.toDomain: Rating data - averageRating: $averageRating, avgRating: $avgRating, final rating: $rating');
      debugPrint('⭐ PropertyDto.toDomain: Review count - reviewCount: $reviewCount, reviewsCount: $reviewsCount, final count: $count');
      debugPrint('⭐ PropertyDto.toDomain: Property name: $resolvedName');
    }

    return Property(
      id: id,
      name: resolvedName,
      description: description,
      city: city,
      address: address,
      latitude: resolvedLatitude,
      longitude: resolvedLongitude,
      propertyType: resolvedType,
      pricePerNight: resolvedPrice,
      amenities: resolvedAmenities,
      imageUrls: resolvedImages,
      ownerId: ownerId ?? owner?.id, // Use owner.id if ownerId is null
      // Priority: owner object > direct fields
      // For phone: phoneNumber > phone > ownerPhoneDirect
      ownerName: owner?.name ?? ownerNameDirect,
      ownerPhone: owner?.phoneNumber ?? owner?.phone ?? ownerPhoneDirect,
      ownerEmail: owner?.email,
      ownerRegion: owner?.region,
      createdAt: createdAt != null ? DateTime.parse(createdAt!) : null,
      updatedAt: updatedAt != null ? DateTime.parse(updatedAt!) : null,
      // Backend always returns numbers (0.0 for rating, 0 for count when no reviews)
      // Keep the actual values (including 0.0) - the UI widget will handle displaying them
      // Only set to null if both rating sources are null (shouldn't happen with new backend)
      averageRating: rating,
      reviewCount: count,
      locationUrl: resolvedLocationUrl,
      bookingsCount: bookingsCount,
      totalRevenue: totalRevenue,
      version: version,
      unavailableDates: parsedUnavailableDates,
    );
  }
}

@JsonSerializable()
class PropertyListResponseDto {
  final List<PropertyDto> data;
  final PropertyListMetaDto? meta;
  @JsonKey(name: 'next_cursor')
  final String? nextCursor;
  @JsonKey(name: 'has_more')
  final bool? hasMore;

  PropertyListResponseDto({
    required this.data,
    this.meta,
    this.nextCursor,
    this.hasMore,
  });

  factory PropertyListResponseDto.fromJson(Map<String, dynamic> json) =>
      _$PropertyListResponseDtoFromJson(json);

  Map<String, dynamic> toJson() => _$PropertyListResponseDtoToJson(this);

  String? get effectiveNextCursor => nextCursor ?? meta?.nextCursor;
  bool get effectiveHasMore => hasMore ?? meta?.hasMore ?? false;
}

@JsonSerializable()
class PropertyListMetaDto {
  @JsonKey(name: 'next_cursor')
  final String? nextCursor;
  @JsonKey(name: 'has_more')
  final bool hasMore;

  PropertyListMetaDto({
    this.nextCursor,
    this.hasMore = false,
  });

  factory PropertyListMetaDto.fromJson(Map<String, dynamic> json) =>
      _$PropertyListMetaDtoFromJson(json);

  Map<String, dynamic> toJson() => _$PropertyListMetaDtoToJson(this);
}

List<String> _mergeStringLists(List<dynamic> lists) {
  final result = <String>[];
  for (final list in lists) {
    if (list is List) {
      for (final value in list) {
        final str = value?.toString() ?? '';
        if (str.isNotEmpty) {
          result.add(str);
        }
      }
    }
  }
  return result;
}

List<String> _buildImageUrls(List<dynamic> sources) {
  final result = <String>[];

  void addValue(dynamic value) {
    final path = _extractImagePath(value);
    if (path != null && path.isNotEmpty) {
      result.add(AppConfig.resolveAssetUrl(path));
    }
  }

  for (final source in sources) {
    if (source is List) {
      for (final value in source) {
        addValue(value);
      }
    } else {
      addValue(source);
    }
  }
  return result;
}

String? _extractImagePath(dynamic value) {
  if (value == null) return null;
  if (value is String) {
    return value;
  }
  if (value is Map) {
    for (final key in ['url', 'path', 'src']) {
      final candidate = value[key];
      if (candidate is String && candidate.isNotEmpty) {
        return candidate;
      }
    }
  }
  final str = value.toString();
  return str.isNotEmpty ? str : null;
}

@JsonSerializable()
class PropertyLocationDto {
  final double? latitude;
  final double? longitude;
  @JsonKey(name: 'map_url')
  final String? mapUrl;
  @JsonKey(name: 'location_url')
  final String? locationUrl;
  @JsonKey(name: 'external_url')
  final String? externalUrl;

  const PropertyLocationDto({
    this.latitude,
    this.longitude,
    this.mapUrl,
    this.locationUrl,
    this.externalUrl,
  });

  factory PropertyLocationDto.fromJson(Map<String, dynamic> json) =>
      _$PropertyLocationDtoFromJson(json);

  Map<String, dynamic> toJson() => _$PropertyLocationDtoToJson(this);
}

@JsonSerializable()
class PropertyOwnerDto {
  final String id;
  final String? name;
  @JsonKey(name: 'phone_number')
  final String? phoneNumber;
  // Support alternative field name 'phone' (in case backend uses it)
  @JsonKey(name: 'phone')
  final String? phone;
  final String? email;
  final String? region;

  const PropertyOwnerDto({
    required this.id,
    this.name,
    this.phoneNumber,
    this.phone,
    this.email,
    this.region,
  });

  factory PropertyOwnerDto.fromJson(Map<String, dynamic> json) =>
      _$PropertyOwnerDtoFromJson(json);

  Map<String, dynamic> toJson() => _$PropertyOwnerDtoToJson(this);
}

