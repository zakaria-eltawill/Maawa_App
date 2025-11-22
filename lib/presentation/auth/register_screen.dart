import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:maawa_project/core/theme/app_theme.dart';
import 'package:maawa_project/presentation/auth/auth_controller.dart';
import 'package:maawa_project/presentation/widgets/app_button.dart';
import 'package:maawa_project/presentation/widgets/app_text_field.dart';
import 'package:maawa_project/presentation/widgets/app_logo.dart';
import 'package:maawa_project/l10n/app_localizations.dart';

class RegisterScreen extends ConsumerStatefulWidget {
  const RegisterScreen({super.key});

  @override
  ConsumerState<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends ConsumerState<RegisterScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _phoneController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();
  String _selectedRole = 'tenant';
  String? _selectedCity;
  bool _agreeToTerms = false;

  // English city names (for backend API)
  final List<String> _cities = [
    'Benghazi',
    'Tripoli',
    'Misrata',
    'Zliten',
    'Al-Bayda',
    'Sirte',
    'Derna',
    'Tobruk',
  ];

  // Arabic city names mapping
  final Map<String, String> _cityNamesAr = {
    'Benghazi': 'بنغازي',
    'Tripoli': 'طرابلس',
    'Misrata': 'مصراتة',
    'Zliten': 'زليتن',
    'Al-Bayda': 'البيضاء',
    'Sirte': 'سرت',
    'Derna': 'درنة',
    'Tobruk': 'طبرق',
  };

  String _getCityDisplayName(String city, Locale locale) {
    if (locale.languageCode == 'ar') {
      return _cityNamesAr[city] ?? city;
    }
    return city;
  }

  @override
  void dispose() {
    _nameController.dispose();
    _phoneController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  Future<void> _handleRegister() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    if (!_agreeToTerms) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(AppLocalizations.of(context).pleaseAgreeToTerms),
          backgroundColor: AppTheme.dangerRed,
        ),
      );
      return;
    }

    final authController = ref.read(authControllerProvider.notifier);
    final success = await authController.register(
      name: _nameController.text.trim(),
      email: _emailController.text.trim(),
      password: _passwordController.text,
      passwordConfirmation: _confirmPasswordController.text,
      role: _selectedRole,
      phoneNumber: _phoneController.text.trim(),
      region: _selectedCity!,
    );

    if (success && mounted) {
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

  @override
  Widget build(BuildContext context) {
    final authState = ref.watch(authControllerProvider);
    final l10n = AppLocalizations.of(context);

    return Scaffold(
      backgroundColor: AppTheme.gray50,
      body: SafeArea(
        child: SingleChildScrollView(
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
              
              // Title section
              Padding(
                padding: const EdgeInsets.fromLTRB(24, 32, 24, 24),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      l10n.createAccount,
                      style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                            fontWeight: FontWeight.bold,
                            color: AppTheme.gray900,
                            fontSize: 28,
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
                        label: l10n.fullName,
                        controller: _nameController,
                        keyboardType: TextInputType.name,
                        prefixIcon: Icons.person_outlined,
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return l10n.nameRequired;
                          }
                          return null;
                        },
                      ),
                      const SizedBox(height: 16),
                      
                            AppTextField(
                              label: l10n.phone,
                              controller: _phoneController,
                              keyboardType: TextInputType.phone,
                              prefixIcon: Icons.phone_outlined,
                              autoValidate: true,
                              validator: (value) {
                                if (value == null || value.isEmpty) {
                                  return l10n.phoneRequired;
                                }
                                // Libyan format: 09XXXXXXXX (10 digits starting with 09)
                                final phoneRegex = RegExp(r'^09\d{8}$');
                                if (!phoneRegex.hasMatch(value)) {
                                  return 'Phone must be 10 digits starting with 09 (e.g., 0912345678)';
                                }
                                return null;
                              },
                            ),
                      const SizedBox(height: 16),
                      
                      // City dropdown
                      Builder(
                        builder: (context) {
                          final locale = Localizations.localeOf(context);
                          return DropdownButtonFormField<String>(
                            value: _selectedCity,
                            decoration: InputDecoration(
                              labelText: l10n.city,
                              prefixIcon: const Icon(Icons.location_on_outlined),
                            ),
                            items: _cities.map((city) {
                              return DropdownMenuItem(
                                value: city,
                                child: Text(_getCityDisplayName(city, locale)),
                              );
                            }).toList(),
                            selectedItemBuilder: (context) {
                              return _cities.map((city) {
                                return Text(_getCityDisplayName(city, locale));
                              }).toList();
                            },
                            onChanged: (value) {
                              setState(() => _selectedCity = value);
                            },
                            validator: (value) {
                              if (value == null) {
                                return l10n.cityRequired;
                              }
                              return null;
                            },
                          );
                        },
                      ),
                      const SizedBox(height: 16),
                      
                      AppTextField(
                        label: l10n.email,
                        controller: _emailController,
                        keyboardType: TextInputType.emailAddress,
                        prefixIcon: Icons.email_outlined,
                        autoValidate: true,
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
                        autoValidate: true,
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
                      const SizedBox(height: 16),
                      
                      AppTextField(
                        label: l10n.confirmPassword,
                        controller: _confirmPasswordController,
                        obscureText: true,
                        prefixIcon: Icons.lock_outlined,
                        autoValidate: true,
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return l10n.passwordRequired;
                          }
                          if (value != _passwordController.text) {
                            return l10n.passwordsDoNotMatch;
                          }
                          return null;
                        },
                      ),
                      const SizedBox(height: 24),
                      
                      // Role selection dropdown
                      DropdownButtonFormField<String>(
                        value: _selectedRole,
                        decoration: InputDecoration(
                          labelText: 'الدور',
                          prefixIcon: const Icon(Icons.badge_outlined),
                        ),
                        items: [
                          DropdownMenuItem(
                            value: 'tenant',
                            child: Text(l10n.tenant),
                          ),
                          DropdownMenuItem(
                            value: 'owner',
                            child: Text(l10n.owner),
                          ),
                        ],
                        onChanged: (value) {
                          if (value != null) {
                            setState(() => _selectedRole = value);
                          }
                        },
                      ),
                      const SizedBox(height: 16),
                      
                      // Terms & conditions checkbox
                      Row(
                        children: [
                          Checkbox(
                            value: _agreeToTerms,
                            onChanged: (value) {
                              setState(() => _agreeToTerms = value ?? false);
                            },
                            activeColor: AppTheme.primaryBlue,
                          ),
                          Expanded(
                            child: GestureDetector(
                              onTap: () {
                                setState(() => _agreeToTerms = !_agreeToTerms);
                              },
                              child: Text.rich(
                                TextSpan(
                                  text: '${l10n.iAgreeToThe} ',
                                  style: const TextStyle(
                                    fontSize: 13,
                                    color: AppTheme.gray700,
                                  ),
                                  children: [
                                    TextSpan(
                                      text: l10n.termsAndConditions,
                                      style: const TextStyle(
                                        color: AppTheme.primaryBlue,
                                        fontWeight: FontWeight.w600,
                                      ),
                                    ),
                                    TextSpan(
                                      text: ' ${l10n.and} ',
                                    ),
                                    TextSpan(
                                      text: l10n.privacyPolicy,
                                      style: const TextStyle(
                                        color: AppTheme.primaryBlue,
                                        fontWeight: FontWeight.w600,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 24),
                      
                      AppButton(
                        text: l10n.register,
                        onPressed: _handleRegister,
                        isLoading: authState.isLoading,
                      ),
                      
                      const SizedBox(height: 24),
                      
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(
                            l10n.alreadyHaveAccount,
                            style: const TextStyle(
                              fontSize: 14,
                              color: AppTheme.gray600,
                            ),
                          ),
                          TextButton(
                            onPressed: () => context.go('/auth'),
                            child: Text(
                              l10n.login,
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
      ),
    );
  }
}
