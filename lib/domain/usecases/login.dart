import 'package:maawa_project/domain/entities/user.dart';
import 'package:maawa_project/domain/repositories/auth_repository.dart';

class LoginUseCase {
  final AuthRepository _repository;

  LoginUseCase(this._repository);

  Future<User> call(String email, String password) async {
    return await _repository.login(email, password);
  }
}

