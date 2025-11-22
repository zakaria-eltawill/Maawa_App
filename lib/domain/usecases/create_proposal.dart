import 'package:maawa_project/domain/entities/proposal.dart';
import 'package:maawa_project/domain/repositories/proposal_repository.dart';

class CreateProposalUseCase {
  final ProposalRepository _repository;

  CreateProposalUseCase(this._repository);

  Future<Proposal> call(Proposal proposal) async {
    return await _repository.createProposal(proposal);
  }
}

