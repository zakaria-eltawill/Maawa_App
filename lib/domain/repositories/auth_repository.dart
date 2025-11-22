import 'package:maawa_project/domain/entities/user.dart';

abstract class AuthRepository {
  Future<User> login(String email, String password);
  Future<User> register({
    required String name,
    required String email,
    required String password,
    required String passwordConfirmation,
    required String role,
    required String phoneNumber,
    required String region,
  });
  Future<void> logout();
  Future<User> getCurrentUser();
  Future<void> refreshToken();
  Future<User> updateProfile({
    String? name,
    String? phoneNumber,
    String? region,
  });
  Future<void> changePassword({
    required String currentPassword,
    required String newPassword,
    required String passwordConfirmation,
  });
}

