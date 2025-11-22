import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:maawa_project/core/storage/secure_storage.dart';
import 'package:maawa_project/core/di/providers.dart';
import 'package:maawa_project/presentation/auth/login_screen.dart';
import 'package:maawa_project/presentation/auth/register_screen.dart';
import 'package:maawa_project/presentation/booking/booking_create_screen.dart';
import 'package:maawa_project/presentation/booking/booking_detail_screen.dart';
import 'package:maawa_project/presentation/booking/booking_payment_screen.dart';
import 'package:maawa_project/presentation/discover/property_detail_screen.dart';
import 'package:maawa_project/presentation/home/home_shell.dart';
import 'package:maawa_project/presentation/owner/proposal_form_add_screen.dart';
import 'package:maawa_project/presentation/owner/proposal_form_edit_screen.dart';
import 'package:maawa_project/presentation/owner/proposal_detail_screen.dart';
import 'package:maawa_project/presentation/owner/property_edit_screen.dart';
import 'package:maawa_project/presentation/profile/profile_screen.dart';
import 'package:maawa_project/presentation/profile/edit_profile_screen.dart';
import 'package:maawa_project/presentation/notifications/notifications_screen.dart';
import 'package:maawa_project/presentation/settings/help_support_screen.dart';
import 'package:maawa_project/presentation/settings/security_privacy_screen.dart';
import 'package:maawa_project/presentation/review/review_create_screen.dart';
import 'package:maawa_project/presentation/onboarding/onboarding_screen.dart';
import 'package:maawa_project/presentation/widgets/app_logo.dart';
import 'package:maawa_project/core/theme/app_theme.dart';

class AppRouter {
  final SecureStorage _secureStorage;

  AppRouter(this._secureStorage);

  GoRouter get router => _router;

  late final _router = GoRouter(
    initialLocation: '/splash',
    redirect: _redirect,
    routes: [
      GoRoute(
        path: '/splash',
        builder: (context, state) => const SplashScreen(),
      ),
      GoRoute(
        path: '/onboarding',
        builder: (context, state) => const OnboardingScreen(),
      ),
      GoRoute(
        path: '/auth',
        builder: (context, state) => const LoginScreen(),
      ),
      GoRoute(
        path: '/register',
        builder: (context, state) => const RegisterScreen(),
      ),
      GoRoute(
        path: '/home',
        builder: (context, state) => const HomeShell(),
        routes: [
          GoRoute(
            path: 'property/:id',
            builder: (context, state) {
              final id = state.pathParameters['id']!;
              return PropertyDetailScreen(propertyId: id);
            },
          ),
          GoRoute(
            path: 'booking/create/:propertyId',
            builder: (context, state) {
              final propertyId = state.pathParameters['propertyId']!;
              return BookingCreateScreen(propertyId: propertyId);
            },
          ),
          GoRoute(
            path: 'booking/:id',
            builder: (context, state) {
              final id = state.pathParameters['id']!;
              return BookingDetailScreen(bookingId: id);
            },
          ),
          GoRoute(
            path: 'booking/:id/payment',
            builder: (context, state) {
              final id = state.pathParameters['id']!;
              return BookingPaymentScreen(bookingId: id);
            },
          ),
          GoRoute(
            path: 'proposal/new',
            builder: (context, state) => const ProposalFormAddScreen(),
          ),
          GoRoute(
            path: 'proposal/detail/:id',
            builder: (context, state) {
              final id = state.pathParameters['id']!;
              return ProposalDetailScreen(proposalId: id);
            },
          ),
          GoRoute(
            path: 'proposal/edit/:id',
            builder: (context, state) {
              final id = state.pathParameters['id']!;
              return ProposalFormEditScreen(proposalId: id);
            },
          ),
          GoRoute(
            path: 'owner/property/edit/:id',
            builder: (context, state) {
              final id = state.pathParameters['id']!;
              return PropertyEditScreen(propertyId: id);
            },
          ),
          GoRoute(
            path: 'review/:propertyId',
            builder: (context, state) {
              final propertyId = state.pathParameters['propertyId']!;
              return ReviewCreateScreen(propertyId: propertyId);
            },
          ),
          GoRoute(
            path: 'profile',
            builder: (context, state) => const ProfileScreen(),
          ),
          GoRoute(
            path: 'profile/edit',
            builder: (context, state) => const EditProfileScreen(),
          ),
          GoRoute(
            path: 'notifications',
            builder: (context, state) => const NotificationsScreen(),
          ),
          GoRoute(
            path: 'help-support',
            builder: (context, state) => const HelpSupportScreen(),
          ),
          GoRoute(
            path: 'security-privacy',
            builder: (context, state) => const SecurityPrivacyScreen(),
          ),
        ],
      ),
    ],
  );

  Future<String?> _redirect(BuildContext context, GoRouterState state) async {
    final currentLocation = state.matchedLocation;
    
    // Don't redirect from splash or onboarding - let them handle navigation
    if (currentLocation == '/splash' || currentLocation == '/onboarding') {
      return null;
    }
    
    // Check if onboarding completed
    final prefs = await SharedPreferences.getInstance();
    final onboardingCompleted = prefs.getBool('onboarding_completed') ?? false;
    
    // If onboarding not completed and not on onboarding screen, redirect to onboarding
    if (!onboardingCompleted && currentLocation != '/onboarding') {
      return '/onboarding';
    }
    
    final isLoggedIn = await _secureStorage.getAccessToken() != null;
    final isAuthRoute = currentLocation == '/auth' || currentLocation == '/register';

    if (!isLoggedIn && !isAuthRoute) {
      return '/auth';
    }

    if (isLoggedIn && isAuthRoute) {
      return '/home';
    }

    return null;
  }
}

// Splash screen with logo
class SplashScreen extends ConsumerStatefulWidget {
  const SplashScreen({super.key});

  @override
  ConsumerState<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends ConsumerState<SplashScreen> {
  @override
  void initState() {
    super.initState();
    _navigateToNext();
  }

  Future<void> _navigateToNext() async {
    // Wait for 2 seconds to show splash screen
    await Future.delayed(const Duration(seconds: 2));
    
    if (!mounted) return;
    
    // Check if onboarding has been completed
    final prefs = await SharedPreferences.getInstance();
    final onboardingCompleted = prefs.getBool('onboarding_completed') ?? false;
    
    if (!mounted) return;
    
    // If onboarding not completed, go to onboarding
    if (!onboardingCompleted) {
      context.go('/onboarding');
      return;
    }
    
    final secureStorage = ref.read(secureStorageProvider);
    final isLoggedIn = await secureStorage.getAccessToken() != null;
    
    if (!mounted) return;
    
    if (isLoggedIn) {
      context.go('/home');
    } else {
      context.go('/auth');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // Logo
            const AppLogo.splash(),
            const SizedBox(height: 24),
            // Loading indicator
            const CircularProgressIndicator(
              valueColor: AlwaysStoppedAnimation<Color>(AppTheme.primaryBlue),
            ),
          ],
        ),
      ),
    );
  }
}

