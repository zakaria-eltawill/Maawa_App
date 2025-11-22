import 'package:equatable/equatable.dart';

enum ProposalType {
  add,
  edit,
  delete;

  static ProposalType fromString(String type) {
    switch (type.toUpperCase()) {
      case 'ADD':
        return ProposalType.add;
      case 'EDIT':
        return ProposalType.edit;
      case 'DELETE':
        return ProposalType.delete;
      default:
        return ProposalType.add;
    }
  }
}

enum ProposalStatus {
  pending,
  approved,
  rejected,
  resubmitted;

  static ProposalStatus fromString(String status) {
    switch (status.toLowerCase()) {
      case 'pending':
        return ProposalStatus.pending;
      case 'approved':
        return ProposalStatus.approved;
      case 'rejected':
        return ProposalStatus.rejected;
      case 'resubmitted':
        return ProposalStatus.resubmitted;
      default:
        return ProposalStatus.pending;
    }
  }
}

class Proposal extends Equatable {
  final String id;
  final ProposalType type;
  final ProposalStatus status;
  final String? propertyId; // null for ADD, present for EDIT/DELETE
  final String ownerId;
  final ProposalData? data; // Property data for ADD/EDIT
  final String? adminNotes;
  final DateTime createdAt;
  final DateTime? updatedAt;

  const Proposal({
    required this.id,
    required this.type,
    required this.status,
    this.propertyId,
    required this.ownerId,
    this.data,
    this.adminNotes,
    required this.createdAt,
    this.updatedAt,
  });

  @override
  List<Object?> get props => [
        id,
        type,
        status,
        propertyId,
        ownerId,
        data,
        adminNotes,
        createdAt,
        updatedAt,
      ];
}

class ProposalData extends Equatable {
  final String? name;
  final String? description;
  final String? city;
  final String? address;
  final double? latitude;
  final double? longitude;
  final String? propertyType;
  final double? pricePerNight;
  final List<String>? amenities;
  final List<String>? photos;

  const ProposalData({
    this.name,
    this.description,
    this.city,
    this.address,
    this.latitude,
    this.longitude,
    this.propertyType,
    this.pricePerNight,
    this.amenities,
    this.photos,
  });

  @override
  List<Object?> get props => [
        name,
        description,
        city,
        address,
        latitude,
        longitude,
        propertyType,
        pricePerNight,
        amenities,
        photos,
      ];
}

