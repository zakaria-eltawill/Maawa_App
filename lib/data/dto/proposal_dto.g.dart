// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'proposal_dto.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

ProposalDto _$ProposalDtoFromJson(Map<String, dynamic> json) => ProposalDto(
  id: json['id'] as String,
  type: json['type'] as String? ?? 'ADD',
  status: json['status'] as String,
  propertyId: json['property_id'] as String?,
  ownerId: json['owner_id'] as String? ?? '',
  data: json['data'] == null
      ? null
      : ProposalDataDto.fromJson(json['data'] as Map<String, dynamic>),
  payload: json['payload'] == null
      ? null
      : ProposalDataDto.fromJson(json['payload'] as Map<String, dynamic>),
  adminNotes: json['admin_notes'] as String?,
  createdAt: json['created_at'] as String? ?? '',
  updatedAt: json['updated_at'] as String?,
);

Map<String, dynamic> _$ProposalDtoToJson(ProposalDto instance) =>
    <String, dynamic>{
      'id': instance.id,
      'type': instance.type,
      'status': instance.status,
      if (instance.propertyId case final value?) 'property_id': value,
      'owner_id': instance.ownerId,
      if (instance.data?.toJson() case final value?) 'data': value,
      if (instance.payload?.toJson() case final value?) 'payload': value,
      if (instance.adminNotes case final value?) 'admin_notes': value,
      'created_at': instance.createdAt,
      if (instance.updatedAt case final value?) 'updated_at': value,
    };

ProposalDataDto _$ProposalDataDtoFromJson(Map<String, dynamic> json) =>
    ProposalDataDto(
      title: json['title'] as String?,
      name: json['name'] as String?,
      description: json['description'] as String?,
      city: json['city'] as String?,
      address: json['address'] as String?,
      type: json['type'] as String?,
      propertyType: json['property_type'] as String?,
      price: (json['price'] as num?)?.toDouble(),
      pricePerNight: (json['price_per_night'] as num?)?.toDouble(),
      location: json['location'] == null
          ? null
          : ProposalLocationDto.fromJson(
              json['location'] as Map<String, dynamic>,
            ),
      latitude: (json['latitude'] as num?)?.toDouble(),
      longitude: (json['longitude'] as num?)?.toDouble(),
      amenities: (json['amenities'] as List<dynamic>?)
          ?.map((e) => e as String)
          .toList(),
      photos: _photosFromJson(json['photos']),
    );

Map<String, dynamic> _$ProposalDataDtoToJson(ProposalDataDto instance) =>
    <String, dynamic>{
      if (instance.title case final value?) 'title': value,
      if (instance.name case final value?) 'name': value,
      if (instance.description case final value?) 'description': value,
      if (instance.city case final value?) 'city': value,
      if (instance.address case final value?) 'address': value,
      if (instance.type case final value?) 'type': value,
      if (instance.propertyType case final value?) 'property_type': value,
      if (instance.price case final value?) 'price': value,
      if (instance.pricePerNight case final value?) 'price_per_night': value,
      if (instance.location?.toJson() case final value?) 'location': value,
      if (instance.latitude case final value?) 'latitude': value,
      if (instance.longitude case final value?) 'longitude': value,
      if (instance.amenities case final value?) 'amenities': value,
      if (_photosToJson(instance.photos) case final value?) 'photos': value,
    };

ProposalLocationDto _$ProposalLocationDtoFromJson(Map<String, dynamic> json) =>
    ProposalLocationDto(
      latitude: (json['latitude'] as num?)?.toDouble(),
      longitude: (json['longitude'] as num?)?.toDouble(),
      mapUrl: json['map_url'] as String?,
      url: json['url'] as String?,
    );

Map<String, dynamic> _$ProposalLocationDtoToJson(
  ProposalLocationDto instance,
) => <String, dynamic>{
  if (instance.latitude case final value?) 'latitude': value,
  if (instance.longitude case final value?) 'longitude': value,
  if (instance.mapUrl case final value?) 'map_url': value,
  if (instance.url case final value?) 'url': value,
};

ProposalPhotoDto _$ProposalPhotoDtoFromJson(Map<String, dynamic> json) =>
    ProposalPhotoDto(
      url: json['url'] as String,
      position: (json['position'] as num).toInt(),
    );

Map<String, dynamic> _$ProposalPhotoDtoToJson(ProposalPhotoDto instance) =>
    <String, dynamic>{'url': instance.url, 'position': instance.position};

CreateProposalRequestDto _$CreateProposalRequestDtoFromJson(
  Map<String, dynamic> json,
) => CreateProposalRequestDto(
  type: json['type'] as String,
  propertyId: json['property_id'] as String?,
  data: json['data'] == null
      ? null
      : ProposalDataDto.fromJson(json['data'] as Map<String, dynamic>),
  payload: json['payload'] == null
      ? null
      : ProposalDataDto.fromJson(json['payload'] as Map<String, dynamic>),
);

Map<String, dynamic> _$CreateProposalRequestDtoToJson(
  CreateProposalRequestDto instance,
) => <String, dynamic>{
  'type': instance.type,
  if (instance.propertyId case final value?) 'property_id': value,
  if (instance.data?.toJson() case final value?) 'data': value,
  if (instance.payload?.toJson() case final value?) 'payload': value,
};
