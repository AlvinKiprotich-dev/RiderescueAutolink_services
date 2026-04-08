import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:riderescue_services/app.dart';
import 'package:riderescue_services/plugins/utils/onesignal_service.dart';
import 'package:riderescue_services/plugins/utils/background_service.dart';

/// Main entry point for the application
void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Initialize OneSignal
  await oneSignalService.initialize();

  // Initialize background service
  await backgroundService.initialize();

  runApp(const ProviderScope(child: MyApp()));
}
