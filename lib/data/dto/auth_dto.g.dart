// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'auth_dto.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

LoginRequestDto _$LoginRequestDtoFromJson(Map<String, dynamic> json) =>
    LoginRequestDto(
      email: json['email'] as String,
      password: json['password'] as String,
    );

Map<String, dynamic> _$LoginRequestDtoToJson(LoginRequestDto instance) =>
    <String, dynamic>{'email': instance.email, 'password': instance.password};

RegisterRequestDto _$RegisterRequestDtoFromJson(Map<String, dynamic> json) =>
    RegisterRequestDto(
      name: json['name'] as String,
      email: json['email'] as String,
      password: json['password'] as String,
      passwordConfirmation: json['password_confirmation'] as String,
      role: json['role'] as String,
      phoneNumber: json['phone_number'] as String,
      region: json['region'] as String,
    );

Map<String, dynamic> _$RegisterRequestDtoToJson(RegisterRequestDto instance) =>
    <String, dynamic>{
      'name': instance.name,
      'email': instance.email,
      'password': instance.password,
      'password_confirmation': instance.passwordConfirmation,
      'role': instance.role,
      'phone_number': instance.phoneNumber,
      'region': instance.region,
    };

AuthResponseDto _$AuthResponseDtoFromJson(Map<String, dynamic> json) =>
    AuthResponseDto(
      access_token: json['access_token'] as String,
      refresh_token: json['refresh_token'] as String?,
      expires_in: (json['expires_in'] as num).toInt(),
      user: UserDto.fromJson(json['user'] as Map<String, dynamic>),
    );

Map<String, dynamic> _$AuthResponseDtoToJson(AuthResponseDto instance) =>
    <String, dynamic>{
      'access_token': instance.access_token,
      if (instance.refresh_token case final value?) 'refresh_token': value,
      'expires_in': instance.expires_in,
      'user': instance.user.toJson(),
    };

UserDto _$UserDtoFromJson(Map<String, dynamic> json) => UserDto(
  id: _stringFromAny(json['id']),
  email: _stringFromAny(json['email']),
  name: _nullableStringFromAny(json['name']),
  fullName: _nullableStringFromAny(json['full_name']),
  role: _stringFromAny(json['role']),
  phoneNumber: _nullableStringFromAny(json['phone_number']),
  region: _nullableStringFromAny(json['region']),
);

Map<String, dynamic> _$UserDtoToJson(UserDto instance) => <String, dynamic>{
  'id': instance.id,
  'email': instance.email,
  if (instance.name case final value?) 'name': value,
  if (instance.fullName case final value?) 'full_name': value,
  'role': instance.role,
  if (instance.phoneNumber case final value?) 'phone_number': value,
  if (instance.region case final value?) 'region': value,
};

RefreshTokenRequestDto _$RefreshTokenRequestDtoFromJson(
  Map<String, dynamic> json,
) => RefreshTokenRequestDto(refresh_token: json['refresh_token'] as String);

Map<String, dynamic> _$RefreshTokenRequestDtoToJson(
  RefreshTokenRequestDto instance,
) => <String, dynamic>{'refresh_token': instance.refresh_token};

UpdateProfileRequestDto _$UpdateProfileRequestDtoFromJson(
  Map<String, dynamic> json,
) => UpdateProfileRequestDto(
  name: json['name'] as String?,
  phoneNumber: json['phone_number'] as String?,
  region: json['region'] as String?,
);

Map<String, dynamic> _$UpdateProfileRequestDtoToJson(
  UpdateProfileRequestDto instance,
) => <String, dynamic>{
  if (instance.name case final value?) 'name': value,
  if (instance.phoneNumber case final value?) 'phone_number': value,
  if (instance.region case final value?) 'region': value,
};

ChangePasswordRequestDto _$ChangePasswordRequestDtoFromJson(
  Map<String, dynamic> json,
) => ChangePasswordRequestDto(
  currentPassword: json['current_password'] as String,
  password: json['password'] as String,
  passwordConfirmation: json['password_confirmation'] as String,
);

Map<String, dynamic> _$ChangePasswordRequestDtoToJson(
  ChangePasswordRequestDto instance,
) => <String, dynamic>{
  'current_password': instance.currentPassword,
  'password': instance.password,
  'password_confirmation': instance.passwordConfirmation,
};
