import 'package:flutter/foundation.dart';
import 'package:maawa_project/core/network/dio_client.dart';
import 'package:maawa_project/data/dto/auth_dto.dart';

class AuthApi {
  final DioClient _dioClient;

  AuthApi(this._dioClient);

  Future<AuthResponseDto> login(String email, String password) async {
    if (kDebugMode) {
      final baseUrl = _dioClient.dio.options.baseUrl;
      debugPrint('🔐 AuthApi.login: Calling ${baseUrl}/auth/login');
      debugPrint('📧 Email: $email');
    }
    
    try {
      final response = await _dioClient.post(
        '/auth/login',
        data: LoginRequestDto(
          email: email,
          password: password,
        ).toJson(),
      );

      debugPrint('✅ AuthApi.login: Success - Status ${response.statusCode}');
      return AuthResponseDto.fromJson(response.data as Map<String, dynamic>);
    } catch (e) {
      debugPrint('❌ AuthApi.login: Error - $e');
      rethrow;
    }
  }

  Future<AuthResponseDto> register({
    required String name,
    required String email,
    required String password,
    required String passwordConfirmation,
    required String role,
    required String phoneNumber,
    required String region,
  }) async {
    if (kDebugMode) {
      final baseUrl = _dioClient.dio.options.baseUrl;
      debugPrint('📝 AuthApi.register: Calling ${baseUrl}/auth/register');
      debugPrint('📧 Email: $email, Role: $role');
      debugPrint('📞 Phone: $phoneNumber, Region: $region');
    }

    try {
      final requestData = RegisterRequestDto(
        name: name,
        email: email,
        password: password,
        passwordConfirmation: passwordConfirmation,
        role: role,
        phoneNumber: phoneNumber,
        region: region,
      ).toJson();
      
      debugPrint('📤 Registration payload: $requestData');
      
      final response = await _dioClient.post(
        '/auth/register',
        data: requestData,
      );

      debugPrint('✅ AuthApi.register: Success - Status ${response.statusCode}');
      return AuthResponseDto.fromJson(response.data as Map<String, dynamic>);
    } catch (e) {
      debugPrint('❌ AuthApi.register: Error - $e');
      rethrow;
    }
  }

  Future<AuthResponseDto> refreshToken(String refreshToken) async {
    final response = await _dioClient.post(
      '/auth/refresh',
      data: RefreshTokenRequestDto(
        refresh_token: refreshToken,
      ).toJson(),
    );

    return AuthResponseDto.fromJson(response.data as Map<String, dynamic>);
  }

  Future<void> logout() async {
    await _dioClient.post('/auth/logout');
  }

  Future<UserDto> getCurrentUser() async {
    final response = await _dioClient.get('/me');
    final raw = response.data;

    if (raw is Map<String, dynamic>) {
      final userJson = _extractUserJson(raw);
      return UserDto.fromJson(userJson);
    }

    throw Exception('Unexpected /me response format: ${raw.runtimeType}');
  }

  Map<String, dynamic> _extractUserJson(Map<String, dynamic> raw) {
    if (raw['data'] is Map<String, dynamic>) {
      return Map<String, dynamic>.from(raw['data'] as Map<String, dynamic>);
    }
    if (raw['user'] is Map<String, dynamic>) {
      return Map<String, dynamic>.from(raw['user'] as Map<String, dynamic>);
    }
    return raw;
  }

  Future<UserDto> updateProfile({
    String? name,
    String? phoneNumber,
    String? region,
  }) async {
    if (kDebugMode) {
      final baseUrl = _dioClient.dio.options.baseUrl;
      debugPrint('✏️ AuthApi.updateProfile: Calling ${baseUrl}/me');
      debugPrint('📝 Name: $name, Phone: $phoneNumber, Region: $region');
    }

    try {
      final requestData = UpdateProfileRequestDto(
        name: name,
        phoneNumber: phoneNumber,
        region: region,
      ).toJson();

      // Remove null values
      requestData.removeWhere((key, value) => value == null);

      debugPrint('📤 Update profile payload: $requestData');

      final response = await _dioClient.put(
        '/me',
        data: requestData,
      );

      debugPrint('✅ AuthApi.updateProfile: Success - Status ${response.statusCode}');
      
      final raw = response.data;
      if (raw is Map<String, dynamic>) {
        final userJson = _extractUserJson(raw);
        return UserDto.fromJson(userJson);
      }

      throw Exception('Unexpected /me response format: ${raw.runtimeType}');
    } catch (e) {
      debugPrint('❌ AuthApi.updateProfile: Error - $e');
      rethrow;
    }
  }

  Future<void> changePassword({
    required String currentPassword,
    required String newPassword,
    required String passwordConfirmation,
  }) async {
    if (kDebugMode) {
      final baseUrl = _dioClient.dio.options.baseUrl;
      debugPrint('🔐 AuthApi.changePassword: Calling ${baseUrl}/me');
    }

    try {
      final response = await _dioClient.put(
        '/me',
        data: ChangePasswordRequestDto(
          currentPassword: currentPassword,
          password: newPassword,
          passwordConfirmation: passwordConfirmation,
        ).toJson(),
      );

      debugPrint('✅ AuthApi.changePassword: Success - Status ${response.statusCode}');
    } catch (e) {
      debugPrint('❌ AuthApi.changePassword: Error - $e');
      rethrow;
    }
  }
}

