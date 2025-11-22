import 'package:maawa_project/domain/repositories/property_repository.dart';

class FetchPropertiesUseCase {
  final PropertyRepository _repository;

  FetchPropertiesUseCase(this._repository);

  Future<PropertyListResult> call(PropertyFilters filters) async {
    return await _repository.getProperties(filters);
  }
}

