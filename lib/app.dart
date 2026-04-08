import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'plugins/providers/app_provider.dart';
import 'plugins/theme/colors.dart';
import 'plugins/theme/styles.dart';
import 'plugins/utils/background_service.dart';
import 'router.dart';

class MyApp extends ConsumerStatefulWidget {
  const MyApp({super.key});

  @override
  ConsumerState<MyApp> createState() => _MyAppState();
}

class _MyAppState extends ConsumerState<MyApp> with WidgetsBindingObserver {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    super.didChangeAppLifecycleState(state);

    // Handle app lifecycle changes
    backgroundService.handleAppLifecycleChange(state);

    // Start/stop background service based on app state
    if (state == AppLifecycleState.paused) {
      backgroundService.startService();
    } else if (state == AppLifecycleState.resumed) {
      backgroundService.stopService();
    }
  }

  @override
  Widget build(BuildContext context) {
    final themeMode = ref.watch(themeModeProvider);
    final colors = AppColors.fromBrightness(
      themeMode == ThemeMode.system
          ? WidgetsBinding.instance.platformDispatcher.platformBrightness
          : (themeMode == ThemeMode.light ? Brightness.light : Brightness.dark),
    );

    // Listen to authentication state changes to automatically refresh data
    ref.watch(authStateListenerProvider);

    return MaterialApp.router(
      title: 'RideRescue Services',
      theme: appThemeData(colors, Brightness.light),
      darkTheme: appThemeData(colors, Brightness.dark),
      themeMode: themeMode,
      routerConfig: router,
      debugShowCheckedModeBanner: false,
    );
  }
}
