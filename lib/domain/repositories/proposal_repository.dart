import 'package:maawa_project/domain/entities/proposal.dart';

abstract class ProposalRepository {
  Future<List<Proposal>> getOwnerProposals();
  Future<Proposal> createProposal(Proposal proposal);
  Future<Proposal> getProposalById(String id);
  Future<Proposal> updateProposal(String id, Proposal proposal);
  Future<void> deleteProposal(String id);
}

