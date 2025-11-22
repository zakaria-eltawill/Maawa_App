import 'package:maawa_project/domain/entities/proposal.dart';
import 'package:maawa_project/domain/repositories/proposal_repository.dart';

class UpdateProposalUseCase {
  final ProposalRepository _repository;

  UpdateProposalUseCase(this._repository);

  Future<Proposal> call(String id, Proposal proposal) async {
    return await _repository.updateProposal(id, proposal);
  }
}

