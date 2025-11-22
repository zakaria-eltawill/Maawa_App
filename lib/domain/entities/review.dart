import 'package:equatable/equatable.dart';

class Review extends Equatable {
  final String id;
  final String propertyId;
  final String tenantId;
  final String? tenantName;
  final int rating; // 1-5
  final String? comment;
  final DateTime createdAt;
  final DateTime? updatedAt;

  const Review({
    required this.id,
    required this.propertyId,
    required this.tenantId,
    this.tenantName,
    required this.rating,
    this.comment,
    required this.createdAt,
    this.updatedAt,
  });

  @override
  List<Object?> get props => [
        id,
        propertyId,
        tenantId,
        tenantName,
        rating,
        comment,
        createdAt,
        updatedAt,
      ];
}

