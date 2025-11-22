import 'package:maawa_project/domain/entities/proposal.dart';
import 'package:maawa_project/domain/repositories/proposal_repository.dart';

class GetProposalByIdUseCase {
  final ProposalRepository _repository;

  GetProposalByIdUseCase(this._repository);

  Future<Proposal> call(String id) async {
    return await _repository.getProposalById(id);
  }
}

