import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:maawa_project/core/network/dio_client.dart';
import 'package:maawa_project/data/dto/proposal_dto.dart';
import 'package:maawa_project/domain/entities/proposal.dart';

class ProposalApi {
  final DioClient _dioClient;

  ProposalApi(this._dioClient);

  Future<List<ProposalDto>> getOwnerProposals() async {
    if (kDebugMode) {
      final baseUrl = _dioClient.dio.options.baseUrl;
      debugPrint('📋 ProposalApi.getOwnerProposals: Calling $baseUrl/owner/proposals');
    }

    try {
      final response = await _dioClient.get('/owner/proposals');
      final responseData = response.data;
      
      // Handle both direct array and wrapped in 'data' key
      List<dynamic> proposalsList;
      if (responseData is Map<String, dynamic> && responseData.containsKey('data')) {
        proposalsList = responseData['data'] as List<dynamic>;
        if (kDebugMode) {
          debugPrint('📦 Response wrapped in "data" key, found ${proposalsList.length} proposals');
        }
      } else if (responseData is List) {
        proposalsList = responseData;
        if (kDebugMode) {
          debugPrint('📦 Response is direct array, found ${proposalsList.length} proposals');
        }
      } else {
        if (kDebugMode) {
          debugPrint('⚠️ ProposalApi.getOwnerProposals: Unexpected response format: ${responseData.runtimeType}');
          debugPrint('⚠️ Response data: $responseData');
        }
        return [];
      }
      
      if (kDebugMode) {
        debugPrint('✅ ProposalApi.getOwnerProposals: Found ${proposalsList.length} proposals');
      }
      
      return proposalsList
          .map((json) => ProposalDto.fromJson(json as Map<String, dynamic>))
          .toList();
    } catch (e, stackTrace) {
      if (kDebugMode) {
        debugPrint('❌ ProposalApi.getOwnerProposals: Error - $e');
        debugPrint('❌ Stack trace: $stackTrace');
      }
      rethrow;
    }
  }

  Future<ProposalDto> createProposal(CreateProposalRequestDto request) async {
    if (kDebugMode) {
      final baseUrl = _dioClient.dio.options.baseUrl;
      debugPrint('📝 ProposalApi.createProposal: Calling $baseUrl/proposals');
      debugPrint('📦 Type: ${request.type}');
      debugPrint('📦 Payload: ${request.toJson()}');
    }

    try {
      final response = await _dioClient.post(
        '/proposals',
        data: request.toJson(),
      );

      if (kDebugMode) {
        debugPrint('✅ ProposalApi.createProposal: Proposal created successfully');
        debugPrint('📦 Response: ${response.data}');
      }
      
      // Handle both direct object and wrapped in 'data' key
      final data = response.data;
      final proposalData = data is Map<String, dynamic> && data.containsKey('data')
          ? data['data'] as Map<String, dynamic>
          : data as Map<String, dynamic>;
      
      if (kDebugMode) {
        debugPrint('📦 Parsing proposal response: $proposalData');
      }
      
      try {
        return ProposalDto.fromJson(proposalData);
      } catch (e, stackTrace) {
        if (kDebugMode) {
          debugPrint('❌ Error parsing ProposalDto: $e');
          debugPrint('❌ Stack trace: $stackTrace');
          debugPrint('❌ Response data: $proposalData');
        }
        rethrow;
      }
    } catch (e) {
      if (kDebugMode) {
        debugPrint('❌ ProposalApi.createProposal: Error - $e');
        if (e is DioException) {
          debugPrint('❌ Status Code: ${e.response?.statusCode}');
          debugPrint('❌ Response Data: ${e.response?.data}');
          debugPrint('❌ Request Headers: ${e.requestOptions.headers}');
        }
      }
      rethrow;
    }
  }

  Future<ProposalDto> getProposalById(String id) async {
    if (kDebugMode) {
      final baseUrl = _dioClient.dio.options.baseUrl;
      debugPrint('🔍 ProposalApi.getProposalById: Calling $baseUrl/owner/proposals/$id');
    }

    try {
      // Use owner endpoint for GET (backend now supports GET /v1/owner/proposals/{id})
      final response = await _dioClient.get('/owner/proposals/$id');
      debugPrint('✅ ProposalApi.getProposalById: Proposal retrieved successfully');
      
      // Handle both direct object and wrapped in 'data' key
      final data = response.data;
      final proposalData = data is Map<String, dynamic> && data.containsKey('data')
          ? data['data'] as Map<String, dynamic>
          : data as Map<String, dynamic>;
      
      return ProposalDto.fromJson(proposalData);
    } catch (e) {
      if (kDebugMode) {
        debugPrint('❌ ProposalApi.getProposalById: Error - $e');
        if (e is DioException) {
          debugPrint('❌ Status Code: ${e.response?.statusCode}');
          debugPrint('❌ Response Data: ${e.response?.data}');
        }
      }
      rethrow;
    }
  }

  Future<ProposalDto> updateProposal({
    required String id,
    required ProposalType type,
    ProposalDataDto? payload,
    String? propertyId,
    int? version,
    String? reason,
  }) async {
    if (kDebugMode) {
      final baseUrl = _dioClient.dio.options.baseUrl;
      debugPrint('✏️ ProposalApi.updateProposal: Calling $baseUrl/owner/proposals/$id');
      debugPrint('📦 Type: ${type.name}');
      debugPrint('📦 Property ID: $propertyId');
      debugPrint('📦 Version: $version');
      debugPrint('📦 Reason: $reason');
    }

    try {
      // Build request body based on proposal type
      final Map<String, dynamic> body = {};
      
      if (type == ProposalType.delete) {
        // For DELETE proposals, send property_id and reason
        if (propertyId != null) body['property_id'] = propertyId;
        if (reason != null) body['reason'] = reason;
      } else {
        // For ADD and EDIT proposals, send payload
        if (payload != null) {
          body['payload'] = payload.toJson();
        }
        // For EDIT proposals, also send property_id and version if provided
        if (type == ProposalType.edit) {
          if (propertyId != null) body['property_id'] = propertyId;
          if (version != null) body['version'] = version;
        }
      }

      if (kDebugMode) {
        debugPrint('📦 Request body: $body');
      }

      final response = await _dioClient.put(
        '/owner/proposals/$id',
        data: body,
      );

      if (kDebugMode) {
        debugPrint('✅ ProposalApi.updateProposal: Proposal updated successfully');
        debugPrint('📦 Response: ${response.data}');
      }
      
      // Backend returns: { "id": "...", "status": "PENDING", "message": "..." }
      // We need to fetch the updated proposal to get full details
      // For now, return a minimal ProposalDto with the response data
      final responseData = response.data as Map<String, dynamic>;
      
      // Try to parse as ProposalDto if it has all required fields
      // Otherwise, fetch the full proposal
      try {
        return ProposalDto.fromJson(responseData);
      } catch (e) {
        // If response doesn't have full proposal data, fetch it
        if (kDebugMode) {
          debugPrint('⚠️ Response doesn\'t contain full proposal data, fetching...');
        }
        return await getProposalById(id);
      }
    } catch (e) {
      if (kDebugMode) {
        debugPrint('❌ ProposalApi.updateProposal: Error - $e');
        if (e is DioException) {
          debugPrint('❌ Status Code: ${e.response?.statusCode}');
          debugPrint('❌ Response Data: ${e.response?.data}');
        }
      }
      rethrow;
    }
  }

  Future<void> deleteProposal(String id) async {
    if (kDebugMode) {
      final baseUrl = _dioClient.dio.options.baseUrl;
      debugPrint('🗑️ ProposalApi.deleteProposal: Calling $baseUrl/owner/proposals/$id');
    }

    try {
      final response = await _dioClient.delete('/owner/proposals/$id');
      if (kDebugMode) {
        debugPrint('✅ ProposalApi.deleteProposal: Proposal deleted successfully');
        debugPrint('📦 Response: ${response.data}');
      }
    } catch (e) {
      if (kDebugMode) {
        debugPrint('❌ ProposalApi.deleteProposal: Error - $e');
        if (e is DioException) {
          debugPrint('❌ Status Code: ${e.response?.statusCode}');
          debugPrint('❌ Response Data: ${e.response?.data}');
        }
      }
      rethrow;
    }
  }
}

