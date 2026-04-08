import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:riderescue_services/plugins/utils/background_service.dart';

void main() {
  group('BackgroundService Tests', () {
    late BackgroundService backgroundService;

    setUp(() {
      backgroundService = BackgroundService();
    });

    tearDown(() async {
      // Clear SharedPreferences after each test
      final prefs = await SharedPreferences.getInstance();
      await prefs.remove('background_service_was_live');
      await prefs.remove('background_service_retry_count');
      await prefs.remove('background_service_last_retry');
      await prefs.remove('background_service_retry_start');
    });

    test('should initialize background service', () async {
      await backgroundService.initialize();
      // Test passes if no exception is thrown
      expect(true, isTrue);
    });

    test('should save and load was live state', () async {
      await backgroundService.initialize();
      
      // Test saving was live state
      await backgroundService.userWentLive();
      
      // Verify the state was saved
      final prefs = await SharedPreferences.getInstance();
      final wasLive = prefs.getBool('background_service_was_live');
      expect(wasLive, isTrue);
    });

    test('should handle retry count persistence', () async {
      await backgroundService.initialize();
      
      // Simulate retry attempts
      await backgroundService.userWentLive();
      
      // Get retry status
      final status = await backgroundService.getRetryStatus();
      expect(status['wasLive'], isTrue);
      expect(status['retryCount'], isA<int>());
      expect(status['maxRetries'], equals(6));
    });

    test('should respect retry time limit', () async {
      await backgroundService.initialize();
      
      // Set retry start time to 31 minutes ago (exceeds 30-minute limit)
      final prefs = await SharedPreferences.getInstance();
      final thirtyOneMinutesAgo = DateTime.now().subtract(const Duration(minutes: 31));
      await prefs.setInt('background_service_retry_start', thirtyOneMinutesAgo.millisecondsSinceEpoch);
      await prefs.setBool('background_service_was_live', true);
      await prefs.setInt('background_service_retry_count', 3);
      
      // Check retry status
      final status = await backgroundService.getRetryStatus();
      expect(status['timeExceeded'], isTrue);
    });

    test('should clear retry state when user goes live', () async {
      await backgroundService.initialize();
      
      // Set up some retry state
      final prefs = await SharedPreferences.getInstance();
      await prefs.setBool('background_service_was_live', true);
      await prefs.setInt('background_service_retry_count', 3);
      
      // User goes live
      await backgroundService.userWentLive();
      
      // Verify retry state is cleared
      final wasLive = prefs.getBool('background_service_was_live');
      final retryCount = prefs.getInt('background_service_retry_count');
      
      expect(wasLive, isNull);
      expect(retryCount, isNull);
    });

    test('should handle max retries limit', () async {
      await backgroundService.initialize();
      
      // Set retry count to max
      final prefs = await SharedPreferences.getInstance();
      await prefs.setBool('background_service_was_live', true);
      await prefs.setInt('background_service_retry_count', 6);
      
      // Check retry status
      final status = await backgroundService.getRetryStatus();
      expect(status['retryCount'], equals(6));
      expect(status['maxRetries'], equals(6));
    });

    test('should provide correct retry status information', () async {
      await backgroundService.initialize();
      
      final status = await backgroundService.getRetryStatus();
      
      expect(status, isA<Map<String, dynamic>>());
      expect(status.containsKey('wasLive'), isTrue);
      expect(status.containsKey('retryCount'), isTrue);
      expect(status.containsKey('maxRetries'), isTrue);
      expect(status.containsKey('timeExceeded'), isTrue);
      expect(status.containsKey('isRetrying'), isTrue);
      expect(status.containsKey('isConnected'), isTrue);
    });
  });
} 