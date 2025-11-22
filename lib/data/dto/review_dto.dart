import 'package:json_annotation/json_annotation.dart';
import 'package:maawa_project/domain/entities/review.dart';

part 'review_dto.g.dart';

@JsonSerializable()
class ReviewDto {
  final String id;
  @JsonKey(name: 'property_id')
  final String propertyId;
  @JsonKey(name: 'tenant_id')
  final String tenantId;
  @JsonKey(name: 'tenant_name')
  final String? tenantName;
  final int rating;
  final String? comment;
  @JsonKey(name: 'created_at')
  final String createdAt;
  @JsonKey(name: 'updated_at')
  final String? updatedAt;

  ReviewDto({
    required this.id,
    required this.propertyId,
    required this.tenantId,
    this.tenantName,
    required this.rating,
    this.comment,
    required this.createdAt,
    this.updatedAt,
  });

  factory ReviewDto.fromJson(Map<String, dynamic> json) =>
      _$ReviewDtoFromJson(json);

  Map<String, dynamic> toJson() => _$ReviewDtoToJson(this);

  Review toDomain() {
    return Review(
      id: id,
      propertyId: propertyId,
      tenantId: tenantId,
      tenantName: tenantName,
      rating: rating,
      comment: comment,
      createdAt: DateTime.parse(createdAt),
      updatedAt: updatedAt != null ? DateTime.parse(updatedAt!) : null,
    );
  }
}

@JsonSerializable()
class CreateReviewRequestDto {
  final int rating;
  final String? comment;

  CreateReviewRequestDto({
    required this.rating,
    this.comment,
  });

  factory CreateReviewRequestDto.fromJson(Map<String, dynamic> json) =>
      _$CreateReviewRequestDtoFromJson(json);

  Map<String, dynamic> toJson() => _$CreateReviewRequestDtoToJson(this);
}

