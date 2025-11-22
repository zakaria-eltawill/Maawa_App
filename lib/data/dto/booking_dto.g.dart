// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'booking_dto.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

BookingDto _$BookingDtoFromJson(Map<String, dynamic> json) => BookingDto(
  id: json['id'] as String,
  propertyId: json['property_id'] as String,
  property: json['property'] == null
      ? null
      : BookingPropertyDto.fromJson(json['property'] as Map<String, dynamic>),
  tenantId: json['tenant_id'] as String,
  tenant: json['tenant'] == null
      ? null
      : BookingTenantDto.fromJson(json['tenant'] as Map<String, dynamic>),
  checkIn: json['check_in'] as String,
  checkOut: json['check_out'] as String,
  status: json['status'] as String,
  guests: (json['guests'] as num?)?.toInt(),
  total: (json['total'] as num).toDouble(),
  isPaid: json['is_paid'] as bool? ?? false,
  paymentDueAt: json['payment_due_at'] as String?,
  createdAt: json['created_at'] as String?,
  updatedAt: json['updated_at'] as String?,
  rejectionReason: json['rejection_reason'] as String?,
  timeline: (json['timeline'] as List<dynamic>?)
      ?.map((e) => BookingTimelineEventDto.fromJson(e as Map<String, dynamic>))
      .toList(),
);

Map<String, dynamic> _$BookingDtoToJson(BookingDto instance) =>
    <String, dynamic>{
      'id': instance.id,
      'property_id': instance.propertyId,
      if (instance.property?.toJson() case final value?) 'property': value,
      'tenant_id': instance.tenantId,
      if (instance.tenant?.toJson() case final value?) 'tenant': value,
      'check_in': instance.checkIn,
      'check_out': instance.checkOut,
      'status': instance.status,
      if (instance.guests case final value?) 'guests': value,
      'total': instance.total,
      'is_paid': instance.isPaid,
      if (instance.paymentDueAt case final value?) 'payment_due_at': value,
      if (instance.createdAt case final value?) 'created_at': value,
      if (instance.updatedAt case final value?) 'updated_at': value,
      if (instance.rejectionReason case final value?) 'rejection_reason': value,
      if (instance.timeline?.map((e) => e.toJson()).toList() case final value?)
        'timeline': value,
    };

BookingTimelineEventDto _$BookingTimelineEventDtoFromJson(
  Map<String, dynamic> json,
) => BookingTimelineEventDto(
  status: json['status'] as String,
  timestamp: json['timestamp'] as String,
  note: json['note'] as String?,
);

Map<String, dynamic> _$BookingTimelineEventDtoToJson(
  BookingTimelineEventDto instance,
) => <String, dynamic>{
  'status': instance.status,
  'timestamp': instance.timestamp,
  if (instance.note case final value?) 'note': value,
};

CreateBookingRequestDto _$CreateBookingRequestDtoFromJson(
  Map<String, dynamic> json,
) => CreateBookingRequestDto(
  propertyId: json['property_id'] as String,
  checkIn: json['check_in'] as String,
  checkOut: json['check_out'] as String,
  guests: (json['guests'] as num?)?.toInt(),
);

Map<String, dynamic> _$CreateBookingRequestDtoToJson(
  CreateBookingRequestDto instance,
) => <String, dynamic>{
  'property_id': instance.propertyId,
  'check_in': instance.checkIn,
  'check_out': instance.checkOut,
  if (instance.guests case final value?) 'guests': value,
};

OwnerDecisionRequestDto _$OwnerDecisionRequestDtoFromJson(
  Map<String, dynamic> json,
) => OwnerDecisionRequestDto(
  decision: json['decision'] as String,
  reason: json['reason'] as String?,
);

Map<String, dynamic> _$OwnerDecisionRequestDtoToJson(
  OwnerDecisionRequestDto instance,
) => <String, dynamic>{
  'decision': instance.decision,
  if (instance.reason case final value?) 'reason': value,
};

BookingPropertyDto _$BookingPropertyDtoFromJson(Map<String, dynamic> json) =>
    BookingPropertyDto(
      title: json['title'] as String?,
      name: json['name'] as String?,
      type: json['type'] as String?,
      city: json['city'] as String?,
      price: (json['price'] as num?)?.toDouble(),
      thumbnail: json['thumbnail'] as String?,
      photo: json['photo'] as String?,
      image: json['image'] as String?,
      thumbnailUrl: json['thumbnail_url'] as String?,
      imageUrl: json['image_url'] as String?,
      imageUrls: json['image_urls'] as List<dynamic>? ?? [],
      images: json['images'] as List<dynamic>? ?? [],
      photos: json['photos'] as List<dynamic>? ?? [],
      gallery: json['gallery'] as List<dynamic>? ?? [],
      owner: json['owner'] == null
          ? null
          : BookingPropertyOwnerDto.fromJson(
              json['owner'] as Map<String, dynamic>,
            ),
    );

Map<String, dynamic> _$BookingPropertyDtoToJson(BookingPropertyDto instance) =>
    <String, dynamic>{
      if (instance.title case final value?) 'title': value,
      if (instance.name case final value?) 'name': value,
      if (instance.type case final value?) 'type': value,
      if (instance.city case final value?) 'city': value,
      if (instance.price case final value?) 'price': value,
      if (instance.thumbnail case final value?) 'thumbnail': value,
      if (instance.photo case final value?) 'photo': value,
      if (instance.image case final value?) 'image': value,
      if (instance.thumbnailUrl case final value?) 'thumbnail_url': value,
      if (instance.imageUrl case final value?) 'image_url': value,
      'image_urls': instance.imageUrls,
      'images': instance.images,
      'photos': instance.photos,
      'gallery': instance.gallery,
      if (instance.owner?.toJson() case final value?) 'owner': value,
    };

BookingTenantDto _$BookingTenantDtoFromJson(Map<String, dynamic> json) =>
    BookingTenantDto(
      id: json['id'] as String,
      name: json['name'] as String?,
      email: json['email'] as String?,
      phoneNumber: json['phone_number'] as String?,
      region: json['region'] as String?,
    );

Map<String, dynamic> _$BookingTenantDtoToJson(BookingTenantDto instance) =>
    <String, dynamic>{
      'id': instance.id,
      if (instance.name case final value?) 'name': value,
      if (instance.email case final value?) 'email': value,
      if (instance.phoneNumber case final value?) 'phone_number': value,
      if (instance.region case final value?) 'region': value,
    };

BookingPropertyOwnerDto _$BookingPropertyOwnerDtoFromJson(
  Map<String, dynamic> json,
) => BookingPropertyOwnerDto(
  id: json['id'] as String,
  name: json['name'] as String?,
  phoneNumber: json['phone_number'] as String?,
  email: json['email'] as String?,
  region: json['region'] as String?,
);

Map<String, dynamic> _$BookingPropertyOwnerDtoToJson(
  BookingPropertyOwnerDto instance,
) => <String, dynamic>{
  'id': instance.id,
  if (instance.name case final value?) 'name': value,
  if (instance.phoneNumber case final value?) 'phone_number': value,
  if (instance.email case final value?) 'email': value,
  if (instance.region case final value?) 'region': value,
};
