import 'package:maawa_project/domain/entities/user.dart';
import 'package:maawa_project/domain/repositories/auth_repository.dart';

class RegisterUseCase {
  final AuthRepository _repository;

  RegisterUseCase(this._repository);

  Future<User> call({
    required String name,
    required String email,
    required String password,
    required String passwordConfirmation,
    required String role,
    required String phoneNumber,
    required String region,
  }) async {
    return await _repository.register(
      name: name,
      email: email,
      password: password,
      passwordConfirmation: passwordConfirmation,
      role: role,
      phoneNumber: phoneNumber,
      region: region,
    );
  }
}

