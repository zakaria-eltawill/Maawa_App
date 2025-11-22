import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:maawa_project/core/theme/app_theme.dart';
import 'package:maawa_project/presentation/widgets/app_logo.dart';
import 'package:maawa_project/presentation/widgets/app_button.dart';
import 'package:maawa_project/l10n/app_localizations.dart';
import 'package:maawa_project/core/providers/language_provider.dart';
import 'package:maawa_project/core/di/providers.dart';

class OnboardingScreen extends ConsumerStatefulWidget {
  const OnboardingScreen({super.key});

  @override
  ConsumerState<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends ConsumerState<OnboardingScreen> {
  final PageController _pageController = PageController();
  int _currentPage = 0;

  @override
  void initState() {
    super.initState();
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  void _onPageChanged(int index) {
    setState(() {
      _currentPage = index;
    });
  }

  void _nextPage() {
    const totalPages = 3; // Number of onboarding pages
    if (_currentPage < totalPages - 1) {
      _pageController.nextPage(
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
      );
    } else {
      _completeOnboarding();
    }
  }

  void _skipOnboarding() {
    _completeOnboarding();
  }

  Future<void> _completeOnboarding() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('onboarding_completed', true);
    
    if (!mounted) return;
    
    final secureStorage = ref.read(secureStorageProvider);
    final isLoggedIn = await secureStorage.getAccessToken() != null;
    
    if (!mounted) return;
    
    if (isLoggedIn) {
      context.go('/home');
    } else {
      context.go('/auth');
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
    final l10n = AppLocalizations.of(context);
    final locale = Localizations.localeOf(context);
    final isRTL = locale.languageCode == 'ar';

    // Initialize pages based on current locale
    final pages = [
      OnboardingPage(
        icon: Icons.search_rounded,
        title: l10n.onboardingPage1Title,
        description: l10n.onboardingPage1Description,
      ),
      OnboardingPage(
        icon: Icons.calendar_today_rounded,
        title: l10n.onboardingPage2Title,
        description: l10n.onboardingPage2Description,
      ),
      OnboardingPage(
        icon: Icons.bookmark_rounded,
        title: l10n.onboardingPage3Title,
        description: l10n.onboardingPage3Description,
      ),
    ];

    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Stack(
          children: [
            // Language switcher button
            Positioned(
              top: 16,
              right: isRTL ? null : 16,
              left: isRTL ? 16 : null,
              child: Consumer(
                builder: (context, ref, _) {
                  final currentLocale = ref.watch(languageProvider);
                  return Material(
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
                              currentLocale.languageCode == 'ar' ? 'العربية' : 'English',
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
                  );
                },
              ),
            ),

            // Main content
            Column(
              children: [
                // Logo and welcome section
                Padding(
                  padding: const EdgeInsets.fromLTRB(24, 40, 24, 20),
                  child: Column(
                    children: [
                      const AppLogo.splash(),
                      const SizedBox(height: 16),
                      Text(
                        l10n.onboardingWelcome,
                        style: Theme.of(context).textTheme.headlineLarge?.copyWith(
                              fontWeight: FontWeight.bold,
                              color: AppTheme.gray900,
                              letterSpacing: -0.5,
                              fontSize: 22,
                            ),
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: 6),
                      Text(
                        l10n.onboardingWelcomeSubtitle,
                        style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                              color: AppTheme.gray600,
                              fontSize: 13,
                            ),
                        textAlign: TextAlign.center,
                      ),
                    ],
                  ),
                ),

                // Page view
                Expanded(
                  child: PageView.builder(
                    controller: _pageController,
                    onPageChanged: _onPageChanged,
                    itemCount: pages.length,
                    itemBuilder: (context, index) {
                      final page = pages[index];
                      return SingleChildScrollView(
                        child: Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 32),
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              const SizedBox(height: 20),
                              // Icon
                              Container(
                                width: 100,
                                height: 100,
                                decoration: BoxDecoration(
                                  color: AppTheme.primaryBlue.withValues(alpha: 0.1),
                                  shape: BoxShape.circle,
                                ),
                                child: Icon(
                                  page.icon,
                                  size: 50,
                                  color: AppTheme.primaryBlue,
                                ),
                              ),
                              const SizedBox(height: 32),
                              // Title
                              Text(
                                page.title,
                                style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                                      fontWeight: FontWeight.bold,
                                      color: AppTheme.gray900,
                                      fontSize: 22,
                                    ),
                                textAlign: TextAlign.center,
                              ),
                              const SizedBox(height: 12),
                              // Description
                              Text(
                                page.description,
                                style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                                      color: AppTheme.gray600,
                                      fontSize: 15,
                                      height: 1.4,
                                    ),
                                textAlign: TextAlign.center,
                              ),
                              const SizedBox(height: 20),
                            ],
                          ),
                        ),
                      );
                    },
                  ),
                ),

                // Page indicators
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: List.generate(
                    pages.length,
                    (index) => _buildPageIndicator(index == _currentPage),
                  ),
                ),

                const SizedBox(height: 16),

                // Action buttons
                Padding(
                  padding: const EdgeInsets.fromLTRB(24, 0, 24, 24),
                  child: Row(
                    children: [
                      if (_currentPage < pages.length - 1)
                        TextButton(
                          onPressed: _skipOnboarding,
                          child: Text(
                            l10n.onboardingSkip,
                            style: const TextStyle(
                              fontSize: 16,
                              color: AppTheme.gray600,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                      const Spacer(),
                      Expanded(
                        flex: 2,
                        child: AppButton(
                          text: _currentPage == pages.length - 1
                              ? l10n.onboardingGetStarted
                              : l10n.next,
                          onPressed: _nextPage,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPageIndicator(bool isActive) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 4),
      width: isActive ? 24 : 8,
      height: 8,
      decoration: BoxDecoration(
        color: isActive ? AppTheme.primaryBlue : AppTheme.gray300,
        borderRadius: BorderRadius.circular(4),
      ),
    );
  }
}

class OnboardingPage {
  final IconData icon;
  final String title;
  final String description;

  OnboardingPage({
    required this.icon,
    required this.title,
    required this.description,
  });
}

