import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'models/service.dart';
import 'screens/home/home_screen.dart';
import 'screens/splash_screen.dart';
import 'screens/onboarding_screen.dart';
import 'screens/auth/login_screen.dart';
import 'screens/auth/signup_screen.dart';
import 'screens/auth/forgot_password_screen.dart';
import 'screens/home/edit_profile_screen.dart';
import 'screens/home/service-form/service_onboarding_screen.dart';
import 'screens/home/service-form/service_documents_screen.dart';
import 'screens/home/service_progress_screen.dart';
import 'screens/home/service_details_screen.dart';
import 'screens/home/service_listing_screen.dart';
import 'screens/booking/booking_details_screen.dart';
import 'screens/pairing/pairing_screen.dart';
import 'screens/settings/settings_screen.dart';
import 'screens/settings/help_support_screen.dart';
import 'screens/settings/privacy_policy_screen.dart';
import 'screens/settings/terms_of_service_screen.dart';
import 'screens/bug_report_screen.dart';
import 'screens/phone_number_screen.dart';
import 'screens/change_password_screen.dart';
import 'constants/route_names.dart';
import 'widgets/transitions.dart';

final router = GoRouter(
  initialLocation: Routes.splash,
  debugLogDiagnostics: true, // Enable debug logging
  routes: [
    GoRoute(
      path: Routes.splash,
      pageBuilder: (context, state) =>
          const NoTransitionPage(child: SplashScreen()),
    ),

    GoRoute(
      path: Routes.onboarding,
      pageBuilder: (context, state) =>
          FadeTransitionPage(child: OnboardingScreen()),
    ),
    GoRoute(
      path: Routes.login,
      pageBuilder: (context, state) => FadeTransitionPage(child: LoginScreen()),
    ),
    GoRoute(
      path: Routes.signup,
      pageBuilder: (context, state) =>
          FadeTransitionPage(child: SignupScreen()),
    ),
    GoRoute(
      path: Routes.forgotPassword,
      pageBuilder: (context, state) =>
          FadeTransitionPage(child: ForgotPasswordScreen()),
    ),
    GoRoute(
      path: Routes.home,
      pageBuilder: (context, state) => NoTransitionPage(child: HomeScreen()),
    ),
    GoRoute(
      path: Routes.editProfile,
      pageBuilder: (context, state) =>
          SlideTransitionPage(child: EditProfileScreen()),
    ),
    GoRoute(
      path: Routes.onboardingService,
      pageBuilder: (context, state) =>
          SlideTransitionPage(child: const ServiceOnboardingScreen()),
    ),
    GoRoute(
      path: Routes.serviceDocuments,
      pageBuilder: (context, state) {
        // final serviceType = state.uri.queryParameters['serviceType'] ?? '';
        final serviceId = state.uri.queryParameters['serviceId'] ?? '';
        return SlideTransitionPage(
          child: ServiceDocumentsScreen(serviceId: serviceId),
        );
      },
    ),
    GoRoute(
      path: Routes.serviceProgress,
      pageBuilder: (context, state) =>
          SlideTransitionPage(child: const ServiceProgressScreen( )),
    ),
    GoRoute(
      path: Routes.serviceDetails,
      pageBuilder: (context, state) {
        final service = state.extra as Service;
        return SlideTransitionPage(
          child: ServiceDetailsScreen(service: service),
        );
      },
    ),
    GoRoute(
      path: Routes.serviceListing,
      pageBuilder: (context, state) =>
          SlideTransitionPage(child: const ServiceListingScreen()),
    ),
    GoRoute(
      path: '/booking/:id',
      pageBuilder: (context, state) {
        final bookingId = state.pathParameters['id']!;
        return SlideTransitionPage(
          child: BookingDetailsScreen(bookingId: bookingId),
        );
      },
    ),
    GoRoute(
      path: '/pairing',
      pageBuilder: (context, state) =>
          SlideTransitionPage(child: const PairingScreen()),
    ),

    // Settings Routes
    GoRoute(
      path: Routes.settings,
      pageBuilder: (context, state) =>
          FadeTransitionPage(child: const SettingsScreen()),
    ),
    GoRoute(
      path: Routes.helpSupport,
      pageBuilder: (context, state) =>
          FadeTransitionPage(child: const HelpSupportScreen()),
    ),
    GoRoute(
      path: Routes.privacyPolicy,
      pageBuilder: (context, state) =>
          FadeTransitionPage(child: const PrivacyPolicyScreen()),
    ),
    GoRoute(
      path: Routes.termsOfService,
      pageBuilder: (context, state) =>
          FadeTransitionPage(child: const TermsOfServiceScreen()),
    ),
    GoRoute(
      path: '/bug-report',
      pageBuilder: (context, state) =>
          FadeTransitionPage(child: const BugReportScreen()),
    ),
    GoRoute(
      path: '/phone-number',
      pageBuilder: (context, state) =>
          FadeTransitionPage(child: const PhoneNumberScreen()),
    ),
    GoRoute(
      path: '/change-password',
      pageBuilder: (context, state) =>
          FadeTransitionPage(child: const ChangePasswordScreen()),
    ),
  ],
  errorBuilder: (context, state) => Scaffold(
    body: Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(Icons.error_outline, size: 64, color: Colors.red),
          const SizedBox(height: 16),
          Text(
            'Page not found: ${state.uri}',
            style: const TextStyle(fontSize: 18),
          ),
          const SizedBox(height: 16),
          ElevatedButton(
            onPressed: () => context.go(Routes.splash),
            child: const Text('Go to Home'),
          ),
        ],
      ),
    ),
  ),
);

// Custom page with slide transition animation (forward only)
class SlideTransitionPage extends CustomTransitionPage<void> {
  SlideTransitionPage({super.key, required super.child})
    : super(
        transitionsBuilder: (context, animation, secondaryAnimation, child) {
          return slideTransition(context, animation, secondaryAnimation, child);
        },
        transitionDuration: const Duration(milliseconds: 250),
        reverseTransitionDuration: const Duration(milliseconds: 200),
      );
}

// Custom page with fade transition animation
class FadeTransitionPage extends CustomTransitionPage<void> {
  FadeTransitionPage({super.key, required super.child})
    : super(
        transitionsBuilder: (context, animation, secondaryAnimation, child) {
          return fadeTransition(context, animation, secondaryAnimation, child);
        },
        transitionDuration: const Duration(milliseconds: 200),
        reverseTransitionDuration: const Duration(milliseconds: 150),
      );
}

// Custom page with scale transition animation
class ScaleTransitionPage extends CustomTransitionPage<void> {
  ScaleTransitionPage({super.key, required super.child})
    : super(
        transitionsBuilder: (context, animation, secondaryAnimation, child) {
          return scaleTransition(context, animation, secondaryAnimation, child);
        },
        transitionDuration: const Duration(milliseconds: 300),
        reverseTransitionDuration: const Duration(milliseconds: 250),
      );
}
