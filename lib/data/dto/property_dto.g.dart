// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'property_dto.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

PropertyDto _$PropertyDtoFromJson(Map<String, dynamic> json) => PropertyDto(
  id: json['id'] as String,
  name: json['name'] as String?,
  title: json['title'] as String?,
  description: json['description'] as String?,
  city: json['city'] as String,
  address: json['address'] as String?,
  latitude: (json['latitude'] as num?)?.toDouble(),
  longitude: (json['longitude'] as num?)?.toDouble(),
  propertyType: json['property_type'] as String?,
  type: json['type'] as String?,
  pricePerNight: (json['price_per_night'] as num?)?.toDouble(),
  price: (json['price'] as num?)?.toDouble(),
  amenities: json['amenities'] as List<dynamic>? ?? [],
  amenitiesList: json['amenities_list'] as List<dynamic>? ?? [],
  imageUrls: json['image_urls'] as List<dynamic>? ?? [],
  images: json['images'] as List<dynamic>? ?? [],
  thumbnail: json['thumbnail'] as String?,
  ownerId: json['owner_id'] as String?,
  owner: json['owner'] == null
      ? null
      : PropertyOwnerDto.fromJson(json['owner'] as Map<String, dynamic>),
  ownerPhoneDirect: json['owner_phone'] as String?,
  ownerNameDirect: json['owner_name'] as String?,
  location: json['location'] == null
      ? null
      : PropertyLocationDto.fromJson(json['location'] as Map<String, dynamic>),
  createdAt: json['created_at'] as String?,
  updatedAt: json['updated_at'] as String?,
  averageRating: (json['average_rating'] as num?)?.toDouble(),
  avgRating: (json['avg_rating'] as num?)?.toDouble(),
  reviewCount: (json['review_count'] as num?)?.toInt(),
  reviewsCount: (json['reviews_count'] as num?)?.toInt(),
  bookingsCount: (json['bookings_count'] as num?)?.toInt(),
  totalRevenue: (json['total_revenue'] as num?)?.toDouble(),
  version: (json['version'] as num?)?.toInt(),
  photos: json['photos'] as List<dynamic>? ?? [],
  gallery: json['gallery'] as List<dynamic>? ?? [],
  media: json['media'] as List<dynamic>? ?? [],
  unavailableDates: json['unavailable_dates'] as List<dynamic>? ?? [],
  availability: json['availability'] as Map<String, dynamic>?,
);

Map<String, dynamic> _$PropertyDtoToJson(PropertyDto instance) =>
    <String, dynamic>{
      'id': instance.id,
      if (instance.name case final value?) 'name': value,
      if (instance.title case final value?) 'title': value,
      if (instance.description case final value?) 'description': value,
      'city': instance.city,
      if (instance.address case final value?) 'address': value,
      if (instance.latitude case final value?) 'latitude': value,
      if (instance.longitude case final value?) 'longitude': value,
      if (instance.propertyType case final value?) 'property_type': value,
      if (instance.type case final value?) 'type': value,
      if (instance.pricePerNight case final value?) 'price_per_night': value,
      if (instance.price case final value?) 'price': value,
      'amenities': instance.amenities,
      'amenities_list': instance.amenitiesList,
      'image_urls': instance.imageUrls,
      'images': instance.images,
      if (instance.thumbnail case final value?) 'thumbnail': value,
      if (instance.ownerId case final value?) 'owner_id': value,
      if (instance.owner?.toJson() case final value?) 'owner': value,
      if (instance.ownerPhoneDirect case final value?) 'owner_phone': value,
      if (instance.ownerNameDirect case final value?) 'owner_name': value,
      if (instance.location?.toJson() case final value?) 'location': value,
      if (instance.createdAt case final value?) 'created_at': value,
      if (instance.updatedAt case final value?) 'updated_at': value,
      if (instance.averageRating case final value?) 'average_rating': value,
      if (instance.avgRating case final value?) 'avg_rating': value,
      if (instance.reviewCount case final value?) 'review_count': value,
      if (instance.reviewsCount case final value?) 'reviews_count': value,
      if (instance.bookingsCount case final value?) 'bookings_count': value,
      if (instance.totalRevenue case final value?) 'total_revenue': value,
      if (instance.version case final value?) 'version': value,
      'photos': instance.photos,
      'gallery': instance.gallery,
      'media': instance.media,
      'unavailable_dates': instance.unavailableDates,
      if (instance.availability case final value?) 'availability': value,
    };

PropertyListResponseDto _$PropertyListResponseDtoFromJson(
  Map<String, dynamic> json,
) => PropertyListResponseDto(
  data: (json['data'] as List<dynamic>)
      .map((e) => PropertyDto.fromJson(e as Map<String, dynamic>))
      .toList(),
  meta: json['meta'] == null
      ? null
      : PropertyListMetaDto.fromJson(json['meta'] as Map<String, dynamic>),
  nextCursor: json['next_cursor'] as String?,
  hasMore: json['has_more'] as bool?,
);

Map<String, dynamic> _$PropertyListResponseDtoToJson(
  PropertyListResponseDto instance,
) => <String, dynamic>{
  'data': instance.data.map((e) => e.toJson()).toList(),
  if (instance.meta?.toJson() case final value?) 'meta': value,
  if (instance.nextCursor case final value?) 'next_cursor': value,
  if (instance.hasMore case final value?) 'has_more': value,
};

PropertyListMetaDto _$PropertyListMetaDtoFromJson(Map<String, dynamic> json) =>
    PropertyListMetaDto(
      nextCursor: json['next_cursor'] as String?,
      hasMore: json['has_more'] as bool? ?? false,
    );

Map<String, dynamic> _$PropertyListMetaDtoToJson(
  PropertyListMetaDto instance,
) => <String, dynamic>{
  if (instance.nextCursor case final value?) 'next_cursor': value,
  'has_more': instance.hasMore,
};

PropertyLocationDto _$PropertyLocationDtoFromJson(Map<String, dynamic> json) =>
    PropertyLocationDto(
      latitude: (json['latitude'] as num?)?.toDouble(),
      longitude: (json['longitude'] as num?)?.toDouble(),
      mapUrl: json['map_url'] as String?,
      locationUrl: json['location_url'] as String?,
      externalUrl: json['external_url'] as String?,
    );

Map<String, dynamic> _$PropertyLocationDtoToJson(
  PropertyLocationDto instance,
) => <String, dynamic>{
  if (instance.latitude case final value?) 'latitude': value,
  if (instance.longitude case final value?) 'longitude': value,
  if (instance.mapUrl case final value?) 'map_url': value,
  if (instance.locationUrl case final value?) 'location_url': value,
  if (instance.externalUrl case final value?) 'external_url': value,
};

PropertyOwnerDto _$PropertyOwnerDtoFromJson(Map<String, dynamic> json) =>
    PropertyOwnerDto(
      id: json['id'] as String,
      name: json['name'] as String?,
      phoneNumber: json['phone_number'] as String?,
      phone: json['phone'] as String?,
      email: json['email'] as String?,
      region: json['region'] as String?,
    );

Map<String, dynamic> _$PropertyOwnerDtoToJson(PropertyOwnerDto instance) =>
    <String, dynamic>{
      'id': instance.id,
      if (instance.name case final value?) 'name': value,
      if (instance.phoneNumber case final value?) 'phone_number': value,
      if (instance.phone case final value?) 'phone': value,
      if (instance.email case final value?) 'email': value,
      if (instance.region case final value?) 'region': value,
    };
