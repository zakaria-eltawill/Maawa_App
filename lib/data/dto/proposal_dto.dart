import 'package:json_annotation/json_annotation.dart';
import 'package:maawa_project/domain/entities/proposal.dart';

part 'proposal_dto.g.dart';

@JsonSerializable()
class ProposalDto {
  final String id;
  @JsonKey(defaultValue: 'ADD')
  final String type;
  final String status;
  @JsonKey(name: 'property_id')
  final String? propertyId;
  @JsonKey(name: 'owner_id', defaultValue: '')
  final String ownerId;
  final ProposalDataDto? data;
  @JsonKey(name: 'payload')
  final ProposalDataDto? payload; // Backend returns 'payload' instead of 'data'
  @JsonKey(name: 'admin_notes')
  final String? adminNotes;
  @JsonKey(name: 'created_at', defaultValue: '')
  final String createdAt;
  @JsonKey(name: 'updated_at')
  final String? updatedAt;

  ProposalDto({
    required this.id,
    this.type = 'ADD',
    required this.status,
    this.propertyId,
    this.ownerId = '',
    this.data,
    this.payload,
    this.adminNotes,
    this.createdAt = '',
    this.updatedAt,
  });

  factory ProposalDto.fromJson(Map<String, dynamic> json) =>
      _$ProposalDtoFromJson(json);

  Map<String, dynamic> toJson() => _$ProposalDtoToJson(this);

  Proposal toDomain() {
    // Use payload if available, otherwise use data (for backward compatibility)
    final proposalData = payload ?? data;
    
    return Proposal(
      id: id,
      type: ProposalType.fromString(type),
      status: ProposalStatus.fromString(status),
      propertyId: propertyId,
      ownerId: ownerId.isNotEmpty ? ownerId : '', // Handle empty string
      data: proposalData?.toDomain(),
      adminNotes: adminNotes,
      createdAt: createdAt.isNotEmpty 
          ? DateTime.parse(createdAt) 
          : DateTime.now(), // Use current time if not provided
      updatedAt: updatedAt != null && updatedAt!.isNotEmpty 
          ? DateTime.parse(updatedAt!) 
          : null,
    );
  }
}

// Custom converter functions for photos to handle both formats:
// New format: ["url1", "url2"] (array of strings)
// Old format: [{"url":"...","position":0}] (array of objects)
List<String>? _photosFromJson(dynamic json) {
  if (json == null) return null;
  if (json is! List) return null;
  
  return json.map((photo) {
    if (photo is String) {
      return photo; // Already in new format
    } else if (photo is Map<String, dynamic>) {
      // Old format: extract URL from object
      return photo['url'] as String? ?? '';
    } else {
      return photo.toString();
    }
  }).where((url) => url.isNotEmpty).toList();
}

dynamic _photosToJson(List<String>? photos) {
  return photos; // Always serialize as array of strings
}

@JsonSerializable()
class ProposalDataDto {
  final String? title;
  final String? name; // Keep for backward compatibility
  final String? description;
  final String? city;
  final String? address;
  final String? type; // Property type (apartment, villa, etc.)
  @JsonKey(name: 'property_type')
  final String? propertyType; // Keep for backward compatibility
  final double? price;
  @JsonKey(name: 'price_per_night')
  final double? pricePerNight; // Keep for backward compatibility
  final ProposalLocationDto? location;
  final double? latitude; // Keep for backward compatibility
  final double? longitude; // Keep for backward compatibility
  final List<String>? amenities;
  // Backend expects photos as array of URL strings: ["https://...", "https://..."]
  // But may return old format: [{"url":"...","position":0}] - handled in fromJson
  @JsonKey(
    name: 'photos',
    fromJson: _photosFromJson,
    toJson: _photosToJson,
  )
  final List<String>? photos;

  ProposalDataDto({
    this.title,
    this.name,
    this.description,
    this.city,
    this.address,
    this.type,
    this.propertyType,
    this.price,
    this.pricePerNight,
    this.location,
    this.latitude,
    this.longitude,
    this.amenities,
    this.photos,
  });

  factory ProposalDataDto.fromJson(Map<String, dynamic> json) =>
      _$ProposalDataDtoFromJson(json);

  Map<String, dynamic> toJson() => _$ProposalDataDtoToJson(this);

  ProposalData toDomain() {
    return ProposalData(
      name: title ?? name,
      description: description,
      city: city,
      address: address,
      latitude: location?.latitude ?? latitude,
      longitude: location?.longitude ?? longitude,
      propertyType: type ?? propertyType,
      pricePerNight: price ?? pricePerNight,
      amenities: amenities,
      photos: photos, // Include photos in domain entity
    );
  }
}

@JsonSerializable()
class ProposalLocationDto {
  final double? latitude;
  final double? longitude;
  @JsonKey(name: 'map_url')
  final String? mapUrl;
  final String? url; // Keep for backward compatibility

  ProposalLocationDto({
    this.latitude,
    this.longitude,
    this.mapUrl,
    this.url,
  });

  factory ProposalLocationDto.fromJson(Map<String, dynamic> json) =>
      _$ProposalLocationDtoFromJson(json);

  Map<String, dynamic> toJson() {
    final json = <String, dynamic>{};
    if (latitude != null) json['latitude'] = latitude;
    if (longitude != null) json['longitude'] = longitude;
    if (mapUrl != null) {
      json['map_url'] = mapUrl;
    } else if (url != null) {
      json['map_url'] = url; // Use url as map_url if mapUrl is not provided
    }
    return json;
  }
}

@JsonSerializable()
class ProposalPhotoDto {
  final String url;
  final int position;

  ProposalPhotoDto({
    required this.url,
    required this.position,
  });

  factory ProposalPhotoDto.fromJson(Map<String, dynamic> json) =>
      _$ProposalPhotoDtoFromJson(json);

  Map<String, dynamic> toJson() => _$ProposalPhotoDtoToJson(this);
}

@JsonSerializable()
class CreateProposalRequestDto {
  final String type;
  @JsonKey(name: 'property_id')
  final String? propertyId;
  final ProposalDataDto? data;
  @JsonKey(name: 'payload')
  final ProposalDataDto? payload; // Backend may use 'payload' instead of 'data'

  CreateProposalRequestDto({
    required this.type,
    this.propertyId,
    this.data,
    this.payload,
  });

  factory CreateProposalRequestDto.fromJson(Map<String, dynamic> json) =>
      _$CreateProposalRequestDtoFromJson(json);

  Map<String, dynamic> toJson() {
    // Use 'payload' if provided, otherwise use 'data'
    final payloadData = payload ?? data;
    return <String, dynamic>{
      'type': type,
      if (propertyId != null) 'property_id': propertyId,
      if (payloadData != null) 'payload': payloadData.toJson(),
    };
  }
}

