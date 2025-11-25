import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:maawa_project/core/theme/app_theme.dart';
import 'package:maawa_project/core/di/providers.dart';
import 'package:maawa_project/core/providers/language_provider.dart';
import 'package:maawa_project/domain/entities/user.dart';
import 'package:maawa_project/presentation/widgets/app_button.dart';
import 'package:maawa_project/presentation/widgets/app_card.dart';
import 'package:maawa_project/presentation/widgets/info_row.dart';
import 'package:maawa_project/l10n/app_localizations.dart';

class ProfileScreen extends ConsumerWidget {
  const ProfileScreen({super.key});

  Future<void> _handleLogout(BuildContext context, WidgetRef ref) async {
    final logoutUseCase = ref.read(logoutUseCaseProvider);
    await logoutUseCase();
    if (context.mounted) {
      ref.invalidate(currentUserProvider);
      context.go('/auth');
    }
  }

  String _getRoleDisplayName(UserRole role, AppLocalizations l10n) {
    switch (role) {
      case UserRole.tenant:
        return l10n.tenant;
      case UserRole.owner:
        return l10n.owner;
      case UserRole.admin:
        return l10n.admin;
    }
  }

  IconData _getRoleIcon(UserRole role) {
    switch (role) {
      case UserRole.tenant:
        return Icons.person_outlined;
      case UserRole.owner:
        return Icons.home_work_outlined;
      case UserRole.admin:
        return Icons.admin_panel_settings_outlined;
    }
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final userAsync = ref.watch(currentUserProvider);
    final l10n = AppLocalizations.of(context);

    return Scaffold(
      backgroundColor: AppTheme.gray50,
      body: SafeArea(
        child: userAsync.when(
          data: (user) {
            if (kDebugMode) {
              debugPrint('👤 Profile Screen - User Data:');
              debugPrint('  - Name: ${user.name}');
              debugPrint('  - Email: ${user.email}');
              debugPrint('  - Phone: ${user.phoneNumber ?? "NOT SET"}');
              debugPrint('  - Region: ${user.region ?? "NOT SET"}');
              debugPrint('  - Role: ${user.role.name}');
            }
            return CustomScrollView(
            slivers: [
              // Header with avatar
              SliverToBoxAdapter(
                child: Container(
                  padding: const EdgeInsets.fromLTRB(24, 24, 24, 40),
                  decoration: const BoxDecoration(
                    gradient: LinearGradient(
                      colors: [AppTheme.primaryBlue, AppTheme.lightBlue],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                    borderRadius: BorderRadius.only(
                      bottomLeft: Radius.circular(32),
                      bottomRight: Radius.circular(32),
                    ),
                  ),
                  child: Column(
                    children: [
                      // Avatar
                      Container(
                        width: 100,
                        height: 100,
                        decoration: BoxDecoration(
                          color: Colors.white,
                          shape: BoxShape.circle,
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withOpacity(0.1),
                              blurRadius: 10,
                              offset: const Offset(0, 4),
                            ),
                          ],
                        ),
                        child: Icon(
                          _getRoleIcon(user.role),
                          size: 50,
                          color: AppTheme.primaryBlue,
                        ),
                      ),
                      const SizedBox(height: 16),
                      
                      // Name
                      if (user.name != null && user.name!.isNotEmpty)
                        Text(
                          user.name!,
                          style: const TextStyle(
                            fontSize: 24,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                          textAlign: TextAlign.center,
                        ),
                      
                      const SizedBox(height: 8),
                      
                      // Role badge
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 16,
                          vertical: 8,
                        ),
                        decoration: BoxDecoration(
                          color: Colors.white.withOpacity(0.2),
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: Text(
                          _getRoleDisplayName(user.role, l10n),
                          style: const TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w600,
                            color: Colors.white,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              
              // User information card
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(24, 24, 24, 16),
                  child: AppCard(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          l10n.personalInformation,
                          style: const TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.w600,
                            color: AppTheme.gray900,
                          ),
                        ),
                        const SizedBox(height: 16),
                        InfoRow(
                          icon: Icons.email_outlined,
                          label: l10n.email,
                          value: user.email,
                        ),
                        const Divider(height: 24),
                        if (user.phoneNumber != null && user.phoneNumber!.isNotEmpty) ...[
                          InfoRow(
                            icon: Icons.phone_outlined,
                            label: l10n.phone,
                            value: user.phoneNumber!,
                          ),
                          const Divider(height: 24),
                        ],
                        if (user.region != null && user.region!.isNotEmpty) ...[
                          InfoRow(
                            icon: Icons.location_city_outlined,
                            label: l10n.region,
                            value: user.region!,
                          ),
                          const Divider(height: 24),
                        ],
                        InfoRow(
                          icon: Icons.badge_outlined,
                          label: 'الدور',
                          value: _getRoleDisplayName(user.role, l10n),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
              
              // Settings section
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(24, 0, 24, 16),
                  child: AppCard(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          l10n.settings,
                          style: const TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.w600,
                            color: AppTheme.gray900,
                          ),
                        ),
                        const SizedBox(height: 16),
                        InkWell(
                          onTap: () {
                            context.push('/home/profile/edit');
                          },
                          borderRadius: BorderRadius.circular(12),
                          child: Padding(
                            padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 4),
                            child: Row(
                              children: [
                                Container(
                                  padding: const EdgeInsets.all(10),
                                  decoration: BoxDecoration(
                                    color: AppTheme.primaryBlue.withOpacity(0.1),
                                    borderRadius: BorderRadius.circular(10),
                                  ),
                                  child: const Icon(
                                    Icons.edit_outlined,
                                    size: 20,
                                    color: AppTheme.primaryBlue,
                                  ),
                                ),
                                const SizedBox(width: 12),
                                Expanded(
                                  child: Text(
                                    l10n.editProfile,
                                    style: const TextStyle(
                                      fontSize: 15,
                                      color: AppTheme.gray900,
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                ),
                                const Icon(
                                  Icons.chevron_left,
                                  color: AppTheme.gray400,
                                  size: 20,
                                ),
                              ],
                            ),
                          ),
                        ),
                        const Divider(height: 24),
                        InkWell(
                          onTap: () {
                            _showLanguageDialog(context, ref);
                          },
                          borderRadius: BorderRadius.circular(12),
                          child: Padding(
                            padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 4),
                            child: Row(
                              children: [
                                Container(
                                  padding: const EdgeInsets.all(10),
                                  decoration: BoxDecoration(
                                    color: AppTheme.primaryBlue.withOpacity(0.1),
                                    borderRadius: BorderRadius.circular(10),
                                  ),
                                  child: const Icon(
                                    Icons.language_outlined,
                                    size: 20,
                                    color: AppTheme.primaryBlue,
                                  ),
                                ),
                                const SizedBox(width: 12),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        l10n.language,
                                        style: const TextStyle(
                                          fontSize: 12,
                                          color: AppTheme.gray500,
                                          fontWeight: FontWeight.w500,
                                        ),
                                      ),
                                      const SizedBox(height: 2),
                                      Consumer(
                                        builder: (context, ref, _) {
                                          final locale = ref.watch(languageProvider);
                                          return Text(
                                            locale.languageCode == 'ar' ? 'العربية' : 'English',
                                            style: const TextStyle(
                                              fontSize: 15,
                                              color: AppTheme.gray900,
                                              fontWeight: FontWeight.w600,
                                            ),
                                          );
                                        },
                                      ),
                                    ],
                                  ),
                                ),
                                const Icon(
                                  Icons.chevron_left,
                                  color: AppTheme.gray400,
                                  size: 20,
                                ),
                              ],
                            ),
                          ),
                        ),
                        const Divider(height: 24),
                        InkWell(
                          onTap: () {
                            context.push('/home/help-support');
                          },
                          borderRadius: BorderRadius.circular(12),
                          child: Padding(
                            padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 4),
                            child: Row(
                              children: [
                                Container(
                                  padding: const EdgeInsets.all(10),
                                  decoration: BoxDecoration(
                                    color: AppTheme.primaryBlue.withOpacity(0.1),
                                    borderRadius: BorderRadius.circular(10),
                                  ),
                                  child: const Icon(
                                    Icons.help_outline,
                                    size: 20,
                                    color: AppTheme.primaryBlue,
                                  ),
                                ),
                                const SizedBox(width: 12),
                                Expanded(
                                  child: Text(
                                    l10n.helpSupport,
                                    style: const TextStyle(
                                      fontSize: 15,
                                      color: AppTheme.gray900,
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                ),
                                const Icon(
                                  Icons.chevron_left,
                                  color: AppTheme.gray400,
                                  size: 20,
                                ),
                              ],
                            ),
                          ),
                        ),
                        const Divider(height: 24),
                        InkWell(
                          onTap: () {
                            context.push('/home/security-privacy');
                          },
                          borderRadius: BorderRadius.circular(12),
                          child: Padding(
                            padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 4),
                            child: Row(
                              children: [
                                Container(
                                  padding: const EdgeInsets.all(10),
                                  decoration: BoxDecoration(
                                    color: AppTheme.primaryBlue.withOpacity(0.1),
                                    borderRadius: BorderRadius.circular(10),
                                  ),
                                  child: const Icon(
                                    Icons.privacy_tip_outlined,
                                    size: 20,
                                    color: AppTheme.primaryBlue,
                                  ),
                                ),
                                const SizedBox(width: 12),
                                Expanded(
                                  child: Text(
                                    l10n.privacy,
                                    style: const TextStyle(
                                      fontSize: 15,
                                      color: AppTheme.gray900,
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                ),
                                const Icon(
                                  Icons.chevron_left,
                                  color: AppTheme.gray400,
                                  size: 20,
                                ),
                              ],
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
              
              // Logout button
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(24, 0, 24, 24),
                  child: SizedBox(
                    width: double.infinity,
                    child: ElevatedButton.icon(
                      onPressed: () => _handleLogout(context, ref),
                      icon: const Icon(Icons.logout),
                      label: Text(l10n.logout),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppTheme.dangerRed,
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        elevation: 0,
                      ),
                    ),
                  ),
                ),
              ),
            ],
            );
          },
          loading: () => const Center(
            child: CircularProgressIndicator(),
          ),
          error: (error, stack) => Center(
            child: Padding(
              padding: const EdgeInsets.all(24),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(
                    Icons.error_outline,
                    size: 64,
                    color: AppTheme.dangerRed,
                  ),
                  const SizedBox(height: 16),
                  Text(
                    l10n.failedToLoad,
                    style: Theme.of(context).textTheme.titleLarge,
                  ),
                  const SizedBox(height: 8),
                  Text(
                    error.toString(),
                    style: Theme.of(context).textTheme.bodySmall,
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 24),
                  AppButton(
                    text: l10n.retry,
                    onPressed: () {
                      ref.invalidate(currentUserProvider);
                    },
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  void _showLanguageDialog(BuildContext context, WidgetRef ref) {
    final currentLocale = ref.read(languageProvider);
    
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(AppLocalizations.of(context).language),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            RadioListTile<Locale>(
              title: const Text('العربية'),
              value: const Locale('ar'),
              groupValue: currentLocale,
              onChanged: (Locale? value) {
                if (value != null) {
                  ref.read(languageProvider.notifier).setLanguage(value);
                  Navigator.of(context).pop();
                }
              },
            ),
            RadioListTile<Locale>(
              title: const Text('English'),
              value: const Locale('en'),
              groupValue: currentLocale,
              onChanged: (Locale? value) {
                if (value != null) {
                  ref.read(languageProvider.notifier).setLanguage(value);
                  Navigator.of(context).pop();
                }
              },
            ),
          ],
        ),
      ),
    );
  }
}
