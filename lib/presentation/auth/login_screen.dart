import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:maawa_project/core/di/providers.dart';
import 'package:maawa_project/core/theme/app_theme.dart';
import 'package:maawa_project/presentation/auth/auth_controller.dart';
import 'package:maawa_project/presentation/widgets/app_button.dart';
import 'package:maawa_project/presentation/widgets/app_text_field.dart';
import 'package:maawa_project/presentation/widgets/app_logo.dart';
import 'package:maawa_project/l10n/app_localizations.dart';
import 'package:maawa_project/core/providers/language_provider.dart';

class LoginScreen extends ConsumerStatefulWidget {
  const LoginScreen({super.key});

  @override
  ConsumerState<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends ConsumerState<LoginScreen> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _rememberMe = false;

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  Future<void> _handleLogin() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    final authController = ref.read(authControllerProvider.notifier);
    final success = await authController.login(
      _emailController.text.trim(),
      _passwordController.text,
    );

    if (success && mounted) {
      // Update FCM token after successful login
      await authController.updateFcm();
      ref.invalidate(currentUserProvider);
      context.go('/home');
    } else if (mounted) {
      final error = ref.read(authControllerProvider).error;
      if (error != null) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(error),
            backgroundColor: AppTheme.dangerRed,
          ),
        );
      }
    }
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

  @override
  Widget build(BuildContext context) {
    final authState = ref.watch(authControllerProvider);
    final l10n = AppLocalizations.of(context);

    return Scaffold(
      backgroundColor: AppTheme.gray50,
      body: SafeArea(
        child: Stack(
          children: [
            SingleChildScrollView(
              child: Column(
                children: [
                  // Professional header with logo
                  Padding(
                padding: const EdgeInsets.fromLTRB(24, 40, 24, 32),
                child: Column(
                  children: [
                    // Logo
                    const AppLogo.header(),
                    const SizedBox(height: 24),
                    // App name
                    Text(
                      l10n.appName,
                      style: Theme.of(context).textTheme.headlineLarge?.copyWith(
                            fontWeight: FontWeight.bold,
                            color: AppTheme.gray900,
                            letterSpacing: -0.5,
                          ),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 8),
                    // Tagline
                    Text(
                      l10n.welcomeMessage,
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                            color: AppTheme.gray600,
                            fontSize: 14,
                          ),
                      textAlign: TextAlign.center,
                    ),
                  ],
                ),
              ),
              
              // Welcome text section
              Padding(
                padding: const EdgeInsets.fromLTRB(24, 32, 24, 24),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      l10n.welcomeBack,
                      style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                            fontWeight: FontWeight.bold,
                            color: AppTheme.gray900,
                            fontSize: 28,
                          ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      l10n.signInToContinue,
                      style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                            color: AppTheme.gray600,
                            fontSize: 15,
                          ),
                    ),
                  ],
                ),
              ),
              
              // Form with card design
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 24),
                child: Container(
                  padding: const EdgeInsets.all(24),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(20),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withValues(alpha: 0.05),
                        blurRadius: 10,
                        offset: const Offset(0, 4),
                      ),
                    ],
                  ),
                  child: Form(
                  key: _formKey,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      AppTextField(
                        label: l10n.email,
                        controller: _emailController,
                        keyboardType: TextInputType.emailAddress,
                        prefixIcon: Icons.email_outlined,
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return l10n.emailRequired;
                          }
                          if (!value.contains('@')) {
                            return l10n.emailInvalid;
                          }
                          return null;
                        },
                      ),
                      const SizedBox(height: 16),
                      AppTextField(
                        label: l10n.password,
                        controller: _passwordController,
                        obscureText: true,
                        prefixIcon: Icons.lock_outlined,
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return l10n.passwordRequired;
                          }
                          if (value.length < 8) {
                            return l10n.passwordTooShort;
                          }
                          return null;
                        },
                      ),
                      
                      // Remember me & Forgot password
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Flexible(
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Checkbox(
                                  value: _rememberMe,
                                  onChanged: (value) {
                                    setState(() => _rememberMe = value ?? false);
                                  },
                                  activeColor: AppTheme.primaryBlue,
                                ),
                                Flexible(
                                  child: Text(
                                    l10n.rememberMe,
                                    style: const TextStyle(
                                      fontSize: 14,
                                      color: AppTheme.gray700,
                                    ),
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          Flexible(
                            child: TextButton(
                              onPressed: () {
                                // TODO: Implement forgot password
                                ScaffoldMessenger.of(context).showSnackBar(
                                  SnackBar(
                                    content: Text(l10n.forgotPassword),
                                    backgroundColor: AppTheme.infoBlue,
                                  ),
                                );
                              },
                              child: Text(
                                l10n.forgotPassword,
                                style: const TextStyle(
                                  fontSize: 14,
                                  color: AppTheme.primaryBlue,
                                  fontWeight: FontWeight.w600,
                                ),
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                          ),
                        ],
                      ),
                      
                      const SizedBox(height: 8),
                      
                      AppButton(
                        text: l10n.login,
                        onPressed: _handleLogin,
                        isLoading: authState.isLoading,
                      ),
                      
                      const SizedBox(height: 24),
                      
                      Wrap(
                        alignment: WrapAlignment.center,
                        crossAxisAlignment: WrapCrossAlignment.center,
                        children: [
                          Text(
                            l10n.dontHaveAccount,
                            style: const TextStyle(
                              fontSize: 14,
                              color: AppTheme.gray600,
                            ),
                          ),
                          TextButton(
                            onPressed: () => context.go('/register'),
                            style: TextButton.styleFrom(
                              padding: EdgeInsets.zero,
                              minimumSize: Size.zero,
                              tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                            ),
                            child: Text(
                              l10n.createNewAccount,
                              style: const TextStyle(
                                fontSize: 14,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ),
                        ],
                      ),
                      
                      const SizedBox(height: 24),
                    ],
                  ),
                ),
                ),
              ),
              
                  const SizedBox(height: 24),
                ],
              ),
            ),
            // Language switcher button in top corner (right for LTR, left for RTL)
            Consumer(
              builder: (context, ref, _) {
                final locale = ref.watch(languageProvider);
                final isRTL = locale.languageCode == 'ar';
                return Positioned(
                  top: 16,
                  right: isRTL ? null : 16,
                  left: isRTL ? 16 : null,
                  child: Material(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(12),
                    elevation: 2,
                    child: InkWell(
                      onTap: () => _showLanguageDialog(context, ref),
                      borderRadius: BorderRadius.circular(12),
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 12,
                          vertical: 8,
                        ),
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(
                            color: AppTheme.gray300,
                            width: 1,
                          ),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(
                              Icons.language,
                              size: 20,
                              color: AppTheme.primaryBlue,
                            ),
                            const SizedBox(width: 6),
                            Text(
                              locale.languageCode == 'ar' ? 'العربية' : 'English',
                              style: const TextStyle(
                                fontSize: 14,
                                fontWeight: FontWeight.w600,
                                color: AppTheme.gray900,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}
