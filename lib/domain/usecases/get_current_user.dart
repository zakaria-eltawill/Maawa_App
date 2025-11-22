import 'package:maawa_project/domain/entities/user.dart';
import 'package:maawa_project/domain/repositories/auth_repository.dart';

class GetCurrentUserUseCase {
  final AuthRepository _repository;

  GetCurrentUserUseCase(this._repository);

  Future<User> call() async {
    return await _repository.getCurrentUser();
  }
}

