import 'dart:convert';
import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:maawa_project/core/network/dio_client.dart';
import 'package:maawa_project/data/dto/booking_dto.dart';

class BookingApi {
  final DioClient _dioClient;

  BookingApi(this._dioClient);

  /// Get bookings for a specific property
  /// 
  /// Query parameters:
  /// - property_id: Filter bookings by property ID
  /// - status: Filter by booking status (ACCEPTED, CONFIRMED, etc.)
  Future<List<BookingDto>> getBookingsByPropertyId(
    String propertyId, {
    List<String>? statuses,
  }) async {
    if (kDebugMode) {
      final baseUrl = _dioClient.dio.options.baseUrl;
      debugPrint('📚 BookingApi.getBookingsByPropertyId: Calling $baseUrl/bookings for property $propertyId');
      debugPrint('📚 BookingApi.getBookingsByPropertyId: Looking for statuses: ${statuses ?? ['ACCEPTED', 'CONFIRMED']}');
    }

    try {
      // Try to fetch bookings with property_id filter if backend supports it
      final queryParams = <String, dynamic>{
        'property_id': propertyId, // Try property_id filter
      };
      
      if (statuses != null && statuses.isNotEmpty) {
        // Try to filter by status - backend might support comma-separated or we filter client-side
        queryParams['status'] = statuses.join(',');
      }

      if (kDebugMode) {
        debugPrint('📚 BookingApi.getBookingsByPropertyId: Query params: $queryParams');
      }

      final response = await _dioClient.get(
        '/bookings',
        queryParameters: queryParams,
      );
      
      if (kDebugMode) {
        debugPrint('📚 BookingApi.getBookingsByPropertyId: Response status: ${response.statusCode}');
        debugPrint('📚 BookingApi.getBookingsByPropertyId: Response data type: ${response.data.runtimeType}');
      }
      
      final data = response.data;
      List<BookingDto> allBookings = [];
      
      // Handle paginated response (Laravel format: {data: [], meta: {}})
      if (data is Map<String, dynamic> && data['data'] is List) {
        allBookings = (data['data'] as List)
            .map((json) => BookingDto.fromJson(json as Map<String, dynamic>))
            .toList();
        if (kDebugMode) {
          debugPrint('📚 BookingApi.getBookingsByPropertyId: Parsed ${allBookings.length} bookings from paginated response');
        }
      } else if (data is List) {
        allBookings = data
            .map((json) => BookingDto.fromJson(json as Map<String, dynamic>))
            .toList();
        if (kDebugMode) {
          debugPrint('📚 BookingApi.getBookingsByPropertyId: Parsed ${allBookings.length} bookings from list response');
        }
      } else {
        if (kDebugMode) {
          debugPrint('⚠️ BookingApi.getBookingsByPropertyId: Unexpected response format: ${data.runtimeType}');
        }
      }
      
      // Filter by property_id and status (in case backend doesn't filter by property_id)
      final filteredBookings = allBookings.where((booking) {
        if (kDebugMode && booking.propertyId == propertyId) {
          debugPrint('📚 BookingApi.getBookingsByPropertyId: Found booking ${booking.id} for property $propertyId with status ${booking.status}');
        }
        
        if (booking.propertyId != propertyId) return false;
        
        final bookingStatus = booking.status.toUpperCase();
        if (statuses != null && statuses.isNotEmpty) {
          return statuses.any((s) => s.toUpperCase() == bookingStatus);
        }
        // Default: only accepted and confirmed bookings make dates unavailable
        return bookingStatus == 'ACCEPTED' || bookingStatus == 'CONFIRMED';
      }).toList();
      
      if (kDebugMode) {
        debugPrint('📚 BookingApi.getBookingsByPropertyId: Total bookings fetched: ${allBookings.length}');
        debugPrint('📚 BookingApi.getBookingsByPropertyId: Filtered bookings for property $propertyId: ${filteredBookings.length}');
        if (filteredBookings.isNotEmpty) {
          for (final booking in filteredBookings) {
            debugPrint('📚   - Booking ${booking.id}: ${booking.checkIn} to ${booking.checkOut}, status: ${booking.status}');
          }
        } else {
          debugPrint('⚠️ BookingApi.getBookingsByPropertyId: No bookings found for property $propertyId');
          debugPrint('⚠️ NOTE: /bookings endpoint is role-based. Tenants only see their own bookings.');
          debugPrint('⚠️ Backend should include unavailable_dates in property detail response.');
        }
      }
      
      return filteredBookings;
    } catch (e) {
      if (kDebugMode) {
        debugPrint('❌ BookingApi.getBookingsByPropertyId: Error - $e');
        if (e is DioException) {
          debugPrint('❌ Status Code: ${e.response?.statusCode}');
          debugPrint('❌ Response Data: ${e.response?.data}');
        }
      }
      // Return empty list on error, don't block property loading
      return [];
    }
  }

  /// List bookings with role-based access (general endpoint)
  /// 
  /// Query parameters:
  /// - status: Filter by booking status (PENDING, ACCEPTED, CONFIRMED, etc.)
  /// - from: Filter bookings from date (YYYY-MM-DD)
  /// - to: Filter bookings to date (YYYY-MM-DD)
  /// - per_page: Results per page (max 50)
  Future<List<BookingDto>> getBookings({
    String? status,
    String? from,
    String? to,
    int? perPage,
  }) async {
    if (kDebugMode) {
      final baseUrl = _dioClient.dio.options.baseUrl;
      debugPrint('📚 BookingApi.getBookings: Calling $baseUrl/bookings');
    }

    try {
      final queryParams = <String, dynamic>{};
      if (status != null) queryParams['status'] = status;
      if (from != null) queryParams['from'] = from;
      if (to != null) queryParams['to'] = to;
      if (perPage != null) queryParams['per_page'] = perPage;

      final response = await _dioClient.get(
        '/bookings',
        queryParameters: queryParams.isNotEmpty ? queryParams : null,
      );
      
      debugPrint('✅ BookingApi.getBookings: Status ${response.statusCode}');
      debugPrint('📦 Response type: ${response.data.runtimeType}');
      
      final data = response.data;
      
      // Handle paginated response (Laravel format: {data: [], meta: {}})
      if (data is Map<String, dynamic> && data['data'] is List) {
        debugPrint('📋 Found ${(data['data'] as List).length} bookings');
        return (data['data'] as List)
            .map((json) => BookingDto.fromJson(json as Map<String, dynamic>))
            .toList();
      }
      
      // Handle direct list response
      if (data is List) {
        debugPrint('📋 Found ${data.length} bookings (direct list)');
        return data
            .map((json) => BookingDto.fromJson(json as Map<String, dynamic>))
            .toList();
      }
      
      debugPrint('⚠️ Unexpected response format');
      return [];
    } catch (e) {
      debugPrint('❌ BookingApi.getBookings: Error - $e');
      rethrow;
    }
  }

  /// Get all bookings for owner's properties
  /// 
  /// Query parameters:
  /// - status: Filter by booking status
  /// - from: Filter bookings from date (YYYY-MM-DD)
  /// - to: Filter bookings to date (YYYY-MM-DD)
  /// - per_page: Results per page (max 50)
  Future<List<BookingDto>> getOwnerBookings({
    String? status,
    String? from,
    String? to,
    int? perPage,
  }) async {
    if (kDebugMode) {
      final baseUrl = _dioClient.dio.options.baseUrl;
      debugPrint('📚 BookingApi.getOwnerBookings: Calling $baseUrl/owner/bookings');
    }

    try {
      final queryParams = <String, dynamic>{};
      if (status != null) queryParams['status'] = status;
      if (from != null) queryParams['from'] = from;
      if (to != null) queryParams['to'] = to;
      if (perPage != null) queryParams['per_page'] = perPage;

      final response = await _dioClient.get(
        '/owner/bookings',
        queryParameters: queryParams.isNotEmpty ? queryParams : null,
      );
      
      final data = response.data;
      
      if (data is Map<String, dynamic> && data['data'] is List) {
        return (data['data'] as List)
            .map((json) => BookingDto.fromJson(json as Map<String, dynamic>))
            .toList();
      }
      
      if (data is List) {
        return data
            .map((json) => BookingDto.fromJson(json as Map<String, dynamic>))
            .toList();
      }
      
      return [];
    } catch (e) {
      if (kDebugMode) {
        debugPrint('❌ BookingApi.getOwnerBookings: Error - $e');
      }
      rethrow;
    }
  }

  /// Get all bookings for tenant
  /// 
  /// Query parameters:
  /// - status: Filter by booking status
  /// - from: Filter bookings from date (YYYY-MM-DD)
  /// - to: Filter bookings to date (YYYY-MM-DD)
  /// - per_page: Results per page (max 50)
  Future<List<BookingDto>> getTenantBookings({
    String? status,
    String? from,
    String? to,
    int? perPage,
  }) async {
    if (kDebugMode) {
      final baseUrl = _dioClient.dio.options.baseUrl;
      debugPrint('📚 BookingApi.getTenantBookings: Calling $baseUrl/tenant/bookings');
    }

    try {
      final queryParams = <String, dynamic>{};
      if (status != null) queryParams['status'] = status;
      if (from != null) queryParams['from'] = from;
      if (to != null) queryParams['to'] = to;
      if (perPage != null) queryParams['per_page'] = perPage;

      final response = await _dioClient.get(
        '/tenant/bookings',
        queryParameters: queryParams.isNotEmpty ? queryParams : null,
      );
      
      final data = response.data;
      
      if (data is Map<String, dynamic> && data['data'] is List) {
        return (data['data'] as List)
            .map((json) => BookingDto.fromJson(json as Map<String, dynamic>))
            .toList();
      }
      
      if (data is List) {
        return data
            .map((json) => BookingDto.fromJson(json as Map<String, dynamic>))
            .toList();
      }
      
      return [];
    } catch (e) {
      if (kDebugMode) {
        debugPrint('❌ BookingApi.getTenantBookings: Error - $e');
      }
      rethrow;
    }
  }

  Future<BookingDto> createBooking({
    required String propertyId,
    required DateTime checkIn,
    required DateTime checkOut,
    int? guests,
  }) async {
    if (kDebugMode) {
      debugPrint('📤 BookingApi.createBooking: Creating booking');
      debugPrint('📤   Property ID: $propertyId');
      debugPrint('📤   Check-in: $checkIn');
      debugPrint('📤   Check-out: $checkOut');
      debugPrint('📤   Guests: $guests');
    }

    try {
      final response = await _dioClient.post(
        '/bookings',
        data: CreateBookingRequestDto(
          propertyId: propertyId,
          checkIn: checkIn.toIso8601String(),
          checkOut: checkOut.toIso8601String(),
          guests: guests,
        ).toJson(),
      );

      if (kDebugMode) {
        debugPrint('✅ BookingApi.createBooking: Response status: ${response.statusCode}');
        debugPrint('📦 Response data type: ${response.data.runtimeType}');
        debugPrint('📦 Response data: ${response.data}');
      }

      // If status is 200/201/204, the operation succeeded even if response is empty
      final isSuccess = response.statusCode != null && 
                       (response.statusCode! >= 200 && response.statusCode! < 300);

      // Handle different response formats
      Map<String, dynamic>? bookingData;
      
      if (response.data == null) {
        if (kDebugMode) {
          debugPrint('⚠️ BookingApi.createBooking: Response data is null');
        }
        // If status is success, the booking was created but response is empty
        if (isSuccess) {
          throw Exception('Response parsing failed but backend returned success. Booking was created.');
        } else {
          throw Exception('Unexpected response format: null');
        }
      } else if (response.data is Map<String, dynamic>) {
        final data = response.data as Map<String, dynamic>;
        // Check if response is wrapped in 'data' key
        if (data.containsKey('data') && data['data'] is Map<String, dynamic>) {
          bookingData = data['data'] as Map<String, dynamic>;
          if (kDebugMode) {
            debugPrint('📦 BookingApi.createBooking: Response wrapped in data key');
          }
        } else {
          bookingData = data;
        }
      } else if (response.data is String) {
        final dataStr = response.data as String;
        if (dataStr.isEmpty) {
          if (kDebugMode) {
            debugPrint('⚠️ BookingApi.createBooking: Empty string response');
          }
          // If status is success, the booking was created
          if (isSuccess) {
            throw Exception('Response parsing failed but backend returned success. Booking was created.');
          } else {
            throw Exception('Unexpected response format: empty string');
          }
        } else {
          // Try to parse as JSON string
          try {
            bookingData = jsonDecode(dataStr) as Map<String, dynamic>?;
            if (bookingData != null && bookingData.containsKey('data')) {
              bookingData = bookingData['data'] as Map<String, dynamic>?;
            }
          } catch (e) {
            if (kDebugMode) {
              debugPrint('⚠️ BookingApi.createBooking: Failed to parse string response: $e');
            }
            // If status is success, the booking was created
            if (isSuccess) {
              throw Exception('Response parsing failed but backend returned success. Booking was created.');
            } else {
              rethrow;
            }
          }
        }
      } else {
        if (kDebugMode) {
          debugPrint('⚠️ BookingApi.createBooking: Unexpected response format: ${response.data.runtimeType}');
        }
        // If status is success, the booking was created
        if (isSuccess) {
          throw Exception('Response parsing failed but backend returned success. Booking was created.');
        } else {
          throw Exception('Unexpected response format: ${response.data.runtimeType}');
        }
      }
      
      // If we have booking data, parse it
      if (bookingData != null) {
        if (kDebugMode) {
          debugPrint('📦 BookingApi.createBooking: Parsing booking data with keys: ${bookingData.keys.toList()}');
        }
        
        try {
          final bookingDto = BookingDto.fromJson(bookingData);
          if (kDebugMode) {
            debugPrint('✅ BookingApi.createBooking: Successfully parsed booking with ID: ${bookingDto.id}');
            debugPrint('✅ BookingApi.createBooking: Booking status: ${bookingDto.status}');
          }
          return bookingDto;
        } catch (parseError) {
          if (kDebugMode) {
            debugPrint('⚠️ BookingApi.createBooking: Failed to parse booking data: $parseError');
          }
          // If status is success, the booking was created
          if (isSuccess) {
            throw Exception('Response parsing failed but backend returned success. Booking was created.');
          } else {
            rethrow;
          }
        }
      } else {
        // No booking data, but if status is success, the booking was created
        if (isSuccess) {
          throw Exception('Response parsing failed but backend returned success. Booking was created.');
        } else {
          throw Exception('Unexpected response format: no booking data');
        }
      }
    } catch (e, stackTrace) {
      if (kDebugMode) {
        debugPrint('❌ BookingApi.createBooking: Error creating booking');
        debugPrint('❌   Error: $e');
        debugPrint('❌   Stack trace: $stackTrace');
      }
      rethrow;
    }
  }

  Future<BookingDto> getBookingById(String id) async {
    if (kDebugMode) {
      final baseUrl = _dioClient.dio.options.baseUrl;
      debugPrint('📚 BookingApi.getBookingById: Calling $baseUrl/bookings/$id');
    }

    try {
      final response = await _dioClient.get('/bookings/$id');
      
      if (kDebugMode) {
        debugPrint('✅ BookingApi.getBookingById: Status ${response.statusCode}');
        debugPrint('📦 Response data: ${response.data}');
      }
      
      // Handle both direct object and wrapped in 'data' key
      final data = response.data;
      final bookingData = data is Map<String, dynamic> && data.containsKey('data')
          ? data['data'] as Map<String, dynamic>
          : data as Map<String, dynamic>;
      
      return BookingDto.fromJson(bookingData);
    } catch (e) {
      if (kDebugMode) {
        debugPrint('❌ BookingApi.getBookingById: Error - $e');
      }
      rethrow;
    }
  }


  Future<BookingDto> ownerDecision({
    required String bookingId,
    required String decision,
    String? reason,
  }) async {
    if (kDebugMode) {
      final baseUrl = _dioClient.dio.options.baseUrl;
      debugPrint('📤 BookingApi.ownerDecision: Calling $baseUrl/owner/bookings/$bookingId/decision');
      debugPrint('📝 Decision: $decision');
      debugPrint('📝 Reason: ${reason ?? "none"}');
      debugPrint('📝 Payload: ${OwnerDecisionRequestDto(decision: decision, reason: reason).toJson()}');
    }

    try {
      final response = await _dioClient.post(
        '/owner/bookings/$bookingId/decision',
        data: OwnerDecisionRequestDto(
          decision: decision,
          reason: reason,
        ).toJson(),
      );

      if (kDebugMode) {
        debugPrint('✅ BookingApi.ownerDecision: Success - Status ${response.statusCode}');
        debugPrint('📦 Response data type: ${response.data.runtimeType}');
        debugPrint('📦 Response data: ${response.data}');
      }

      // If status is 200/201/204, the operation succeeded even if response is empty
      final isSuccess = response.statusCode != null && 
                       (response.statusCode! >= 200 && response.statusCode! < 300);

      // Handle different response formats
      Map<String, dynamic>? bookingData;
      
      if (response.data == null) {
        if (kDebugMode) {
          debugPrint('⚠️ BookingApi.ownerDecision: Response data is null');
        }
        // If status is success, fetch the updated booking
        if (isSuccess) {
          if (kDebugMode) {
            debugPrint('📤 BookingApi.ownerDecision: Fetching updated booking as fallback');
          }
          try {
            final updatedBooking = await getBookingById(bookingId);
            if (kDebugMode) {
              debugPrint('✅ BookingApi.ownerDecision: Fetched updated booking with status: ${updatedBooking.status}');
            }
            return updatedBooking;
          } catch (fetchError) {
            if (kDebugMode) {
              debugPrint('⚠️ BookingApi.ownerDecision: Failed to fetch updated booking: $fetchError');
              debugPrint('⚠️   But status code indicates success, so operation likely succeeded');
            }
            // Even if fetch fails, if status is 200, assume success
            // Return a minimal DTO with the booking ID and expected status
            throw Exception('Response parsing failed but backend returned success. Booking status was updated.');
          }
        }
      } else if (response.data is Map<String, dynamic>) {
        final data = response.data as Map<String, dynamic>;
        // Check if response is wrapped in 'data' key
        if (data.containsKey('data') && data['data'] is Map<String, dynamic>) {
          bookingData = data['data'] as Map<String, dynamic>;
          if (kDebugMode) {
            debugPrint('📦 BookingApi.ownerDecision: Response wrapped in data key');
          }
        } else {
          bookingData = data;
        }
      } else if (response.data is String) {
        final dataStr = response.data as String;
        if (dataStr.isEmpty) {
          if (kDebugMode) {
            debugPrint('⚠️ BookingApi.ownerDecision: Empty string response');
          }
          // If status is success, fetch the updated booking
          if (isSuccess) {
            try {
              final updatedBooking = await getBookingById(bookingId);
              if (kDebugMode) {
                debugPrint('✅ BookingApi.ownerDecision: Fetched updated booking with status: ${updatedBooking.status}');
              }
              return updatedBooking;
            } catch (fetchError) {
              if (kDebugMode) {
                debugPrint('⚠️ BookingApi.ownerDecision: Failed to fetch updated booking: $fetchError');
              }
              throw Exception('Response parsing failed but backend returned success. Booking status was updated.');
            }
          }
        } else {
          // Try to parse as JSON string
          try {
            bookingData = jsonDecode(dataStr) as Map<String, dynamic>?;
            if (bookingData != null && bookingData.containsKey('data')) {
              bookingData = bookingData['data'] as Map<String, dynamic>?;
            }
          } catch (e) {
            if (kDebugMode) {
              debugPrint('⚠️ BookingApi.ownerDecision: Failed to parse string response: $e');
            }
            // If status is success, fetch the updated booking
            if (isSuccess) {
              try {
                final updatedBooking = await getBookingById(bookingId);
                if (kDebugMode) {
                  debugPrint('✅ BookingApi.ownerDecision: Fetched updated booking with status: ${updatedBooking.status}');
                }
                return updatedBooking;
              } catch (fetchError) {
                if (kDebugMode) {
                  debugPrint('⚠️ BookingApi.ownerDecision: Failed to fetch updated booking: $fetchError');
                }
                throw Exception('Response parsing failed but backend returned success. Booking status was updated.');
              }
            }
          }
        }
      }
      
      // If we have booking data, parse it
      if (bookingData != null) {
        if (kDebugMode) {
          debugPrint('📦 BookingApi.ownerDecision: Parsing booking data with keys: ${bookingData.keys.toList()}');
        }
        
        try {
          final bookingDto = BookingDto.fromJson(bookingData);
          if (kDebugMode) {
            debugPrint('✅ BookingApi.ownerDecision: Successfully parsed booking with ID: ${bookingDto.id}');
            debugPrint('✅ BookingApi.ownerDecision: Booking status: ${bookingDto.status}');
          }
          return bookingDto;
        } catch (parseError) {
          if (kDebugMode) {
            debugPrint('⚠️ BookingApi.ownerDecision: Failed to parse booking data: $parseError');
            debugPrint('⚠️   Attempting to fetch updated booking as fallback');
          }
          // If parsing fails but status is success, fetch the updated booking
          if (isSuccess) {
            try {
              final updatedBooking = await getBookingById(bookingId);
              if (kDebugMode) {
                debugPrint('✅ BookingApi.ownerDecision: Fetched updated booking with status: ${updatedBooking.status}');
              }
              return updatedBooking;
            } catch (fetchError) {
              if (kDebugMode) {
                debugPrint('⚠️ BookingApi.ownerDecision: Failed to fetch updated booking: $fetchError');
              }
              throw Exception('Response parsing failed but backend returned success. Booking status was updated.');
            }
          } else {
            rethrow;
          }
        }
      } else {
        // No booking data, but if status is success, fetch the updated booking
        if (isSuccess) {
          if (kDebugMode) {
            debugPrint('⚠️ BookingApi.ownerDecision: No booking data in response, fetching updated booking');
          }
          try {
            final updatedBooking = await getBookingById(bookingId);
            if (kDebugMode) {
              debugPrint('✅ BookingApi.ownerDecision: Fetched updated booking with status: ${updatedBooking.status}');
            }
            return updatedBooking;
          } catch (fetchError) {
            if (kDebugMode) {
              debugPrint('⚠️ BookingApi.ownerDecision: Failed to fetch updated booking: $fetchError');
            }
            throw Exception('Response parsing failed but backend returned success. Booking status was updated.');
          }
        } else {
          throw Exception('Unexpected response format: ${response.data.runtimeType}');
        }
      }
    } catch (e, stackTrace) {
      if (kDebugMode) {
        debugPrint('❌ BookingApi.ownerDecision: Error making decision');
        debugPrint('❌   Error: $e');
        debugPrint('❌   Stack trace: $stackTrace');
        if (e is DioException) {
          debugPrint('❌   Status Code: ${e.response?.statusCode}');
          debugPrint('❌   Response Data: ${e.response?.data}');
          debugPrint('❌   Request URL: ${e.requestOptions.uri}');
        }
      }
      rethrow;
    }
  }

  /// Get owner bookings by status (pending, accepted, confirmed, rejected, canceled, expired, completed, failed)
  /// 
  /// Query parameters:
  /// - from: Filter bookings from date (YYYY-MM-DD)
  /// - to: Filter bookings to date (YYYY-MM-DD)
  /// - per_page: Results per page (max 50)
  Future<List<BookingDto>> getOwnerBookingsByStatus(
    String status, {
    String? from,
    String? to,
    int? perPage,
  }) async {
    if (kDebugMode) {
      final baseUrl = _dioClient.dio.options.baseUrl;
      debugPrint('📚 BookingApi.getOwnerBookingsByStatus: Calling $baseUrl/owner/bookings/$status');
    }

    try {
      final queryParams = <String, dynamic>{};
      if (from != null) queryParams['from'] = from;
      if (to != null) queryParams['to'] = to;
      if (perPage != null) queryParams['per_page'] = perPage;

      final response = await _dioClient.get(
        '/owner/bookings/$status',
        queryParameters: queryParams.isNotEmpty ? queryParams : null,
      );
      
      if (kDebugMode) {
        debugPrint('✅ BookingApi.getOwnerBookingsByStatus: Status ${response.statusCode}');
      }
      
      final data = response.data;
      
      if (data is Map<String, dynamic> && data['data'] is List) {
        return (data['data'] as List)
            .map((json) => BookingDto.fromJson(json as Map<String, dynamic>))
            .toList();
      }
      
      if (data is List) {
        return data
            .map((json) => BookingDto.fromJson(json as Map<String, dynamic>))
            .toList();
      }
      
      return [];
    } catch (e) {
      if (kDebugMode) {
        debugPrint('❌ BookingApi.getOwnerBookingsByStatus: Error - $e');
      }
      rethrow;
    }
  }

  /// Get tenant bookings by status (pending, accepted, confirmed, rejected, canceled, expired, completed, failed)
  /// 
  /// Query parameters:
  /// - from: Filter bookings from date (YYYY-MM-DD)
  /// - to: Filter bookings to date (YYYY-MM-DD)
  /// - per_page: Results per page (max 50)
  Future<List<BookingDto>> getTenantBookingsByStatus(
    String status, {
    String? from,
    String? to,
    int? perPage,
  }) async {
    if (kDebugMode) {
      final baseUrl = _dioClient.dio.options.baseUrl;
      debugPrint('📚 BookingApi.getTenantBookingsByStatus: Calling $baseUrl/tenant/bookings/$status');
    }

    try {
      final queryParams = <String, dynamic>{};
      if (from != null) queryParams['from'] = from;
      if (to != null) queryParams['to'] = to;
      if (perPage != null) queryParams['per_page'] = perPage;

      final response = await _dioClient.get(
        '/tenant/bookings/$status',
        queryParameters: queryParams.isNotEmpty ? queryParams : null,
      );
      
      if (kDebugMode) {
        debugPrint('✅ BookingApi.getTenantBookingsByStatus: Status ${response.statusCode}');
      }
      
      final data = response.data;
      
      if (data is Map<String, dynamic> && data['data'] is List) {
        return (data['data'] as List)
            .map((json) => BookingDto.fromJson(json as Map<String, dynamic>))
            .toList();
      }
      
      if (data is List) {
        return data
            .map((json) => BookingDto.fromJson(json as Map<String, dynamic>))
            .toList();
      }
      
      return [];
    } catch (e) {
      if (kDebugMode) {
        debugPrint('❌ BookingApi.getTenantBookingsByStatus: Error - $e');
      }
      rethrow;
    }
  }
}

