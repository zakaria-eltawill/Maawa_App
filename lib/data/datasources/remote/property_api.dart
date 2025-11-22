import 'package:flutter/foundation.dart';
import 'package:maawa_project/core/network/dio_client.dart';
import 'package:maawa_project/data/dto/property_dto.dart';
import 'package:maawa_project/data/dto/review_dto.dart';
import 'package:maawa_project/domain/repositories/property_repository.dart';

class PropertyApi {
  final DioClient _dioClient;

  PropertyApi(this._dioClient);

  Future<PropertyListResponseDto> getProperties(
    PropertyFilters filters,
  ) async {
    final queryParams = <String, dynamic>{};

    if (filters.city != null) {
      queryParams['city'] = filters.city;
    }
    if (filters.propertyType != null) {
      queryParams['type'] = filters.propertyType; // Backend expects 'type' not 'property_type'
    }
    if (filters.minPrice != null) {
      queryParams['min_price'] = filters.minPrice;
    }
    if (filters.maxPrice != null) {
      queryParams['max_price'] = filters.maxPrice;
    }
    // Support cursor-based pagination
    if (filters.cursor != null) {
      queryParams['cursor'] = filters.cursor;
    }
    // Date filters (if supported by backend)
    if (filters.dateFrom != null) {
      queryParams['date_from'] = filters.dateFrom!.toIso8601String();
    }
    if (filters.dateTo != null) {
      queryParams['date_to'] = filters.dateTo!.toIso8601String();
    }
    if (filters.searchQuery != null && filters.searchQuery!.isNotEmpty) {
      queryParams['search'] = filters.searchQuery; // Search by property name/title
    }

    debugPrint('🌐 PropertyApi: GET /properties with params: $queryParams');
    final response = await _dioClient.get(
      '/properties',
      queryParameters: queryParams,
    );

    debugPrint('📡 PropertyApi: Response status: ${response.statusCode}');
    debugPrint('📡 PropertyApi: Response data type: ${response.data.runtimeType}');
    debugPrint('📡 PropertyApi: Response data: ${response.data}');
    
    final jsonData = response.data as Map<String, dynamic>;
    debugPrint('📦 PropertyApi: Parsing response with keys: ${jsonData.keys.toList()}');
    
    final result = PropertyListResponseDto.fromJson(jsonData);
    debugPrint('✅ PropertyApi: Successfully parsed ${result.data.length} properties');
    
    return result;
  }

  Future<PropertyDto> getPropertyById(String id) async {
    debugPrint('🌐 PropertyApi.getPropertyById: Calling /properties/$id');
    final response = await _dioClient.get('/properties/$id');
    
    if (kDebugMode) {
      debugPrint('📦 PropertyApi.getPropertyById: Response data: ${response.data}');
      if (response.data is Map<String, dynamic>) {
        final data = response.data as Map<String, dynamic>;
        debugPrint('📦 PropertyApi.getPropertyById: Owner ID: ${data['owner_id']}');
        debugPrint('📦 PropertyApi.getPropertyById: Owner object: ${data['owner']}');
        if (data['owner'] != null) {
          debugPrint('📦 PropertyApi.getPropertyById: Owner name: ${(data['owner'] as Map<String, dynamic>?)?['name']}');
          debugPrint('📦 PropertyApi.getPropertyById: Owner phone_number: ${(data['owner'] as Map<String, dynamic>?)?['phone_number']}');
        }
        
        // Debug unavailable dates
        debugPrint('📅 PropertyApi.getPropertyById: Checking for unavailable dates...');
        debugPrint('📅 PropertyApi.getPropertyById: unavailable_dates (root): ${data['unavailable_dates']}');
        debugPrint('📅 PropertyApi.getPropertyById: availability.unavailable_dates: ${(data['availability'] as Map<String, dynamic>?)?['unavailable_dates']}');
        if (data['unavailable_dates'] != null) {
          final dates = data['unavailable_dates'];
          if (dates is List) {
            debugPrint('📅 PropertyApi.getPropertyById: Found ${dates.length} unavailable dates');
            if (dates.isNotEmpty) {
              debugPrint('📅 PropertyApi.getPropertyById: First date: ${dates.first}');
              debugPrint('📅 PropertyApi.getPropertyById: Last date: ${dates.last}');
            }
          }
        }
      }
    }
    
    return PropertyDto.fromJson(response.data as Map<String, dynamic>);
  }

  Future<List<ReviewDto>> getPropertyReviews(String propertyId) async {
    final response = await _dioClient.get('/properties/$propertyId/reviews');
    final data = response.data;
    if (data is List) {
      return data
          .map((json) => ReviewDto.fromJson(json as Map<String, dynamic>))
          .toList();
    }
    return [];
  }

  /// Get all properties owned by the authenticated owner
  /// 
  /// Query parameters:
  /// - city: Filter by city
  /// - type: Filter by type (apartment, villa, chalet)
  /// - min_price: Minimum price
  /// - max_price: Maximum price
  /// - per_page: Results per page (max 50)
  Future<PropertyListResponseDto> getOwnerProperties({
    String? city,
    String? type,
    double? minPrice,
    double? maxPrice,
    int? perPage,
  }) async {
    final queryParams = <String, dynamic>{};
    if (city != null && city.isNotEmpty) queryParams['city'] = city;
    if (type != null && type.isNotEmpty) queryParams['type'] = type;
    if (minPrice != null) queryParams['min_price'] = minPrice;
    if (maxPrice != null) queryParams['max_price'] = maxPrice;
    if (perPage != null) queryParams['per_page'] = perPage;

    debugPrint('🌐 PropertyApi: GET /owner/properties with params: $queryParams');
    final response = await _dioClient.get(
      '/owner/properties',
      queryParameters: queryParams,
    );

    final jsonData = response.data as Map<String, dynamic>;
    return PropertyListResponseDto.fromJson(jsonData);
  }

  /// Get a specific property owned by the authenticated owner
  Future<PropertyDto> getOwnerPropertyById(String id) async {
    debugPrint('🌐 PropertyApi: GET /owner/properties/$id');
    final response = await _dioClient.get('/owner/properties/$id');
    return PropertyDto.fromJson(response.data as Map<String, dynamic>);
  }

  /// Create an EDIT proposal for a property owned by the authenticated owner
  /// 
  /// This creates a PENDING proposal that requires admin approval.
  /// All fields are optional (partial updates supported).
  /// 
  /// Request body fields (all optional):
  /// - title: Property title (max 200 chars)
  /// - description: Property description (max 5000 chars)
  /// - city: City name (max 80 chars)
  /// - type: Property type (apartment, villa, chalet)
  /// - price: Price per night (min 0)
  /// - location: Location object with latitude, longitude, map_url
  /// - amenities: Array of amenity strings (max 50 chars each)
  /// - photos: Array of photo URLs (max 20 photos, from /v1/upload)
  /// - unavailable_dates: Array of date strings
  Future<Map<String, dynamic>> createEditProposalForProperty({
    required String propertyId,
    String? title,
    String? description,
    String? city,
    String? type,
    double? price,
    Map<String, dynamic>? location,
    List<String>? amenities,
    List<String>? photos,
    List<String>? unavailableDates,
  }) async {
    debugPrint('🌐 PropertyApi: PUT /owner/properties/$propertyId (create edit proposal)');
    
    final payload = <String, dynamic>{};
    if (title != null) payload['title'] = title;
    if (description != null) payload['description'] = description;
    if (city != null) payload['city'] = city;
    if (type != null) payload['type'] = type;
    if (price != null) payload['price'] = price;
    if (location != null) payload['location'] = location;
    if (amenities != null) payload['amenities'] = amenities;
    if (photos != null) payload['photos'] = photos;
    if (unavailableDates != null) payload['unavailable_dates'] = unavailableDates;

    final response = await _dioClient.put(
      '/owner/properties/$propertyId',
      data: payload,
    );

    return response.data as Map<String, dynamic>;
  }
}

