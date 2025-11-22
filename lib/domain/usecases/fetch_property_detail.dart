import 'package:maawa_project/domain/entities/property.dart';
import 'package:maawa_project/domain/repositories/property_repository.dart';

class FetchPropertyDetailUseCase {
  final PropertyRepository _repository;

  FetchPropertyDetailUseCase(this._repository);

  Future<Property> call(String id) async {
    return await _repository.getPropertyById(id);
  }
}

