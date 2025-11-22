// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'review_dto.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

ReviewDto _$ReviewDtoFromJson(Map<String, dynamic> json) => ReviewDto(
  id: json['id'] as String,
  propertyId: json['property_id'] as String,
  tenantId: json['tenant_id'] as String,
  tenantName: json['tenant_name'] as String?,
  rating: (json['rating'] as num).toInt(),
  comment: json['comment'] as String?,
  createdAt: json['created_at'] as String,
  updatedAt: json['updated_at'] as String?,
);

Map<String, dynamic> _$ReviewDtoToJson(ReviewDto instance) => <String, dynamic>{
  'id': instance.id,
  'property_id': instance.propertyId,
  'tenant_id': instance.tenantId,
  if (instance.tenantName case final value?) 'tenant_name': value,
  'rating': instance.rating,
  if (instance.comment case final value?) 'comment': value,
  'created_at': instance.createdAt,
  if (instance.updatedAt case final value?) 'updated_at': value,
};

CreateReviewRequestDto _$CreateReviewRequestDtoFromJson(
  Map<String, dynamic> json,
) => CreateReviewRequestDto(
  rating: (json['rating'] as num).toInt(),
  comment: json['comment'] as String?,
);

Map<String, dynamic> _$CreateReviewRequestDtoToJson(
  CreateReviewRequestDto instance,
) => <String, dynamic>{
  'rating': instance.rating,
  if (instance.comment case final value?) 'comment': value,
};
