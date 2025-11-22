import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:maawa_project/core/di/providers.dart';
import 'package:maawa_project/core/theme/app_theme.dart';
import 'package:maawa_project/domain/entities/proposal.dart';
import 'package:maawa_project/presentation/widgets/empty_state.dart';
import 'package:maawa_project/presentation/widgets/app_button.dart';
import 'package:maawa_project/presentation/widgets/state_badge.dart';
import 'package:intl/intl.dart';

class OwnerProposalsListScreen extends ConsumerWidget {
  const OwnerProposalsListScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final proposalsAsync = ref.watch(ownerProposalsProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Proposals'),
        actions: [
          IconButton(
            icon: const Icon(Icons.add),
            onPressed: () {
              context.push('/home/proposal/new');
            },
          ),
        ],
      ),
      body: RefreshIndicator(
        onRefresh: () async {
          ref.invalidate(ownerProposalsProvider);
        },
        child: proposalsAsync.when(
          data: (proposals) {
            if (proposals.isEmpty) {
              return Center(
                child: EmptyState(
                  message: 'No proposals found',
                  icon: Icons.edit_note_outlined,
                  action: AppButton(
                    text: 'Create Proposal',
                    onPressed: () {
                      context.push('/home/proposal/new');
                    },
                  ),
                ),
              );
            }
            return ListView.builder(
              padding: const EdgeInsets.all(AppTheme.spacingMD),
              itemCount: proposals.length,
              itemBuilder: (context, index) {
                final proposal = proposals[index];
                return _ProposalCard(proposal: proposal);
              },
            );
          },
          loading: () => const Center(child: CircularProgressIndicator()),
          error: (error, stack) => Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(Icons.error_outline, size: 48, color: Colors.red),
                const SizedBox(height: 16),
                Text(
                  'Failed to load proposals',
                  style: Theme.of(context).textTheme.titleMedium,
                ),
                const SizedBox(height: 8),
                Text(
                  error.toString(),
                  style: Theme.of(context).textTheme.bodySmall,
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 16),
                ElevatedButton(
                  onPressed: () {
                    ref.invalidate(ownerProposalsProvider);
                  },
                  child: const Text('Retry'),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _ProposalCard extends StatelessWidget {
  final Proposal proposal;

  const _ProposalCard({required this.proposal});

  String _getTypeLabel(ProposalType type) {
    switch (type) {
      case ProposalType.add:
        return 'ADD';
      case ProposalType.edit:
        return 'EDIT';
      case ProposalType.delete:
        return 'DELETE';
    }
  }

  @override
  Widget build(BuildContext context) {
    final dateFormat = DateFormat('MMM dd, yyyy');

    return Card(
      margin: const EdgeInsets.only(bottom: AppTheme.spacingMD),
      child: InkWell(
        onTap: () {
          if (proposal.type == ProposalType.edit || proposal.type == ProposalType.delete) {
            context.push('/home/proposal/${proposal.id}');
          }
        },
        child: Padding(
          padding: const EdgeInsets.all(AppTheme.spacingMD),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Expanded(
                    child: Text(
                      proposal.data?.name ?? _getTypeLabel(proposal.type),
                      style: Theme.of(context).textTheme.titleMedium,
                    ),
                  ),
                  StateBadge(label: proposal.status.name),
                ],
              ),
              const SizedBox(height: 8),
              Row(
                children: [
                  Chip(
                    label: Text(_getTypeLabel(proposal.type)),
                    visualDensity: VisualDensity.compact,
                  ),
                  const SizedBox(width: 8),
                  Text(
                    dateFormat.format(proposal.createdAt),
                    style: Theme.of(context).textTheme.bodySmall,
                  ),
                ],
              ),
              if (proposal.adminNotes != null) ...[
                const SizedBox(height: 8),
                Text(
                  'Admin Notes: ${proposal.adminNotes}',
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        fontStyle: FontStyle.italic,
                      ),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}

