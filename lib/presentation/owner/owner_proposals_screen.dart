import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import 'package:maawa_project/core/di/providers.dart';
import 'package:maawa_project/core/theme/app_theme.dart';
import 'package:maawa_project/domain/entities/proposal.dart';
import 'package:maawa_project/l10n/app_localizations.dart';
import 'package:maawa_project/presentation/widgets/empty_state.dart';
import 'package:maawa_project/presentation/widgets/error_state.dart';
import 'package:maawa_project/presentation/widgets/shimmer_loading.dart';
import 'package:maawa_project/presentation/widgets/app_card.dart';

class OwnerProposalsScreen extends ConsumerWidget {
  const OwnerProposalsScreen({super.key});

  void _showDeleteConfirmation(BuildContext context, WidgetRef ref, Proposal proposal) {
    final l10n = AppLocalizations.of(context);
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(l10n.deleteProposal),
        content: Text(l10n.deleteProposalConfirmation),
        actions: [
          TextButton(
            onPressed: () => context.pop(),
            child: Text(l10n.cancel),
          ),
          ElevatedButton(
            onPressed: () async {
              context.pop();
              await _deleteProposal(context, ref, proposal.id);
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: AppTheme.dangerRed,
            ),
            child: Text(l10n.delete),
          ),
        ],
      ),
    );
  }

  Future<void> _deleteProposal(BuildContext context, WidgetRef ref, String proposalId) async {
    final l10n = AppLocalizations.of(context);
    try {
      final repository = ref.read(proposalRepositoryProvider);
      await repository.deleteProposal(proposalId);
      
      // Invalidate proposals list
      ref.invalidate(ownerProposalsProvider);
      
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(l10n.proposalDeletedSuccessfully),
            backgroundColor: AppTheme.successGreen,
          ),
        );
      }
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('${l10n.failedToDeleteProposal}: ${e.toString()}'),
            backgroundColor: AppTheme.dangerRed,
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final proposalsAsync = ref.watch(ownerProposalsProvider);
    final l10n = AppLocalizations.of(context);

    return Scaffold(
      appBar: AppBar(
        title: Text(l10n.proposals),
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () {
          context.push('/home/proposal/new');
        },
        icon: const Icon(Icons.add),
        label: Text(l10n.createProposal),
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
                  message: l10n.noProposalsFound,
                  subtitle: l10n.createYourFirstProposal,
                  icon: Icons.edit_note_outlined,
                  iconColor: AppTheme.primaryBlue,
                  action: ElevatedButton.icon(
                    onPressed: () {
                      context.push('/home/proposal/new');
                    },
                    icon: const Icon(Icons.add),
                    label: Text(l10n.createProposal),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppTheme.primaryBlue,
                      padding: const EdgeInsets.symmetric(
                        horizontal: 24,
                        vertical: 12,
                      ),
                    ),
                  ),
                ),
              );
            }

            // Sort proposals: PENDING first, then by most recent activity
            // Uses both updated_at and created_at from backend (ISO 8601 format)
            // This ensures newly updated proposals (e.g., status changed to pending) appear at the top
            final sortedProposals = List<Proposal>.from(proposals)
              ..sort((a, b) {
                // First priority: PENDING status comes first
                final aIsPending = a.status == ProposalStatus.pending;
                final bIsPending = b.status == ProposalStatus.pending;
                
                if (aIsPending && !bIsPending) {
                  return -1; // a (pending) comes first
                } else if (!aIsPending && bIsPending) {
                  return 1; // b (pending) comes first
                }
                
                // Both have same status priority, now sort by date
                // Primary sort: updatedAt (most recent activity)
                // Secondary sort: createdAt (if updatedAt is same or null)
                
                DateTime aDate;
                DateTime bDate;
                
                // Use updatedAt if available, otherwise fall back to createdAt
                // Backend now guarantees both fields are present
                if (a.updatedAt != null) {
                  aDate = a.updatedAt!;
                } else {
                  aDate = a.createdAt;
                }
                
                if (b.updatedAt != null) {
                  bDate = b.updatedAt!;
                } else {
                  bDate = b.createdAt;
                }
                
                // Sort in descending order (most recent first)
                final dateComparison = bDate.compareTo(aDate);
                
                // If dates are equal, use createdAt as tiebreaker
                if (dateComparison == 0) {
                  return b.createdAt.compareTo(a.createdAt);
                }
                
                return dateComparison;
              });

            return ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: sortedProposals.length,
              itemBuilder: (context, index) {
                final proposal = sortedProposals[index];
                return _ProposalCard(
                  proposal: proposal,
                  onTap: () {
                    // Navigate to proposal detail screen
                    context.push('/home/proposal/detail/${proposal.id}');
                  },
                  onEdit: () {
                    // Navigate to edit proposal screen
                    context.push('/home/proposal/edit/${proposal.id}');
                  },
                  onDelete: () {
                    // Show delete confirmation dialog
                    _showDeleteConfirmation(context, ref, proposal);
                  },
                );
              },
            );
          },
          loading: () => ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: 5,
            itemBuilder: (context, index) => const SkeletonProposalCard(),
          ),
          error: (error, stack) {
            final errorString = error.toString().toLowerCase();
            if (errorString.contains('socket') ||
                errorString.contains('network') ||
                errorString.contains('connection')) {
              return NetworkErrorState(
                onRetry: () => ref.invalidate(ownerProposalsProvider),
              );
            } else {
              return ServerErrorState(
                onRetry: () => ref.invalidate(ownerProposalsProvider),
                errorDetails: error.toString(),
              );
            }
          },
        ),
      ),
    );
  }
}

class _ProposalCard extends StatelessWidget {
  final Proposal proposal;
  final VoidCallback? onTap;
  final VoidCallback? onEdit;
  final VoidCallback? onDelete;

  const _ProposalCard({
    required this.proposal,
    this.onTap,
    this.onEdit,
    this.onDelete,
  });

  Color _getStatusColor(ProposalStatus status) {
    switch (status) {
      case ProposalStatus.approved:
        return AppTheme.successGreen;
      case ProposalStatus.rejected:
        return AppTheme.dangerRed;
      case ProposalStatus.pending:
        return AppTheme.warningOrange;
      case ProposalStatus.resubmitted:
        return AppTheme.primaryBlue;
    }
  }

  String _getStatusLabel(ProposalStatus status, AppLocalizations l10n) {
    switch (status) {
      case ProposalStatus.approved:
        return l10n.approved;
      case ProposalStatus.rejected:
        return l10n.rejected;
      case ProposalStatus.pending:
        return l10n.pending;
      case ProposalStatus.resubmitted:
        return 'Resubmitted';
    }
  }

  String _getTypeLabel(ProposalType type, AppLocalizations l10n) {
    switch (type) {
      case ProposalType.add:
        return 'Add Property';
      case ProposalType.edit:
        return 'Edit Property';
      case ProposalType.delete:
        return 'Delete Property';
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final dateFormat = DateFormat('MMM dd, yyyy');

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(16),
        child: AppCard(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      proposal.data?.name ?? _getTypeLabel(proposal.type, l10n),
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                            fontWeight: FontWeight.bold,
                          ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      _getTypeLabel(proposal.type, l10n),
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                            color: AppTheme.gray600,
                          ),
                    ),
                  ],
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 6,
                ),
                decoration: BoxDecoration(
                  color: _getStatusColor(proposal.status).withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  _getStatusLabel(proposal.status, l10n),
                  style: Theme.of(context).textTheme.labelSmall?.copyWith(
                        color: _getStatusColor(proposal.status),
                        fontWeight: FontWeight.w600,
                      ),
                ),
              ),
                ],
              ),
              const SizedBox(height: 12),
              Row(
                children: [
                  Icon(Icons.calendar_today_outlined, size: 16, color: AppTheme.gray600),
                  const SizedBox(width: 8),
                  Text(
                    'Submitted: ${dateFormat.format(proposal.createdAt)}',
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          color: AppTheme.gray600,
                        ),
                  ),
                  const Spacer(),
                  // Edit icon button - only show for PENDING or REJECTED proposals
                  if (onEdit != null && (proposal.status == ProposalStatus.pending || proposal.status == ProposalStatus.rejected))
                    IconButton(
                      icon: Icon(Icons.edit_outlined, size: 20, color: AppTheme.primaryBlue),
                      onPressed: () {
                        onEdit?.call();
                      },
                      padding: EdgeInsets.zero,
                      constraints: const BoxConstraints(),
                      tooltip: l10n.proposalEdit,
                    ),
                  // Delete icon button - only show for PENDING or REJECTED proposals
                  if (onDelete != null && (proposal.status == ProposalStatus.pending || proposal.status == ProposalStatus.rejected)) ...[
                    if (onEdit != null && (proposal.status == ProposalStatus.pending || proposal.status == ProposalStatus.rejected))
                      const SizedBox(width: 8),
                    IconButton(
                      icon: Icon(Icons.delete_outline, size: 20, color: AppTheme.dangerRed),
                      onPressed: () {
                        onDelete?.call();
                      },
                      padding: EdgeInsets.zero,
                      constraints: const BoxConstraints(),
                      tooltip: l10n.deleteProposal,
                    ),
                  ],
                ],
              ),
          if (proposal.adminNotes != null && proposal.adminNotes!.isNotEmpty) ...[
            const SizedBox(height: 12),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: AppTheme.gray50,
                borderRadius: BorderRadius.circular(8),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Admin Notes:',
                    style: Theme.of(context).textTheme.labelSmall?.copyWith(
                          fontWeight: FontWeight.w600,
                        ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    proposal.adminNotes!,
                    style: Theme.of(context).textTheme.bodySmall,
                  ),
                ],
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

class SkeletonProposalCard extends StatelessWidget {
  const SkeletonProposalCard({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      child: AppCard(
        child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    SkeletonBox(width: double.infinity, height: 20),
                    const SizedBox(height: 8),
                    SkeletonBox(width: 150, height: 14),
                  ],
                ),
              ),
              SkeletonBox(width: 80, height: 24, borderRadius: BorderRadius.circular(12)),
            ],
          ),
          const SizedBox(height: 12),
          SkeletonBox(width: 200, height: 14),
        ],
        ),
      ),
    );
  }
}

