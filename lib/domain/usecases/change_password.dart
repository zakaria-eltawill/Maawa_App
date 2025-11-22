import 'package:maawa_project/domain/repositories/auth_repository.dart';

class ChangePasswordUseCase {
  final AuthRepository _repository;

  ChangePasswordUseCase(this._repository);

  Future<void> call({
    required String currentPassword,
    required String newPassword,
    required String passwordConfirmation,
  }) async {
    return await _repository.changePassword(
      currentPassword: currentPassword,
      newPassword: newPassword,
      passwordConfirmation: passwordConfirmation,
    );
  }
}

