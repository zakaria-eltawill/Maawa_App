import 'package:maawa_project/domain/entities/proposal.dart';
import 'package:maawa_project/domain/repositories/proposal_repository.dart';

class ListOwnerProposalsUseCase {
  final ProposalRepository _repository;

  ListOwnerProposalsUseCase(this._repository);

  Future<List<Proposal>> call() async {
    return await _repository.getOwnerProposals();
  }
}

