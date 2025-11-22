import 'package:flutter/foundation.dart';
import 'package:maawa_project/core/error/error_handler.dart';
import 'package:maawa_project/data/datasources/remote/property_api.dart';
import 'package:maawa_project/domain/entities/property.dart';
import 'package:maawa_project/domain/entities/review.dart';
import 'package:maawa_project/domain/repositories/property_repository.dart';

class PropertyRepositoryImpl implements PropertyRepository {
  final PropertyApi _propertyApi;

  PropertyRepositoryImpl(this._propertyApi);

  @override
  Future<PropertyListResult> getProperties(PropertyFilters filters) async {
    try {
      debugPrint('🔍 PropertyRepository: Fetching properties with filters: ${filters.propertyType}');
      debugPrint('🔍 Search query: ${filters.searchQuery}');
      
      final response = await _propertyApi.getProperties(filters);
      debugPrint('✅ PropertyRepository: Received ${response.data.length} properties from API');
      
      var properties = response.data.map((dto) => dto.toDomain()).toList();
      debugPrint('📦 PropertyRepository: Mapped to ${properties.length} domain properties');
      
      // Client-side search filtering if backend doesn't support it
      if (filters.searchQuery != null && filters.searchQuery!.isNotEmpty) {
        final searchQuery = filters.searchQuery!.toLowerCase();
        debugPrint('🔎 Applying client-side search filter: "$searchQuery"');
        
        final originalCount = properties.length;
        properties = properties.where((property) {
          // Search in property name (case-insensitive)
          final matchesName = property.name.toLowerCase().contains(searchQuery);
          
          // Search in property city (case-insensitive)
          final matchesCity = property.city.toLowerCase().contains(searchQuery);
          
          // Search in property type (case-insensitive)
          final matchesType = property.propertyType.toLowerCase().contains(searchQuery);
          
          // Search in property address if available
          final matchesAddress = property.address?.toLowerCase().contains(searchQuery) ?? false;
          
          return matchesName || matchesCity || matchesType || matchesAddress;
        }).toList();
        
        debugPrint('✂️ Filtered from $originalCount to ${properties.length} properties');
      }
      
      if (properties.isNotEmpty) {
        debugPrint('🏠 First property: ${properties.first.name} - ${properties.first.city}');
      }

      return PropertyListResult(
        properties: properties,
        nextCursor: response.effectiveNextCursor,
        hasMore: response.effectiveHasMore,
      );
    } catch (e, stackTrace) {
      debugPrint('❌ PropertyRepository: Error fetching properties: $e');
      debugPrint('❌ Stack trace: $stackTrace');
      throw ErrorHandler.handleError(e);
    }
  }

  @override
  Future<Property> getPropertyById(String id) async {
    try {
      final dto = await _propertyApi.getPropertyById(id);
      return dto.toDomain();
    } catch (e) {
      throw ErrorHandler.handleError(e);
    }
  }

  @override
  Future<Property> getOwnerPropertyById(String id) async {
    try {
      debugPrint('🔍 PropertyRepository: Fetching owner property by ID: $id');
      final dto = await _propertyApi.getOwnerPropertyById(id);
      debugPrint('✅ PropertyRepository: Received owner property from API');
      return dto.toDomain();
    } catch (e) {
      debugPrint('❌ PropertyRepository: Error fetching owner property: $e');
      throw ErrorHandler.handleError(e);
    }
  }

  @override
  Future<PropertyListResult> getOwnerProperties() async {
    try {
      debugPrint('🔍 PropertyRepository: Fetching owner properties');
      // Use /properties endpoint - backend automatically filters by role
      // Owners will only see their own properties
      final response = await _propertyApi.getProperties(const PropertyFilters());
      debugPrint('✅ PropertyRepository: Received ${response.data.length} owner properties from API');
      
      final properties = response.data.map((dto) => dto.toDomain()).toList();
      debugPrint('📦 PropertyRepository: Mapped to ${properties.length} domain properties');
      
      return PropertyListResult(
        properties: properties,
        nextCursor: response.effectiveNextCursor,
        hasMore: response.effectiveHasMore,
      );
    } catch (e, stackTrace) {
      debugPrint('❌ PropertyRepository: Error fetching owner properties: $e');
      debugPrint('❌ Stack trace: $stackTrace');
      throw ErrorHandler.handleError(e);
    }
  }

  @override
  Future<List<Review>> getPropertyReviews(String propertyId) async {
    try {
      final dtos = await _propertyApi.getPropertyReviews(propertyId);
      return dtos.map((dto) => dto.toDomain()).toList();
    } catch (e) {
      throw ErrorHandler.handleError(e);
    }
  }
}

