import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import 'package:maawa_project/core/di/providers.dart';
import 'package:maawa_project/core/error/failures.dart';
import 'package:maawa_project/core/theme/app_theme.dart';
import 'package:maawa_project/domain/entities/proposal.dart';
import 'package:maawa_project/l10n/app_localizations.dart';
import 'package:maawa_project/presentation/widgets/app_button.dart';
import 'package:maawa_project/presentation/widgets/app_card.dart';
import 'package:cached_network_image/cached_network_image.dart';

class ProposalDetailScreen extends ConsumerWidget {
  final String proposalId;

  const ProposalDetailScreen({
    super.key,
    required this.proposalId,
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
  Widget build(BuildContext context, WidgetRef ref) {
    final proposalAsync = ref.watch(proposalDetailProvider(proposalId));
    final l10n = AppLocalizations.of(context);
    final dateFormat = DateFormat('MMM dd, yyyy • hh:mm a');

    return Scaffold(
      appBar: AppBar(
        title: Text(l10n.proposalDetails),
      ),
      body: proposalAsync.when(
        data: (proposal) {
          final proposalData = proposal.data;
          
          return SingleChildScrollView(
            padding: const EdgeInsets.all(AppTheme.spacingLG),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // Status Badge
                AppCard(
                  child: Row(
                    children: [
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              proposalData?.name ?? _getTypeLabel(proposal.type, l10n),
                              style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                                    fontWeight: FontWeight.bold,
                                  ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              _getTypeLabel(proposal.type, l10n),
                              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
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
                          style: Theme.of(context).textTheme.labelMedium?.copyWith(
                                color: _getStatusColor(proposal.status),
                                fontWeight: FontWeight.w600,
                              ),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: AppTheme.spacingMD),

                // Proposal Information
                if (proposalData != null) ...[
                  // Description
                  if (proposalData.description != null && proposalData.description!.isNotEmpty) ...[
                    AppCard(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            l10n.description,
                            style: Theme.of(context).textTheme.titleMedium?.copyWith(
                                  fontWeight: FontWeight.w600,
                                ),
                          ),
                          const SizedBox(height: AppTheme.spacingMD),
                          Text(
                            proposalData.description!,
                            style: Theme.of(context).textTheme.bodyMedium,
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: AppTheme.spacingMD),
                  ],

                  // Property Details
                  AppCard(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Property Details',
                          style: Theme.of(context).textTheme.titleMedium?.copyWith(
                                fontWeight: FontWeight.w600,
                              ),
                        ),
                        const SizedBox(height: AppTheme.spacingMD),
                        _InfoRow(
                          icon: Icons.location_city,
                          label: l10n.city,
                          value: proposalData.city ?? 'N/A',
                        ),
                        if (proposalData.propertyType != null) ...[
                          const SizedBox(height: AppTheme.spacingMD),
                          _InfoRow(
                            icon: Icons.category,
                            label: 'Type',
                            value: proposalData.propertyType!,
                          ),
                        ],
                        if (proposalData.pricePerNight != null) ...[
                          const SizedBox(height: AppTheme.spacingMD),
                          _InfoRow(
                            icon: Icons.attach_money,
                            label: l10n.pricePerNight,
                            value: '${proposalData.pricePerNight} دل / ليلة',
                          ),
                        ],
                        if (proposalData.amenities != null && proposalData.amenities!.isNotEmpty) ...[
                          const SizedBox(height: AppTheme.spacingMD),
                          Text(
                            l10n.amenities,
                            style: Theme.of(context).textTheme.titleSmall?.copyWith(
                                  fontWeight: FontWeight.w600,
                                ),
                          ),
                          const SizedBox(height: 8),
                          Wrap(
                            spacing: 8,
                            runSpacing: 8,
                            children: proposalData.amenities!.map((amenity) {
                              return Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 12,
                                  vertical: 6,
                                ),
                                decoration: BoxDecoration(
                                  color: AppTheme.gray50,
                                  borderRadius: BorderRadius.circular(8),
                                  border: Border.all(color: AppTheme.gray200),
                                ),
                                child: Text(
                                  amenity,
                                  style: Theme.of(context).textTheme.bodySmall,
                                ),
                              );
                            }).toList(),
                          ),
                        ],
                      ],
                    ),
                  ),
                  const SizedBox(height: AppTheme.spacingMD),

                  // Photos
                  if (proposalData.photos != null && proposalData.photos!.isNotEmpty) ...[
                    AppCard(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            l10n.photos,
                            style: Theme.of(context).textTheme.titleMedium?.copyWith(
                                  fontWeight: FontWeight.w600,
                                ),
                          ),
                          const SizedBox(height: AppTheme.spacingMD),
                          SizedBox(
                            height: 200,
                            child: ListView.builder(
                              scrollDirection: Axis.horizontal,
                              itemCount: proposalData.photos!.length,
                              itemBuilder: (context, index) {
                                final photoUrl = proposalData.photos![index];
                                return Container(
                                  width: 200,
                                  margin: const EdgeInsets.only(right: 8),
                                  child: ClipRRect(
                                    borderRadius: BorderRadius.circular(8),
                                    child: CachedNetworkImage(
                                      imageUrl: photoUrl,
                                      fit: BoxFit.cover,
                                      placeholder: (context, url) => Container(
                                        color: AppTheme.gray200,
                                        child: const Center(child: CircularProgressIndicator()),
                                      ),
                                      errorWidget: (context, url, error) => Container(
                                        color: AppTheme.gray200,
                                        child: const Icon(Icons.image_not_supported),
                                      ),
                                    ),
                                  ),
                                );
                              },
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: AppTheme.spacingMD),
                  ],
                ],

                // Submission Info
                AppCard(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Submission Information',
                        style: Theme.of(context).textTheme.titleMedium?.copyWith(
                              fontWeight: FontWeight.w600,
                            ),
                      ),
                      const SizedBox(height: AppTheme.spacingMD),
                      _InfoRow(
                        icon: Icons.calendar_today,
                        label: 'Submitted',
                        value: dateFormat.format(proposal.createdAt),
                      ),
                      if (proposal.updatedAt != null) ...[
                        const SizedBox(height: AppTheme.spacingMD),
                        _InfoRow(
                          icon: Icons.update,
                          label: 'Last Updated',
                          value: dateFormat.format(proposal.updatedAt!),
                        ),
                      ],
                    ],
                  ),
                ),
                const SizedBox(height: AppTheme.spacingMD),

                // Admin Notes
                if (proposal.adminNotes != null && proposal.adminNotes!.isNotEmpty) ...[
                  AppCard(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Admin Notes',
                          style: Theme.of(context).textTheme.titleMedium?.copyWith(
                                fontWeight: FontWeight.w600,
                                color: AppTheme.dangerRed,
                              ),
                        ),
                        const SizedBox(height: AppTheme.spacingMD),
                        Text(
                          proposal.adminNotes!,
                          style: Theme.of(context).textTheme.bodyMedium,
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: AppTheme.spacingMD),
                ],

                // Action Buttons - only show for PENDING or REJECTED proposals
                if (proposal.status == ProposalStatus.pending || proposal.status == ProposalStatus.rejected) ...[
                  AppButton(
                    text: l10n.proposalEdit,
                    icon: Icons.edit,
                    onPressed: () {
                      context.push('/home/proposal/edit/${proposal.id}');
                    },
                  ),
                  const SizedBox(height: AppTheme.spacingSM),
                  OutlinedButton.icon(
                    onPressed: () {
                      _showDeleteConfirmation(context, ref, proposal.id);
                    },
                    icon: const Icon(Icons.delete_outline),
                    label: Text(l10n.deleteProposal),
                    style: OutlinedButton.styleFrom(
                      foregroundColor: AppTheme.dangerRed,
                      side: BorderSide(color: AppTheme.dangerRed),
                      padding: const EdgeInsets.symmetric(
                        horizontal: AppTheme.spacingLG,
                        vertical: AppTheme.spacingMD,
                      ),
                    ),
                  ),
                ] else ...[
                  // Show info message for APPROVED proposals
                  Container(
                    padding: const EdgeInsets.all(AppTheme.spacingMD),
                    decoration: BoxDecoration(
                      color: AppTheme.warningOrange.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: AppTheme.warningOrange),
                    ),
                    child: Row(
                      children: [
                        Icon(Icons.info_outline, color: AppTheme.warningOrange),
                        const SizedBox(width: AppTheme.spacingMD),
                        Expanded(
                          child: Text(
                            l10n.approvedProposalCannotBeModified,
                            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                                  color: AppTheme.warningOrange,
                                ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
                const SizedBox(height: AppTheme.spacingLG),
              ],
            ),
          );
        },
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (error, stack) {
          return Center(
            child: Padding(
              padding: const EdgeInsets.all(24.0),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.error_outline, size: 64, color: AppTheme.dangerRed),
                  const SizedBox(height: 16),
                  Text(
                    'Failed to load proposal',
                    style: Theme.of(context).textTheme.titleLarge,
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 8),
                  Text(
                    error.toString(),
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                          color: AppTheme.gray600,
                        ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 24),
                  AppButton(
                    text: 'Go Back',
                    onPressed: () => context.pop(),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  void _showDeleteConfirmation(BuildContext context, WidgetRef ref, String proposalId) {
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
              await _deleteProposal(context, ref, proposalId);
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
        context.pop();
      }
    } catch (e) {
      if (context.mounted) {
        String errorMessage = l10n.failedToDeleteProposal;
        
        // Handle specific error types
        if (e is ValidationFailure) {
          errorMessage = '${l10n.failedToDeleteProposal}\n${e.message}';
        } else if (e is UnauthorizedFailure) {
          errorMessage = l10n.youDontHavePermissionToModify;
        } else if (e is NotFoundFailure) {
          errorMessage = '${l10n.failedToDeleteProposal}\n${e.message}';
        } else {
          errorMessage = '${l10n.failedToDeleteProposal}: ${e.toString()}';
        }
        
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(errorMessage),
            backgroundColor: AppTheme.dangerRed,
            duration: const Duration(seconds: 5),
          ),
        );
      }
    }
  }
}

class _InfoRow extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;

  const _InfoRow({
    required this.icon,
    required this.label,
    required this.value,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Icon(icon, size: 20, color: AppTheme.gray600),
        const SizedBox(width: AppTheme.spacingMD),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: AppTheme.gray600,
                    ),
              ),
              const SizedBox(height: 2),
              Text(
                value,
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      fontWeight: FontWeight.w500,
                    ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

