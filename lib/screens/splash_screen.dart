import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:riderescue_services/constants/route_names.dart';
import 'package:riderescue_services/plugins/providers/app_provider.dart';

class SplashScreen extends ConsumerStatefulWidget {
  const SplashScreen({super.key});

  @override
  ConsumerState<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends ConsumerState<SplashScreen> {
  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _setSystemUI();
  }

  @override
  void didUpdateWidget(covariant SplashScreen oldWidget) {
    super.didUpdateWidget(oldWidget);
    _setSystemUI();
  }

  void _setSystemUI() {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    SystemChrome.setSystemUIOverlayStyle(
      SystemUiOverlayStyle(
        statusBarColor: theme.colorScheme.surface,
        statusBarIconBrightness: isDark ? Brightness.light : Brightness.dark,
        statusBarBrightness: isDark ? Brightness.dark : Brightness.light,
        systemNavigationBarColor: theme.colorScheme.surface,
        systemNavigationBarIconBrightness: isDark
            ? Brightness.dark
            : Brightness.light,
        systemNavigationBarDividerColor: Colors.transparent,
        systemStatusBarContrastEnforced: false,
        systemNavigationBarContrastEnforced: false,
      ),
    );
  }

  @override
  void initState() {
    super.initState();
    _initializeApp();
  }

  Future<void> _initializeApp() async {
    // Wait for a short delay
    await Future.delayed(const Duration(seconds: 2));

    if (!mounted) return;

    final appState = ref.read(appNotifierProvider);

    if (appState.isAuthenticated) {
      if (context.mounted) {
        context.go(Routes.home);
      }
    } else {
      if (context.mounted) {
        context.go(Routes.onboarding);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Container(
      color: theme.colorScheme.surface,
      child: Column(
        children: [
          // Main content - centered
          Expanded(
            child: Center(
              child: ShaderMask(
                shaderCallback: (bounds) => LinearGradient(
                  colors: [
                    theme.colorScheme.primary,
                    theme.colorScheme.primary.withOpacity(0.7),
                  ],
                  begin: Alignment.centerLeft,
                  end: Alignment.centerRight,
                ).createShader(bounds),
                child: Text(
                  'RideRescue',
                  style: TextStyle(
                    fontSize: 36,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                    letterSpacing: 1.5,
                    decoration: TextDecoration.none,
                  ),
                ),
              ),
            ),
          ),
          // Footer with bouncing dots and text
          Padding(
            padding: const EdgeInsets.only(bottom: 40),
            child: Column(
              children: [
                // Bouncing dots
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: List.generate(3, (index) {
                    return TweenAnimationBuilder<double>(
                      tween: Tween(begin: 0.0, end: 1.0),
                      duration: Duration(milliseconds: 600 + (index * 200)),
                      builder: (context, value, child) {
                        return Container(
                          margin: const EdgeInsets.symmetric(horizontal: 4),
                          child: Transform.translate(
                            offset: Offset(0, -8 * value),
                            child: Container(
                              width: 8,
                              height: 8,
                              decoration: BoxDecoration(
                                color: theme.colorScheme.primary,
                                shape: BoxShape.circle,
                              ),
                            ),
                          ),
                        );
                      },
                      onEnd: () {
                        // Restart animation when it ends
                        if (mounted) {
                          setState(() {});
                        }
                      },
                    );
                  }),
                ),
                const SizedBox(height: 16),
                // Footer text
                Text(
                  'Powered by RideRescue Autolink',
                  style: TextStyle(
                    color: theme.colorScheme.onSurface.withOpacity(0.6),
                    fontSize: 9,
                    decoration: TextDecoration.none,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
