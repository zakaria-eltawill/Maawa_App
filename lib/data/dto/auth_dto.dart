import 'package:json_annotation/json_annotation.dart';
import 'package:maawa_project/domain/entities/user.dart';

part 'auth_dto.g.dart';

@JsonSerializable()
class LoginRequestDto {
  final String email;
  final String password;

  LoginRequestDto({
    required this.email,
    required this.password,
  });

  factory LoginRequestDto.fromJson(Map<String, dynamic> json) =>
      _$LoginRequestDtoFromJson(json);

  Map<String, dynamic> toJson() => _$LoginRequestDtoToJson(this);
}

@JsonSerializable()
class RegisterRequestDto {
  final String name;
  final String email;
  final String password;
  @JsonKey(name: 'password_confirmation')
  final String passwordConfirmation;
  final String role;
  @JsonKey(name: 'phone_number')
  final String phoneNumber;
  final String region;

  RegisterRequestDto({
    required this.name,
    required this.email,
    required this.password,
    required this.passwordConfirmation,
    required this.role,
    required this.phoneNumber,
    required this.region,
  });

  factory RegisterRequestDto.fromJson(Map<String, dynamic> json) =>
      _$RegisterRequestDtoFromJson(json);

  Map<String, dynamic> toJson() => _$RegisterRequestDtoToJson(this);
}

@JsonSerializable()
class AuthResponseDto {
  final String access_token;
  final String? refresh_token;
  final int expires_in;
  final UserDto user;

  AuthResponseDto({
    required this.access_token,
    this.refresh_token,
    required this.expires_in,
    required this.user,
  });

  factory AuthResponseDto.fromJson(Map<String, dynamic> json) =>
      _$AuthResponseDtoFromJson(json);

  Map<String, dynamic> toJson() => _$AuthResponseDtoToJson(this);

  User toDomain() {
    return User(
      id: user.id,
      email: user.email,
      name: user.displayName,
      role: UserRole.fromString(user.role),
    );
  }
}

@JsonSerializable()
class UserDto {
  @JsonKey(fromJson: _stringFromAny)
  final String id;
  @JsonKey(fromJson: _stringFromAny)
  final String email;
  @JsonKey(fromJson: _nullableStringFromAny)
  final String? name;
  @JsonKey(name: 'full_name', fromJson: _nullableStringFromAny)
  final String? fullName;
  @JsonKey(fromJson: _stringFromAny)
  final String role;
  @JsonKey(name: 'phone_number', fromJson: _nullableStringFromAny)
  final String? phoneNumber;
  @JsonKey(fromJson: _nullableStringFromAny)
  final String? region;

  const UserDto({
    required this.id,
    required this.email,
    this.name,
    this.fullName,
    required this.role,
    this.phoneNumber,
    this.region,
  });

  factory UserDto.fromJson(Map<String, dynamic> json) =>
      _$UserDtoFromJson(json);

  Map<String, dynamic> toJson() => _$UserDtoToJson(this);

  String? get displayName {
    if (name != null && name!.trim().isNotEmpty) {
      return name;
    }
    if (fullName != null && fullName!.trim().isNotEmpty) {
      return fullName;
    }
    return null;
  }
}

@JsonSerializable()
class RefreshTokenRequestDto {
  final String refresh_token;

  RefreshTokenRequestDto({
    required this.refresh_token,
  });

  factory RefreshTokenRequestDto.fromJson(Map<String, dynamic> json) =>
      _$RefreshTokenRequestDtoFromJson(json);

  Map<String, dynamic> toJson() => _$RefreshTokenRequestDtoToJson(this);
}

String _stringFromAny(dynamic value) {
  if (value == null) return '';
  return value.toString();
}

String? _nullableStringFromAny(dynamic value) {
  if (value == null) return null;
  final str = value.toString();
  return str.isEmpty ? null : str;
}

@JsonSerializable()
class UpdateProfileRequestDto {
  final String? name;
  @JsonKey(name: 'phone_number')
  final String? phoneNumber;
  final String? region;

  UpdateProfileRequestDto({
    this.name,
    this.phoneNumber,
    this.region,
  });

  factory UpdateProfileRequestDto.fromJson(Map<String, dynamic> json) =>
      _$UpdateProfileRequestDtoFromJson(json);

  Map<String, dynamic> toJson() => _$UpdateProfileRequestDtoToJson(this);
}

@JsonSerializable()
class ChangePasswordRequestDto {
  @JsonKey(name: 'current_password')
  final String currentPassword;
  final String password;
  @JsonKey(name: 'password_confirmation')
  final String passwordConfirmation;

  ChangePasswordRequestDto({
    required this.currentPassword,
    required this.password,
    required this.passwordConfirmation,
  });

  factory ChangePasswordRequestDto.fromJson(Map<String, dynamic> json) =>
      _$ChangePasswordRequestDtoFromJson(json);

  Map<String, dynamic> toJson() => _$ChangePasswordRequestDtoToJson(this);
}

