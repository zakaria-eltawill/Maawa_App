import 'package:maawa_project/core/error/error_handler.dart';
import 'package:maawa_project/data/datasources/remote/proposal_api.dart';
import 'package:maawa_project/data/dto/proposal_dto.dart';
import 'package:maawa_project/domain/entities/proposal.dart';
import 'package:maawa_project/domain/repositories/proposal_repository.dart';

class ProposalRepositoryImpl implements ProposalRepository {
  final ProposalApi _proposalApi;

  ProposalRepositoryImpl(this._proposalApi);

  @override
  Future<List<Proposal>> getOwnerProposals() async {
    try {
      final dtos = await _proposalApi.getOwnerProposals();
      return dtos.map((dto) => dto.toDomain()).toList();
    } catch (e) {
      throw ErrorHandler.handleError(e);
    }
  }

  @override
  Future<Proposal> createProposal(Proposal proposal) async {
    try {
      ProposalDataDto? payloadData;
      
      if (proposal.data != null) {
        // Create location DTO with both URL and coordinates (backend requires lat/long)
        ProposalLocationDto? locationDto;
        final address = proposal.data!.address;
        
        // Backend requires latitude and longitude, so prioritize those
        if (proposal.data!.latitude != null && proposal.data!.longitude != null) {
          locationDto = ProposalLocationDto(
            url: address, // Include URL if available
            latitude: proposal.data!.latitude,
            longitude: proposal.data!.longitude,
          );
        } else if (address != null && address.isNotEmpty) {
          // If no lat/long but we have a URL, try to extract (shouldn't happen if extraction worked)
          final uri = Uri.tryParse(address);
          if (uri != null && uri.hasScheme) {
            // URL only - backend will reject, but include it anyway
            locationDto = ProposalLocationDto(url: address);
          }
        }
        
        payloadData = ProposalDataDto(
          title: proposal.data!.name,
          name: proposal.data!.name, // Keep for backward compatibility
          description: proposal.data!.description,
          city: proposal.data!.city,
          address: address,
          type: proposal.data!.propertyType,
          propertyType: proposal.data!.propertyType, // Keep for backward compatibility
          price: proposal.data!.pricePerNight,
          pricePerNight: proposal.data!.pricePerNight, // Keep for backward compatibility
          location: locationDto,
          latitude: proposal.data!.latitude,
          longitude: proposal.data!.longitude,
          amenities: proposal.data!.amenities,
          // Photos will be handled separately if needed
        );
      }

      final request = CreateProposalRequestDto(
        type: proposal.type.name.toUpperCase(),
        propertyId: proposal.propertyId,
        payload: payloadData, // Use payload for backend compatibility
      );

      final dto = await _proposalApi.createProposal(request);
      return dto.toDomain();
    } catch (e) {
      throw ErrorHandler.handleError(e);
    }
  }

  @override
  Future<Proposal> getProposalById(String id) async {
    try {
      final dto = await _proposalApi.getProposalById(id);
      return dto.toDomain();
    } catch (e) {
      throw ErrorHandler.handleError(e);
    }
  }

  @override
  Future<Proposal> updateProposal(String id, Proposal proposal) async {
    try {
      ProposalDataDto? payloadData;
      
      // Only include payload for ADD and EDIT proposals
      if (proposal.type != ProposalType.delete && proposal.data != null) {
        ProposalLocationDto? locationDto;
        final address = proposal.data!.address;
        
        if (proposal.data!.latitude != null && proposal.data!.longitude != null) {
          locationDto = ProposalLocationDto(
            latitude: proposal.data!.latitude,
            longitude: proposal.data!.longitude,
            mapUrl: address, // Use address as map_url
            url: address, // Keep for backward compatibility
          );
        } else if (address != null && address.isNotEmpty) {
          final uri = Uri.tryParse(address);
          if (uri != null && uri.hasScheme) {
            locationDto = ProposalLocationDto(
              mapUrl: address,
              url: address,
            );
          }
        }
        
        payloadData = ProposalDataDto(
          title: proposal.data!.name,
          name: proposal.data!.name,
          description: proposal.data!.description,
          city: proposal.data!.city,
          address: address,
          type: proposal.data!.propertyType,
          propertyType: proposal.data!.propertyType,
          price: proposal.data!.pricePerNight,
          pricePerNight: proposal.data!.pricePerNight,
          location: locationDto,
          latitude: proposal.data!.latitude,
          longitude: proposal.data!.longitude,
          amenities: proposal.data!.amenities,
          photos: proposal.data!.photos,
        );
      }

      // For DELETE proposals, we need to get the reason from adminNotes or a separate field
      // Since Proposal entity doesn't have a reason field, we'll use adminNotes as reason
      String? reason;
      if (proposal.type == ProposalType.delete) {
        reason = proposal.adminNotes;
      }

      final dto = await _proposalApi.updateProposal(
        id: id,
        type: proposal.type,
        payload: payloadData,
        propertyId: proposal.propertyId,
        version: null, // Version can be added later if needed
        reason: reason,
      );
      return dto.toDomain();
    } catch (e) {
      throw ErrorHandler.handleError(e);
    }
  }

  @override
  Future<void> deleteProposal(String id) async {
    try {
      await _proposalApi.deleteProposal(id);
    } catch (e) {
      throw ErrorHandler.handleError(e);
    }
  }
}

