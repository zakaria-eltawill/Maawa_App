import 'package:maawa_project/core/error/error_handler.dart';
import 'package:maawa_project/core/error/failures.dart';
import 'package:maawa_project/core/storage/secure_storage.dart';
import 'package:maawa_project/data/datasources/remote/auth_api.dart';
import 'package:maawa_project/domain/entities/user.dart';
import 'package:maawa_project/domain/repositories/auth_repository.dart';

class AuthRepositoryImpl implements AuthRepository {
  final AuthApi _authApi;
  final SecureStorage _secureStorage;

  AuthRepositoryImpl(this._authApi, this._secureStorage);

  @override
  Future<User> login(String email, String password) async {
    try {
      final response = await _authApi.login(email, password);
      final user = response.toDomain();

      // Store tokens
      await _secureStorage.setAccessToken(response.access_token);
      if (response.refresh_token != null) {
        await _secureStorage.setRefreshToken(response.refresh_token!);
      }
      await _secureStorage.setTokenExpiresIn(response.expires_in.toString());
      await _secureStorage.setUserRole(user.role.name);
      await _secureStorage.setUserId(user.id);

      return user;
    } catch (e) {
      throw ErrorHandler.handleError(e);
    }
  }

  @override
  Future<User> register({
    required String name,
    required String email,
    required String password,
    required String passwordConfirmation,
    required String role,
    required String phoneNumber,
    required String region,
  }) async {
    try {
      final response = await _authApi.register(
        name: name,
        email: email,
        password: password,
        passwordConfirmation: passwordConfirmation,
        role: role,
        phoneNumber: phoneNumber,
        region: region,
      );
      final user = response.toDomain();

      // Store tokens
      await _secureStorage.setAccessToken(response.access_token);
      if (response.refresh_token != null) {
        await _secureStorage.setRefreshToken(response.refresh_token!);
      }
      await _secureStorage.setTokenExpiresIn(response.expires_in.toString());
      await _secureStorage.setUserRole(user.role.name);
      await _secureStorage.setUserId(user.id);

      return user;
    } catch (e) {
      throw ErrorHandler.handleError(e);
    }
  }

  @override
  Future<void> logout() async {
    try {
      await _authApi.logout();
    } catch (e) {
      // Continue with clearing tokens even if API call fails
    } finally {
      await _secureStorage.clearTokens();
    }
  }

  @override
  Future<User> getCurrentUser() async {
    try {
      final userDto = await _authApi.getCurrentUser();
      return User(
        id: userDto.id,
        email: userDto.email,
        name: userDto.displayName,
        role: UserRole.fromString(userDto.role),
        phoneNumber: userDto.phoneNumber,
        region: userDto.region,
      );
    } catch (e) {
      throw ErrorHandler.handleError(e);
    }
  }

  @override
  Future<void> refreshToken() async {
    try {
      final refreshToken = await _secureStorage.getRefreshToken();
      if (refreshToken == null) {
        throw const UnauthorizedFailure('No refresh token available');
      }

      final response = await _authApi.refreshToken(refreshToken);

      // Store new tokens
      await _secureStorage.setAccessToken(response.access_token);
      if (response.refresh_token != null) {
        await _secureStorage.setRefreshToken(response.refresh_token!);
      }
      await _secureStorage.setTokenExpiresIn(response.expires_in.toString());
    } catch (e) {
      await _secureStorage.clearTokens();
      throw ErrorHandler.handleError(e);
    }
  }

  @override
  Future<User> updateProfile({
    String? name,
    String? phoneNumber,
    String? region,
  }) async {
    try {
      final userDto = await _authApi.updateProfile(
        name: name,
        phoneNumber: phoneNumber,
        region: region,
      );
      return User(
        id: userDto.id,
        email: userDto.email,
        name: userDto.displayName,
        role: UserRole.fromString(userDto.role),
        phoneNumber: userDto.phoneNumber,
        region: userDto.region,
      );
    } catch (e) {
      throw ErrorHandler.handleError(e);
    }
  }

  @override
  Future<void> changePassword({
    required String currentPassword,
    required String newPassword,
    required String passwordConfirmation,
  }) async {
    try {
      await _authApi.changePassword(
        currentPassword: currentPassword,
        newPassword: newPassword,
        passwordConfirmation: passwordConfirmation,
      );
    } catch (e) {
      throw ErrorHandler.handleError(e);
    }
  }
}

