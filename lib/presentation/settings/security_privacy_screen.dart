import 'package:flutter/material.dart';
import 'package:maawa_project/core/theme/app_theme.dart';
import 'package:maawa_project/l10n/app_localizations.dart';
import 'package:maawa_project/presentation/widgets/app_card.dart';

class SecurityPrivacyScreen extends StatelessWidget {
  const SecurityPrivacyScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);

    return Scaffold(
      appBar: AppBar(
        title: Text(l10n.privacy),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Security Section
            Text(
              l10n.security,
              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
            ),
            const SizedBox(height: 16),

            AppCard(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: AppTheme.successGreen.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: const Icon(
                          Icons.lock_outline,
                          color: AppTheme.successGreen,
                          size: 24,
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              l10n.dataSecurity,
                              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                                    fontWeight: FontWeight.bold,
                                  ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              l10n.yourDataIsProtected,
                              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                                    color: AppTheme.gray600,
                                  ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 20),
                  _SecurityFeature(
                    icon: Icons.lock_outline,
                    title: l10n.encryptedCommunication,
                    description: l10n.encryptedCommunicationDesc,
                  ),
                  const Divider(height: 24),
                  _SecurityFeature(
                    icon: Icons.shield_outlined,
                    title: l10n.secureAuthentication,
                    description: l10n.secureAuthenticationDesc,
                  ),
                  const Divider(height: 24),
                  _SecurityFeature(
                    icon: Icons.storage_outlined,
                    title: l10n.secureStorage,
                    description: l10n.secureStorageDesc,
                  ),
                ],
              ),
            ),

            const SizedBox(height: 32),

            // Privacy Section
            Text(
              l10n.privacy,
              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
            ),
            const SizedBox(height: 16),

            AppCard(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: AppTheme.primaryBlue.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: const Icon(
                          Icons.privacy_tip_outlined,
                          color: AppTheme.primaryBlue,
                          size: 24,
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              l10n.yourPrivacyMatters,
                              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                                    fontWeight: FontWeight.bold,
                                  ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              l10n.weRespectYourPrivacy,
                              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                                    color: AppTheme.gray600,
                                  ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 20),
                  _PrivacyFeature(
                    icon: Icons.person_outline,
                    title: l10n.dataCollection,
                    description: l10n.dataCollectionDesc,
                  ),
                  const Divider(height: 24),
                  _PrivacyFeature(
                    icon: Icons.share_outlined,
                    title: l10n.dataSharing,
                    description: l10n.dataSharingDesc,
                  ),
                  const Divider(height: 24),
                  _PrivacyFeature(
                    icon: Icons.delete_outline,
                    title: l10n.dataDeletion,
                    description: l10n.dataDeletionDesc,
                  ),
                  const Divider(height: 24),
                  _PrivacyFeature(
                    icon: Icons.gavel_outlined,
                    title: l10n.libyanDataProtection,
                    description: l10n.libyanDataProtectionDesc,
                  ),
                ],
              ),
            ),

            const SizedBox(height: 32),

            // Terms & Conditions
            AppCard(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    l10n.termsAndConditionsTitle,
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                  ),
                  const SizedBox(height: 12),
                  Text(
                    l10n.termsAndConditionsIntro,
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                          color: AppTheme.gray600,
                        ),
                  ),
                  const SizedBox(height: 16),
                  _TermItem(
                    text: l10n.term18Years,
                  ),
                  const SizedBox(height: 8),
                  _TermItem(
                    text: l10n.termOwnerResponsibility,
                  ),
                  const SizedBox(height: 8),
                  _TermItem(
                    text: l10n.termTenantResponsibility,
                  ),
                  const SizedBox(height: 8),
                  _TermItem(
                    text: l10n.termCancellationPolicy,
                  ),
                ],
              ),
            ),

            const SizedBox(height: 24),

            // Contact
            AppCard(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    l10n.questionsAboutPrivacy,
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                  ),
                  const SizedBox(height: 12),
                  Text(
                    l10n.privacyQuestionsMessage,
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                          color: AppTheme.gray600,
                        ),
                  ),
                  const SizedBox(height: 16),
                  ElevatedButton.icon(
                    onPressed: () {
                      // TODO: Open email client
                    },
                    icon: const Icon(Icons.email),
                    label: Text(l10n.contactPrivacyTeam),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppTheme.primaryBlue,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(
                        horizontal: 24,
                        vertical: 12,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _SecurityFeature extends StatelessWidget {
  final IconData icon;
  final String title;
  final String description;

  const _SecurityFeature({
    required this.icon,
    required this.title,
    required this.description,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(icon, size: 20, color: AppTheme.primaryBlue),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: Theme.of(context).textTheme.titleSmall?.copyWith(
                      fontWeight: FontWeight.w600,
                    ),
              ),
              const SizedBox(height: 4),
              Text(
                description,
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: AppTheme.gray600,
                    ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class _PrivacyFeature extends StatelessWidget {
  final IconData icon;
  final String title;
  final String description;

  const _PrivacyFeature({
    required this.icon,
    required this.title,
    required this.description,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(icon, size: 20, color: AppTheme.primaryBlue),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: Theme.of(context).textTheme.titleSmall?.copyWith(
                      fontWeight: FontWeight.w600,
                    ),
              ),
              const SizedBox(height: 4),
              Text(
                description,
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: AppTheme.gray600,
                    ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class _TermItem extends StatelessWidget {
  final String text;

  const _TermItem({required this.text});

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          margin: const EdgeInsets.only(top: 6),
          width: 6,
          height: 6,
          decoration: const BoxDecoration(
            color: AppTheme.primaryBlue,
            shape: BoxShape.circle,
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Text(
            text,
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: AppTheme.gray700,
                ),
          ),
        ),
      ],
    );
  }
}

