import 'package:equatable/equatable.dart';

enum UserRole {
  tenant,
  owner,
  admin;

  static UserRole fromString(String role) {
    switch (role.toLowerCase()) {
      case 'tenant':
        return UserRole.tenant;
      case 'owner':
        return UserRole.owner;
      case 'admin':
        return UserRole.admin;
      default:
        return UserRole.tenant;
    }
  }
}

class User extends Equatable {
  final String id;
  final String email;
  final String? name;
  final UserRole role;
  final String? phoneNumber;
  final String? region;

  const User({
    required this.id,
    required this.email,
    this.name,
    required this.role,
    this.phoneNumber,
    this.region,
  });

  @override
  List<Object?> get props => [id, email, name, role, phoneNumber, region];
}

