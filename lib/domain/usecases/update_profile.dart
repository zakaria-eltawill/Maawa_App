import 'package:maawa_project/domain/entities/user.dart';
import 'package:maawa_project/domain/repositories/auth_repository.dart';

class UpdateProfileUseCase {
  final AuthRepository _repository;

  UpdateProfileUseCase(this._repository);

  Future<User> call({
    String? name,
    String? phoneNumber,
    String? region,
  }) async {
    return await _repository.updateProfile(
      name: name,
      phoneNumber: phoneNumber,
      region: region,
    );
  }
}

