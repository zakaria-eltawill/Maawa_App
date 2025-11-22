import 'package:equatable/equatable.dart';
import 'package:maawa_project/domain/entities/property.dart';
import 'package:maawa_project/domain/entities/review.dart';

class PropertyFilters extends Equatable {
  final String? city;
  final String? propertyType;
  final double? minPrice;
  final double? maxPrice;
  final DateTime? dateFrom;
  final DateTime? dateTo;
  final String? cursor;
  final String? searchQuery; // For searching by property name/title

  const PropertyFilters({
    this.city,
    this.propertyType,
    this.minPrice,
    this.maxPrice,
    this.dateFrom,
    this.dateTo,
    this.cursor,
    this.searchQuery,
  });

  PropertyFilters copyWith({
    String? city,
    String? propertyType,
    double? minPrice,
    double? maxPrice,
    DateTime? dateFrom,
    DateTime? dateTo,
    String? cursor,
    String? searchQuery,
  }) {
    return PropertyFilters(
      city: city ?? this.city,
      propertyType: propertyType ?? this.propertyType,
      minPrice: minPrice ?? this.minPrice,
      maxPrice: maxPrice ?? this.maxPrice,
      dateFrom: dateFrom ?? this.dateFrom,
      dateTo: dateTo ?? this.dateTo,
      cursor: cursor ?? this.cursor,
      searchQuery: searchQuery ?? this.searchQuery,
    );
  }

  PropertyFilters clearFilters() {
    return const PropertyFilters();
  }

  bool get hasActiveFilters =>
      city != null ||
      propertyType != null ||
      minPrice != null ||
      maxPrice != null ||
      searchQuery != null;

  @override
  List<Object?> get props => [
        city,
        propertyType,
        minPrice,
        maxPrice,
        dateFrom,
        dateTo,
        cursor,
        searchQuery,
      ];
}

class PropertyListResult {
  final List<Property> properties;
  final String? nextCursor;
  final bool hasMore;

  const PropertyListResult({
    required this.properties,
    this.nextCursor,
    required this.hasMore,
  });
}

abstract class PropertyRepository {
  Future<PropertyListResult> getProperties(PropertyFilters filters);
  Future<PropertyListResult> getOwnerProperties();
  Future<Property> getPropertyById(String id);
  Future<Property> getOwnerPropertyById(String id);
  Future<List<Review>> getPropertyReviews(String propertyId);
}

