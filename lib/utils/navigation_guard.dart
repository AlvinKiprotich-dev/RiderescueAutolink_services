import 'package:go_router/go_router.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../plugins/providers/app_provider.dart';
import '../constants/route_names.dart';

String? navigationGuard({
  required GoRouterState state,
  required AppState appState,
  required SharedPreferences prefs,
}) {
  final isAuthenticated = appState.isAuthenticated;
  final isOnboarded = prefs.getBool('is_onboarded') ?? false;
  final isSplashDone = prefs.getBool('is_splash_done') ?? false;

  final loggingIn =
      state.matchedLocation == Routes.login ||
      state.matchedLocation == Routes.signup;
  final onboarding = state.matchedLocation == Routes.onboarding;
  final splash = state.matchedLocation == Routes.splash;
  final home = state.matchedLocation == Routes.home;

  if (!isSplashDone && !splash) {
    return Routes.splash;
  }
  if (!isOnboarded && !onboarding && !splash) {
    return Routes.onboarding;
  }
  if (!isAuthenticated && (home || (!loggingIn && !onboarding && !splash))) {
    // If trying to go to home or any protected route, redirect to login or onboarding
    return isOnboarded ? Routes.login : Routes.onboarding;
  }
  if (isAuthenticated && (loggingIn || onboarding || splash)) {
    return Routes.home;
  }
  return null;
}
