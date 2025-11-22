import 'package:maawa_project/domain/repositories/property_repository.dart';

class GetOwnerPropertiesUseCase {
  final PropertyRepository _repository;

  GetOwnerPropertiesUseCase(this._repository);

  Future<PropertyListResult> call() async {
    return await _repository.getOwnerProperties();
  }
}

